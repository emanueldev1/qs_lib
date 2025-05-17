if cache.game == 'redm' then return end

---@class KeybindProps
---@field name string
---@field description string
---@field defaultMapper? string
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

-- Metatable for keybind objects
local bindMetatable = {
   disabled = false,
   isPressed = false,
   defaultKey = '',
   defaultMapper = 'keyboard',
}

function bindMetatable:__index(key)
   if key == 'currentKey' then
      return self:getCurrentKey()
   end
   return bindMetatable[key]
end

function bindMetatable:getCurrentKey()
   local button = GetControlInstructionalButton(0, self.hash, true)
   return button:sub(3)
end

function bindMetatable:isControlPressed()
   return self.isPressed
end

function bindMetatable:disable(state)
   self.disabled = state
end

-- Registrar comandos para presión y liberación con manejo explícito
local function registerBindCommand(commandName, keybind, isPress)
   RegisterCommand(commandName, function()
      if keybind.disabled or IsPauseMenuActive() then return end

      -- Solo ejecutar si el estado de presión cambia
      if isPress and not keybind.isPressed then
         keybind.isPressed = true
         if keybind.onPressed then
            keybind.onPressed(keybind)
         end
      elseif not isPress and keybind.isPressed then
         keybind.isPressed = false
         if keybind.onReleased then
            keybind.onReleased(keybind)
         end
      end
   end, false)
end

-- Configurar mapeo de teclas
local function setupKeyMappings(bindConfig)
   RegisterKeyMapping('+' .. bindConfig.name, bindConfig.description, bindConfig.defaultMapper, bindConfig.defaultKey)
   if bindConfig.secondaryKey then
      local mapper = bindConfig.secondaryMapper or bindConfig.defaultMapper
      RegisterKeyMapping('~!+' .. bindConfig.name, bindConfig.description, mapper, bindConfig.secondaryKey)
   end
end

-- Eliminar sugerencias del chat
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
   config.hash = joaat('+' .. config.name) | 0x80000000

   local keybind = setmetatable(config, bindMetatable)
   keybinds[config.name] = keybind

   -- Registrar comandos de presión y liberación
   registerBindCommand('+' .. config.name, keybind, true)
   registerBindCommand('-' .. config.name, keybind, false)

   -- Configurar mapeo de teclas
   setupKeyMappings(config)

   -- Limpiar sugerencias del chat
   removeChatSuggestions(config.name)

   return keybind
end

return lib.addKeybind
