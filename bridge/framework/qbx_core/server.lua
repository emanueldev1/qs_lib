--- Framework item management library
--- This module provides functions for checking and registering usable items within the framework.
--- Replace the placeholder logic with your own implementation to interface with your item system.
--- @module framework

local Framework = {}

--- Checks if an item can be used.
--- @param item string The name or identifier of the item to check.
--- @return boolean|nil True if the item can be used, false or nil if it cannot be used.
function Framework.canUseItem(item)
   -- Replace with your custom logic to check if an item is usable.
   -- Example: return YourItemSystem:CheckUsableItem(item)
   return exports.qbx_core:CanUseItem(item)
end

--- Registers a callback for a usable item.
--- @param item string The name or identifier of the item to register.
--- @param cb function The callback function to execute when the item is used.
--- @return boolean|nil True if the item was registered successfully, false or nil otherwise.
function Framework.registerUsableItem(item, cb)
   -- Replace with your custom logic to register a usable item.
   -- Example: return YourItemSystem:RegisterItemCallback(item, cb)
   return exports.qbx_core:CreateUseableItem(item, cb)
end

return Framework
