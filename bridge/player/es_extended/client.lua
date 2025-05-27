-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

--- Player management library for ESX framework.
--- This module provides a standardized interface for accessing player-related data on the client side in FiveM.
--- It is designed to integrate seamlessly with ESX, retrieving data from the framework's PlayerData structure.
--- The functions cover essential player information such as identity, inventory, job, and status, enabling cross-framework compatibility for roleplay scripts.
--- All functions adhere to a unified API, with consistent return formats to ensure reliability and ease of use.
--- @module player

local Player = {}

--- Retrieves the player's unique identifier.
--- @return string|nil The player's identifier (e.g., "char1:abc123"), or nil if not available.
function Player.identifier()
   return lib.framework.PlayerData.identifier or nil
end

--- Retrieves the player's first and last name.
--- @return string|nil The player's first name, or nil if not available.
--- @return string|nil The player's last name, or nil if not available.
function Player.name()
   local playerData = lib.framework.PlayerData or {}
   return playerData.firstName or nil, playerData.lastName or nil
end

--- Retrieves the player's username.
--- @return string|nil The player's username, or nil if not available.
function Player.getUsername()
   return lib.framework.PlayerData.name or nil
end

--- Retrieves the player's date of birth.
--- @return string|nil The player's date of birth (e.g., "01/01/2000"), or nil if not available.
function Player.getBirth()
   return lib.framework.PlayerData.dateofbirth or nil
end

--- Retrieves the player's height.
--- @return number|nil The player's height in cm (e.g., 181), or nil if not available.
function Player.getHeight()
   return lib.framework.PlayerData.height or nil
end

--- Retrieves the player's sex.
--- @return number|nil The player's sex (0 for male, 1 for female), or nil if not available.
function Player.getSex()
   return lib.framework.PlayerData.sex or nil
end

--- Retrieves the player's license.
--- @return string|nil The player's license (e.g., "license:abc123"), or nil if not available.
function Player.getLicense()
   return lib.framework.PlayerData.license or nil
end

--- Retrieves the player's permission group.
--- @return string|nil The player's group (e.g., "user", "admin"), or nil if not available.
function Player.getGroup()
   return lib.framework.PlayerData.group or nil
end

--- Checks if the player is an admin.
--- @return boolean True if the player is an admin, false otherwise.
function Player.isAdmin()
   return lib.framework.PlayerData.admin or false
end

--- Checks if the player is dead.
--- @return boolean True if the player is dead, false otherwise.
function Player.isDead()
   return lib.framework.PlayerData.dead or false
end

--- Retrieves the current weight of the player's inventory.
--- @return number The current inventory weight (e.g., 12), or 0 if not available.
function Player.getWeight()
   return lib.framework.PlayerData.weight or 0
end

--- Retrieves the maximum weight of the player's inventory.
--- @return number The maximum inventory weight (e.g., 24), or 0 if not available.
function Player.getMaxWeight()
   return lib.framework.PlayerData.maxWeight or 0
end

--- Retrieves the player's ped ID.
--- @return number The player's ped ID, or 0 if not available.
function Player.getPed()
   return lib.framework.PlayerData.ped or 0
end

--- Retrieves the player's ID.
--- @return number The player's ID (e.g., 1), or 0 if not available.
function Player.getPlayerId()
   return lib.framework.PlayerData.playerId or 0
end

--- Retrieves the player's server source ID.
--- @return number The player's source ID (e.g., 1), or 0 if not available.
function Player.getSource()
   return lib.framework.PlayerData.source or 0
end

--- Retrieves the player's data or a specific key from it.
--- @param _key string|nil Optional key to retrieve specific data.
--- @return table|any The player's data or the value of the specified key, or nil if not available.
function Player.getPlayerData(_key)
   local playerData = lib.framework.PlayerData or {}
   if _key then
      return playerData[_key] or nil
   end
   return playerData
end

--- Retrieves player metadata or a specific key from it.
--- @param _key string|nil Optional key to retrieve specific metadata.
--- @return table|any The player's metadata or the value of the specified key, or nil if not available.
function Player.getMetadata(_key)
   return lib.getPlayerMetadata(_key) or nil
end

--- Retrieves the player's inventory.
--- @return table The player's inventory items, or an empty table if not available.
function Player.getInventory()
   return lib.framework.inventory or {}
end

--- Retrieves the player's money for a specific account.
--- @param _account string The account name (e.g., "bank", "cash").
--- @return number The amount of money in the specified account, or 0 if not found.
function Player.getMoney(_account)
   local accounts = lib.framework.PlayerData.accounts or {}
   for _, account in pairs(accounts) do
      if account.name == _account then
         return account.money or 0
      end
   end
   -- Fallback to PlayerData.money for compatibility with some ESX setups
   return lib.framework.PlayerData.money or 0
end

--- Retrieves the player's job information.
--- @return table A table containing job details (name, type, label, grade, gradeLabel, isBoss, bankAuth, duty).
function Player.getJob()
   local playerData = lib.framework.PlayerData or {}
   local rawJob = playerData.job or {}
   local jobInfo = lib.framework.Jobs and lib.framework.Jobs[rawJob.name] or {}
   local gradeInfo = jobInfo.grades and jobInfo.grades[tostring(rawJob.grade)] or {}
   return {
      name       = rawJob.name or '',
      type       = rawJob.type or '',
      label      = rawJob.label or '',
      grade      = rawJob.grade or 0,
      gradeLabel = rawJob.grade_label or '',
      isBoss     = rawJob.isboss or false,
      bankAuth   = rawJob.bankAuth or false,
      duty       = false   -- ESX does not have a default duty field
   }
end

--- Shows a notification to the player.
--- @param message string The notification message.
--- @param type string|nil The notification type (e.g., "success", "error", "info").
--- @param duration number|nil Duration in milliseconds (optional).
--- @return nil
function Player.notify(message, type, duration)
   if not message then return end
   local formattedMessage = message
   if type then
      formattedMessage = string.format("[%s] %s", type:upper(), message)
   end
   lib.framework.ShowNotification(formattedMessage)
end

--- Retrieves the player's current coordinates.
--- @return table A table with x, y, z coordinates.
function Player.getCoords()
   local coords = lib.framework.PlayerData.coords or vector3(0, 0, 0)
   return {
      x = coords.x or 0.0,
      y = coords.y or 0.0,
      z = coords.z or 0.0
   }
end

--- Retrieves the player's gang information (if applicable).
--- @return table A table containing gang details (name, label, grade, gradeLabel, isBoss).
function Player.getGang()
   local metadata = lib.getPlayerMetadata('gang') or {}
   return {
      name       = metadata.name or '',
      label      = metadata.label or '',
      grade      = metadata.grade or 0,
      gradeLabel = metadata.gradeLabel or '',
      isBoss     = metadata.isBoss or false
   }
end

--- Checks if the player has a specific item in their inventory.
--- @param item string The item name.
--- @param amount number|nil The minimum amount required (default: 1).
--- @return boolean True if the player has the item and amount, false otherwise.
function Player.hasItem(item, amount)
   amount = amount or 1
   local inventory = lib.framework.inventory or {}
   for _, invItem in pairs(inventory) do
      if invItem.name == item and invItem.count >= amount then
         return true
      end
   end
   return false
end

return Player
