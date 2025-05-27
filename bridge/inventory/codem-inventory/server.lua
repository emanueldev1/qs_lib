-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

--- Inventory management library (codem-inventory)
--- This module provides functions for managing items in player inventories and stashes.
--- ADVICE: This bridge has not entire bridge support The inventory system has very few events and functions on server side.
--- @module inventory

local Inventory = {}

--- Retrieves the list of items available in the inventory system.
--- @return table A list of items.
function Inventory.getItemList()
   return exports['codem-inventory']:GetItemList()
end

--- Retrieves the list of weapons available in the inventory system.
--- @return table A list of weapons.
function Inventory.getWeaponList()
   lib.print.warn('codem-inventory does not support weapon list retrieval yet, returning raw item list.')
   return exports['codem-inventory']:GetItemList()
end

--- Retrieves the inventory of a specific player or stash.
--- @param id any The identifier of the inventory (player ID or stash ID).
--- @return table The inventory data.
function Inventory.get(id)
   local citizen_id = lib.player.identifier(id)
   return exports['codem-inventory']:GetInventory(citizen_id, id)
end

--- Adds an item to a player's inventory.
--- @param source number The player source.
--- @param itemName string The name of the item.
--- @param itemCount number The quantity of the item.
--- @param itemSlot number The slot where the item will be placed.
--- @param itemMetadata table Metadata associated with the item.
--- @return boolean Whether the item was successfully added.
function Inventory.addItem(source, itemName, itemCount, itemSlot, itemMetadata)
   return exports['codem-inventory']:AddItem(source, itemName, itemCount, itemSlot, itemMetadata)
end

--- Removes an item from a player's inventory.
--- @param source number The player source.
--- @param itemName string The name of the item.
--- @param itemCount number The quantity of the item.
--- @param itemSlot number The slot of the item to remove.
--- @param itemMetadata table Metadata associated with the item.
--- @return boolean Whether the item was successfully removed.
function Inventory.removeItem(source, itemName, itemCount, itemSlot, itemMetadata)
   return exports['codem-inventory']:RemoveItem(source, itemName, itemCount, itemSlot)
end

--- Checks if a player can carry a specific quantity of an item.
--- @param source number The player source.
--- @param itemName string The name of the item.
--- @param itemCount number The quantity of the item.
--- @return boolean Whether the player can carry the item.
function Inventory.canCarryItem(source, itemName, itemCount)
   lib.print.warn('codem-inventory does not support item carrying checks yet, returning true.')
   return true
end

--- Retrieves the total amount of a specific item in a player's inventory.
--- @param source number The player source.
--- @param itemName string The name of the item.
--- @return number The total amount of the item.
function Inventory.getItemTotalAmount(source, itemName)
   return exports['codem-inventory']:GetItemsTotalAmount(source, itemName)
end

--- Retrieves the label of a specific item.
--- @param itemName string The item name or identifier.
--- @return string The label of the item.
function Inventory.getItemLabel(itemName)
   return exports['codem-inventory']:GetItemLabel(itemName)
end

--- Checks if an inventory contains a specific item with optional conditions.
--- @param source number The player source.
--- @param item string The name of the item.
--- @param count number|nil The quantity to check (optional).
--- @param md table|nil Metadata to match (optional).
--- @param slot number|nil The slot to check (optional).
--- @return boolean|number Whether the item exists and its quantity if found.
function Inventory.hasItem(source, item, count, md, slot)
   return exports['codem-inventory']:HasItem(source, item, count)
end

--- Creates a usable item with a callback function.
--- @param itemName string The name of the usable item.
--- @param callback function The function to execute when the item is used.
function Inventory.createUsableItem(itemName, callback)
   lib.framework.registerUsableItem(itemName, function(source, item, metadata)
      callback(source, item, metadata)
   end)
end

--- Sets metadata for a specific item in a player's inventory.
--- @param source number The player source.
--- @param itemSlot number The slot of the item.
--- @param itemMetadata table The metadata to set.
function Inventory.setItemMetadata(source, itemSlot, itemMetadata)
   exports['codem-inventory']:SetItemMetadata(source, itemSlot, itemMetadata)
end

--- Registers a stash with specific properties.
--- @param source number|nil The player source (optional).
--- @param stashId string The identifier of the stash.
--- @param data table The stash properties (e.g., maxSlots, maxWeight).
--- @return boolean Whether the stash was successfully registered.
function Inventory.registerStash(source, stashId, data)
   if not source then return false end
   TriggerClientEvent(GetCurrentResourceName() .. ':bridge:codem-inventoy:openStash', source, stashId, data)
   return true
end

--- Adds an item to a stash.
--- @param stashId string The identifier of the stash.
--- @param itemName string The name of the item.
--- @param itemAmount number The quantity of the item.
--- @param itemSlot number The slot where the item will be placed.
--- @param itemMetadata table Metadata associated with the item.
--- @param stashSlots number The maximum slots of the stash.
--- @param stashMaxWeight number The maximum weight of the stash.
--- @return boolean Whether the item was successfully added.
function Inventory.addItemToStash(stashId, itemName, itemAmount, itemSlot, itemMetadata, stashSlots, stashMaxWeight)
   local stashItems = exports['codem-inventory']:GetStash(stashId) or {}
   local stashItem = {
      name = itemName,
      amount = itemAmount,
      slot = itemSlot,
      metadata = itemMetadata,
   }
   lib.table.insert(stashItems, stashItem)
   exports['codem-inventory']:UpdateStash(stashId, stashItems)
   return false
end

--- Removes an item from a stash.
--- @param stashId string The identifier of the stash.
--- @param itemName string The name of the item.
--- @param itemAmount number The quantity of the item.
--- @param itemSlot number The slot of the item to remove.
--- @param stashSlots number The maximum slots of the stash.
--- @param stashMaxWeight number The maximum weight of the stash.
--- @return boolean Whether the item was successfully removed.
function Inventory.removeItemFromStash(stashId, itemName, itemAmount, itemSlot, stashSlots, stashMaxWeight)
   lib.print.warn('codem-inventory does not support removing items from stash yet, returning false.')
   return false
end

--- Retrieves the items in a specific stash.
--- @param stashId string The identifier of the stash.
--- @return table The items in the stash.
function Inventory.getStashItems(stashId)
   return exports['codem-inventory']:GetStashItems(stashId)
end

--- Retrieves an item by its slot in a player's inventory.
--- @param source number The player source.
--- @param slot number The slot of the item.
--- @return table|boolean The item data or false if not found.
function Inventory.getItemBySlot(source, slot)
   return false
end

return Inventory
