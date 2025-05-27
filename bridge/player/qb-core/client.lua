-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

--- Player management library for QBCore framework.
--- This module provides a standardized interface for accessing player-related data on the client side in FiveM.
--- It integrates seamlessly with QBCore, retrieving data via lib.framework.Functions.GetPlayerData().
--- The functions cover essential player information such as identity, inventory, job, and status, enabling cross-framework compatibility for roleplay scripts.
--- All functions adhere to a unified API, with consistent return formats to ensure reliability and ease of use.
--- @module player

local Player = {}

--- Retrieves the player's unique identifier.
--- @return string|nil The player's identifier (e.g., "citizenid123"), or nil if not available.
function Player.identifier()
   return lib.framework.Functions.GetPlayerData().citizenid or nil
end

--- Retrieves the player's first and last name.
--- @return string|nil The player's first name, or nil if not available.
--- @return string|nil The player's last name, or nil if not available.
function Player.name()
   local playerData = lib.framework.Functions.GetPlayerData() or {}
   return playerData.charinfo and playerData.charinfo.firstname or nil, playerData.charinfo and playerData.charinfo.lastname or nil
end

--- Retrieves the player's username.
--- @return string|nil The player's username, or nil if not available.
function Player.getUsername()
   return lib.framework.Functions.GetPlayerData().name or nil
end

--- Retrieves the player's date of birth.
--- @return string|nil The player's date of birth (e.g., "01/01/2000"), or nil if not available.
function Player.getBirth()
   return lib.framework.Functions.GetPlayerData().charinfo and lib.framework.Functions.GetPlayerData().charinfo.birthdate or nil
end

--- Retrieves the player's height.
--- @return number|nil The player's height in cm (e.g., 181), or nil if not available.
function Player.getHeight()
   local metadata = lib.framework.Functions.GetPlayerData().metadata or {}
   return metadata.height or nil
end

--- Retrieves the player's sex.
--- @return number|nil The player's sex (0 for male, 1 for female), or nil if not available.
function Player.getSex()
   return lib.framework.Functions.GetPlayerData().charinfo and lib.framework.Functions.GetPlayerData().charinfo.gender or nil
end

--- Retrieves the player's license.
--- @return string|nil The player's license (e.g., "license:abc123"), or nil if not available.
function Player.getLicense()
   local metadata = lib.framework.Functions.GetPlayerData().metadata or {}
   return metadata.license or lib.framework.Functions.GetPlayerData().citizenid or nil
end

--- Retrieves the player's permission group.
--- @return string|nil The player's group (e.g., "user", "admin"), or nil if not available.
function Player.getGroup()
   local metadata = lib.framework.Functions.GetPlayerData().metadata or {}
   return metadata.group or nil
end

--- Checks if the player is an admin.
--- @return boolean True if the player is an admin, false otherwise.
function Player.isAdmin()
   local metadata = lib.framework.Functions.GetPlayerData().metadata or {}
   return metadata.admin or false
end

--- Checks if the player is dead.
--- @return boolean True if the player is dead, false otherwise.
function Player.isDead()
   local metadata = lib.framework.Functions.GetPlayerData().metadata or {}
   return metadata.isdead or false
end

--- Retrieves the current weight of the player's inventory.
--- @return number The current inventory weight (e.g., 12), or 0 if not available.
function Player.getWeight()
   return lib.framework.Functions.GetPlayerData().weight or 0
end

--- Retrieves the maximum weight of the player's inventory.
--- @return number The maximum inventory weight (e.g., 24), or 0 if not available.
function Player.getMaxWeight()
   return lib.framework.Functions.GetPlayerData().maxWeight or 0
end

--- Retrieves the player's ped ID.
--- @return number The player's ped ID, or 0 if not available.
function Player.getPed()
   -- QBCore does not store ped in PlayerData; use native function
   return GetPlayerPed(-1) or 0
end

--- Retrieves the player's ID.
--- @return number The player's ID (e.g., 1), or 0 if not available.
function Player.getPlayerId()
   return lib.framework.Functions.GetPlayerData().playerId or 0
end

--- Retrieves the player's server source ID.
--- @return number The player's source ID (e.g., 1), or 0 if not available.
function Player.getSource()
   return lib.framework.Functions.GetPlayerData().source or 0
end

--- Retrieves the player's data or a specific key from it.
--- @param _key string|nil Optional key to retrieve specific data.
--- @return table|any The player's data or the value of the specified key, or nil if not available.
function Player.getPlayerData(_key)
   local playerData = lib.framework.Functions.GetPlayerData() or {}
   if _key then
      return playerData[_key] or nil
   end
   return playerData
end

--- Retrieves player metadata or a specific key from it.
--- @param _key string|nil Optional key to retrieve specific metadata.
--- @return table|any The player's metadata or the value of the specified key, or nil if not available.
function Player.getMetadata(_key)
   local metadata = lib.framework.Functions.GetPlayerData().metadata or {}
   return _key and metadata[_key] or metadata
end

--- Retrieves the player's inventory.
--- @return table The player's inventory items, or an empty table if not available.
function Player.getInventory()
   return lib.framework.Functions.GetPlayerData().items or {}
end

--- Retrieves the player's money for a specific account.
--- @param _account string The account name (e.g., "bank", "cash").
--- @return number The amount of money in the specified account, or 0 if not found.
function Player.getMoney(_account)
   local playerData = lib.framework.Functions.GetPlayerData() or {}
   return playerData.money and playerData.money[_account] or 0
end

--- Retrieves the player's job information.
--- @return table A table containing job details (name, type, label, grade, gradeLabel, isBoss, bankAuth, duty).
function Player.getJob()
   local playerData = lib.framework.Functions.GetPlayerData() or {}
   local rawJob = playerData.job or {}
   return {
      name       = rawJob.name or '',
      type       = rawJob.type or '',
      label      = rawJob.label or '',
      grade      = rawJob.grade and rawJob.grade.level or 0,
      gradeLabel = rawJob.grade and rawJob.grade.name or '',
      isBoss     = rawJob.isboss or false,
      bankAuth   = rawJob.bankAuth or false,
      duty       = rawJob.onduty or false
   }
end

--- Shows a notification to the player.
--- @param message string The notification message.
--- @param type string|nil The notification type (e.g., "success", "error", "info").
--- @param duration number|nil Duration in milliseconds (optional).
--- @return nil
function Player.notify(message, type, duration)
   if not message then return end
   lib.framework.Functions.Notify(message, type or "info", duration or 5000)
end

--- Retrieves the player's current coordinates.
--- @return table A table with x, y, z coordinates.
function Player.getCoords()
   local playerData = lib.framework.Functions.GetPlayerData() or {}
   local coords = playerData.position or vector3(0, 0, 0)
   return {
      x = coords.x or 0.0,
      y = coords.y or 0.0,
      z = coords.z or 0.0
   }
end

--- Retrieves the player's gang information (if applicable).
--- @return table A table containing gang details (name, label, grade, gradeLabel, isBoss).
function Player.getGang()
   local playerData = lib.framework.Functions.GetPlayerData() or {}
   local rawGang = playerData.gang or {}
   return {
      name       = rawGang.name or '',
      label      = rawGang.label or '',
      grade      = rawGang.grade and rawGang.grade.level or 0,
      gradeLabel = rawGang.grade and rawGang.grade.name or '',
      isBoss     = rawGang.isboss or false
   }
end

--- Checks if the player has a specific item in their inventory.
--- @param item string The item name.
--- @param amount number|nil The minimum amount required (default: 1).
--- @return boolean True if the player has the item and amount, false otherwise.
function Player.hasItem(item, amount)
   amount = amount or 1
   local items = lib.framework.Functions.GetPlayerData().items or {}
   for _, invItem in pairs(items) do
      if invItem.name == item and invItem.amount >= amount then
         return true
      end
   end
   return false
end

return Player
