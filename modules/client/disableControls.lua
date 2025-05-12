-- This script provides a system for disabling input controls in FiveM. It allows developers to add, remove,
-- or clear control keys, maintaining a counter for multiple disable requests. When called per frame, it
-- disables all stored controls.

local disableControls = {}
local keys = {}

-- Cache native function for performance
local DisableControlAction = DisableControlAction

-- Processes a list of control keys from either a table or varargs
-- @param ... number|table Control keys to process
-- @return table List of control keys
local function processInputKeys(...)
   return type(...) == 'table' and ... or { ... }
end

-- Increments the counter for specified control keys
-- @param ... number|table Control keys to add
function disableControls:Add(...)
   local inputKeys = processInputKeys(...)
   for _, controlId in ipairs(inputKeys) do
      keys[controlId] = (keys[controlId] or 0) + 1
   end
end

-- Decrements the counter for specified control keys, removing them if the count reaches zero
-- @param ... number|table Control keys to remove
function disableControls:Remove(...)
   local inputKeys = processInputKeys(...)
   for _, controlId in ipairs(inputKeys) do
      local count = keys[controlId]
      if count then
         if count > 1 then
            keys[controlId] = count - 1
         else
            keys[controlId] = nil
         end
      end
   end
end

-- Removes specified control keys entirely, ignoring their counter
-- @param ... number|table Control keys to clear
function disableControls:Clear(...)
   local inputKeys = processInputKeys(...)
   for _, controlId in ipairs(inputKeys) do
      keys[controlId] = nil
   end
end

-- Disables all stored control keys when called
lib.disableControls = setmetatable(disableControls, {
   __index = keys,
   __newindex = keys,
   __call = function()
      for controlId, _ in pairs(keys) do
         DisableControlAction(0, controlId, true)
      end
   end
})

return lib.disableControls


-- //TODO: TEST it
