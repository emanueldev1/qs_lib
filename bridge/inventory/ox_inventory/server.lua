-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

--- Inventory management library
--- This module provides functions to manage items in player inventories and stashes across different inventory systems.
--- Specifically designed for integration with the qs-inventory system.
--- @module inventory

local Inventory = {}

--- Retrieves the complete list of items available in the inventory system.
--- @return table A table containing the list of all items.
function Inventory.getItemList()
   return exports.ox_inventory:Items()
end

--- Retrieves the list of weapons available in the inventory system.
--- @return table A table containing the list of all weapons.
function Inventory.getWeaponList()
   -- The ox_inventory does not have a specific function for weapons, so we return the item list.
   lib.print.debug('ox_inventory does not support getWeaponList, returning getItemList instead')
   return exports.ox_inventory:Items()
end

--- Retrieves the inventory for a specific player or stash by ID.
--- @param id number|string The player ID or stash ID.
--- @return table A table containing the inventory items.
function Inventory.get(id)
   return exports.ox_inventory:GetInventory(id)
end

--- Adds an item to a player's inventory.
--- @param source number The player source ID.
--- @param itemName string The name of the item to add.
--- @param itemCount number The quantity of the item to add.
--- @param itemSlot number|nil The slot to place the item in (optional).
--- @param itemMetadata table|nil Metadata for the item (optional).
--- @return boolean True if the item was added successfully, false otherwise.
function Inventory.addItem(source, itemName, itemCount, itemSlot, itemMetadata)
   return exports.ox_inventory:AddItem(source, itemName, itemCount, itemMetadata, itemSlot)
end

--- Removes an item from a player's inventory.
--- @param source number The player source ID.
--- @param itemName string The name of the item to remove.
--- @param itemCount number The quantity of the item to remove.
--- @param itemSlot number|nil The slot to remove the item from (optional).
--- @param itemMetadata table|nil Metadata for the item (optional).
--- @return boolean True if the item was removed successfully, false otherwise.
function Inventory.removeItem(source, itemName, itemCount, itemSlot, itemMetadata)
   return exports.ox_inventory:RemoveItem(source, itemName, itemCount, itemMetadata, itemSlot)
end

--- Checks if a player can carry a specified item and quantity.
--- @param source number The player source ID.
--- @param itemName string The name of the item.
--- @param itemCount number The quantity of the item.
--- @return boolean True if the player can carry the item, false otherwise.
function Inventory.canCarryItem(source, itemName, itemCount)
   return exports.ox_inventory:CanCarryItem(source, itemName, itemCount)
end

--- Retrieves the total amount of a specific item in a player's inventory.
--- @param source number The player source ID.
--- @param itemName string The name of the item.
--- @return number The total amount of the item.
function Inventory.getItemTotalAmmount(source, itemName)
   return exports.ox_inventory:GetItemCount(source, itemName)
end

--- Retrieves the label (display name) of a specific item.
--- @param item string The name of the item.
--- @return string The label of the item.
function Inventory.getItemLabel(item)
   local item_exists = exports.ox_inventory:Items(item)
   return item_exists and item_exists.label or false
end

--- Checks if a specific item exists in an inventory or stash with optional conditions.
--- @param invId number|string The player ID or stash ID.
--- @param item string The name of the item to check.
--- @param count number|nil The minimum quantity required (optional).
--- @param md table|nil The metadata to match (optional).
--- @param slot number|nil The slot to check (optional).
--- @return number|boolean The item count if found and matches conditions, false otherwise.
function Inventory.hasItem(invId, item, count, md, slot)
   if not slot then
      local found = exports.ox_inventory:GetItem(invId, item, md, true)
      return not count and found or found >= count
   else
      local item_in_slot = exports.ox_inventory:GetSlot(invId, slot)
      if not item_in_slot then return false end
      if item_in_slot.name ~= item then return false, 'not_right_name' end
      if md then
         for k, v in pairs(md) do
            if item_in_slot.metadata[k] ~= v then return false, 'metadata_mismatch' end
         end
      end
      if count then
         if item_in_slot.count < count then return false, 'wrong_count' end
         return true
      end
      return item_in_slot.count
   end
   return false
end

--- Registers a usable item with a callback function.
--- @param itemName string The name of the item.
--- @param callback function The callback function to execute when the item is used.
function Inventory.createUsableItem(itemName, callback)
   lib.framework.registerUseableItem(itemName, function(source, item)
      -- lib.print.debug("Creating usable item from qs_lib bridge", itemName, source, item)
      callback(source, item)
   end)
end

--- Sets metadata for an item in a specific slot of a player's inventory.
--- @param source number The player source ID.
--- @param itemSlot number The slot containing the item.
--- @param itemMetadata table The metadata to set.
function Inventory.setItemMetadata(source, itemSlot, itemMetadata)
   exports.ox_inventory:SetMetadata(source, itemSlot, itemMetadata)
end

--- Registers a new stash with specified parameters.
--- @param source number|nil The player source ID (optional, defaults to 0).
--- @param stashId string The unique identifier for the stash.
--- @param data table|nil Optional table containing stash configuration (maxSlots, maxWeight).
--- @field data.maxSlots number The maximum number of slots in the stash (default: 20).
--- @field data.maxWeight number The maximum weight capacity of the stash (default: 100000).
--- @return boolean True if the stash was registered successfully, false otherwise.
function Inventory.registerStash(source, stashId, data)
   if not source then source = 0 end
   if not data then data = {} end
   if not data.maxSlots then data.maxSlots = 20 end
   if not data.maxWeight then data.maxWeight = 100000 end
   exports.ox_inventory:RegisterStash(stashId, data.label, data.maxSlots, data.maxWeight, data.owner)
   TriggerClientEvent(GetCurrentResourceName() .. ':bridge:ox_inventoy:openStash', source, stashId, data)
   return true
end

RegisterNetEvent(GetCurrentResourceName() .. ':bridge:ox_inventoy:registerStash', function(stashId, data)
   if not data then data = { maxweight = 150000, slots = 50 } end
   Inventory.registerStash(source, stashId, data)
end)

--- Adds an item to a stash.
--- @param stashId string The stash ID.
--- @param itemName string The name of the item to add.
--- @param itemAmount number The quantity of the item to add.
--- @param itemSlot number|nil The slot to place the item in (optional).
--- @param itemMetadata table|nil Metadata for the item (optional).
--- @param stashSlots number|nil The maximum slots in the stash (optional).
--- @param stashMaxWeight number|nil The maximum weight capacity of the stash (optional).
--- @return boolean True if the item was added successfully, false otherwise.
function Inventory.addItemToStash(stashId, itemName, itemAmount, itemSlot, itemMetadata, stashSlots, stashMaxWeight)
   exports.ox_inventory:AddItem({ id = stashId }, itemName, itemAmount, itemMetadata, itemSlot)
   return true
end

--- Removes an item from a stash.
--- @param stashId string The stash ID.
--- @param itemName string The name of the item to remove.
--- @param itemAmount number The quantity of the item to remove.
--- @param itemSlot number|nil The slot to remove the item from (optional).
--- @param stashSlots number|nil The maximum slots in the stash (optional).
--- @param stashMaxWeight number|nil The maximum weight capacity of the stash (optional).
--- @return boolean True if the item was removed successfully, false otherwise.
function Inventory.removeItemFromStash(stashId, itemName, itemAmount, itemSlot, stashSlots, stashMaxWeight)
   exports.ox_inventory:RemoveItem({ id = stashId }, itemName, itemAmount, itemSlot)
   return true
end

--- Retrieves the items in a stash.
--- @param stashId string The stash ID.
--- @return table A table containing the stash's items.
function Inventory.getStashItems(stashId)
   return exports.ox_inventory:GetInventory(stashId, false)
end

--- Retrieves an item from a player's inventory by slot.
--- @param source number The player source ID.
--- @param slot number The slot to check.
--- @return table|boolean The item details if found, false otherwise.
function Inventory.getItemBySlot(source, slot)
   return exports.ox_inventory:GetSlot(source, slot)
end

return Inventory
