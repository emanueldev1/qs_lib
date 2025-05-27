-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

--- Player management library for QBCore framework.
--- This module provides a standardized interface for accessing and managing player-related data and actions on the server side in FiveM.
--- It integrates seamlessly with QBCore, retrieving data via lib.framework.Functions.GetPlayer().
--- The functions cover essential player operations such as identity, job, inventory, financial transactions, and moderation, enabling cross-framework compatibility for roleplay scripts.
--- All functions adhere to a unified API, with consistent return formats to ensure reliability and ease of use.
--- @module player

local Player = {}

--- Retrieves a player object by server ID.
--- @param src number The player server ID.
--- @return table|nil The player object, or nil if not found.
function Player.get(src)
   return lib.framework.Functions.GetPlayer(src)
end

--- Retrieves the player's unique identifier.
--- @param src number The player server ID.
--- @return string|nil The player's identifier (e.g., "citizenid123"), or nil if not available.
function Player.identifier(src)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return nil
   end
   return ply.PlayerData.citizenid
end

--- Retrieves the player's first and last name.
--- @param src number The player server ID.
--- @return string|nil The player's first name, or nil if not available.
--- @return string|nil The player's last name, or nil if not available.
function Player.name(src)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return nil, nil
   end
   return ply.PlayerData.charinfo.firstname, ply.PlayerData.charinfo.lastname
end

--- Retrieves the player's phone number.
--- @param src number The player server ID.
--- @return string The player's phone number, or "No Number" if not found.
function Player.phoneNumber(src)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return "No Number"
   end
   return ply.PlayerData.charinfo.phone or "No Number"
end

--- Retrieves the player's gender.
--- @param src number The player server ID.
--- @return string The player's gender (e.g., "male", "female"), or "unknown" if not available.
function Player.gender(src)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return "unknown"
   end
   return ply.PlayerData.charinfo.gender == 0 and "male" or ply.PlayerData.charinfo.gender == 1 and "female" or "unknown"
end

--- Deletes a character for a player.
--- @param src number The player server ID.
--- @param citizenId string The citizen ID of the character to delete.
--- @return boolean Whether the character was successfully deleted.
function Player.deleteCharacter(src, citizenId)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   return lib.framework.Player.DeleteCharacter(src, citizenId)
end

--- Logs a player into a character.
--- @param src number The player server ID.
--- @param citizenId string The citizen ID of the character to log into.
--- @param newData table|nil Optional new data for the character.
--- @return boolean Whether the login was successful.
function Player.loginCharacter(src, citizenId, newData)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   return lib.framework.Player.Login(src, citizenId, newData)
end

--- Logs a player out of their character.
--- @param src number The player server ID.
--- @param citizenId string|nil The citizen ID of the character to log out (optional).
--- @return boolean Whether the logout was successful.
function Player.logoutCharacter(src, citizenId)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   return lib.framework.Player.Logout(src, citizenId)
end

--- Retrieves the player's job information.
--- @param src number The player server ID.
--- @return table|nil A table containing job details (name, type, label, grade, gradeLabel, isBoss, bankAuth, duty), or nil if player not found.
function Player.getJob(src)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return nil
   end
   local rawJob = ply.PlayerData.job or {}
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

--- Sets the player's job and grade.
--- @param src number The player server ID.
--- @param name string The job name.
--- @param grade number The job grade or rank.
--- @return boolean True if the job was set successfully, false otherwise.
function Player.setJob(src, name, grade)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   ply.Functions.SetJob(name, grade)
   return true
end

--- Sets the player's duty status.
--- @param src number The player server ID.
--- @param duty boolean True to set the player on duty, false otherwise.
--- @return boolean True if the duty status was set successfully, false otherwise.
function Player.setDuty(src, duty)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   ply.Functions.SetJobDuty(duty)
   return true
end

--- Sets player data for a specific key.
--- @param src number The player server ID.
--- @param key string The data key to set.
--- @param data any The data to set.
--- @return boolean True if the data was set successfully, false otherwise.
function Player.setPlayerData(src, key, data)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   ply.Functions.SetPlayerData(key, data)
   return true
end

--- Retrieves the player's data or a specific key from it.
--- @param src number The player server ID.
--- @param key string|nil Optional key to retrieve specific data.
--- @return table|any|nil The player's data, the value of the specified key, or nil if player not found.
function Player.getPlayerData(src, key)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return nil
   end
   if key then
      return ply.PlayerData[key] or nil
   end
   return ply.PlayerData
end

--- Sets metadata for a specific key.
--- @param src number The player server ID.
--- @param key string The metadata key.
--- @param data any The metadata value to set.
--- @return boolean True if the metadata was set successfully, false otherwise.
function Player.setMetadata(src, key, data)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   ply.Functions.SetMetaData(key, data)
   return true
end

--- Retrieves metadata for a specific key.
--- @param src number The player server ID.
--- @param key string The metadata key.
--- @return any|nil The metadata value, or nil if not found.
function Player.getMetadata(src, key)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return nil
   end
   return ply.Functions.GetMetaData(key)
end

--- Jails a player for a specified duration.
--- @param src number The player server ID.
--- @param time number The duration of the jail time in minutes.
--- @param reason string|nil Optional reason for jailing.
--- @return boolean True if the player was jailed successfully, false otherwise.
function Player.jail(src, time, reason)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   -- QBCore typically uses a jail system; assume a custom event or function
   TriggerEvent("qb-policejob:jailPlayer", src, time * 60, reason or "No reason provided")
   return true
end

--- Retrieves the player's money for a specific account.
--- @param src number The player server ID.
--- @param account string The account name (e.g., "bank", "cash").
--- @return number|nil The amount of money in the specified account, or nil if player not found.
function Player.getMoney(src, account)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return nil
   end
   return ply.Functions.GetMoney(account) or 0
end

--- Adds money to a player's account.
--- @param src number The player server ID.
--- @param account string The account name (e.g., "bank", "cash").
--- @param amount number The amount of money to add.
--- @param reason string|nil Optional reason for the transaction.
--- @return boolean True if the money was added successfully, false otherwise.
function Player.addMoney(src, account, amount, reason)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   return ply.Functions.AddMoney(account, amount, reason) or false
end

--- Removes money from a player's account.
--- @param src number The player server ID.
--- @param account string The account name (e.g., "bank", "cash").
--- @param amount number The amount of money to remove.
--- @param reason string|nil Optional reason for the transaction.
--- @param force boolean|nil True to force removal even if funds are insufficient.
--- @return boolean Whether the money was successfully removed.
--- @return string|nil Error code (e.g., "no_account", "insufficient_funds") if removal failed.
function Player.removeMoney(src, account, amount, reason, force)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false, nil
   end
   if not force then
      local has = ply.Functions.GetMoney(account)
      if has < amount then
         return false, "insufficient_funds"
      end
   end
   return ply.Functions.RemoveMoney(account, amount, reason) or false, nil
end

--- Sets the money in a player's account.
--- @param src number The player server ID.
--- @param account string The account name (e.g., "bank", "cash").
--- @param amount number The amount of money to set.
--- @return boolean True if the money was set successfully, false otherwise.
function Player.setMoney(src, account, amount)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   return ply.Functions.SetMoney(account, amount) or false
end

--- Checks if a player is online by their character ID or server ID.
--- @param identifier string|number The character ID or server ID.
--- @return boolean|string False if the player is offline, or the server ID if online.
function Player.checkOnline(identifier)
   if type(identifier) ~= "string" and type(identifier) ~= "number" then
      lib.print.warn("Identifier must be a string or number")
      return false
   end
   if type(identifier) == "number" then
      return Player.get(identifier) and identifier or false
   end
   local players = GetPlayers()
   for _, ply in ipairs(players) do
      local other_ply = Player.get(tonumber(ply))
      if other_ply and other_ply.PlayerData.citizenid == identifier then
         return ply
      end
   end
   return false
end

--- Kicks a player from the server.
--- @param src number The player server ID.
--- @param reason string|nil Optional reason for the kick.
--- @return boolean True if the player was kicked successfully, false otherwise.
function Player.kick(src, reason)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   ply.Functions.Kick(reason or "Kicked from server")
   return true
end

--- Retrieves the player's gang information (if applicable).
--- @param src number The player server ID.
--- @return table|nil A table containing gang details (name, label, grade, gradeLabel, isBoss), or nil if player not found.
function Player.getGang(src)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return nil
   end
   local rawGang = ply.PlayerData.gang or {}
   return {
      name       = rawGang.name or '',
      label      = rawGang.label or '',
      grade      = rawGang.grade and rawGang.grade.level or 0,
      gradeLabel = rawGang.grade and rawGang.grade.name or '',
      isBoss     = rawGang.isboss or false
   }
end

--- Sets the player's gang and grade.
--- @param src number The player server ID.
--- @param name string The gang name.
--- @param grade number The gang grade or rank.
--- @return boolean True if the gang was set successfully, false otherwise.
function Player.setGang(src, name, grade)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   ply.Functions.SetGang(name, grade)
   return true
end

--- Adds an item to the player's inventory.
--- @param src number The player server ID.
--- @param item string The item name.
--- @param amount number The amount of the item to add.
--- @param metadata table|nil Optional metadata for the item.
--- @return boolean True if the item was added successfully, false otherwise.
function Player.addItem(src, item, amount, metadata)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   return ply.Functions.AddItem(item, amount, nil, metadata) or false
end

--- Removes an item from the player's inventory.
--- @param src number The player server ID.
--- @param item string The item name.
--- @param amount number The amount of the item to remove.
--- @return boolean True if the item was removed successfully, false otherwise.
function Player.removeItem(src, item, amount)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   return ply.Functions.RemoveItem(item, amount) or false
end

--- Checks if the player has a specific item in their inventory.
--- @param src number The player server ID.
--- @param item string The item name.
--- @param amount number|nil The minimum amount required (default: 1).
--- @return boolean True if the player has the item and amount, false otherwise.
function Player.hasItem(src, item, amount)
   amount = amount or 1
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   return ply.Functions.HasItem(item, amount) or false
end

--- Retrieves all accounts of the player.
--- @param src number The player server ID.
--- @return table|nil A table of account names and their amounts, or nil if player not found.
function Player.getAccounts(src)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return nil
   end
   return ply.PlayerData.money or {}
end

--- Bans a player from the server.
--- @param src number The player server ID.
--- @param duration number The duration of the ban in minutes (0 for permanent).
--- @param reason string|nil Optional reason for the ban.
--- @return boolean True if the player was banned successfully, false otherwise.
function Player.ban(src, duration, reason)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   -- QBCore supports banning; use a custom ban function or event
   TriggerEvent("qb-admin:server:banPlayer", src, duration, reason or "Banned from server")
   return true
end

return Player
