-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

--- Inventory management library
--- This module provides functions to manage items in player inventories and stashes across different inventory systems.
--- Specifically designed for integration with the qs-inventory system.
--- @module inventory

local Inventory = {}

--- Retrieves the complete list of items available in the inventory system.
--- @return table A table containing the list of all items.
function Inventory.getItemList()
   return exports['qs-inventory']:GetItemList()
end

--- Retrieves the list of weapons available in the inventory system.
--- @return table A table containing the list of all weapons.
function Inventory.getWeaponList()
   return exports['qs-inventory']:GetWeaponList()
end

--- Checks if the inventory UI is currently open.
--- @return boolean True if the inventory is open, false otherwise.
function Inventory.isOpen()
   return exports['qs-inventory']:inInventory()
end

--- Enables or disables the inventory system.
--- @param state boolean True to disable the inventory, false to enable it.
--- @return boolean True if the state was set successfully, false otherwise.
function Inventory.setDisabled(state)
   return exports['qs-inventory']:setInventoryDisabled(state)
end

--- Retrieves the current user's inventory.
--- @return table A table containing the user's inventory items.
function Inventory.get()
   return exports['qs-inventory']:getUserInventory()
end

--- Registers a new stash with specified parameters.
--- @param stashId string The unique identifier for the stash.
--- @param data table Optional table containing stash configuration (maxSlots, maxWeight).
--- @field data.maxSlots number The maximum number of slots in the stash (default: 20).
--- @field data.maxWeight number The maximum weight capacity of the stash (default: 100000).
--- @return boolean True if the stash was registered successfully, false otherwise.
function Inventory.registerStash(stashId, data)
   if not data then data = {} end
   if not data.maxSlots then data.maxSlots = 20 end
   if not data.maxWeight then data.maxWeight = 100000 end
   return exports['qs-inventory']:RegisterStash(stashId, data.maxSlots, data.maxWeight)
end

--- Retrieves the currently equipped weapon from the inventory.
--- @return table|nil A table containing the current weapon's details, or nil if no weapon is equipped.
function Inventory.getCurrentWeapon()
   return exports['qs-inventory']:GetCurrentWeapon()
end

--- Searches the inventory for a specific item by name.
--- @param itemName string The name of the item to search for.
--- @return table A table containing the search results (items found).
function Inventory.search(itemName)
   return exports['qs-inventory']:Search(itemName)
end

--- Checks if the inventory is currently blocked (e.g., during specific actions).
--- @return boolean True if the inventory is blocked, false otherwise.
function Inventory.isBlocked()
   return exports['qs-inventory']:CheckIfInventoryBlocked()
end

return Inventory
