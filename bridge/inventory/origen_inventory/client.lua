-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

--- Inventory management library (origen_inventory)
--- This module provides a template for integrating custom inventory systems.
--- Replace the placeholder logic with your own implementation to interface with your inventory system.
--- @module inventory


RegisterNetEvent(GetCurrentResourceName() .. 'bridge:origen_inventory:openStash', function(stashId, data)
   if not data then data = {} end
   if not data.maxSlots then data.maxSlots = 20 end
   if not data.maxWeight then data.maxWeight = 100000 end
   exports.origen_inventory:openInventory('stash', stashId, {
      label = data.label or stashId,
      maxSlots = data.maxSlots,
      slots = data.maxSlots,
   })
end)

local Inventory = {}

--- Retrieves the list of items from the inventory system.
--- @return table A table containing the list of all items.
function Inventory.getItemList()
   return exports.origen_inventory:Items()
end

--- Retrieves the list of weapons from the inventory system.
--- @return table A table containing the list of all weapons.
function Inventory.getWeaponList()
   return exports.origen_inventory:Items()
end

--- Checks if the inventory UI is currently open.
--- @return boolean True if the inventory is open, false otherwise.
function Inventory.isOpen()
   return exports.origen_inventory:IsInventoryOpen() -- return boolean
end

--- Enables or disables the inventory system.
--- @param state boolean True to disable the inventory, false to enable it.
--- @return boolean|nil True if the state was set successfully, false or nil otherwise.
function Inventory.setDisabled(state)
   exports.origen_inventory:ToggleInventoryAccess(state --[[true/false]]) -- Lock / unlock inventory
end

--- Retrieves the user's inventory data.
--- @return table A table containing the user's inventory items.
function Inventory.get()
   return exports.origen_inventory:GetInventory()
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
   TriggerServerEvent(GetCurrentResourceName() .. 'bridge:origen_inventory:registerStash', stashId, data)
   return true
end

--- Retrieves the currently equipped weapon.
--- @return table|nil A table containing the current weapon's details, or nil if no weapon is equipped.
function Inventory.getCurrentWeapon()
   -- Replace with your custom logic to fetch the current weapon.
   -- Example: return YourInventorySystem:GetEquippedWeapon()

   lib.print.debug('codem-inventory does not support getCurrentWeapon, returning a custom one using Fivem natives (Different data than other inventoryes)')
   local weapon = GetSelectedPedWeapon(PlayerPedId())
   if weapon == -1569615261 then
      return nil
   end
   local weaponHash = GetHashKey(weapon)
   local weaponData = {
      hash = weaponHash,
      ammo = GetAmmoInPedWeapon(PlayerPedId(), weaponHash),
   }
   return weaponData
end

--- Searches for an item in the inventory by name.
--- @param itemName string The name of the item to search for.
--- @return table A table containing the search results (items found).
function Inventory.search(itemName)
   -- custom search logic on current inventory only return ONE item

   local itemList = Inventory.getItemList()
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
   -- Replace with your custom logic to check if the inventory is blocked.
   -- Example: return YourInventorySystem:IsInventoryBlocked()
   return exports.origen_inventory:IsInventoryLocked()
end

return Inventory
