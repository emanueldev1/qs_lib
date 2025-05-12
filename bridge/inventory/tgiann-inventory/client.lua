--- Inventory management library (tgiann-inventory)
--- This module provides a template for integrating custom inventory systems.
--- Replace the placeholder logic with your own implementation to interface with your inventory system.
--- @module inventory

local Inventory = {}

--- Retrieves the list of items from the inventory system.
--- @return table A table containing the list of all items.
function Inventory.getItemList()
   return exports["tgiann-inventory"]:GetItemList()
end

--- Retrieves the list of weapons from the inventory system.
--- @return table A table containing the list of all weapons.
function Inventory.getWeaponList()
   lib.print.debug("tgiann-inventory does not support GetWeaponList functions yet, returning the item list.")
   return exports["tgiann-inventory"]:GetItemList()
end

--- Checks if the inventory UI is currently open.
--- @return boolean True if the inventory is open, false otherwise.
function Inventory.isOpen()
   -- Replace with your custom logic to check inventory state.
   -- Example: return YourInventorySystem:IsInventoryOpen()
   return false
end

--- Enables or disables the inventory system.
--- @param state boolean True to disable the inventory, false to enable it.
--- @return boolean|nil True if the state was set successfully, false or nil otherwise.
function Inventory.setDisabled(state)
   exports["tgiann-inventory"]:SetInventoryActive(not state)
end

--- Retrieves the user's inventory data.
--- @return table A table containing the user's inventory items.
function Inventory.get()
   return exports["tgiann-inventory"]:GetPlayerItems()
end

--- Registers a stash with the inventory system.
--- @param stashId string The unique identifier for the stash.
--- @param data table|nil Optional table containing stash configuration (maxSlots, maxWeight).
--- @field data.maxSlots number The maximum number of slots in the stash (default: 20).
--- @field data.maxWeight number The maximum weight capacity of the stash (default: 100000).
--- @return boolean|nil True if the stash was registered successfully, false or nil otherwise.
function Inventory.registerStash(stashId, data)
   if not data then data = {} end
   if not data.maxSlots then data.maxSlots = 20 end
   if not data.maxWeight then data.maxWeight = 100000 end

   exports["tgiann-inventory"]:OpenInventory("stash", "stashId", { maxweight = data.maxWeight, slots = data.maxSlots })
end

--- Retrieves the currently equipped weapon.
--- @return table|nil A table containing the current weapon's details, or nil if no weapon is equipped.
function Inventory.getCurrentWeapon()
   return exports["tgiann-inventory"]:GetCurrentWeapon()
end

--- Searches for an item in the inventory by name.
--- @param itemName string The name of the item to search for.
--- @return table A table containing the search results (items found).
function Inventory.search(itemName)
   -- custom search logic on current inventory only return ONE item
   local itemList = Inventory.get()
   local searchResults = {}
   for _, item in ipairs(itemList) do
      if string.find(item.name:lower(), itemName:lower(), 1, true) then
         table.insert(searchResults, item)
      end
   end
   return searchResults
end

--- Checks if the inventory is blocked (e.g., during specific actions).
--- @return boolean True if the inventory is blocked, false otherwise.
function Inventory.isBlocked()
   return exports["tgiann-inventory"]:IsInventoryActive()
end

return Inventory
