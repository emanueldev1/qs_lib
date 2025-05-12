-- This script provides a keybind management system for FiveM, allowing developers to register custom keybinds
-- with associated press and release events. It supports key mapping, disabling keybinds, and retrieving the current key.

if cache.game == 'redm' then return end

---@class KeybindProps
---@field name string
---@field description string
---@field defaultMapper? string (see: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/)
---@field defaultKey? string
---@field disabled? boolean
---@field disable? fun(self: CKeybind, toggle: boolean)
---@field onPressed? fun(self: CKeybind)
---@field onReleased? fun(self: CKeybind)
---@field [string] any

---@class CKeybind : KeybindProps
---@field currentKey string
---@field disabled boolean
---@field isPressed boolean
---@field hash number
---@field getCurrentKey fun(): string
---@field isControlPressed fun(): boolean

local keybinds = {}

-- Cache native functions for performance
local IsPauseMenuActive = IsPauseMenuActive
local GetControlInstructionalButton = GetControlInstructionalButton

-- Metatable for keybind objects, defining default behavior and methods
local bindMetatable = {
   disabled = false,
   isPressed = false,
   defaultKey = '',
   defaultMapper = 'keyboard',
}

-- Retrieves a property or method from the metatable or dynamically computes the current key
function bindMetatable:__index(key)
   if key == 'currentKey' then
      return self:getCurrentKey()
   end
   return bindMetatable[key]
end

-- Returns the currently assigned key for this keybind, extracted from the control instructional button
function bindMetatable:getCurrentKey()
   local button = GetControlInstructionalButton(0, self.hash, true)
   return button:sub(3)
end

-- Checks if the keybind is currently pressed
function bindMetatable:isControlPressed()
   return self.isPressed
end

-- Toggles the disabled state of the keybind
function bindMetatable:disable(state)
   self.disabled = state
end

-- Registers a command for a keybind (press or release) with the specified handler
local function registerBindCommand(commandName, keybind, isPress)
   RegisterCommand(commandName, function()
      if keybind.disabled or IsPauseMenuActive() then return end
      keybind.isPressed = isPress
      local callback = isPress and keybind.onPressed or keybind.onReleased
      if callback then callback(keybind) end
   end)
end

-- Sets up key mappings for a keybind, including primary and optional secondary keys
local function setupKeyMappings(bindConfig)
   RegisterKeyMapping('+' .. bindConfig.name, bindConfig.description, bindConfig.defaultMapper, bindConfig.defaultKey)
   if bindConfig.secondaryKey then
      local mapper = bindConfig.secondaryMapper or bindConfig.defaultMapper
      RegisterKeyMapping('~!+' .. bindConfig.name, bindConfig.description, mapper, bindConfig.secondaryKey)
   end
end

-- Removes command suggestions from the chat to keep it clean
local function removeChatSuggestions(bindName)
   SetTimeout(500, function()
      TriggerEvent('chat:removeSuggestion', '/+' .. bindName)
      TriggerEvent('chat:removeSuggestion', '/-' .. bindName)
   end)
end

---@param config KeybindProps
---@return CKeybind
function lib.addKeybind(config)
   ---@cast config CKeybind
   -- Generate a unique hash for the keybind based on its name
   config.hash = joaat('+' .. config.name) | 0x80000000

   -- Initialize the keybind with the metatable
   local keybind = setmetatable(config, bindMetatable)
   keybinds[config.name] = keybind

   -- Register press and release commands
   registerBindCommand('+' .. config.name, keybind, true)
   registerBindCommand('-' .. config.name, keybind, false)

   -- Configure key mappings for the keybind
   setupKeyMappings(config)

   -- Clean up chat suggestions
   removeChatSuggestions(config.name)

   return keybind
end

return lib.addKeybind
