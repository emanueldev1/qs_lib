--- Player management library for ESX framework.
--- This module provides a standardized interface for accessing and managing player-related data and actions on the server side in FiveM.
--- It integrates seamlessly with ESX, retrieving data via lib.framework.GetPlayerFromId() and related methods.
--- The functions cover essential player operations such as identity, job, inventory, financial transactions, and moderation, enabling cross-framework compatibility for roleplay scripts.
--- All functions adhere to a unified API, with consistent return formats to ensure reliability and ease of use.
--- @module player

local Player = {}

--- Retrieves a player object by server ID.
--- @param src number The player server ID.
--- @return table|nil The player object, or nil if not found.
function Player.get(src)
   return lib.framework.GetPlayerFromId(src)
end

--- Retrieves the player's unique identifier.
--- @param src number The player server ID.
--- @return string|nil The player's identifier (e.g., "license:abc123"), or nil if not available.
function Player.identifier(src)
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return nil
   end
   return ply.identifier
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
   local firstName = ply.get("firstName")
   local lastName = ply.get("lastName")
   return firstName or nil, lastName or nil
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
   local result = MySQL.Sync.fetchAll("SELECT phone_number FROM users WHERE identifier = @identifier", { ['@identifier'] = ply.identifier })
   return result[1] and result[1].phone_number or "No Number"
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
   local sex = ply.get("sex")
   return sex == 0 and "male" or sex == 1 and "female" or "unknown"
end

--- Deletes a character for a player.
--- @param src number The player server ID.
--- @param citizenId string The citizen ID of the character to delete.
--- @return boolean Whether the character was successfully deleted.
function Player.deleteCharacter(src, citizenId)
   lib.print.warn("deleteCharacter is not natively supported in ESX; requires custom character management system")
   -- Attempt to implement using MySQL if a characters table exists
   local ply = Player.get(src)
   if not ply then
      lib.print.warn("Player does not exist for server ID: " .. tostring(src))
      return false
   end
   local result = MySQL.Sync.execute("DELETE FROM characters WHERE identifier = @identifier AND citizenid = @citizenid", {
      ['@identifier'] = ply.identifier,
      ['@citizenid'] = citizenId
   })
   return result > 0
end

--- Logs a player into a character.
--- @param src number The player server ID.
--- @param citizenId string The citizen ID of the character to log into.
--- @param newData table|nil Optional new data for the character.
--- @return boolean Whether the login was successful.
function Player.loginCharacter(src, citizenId, newData)
   lib.print.warn("loginCharacter is not natively supported in ESX; requires custom character management system")
   -- ESX does not have a native multi-character system; return false
   return false
end

--- Logs a player out of their character.
--- @param src number The player server ID.
--- @param citizenId string|nil The citizen ID of the character to log out (optional).
--- @return boolean Whether the logout was successful.
function Player.logoutCharacter(src, citizenId)
   lib.print.warn("logoutCharacter is not natively supported in ESX; requires custom character management system")
   -- ESX does not have a native multi-character system; return false
   return false
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
   local rawJob = ply.job or {}
   local jobInfo = lib.framework.Jobs and lib.framework.Jobs[rawJob.name] or {}
   local gradeInfo = jobInfo.grades and jobInfo.grades[tostring(rawJob.grade)] or {}
   return {
      name       = rawJob.name or '',
      type       = rawJob.type or '',
      label      = rawJob.label or '',
      grade      = rawJob.grade or 0,
      gradeLabel = rawJob.grade_label or '',
      isBoss     = rawJob.isboss or false,
      bankAuth   = rawJob.payment or false,   -- ESX uses payment instead of bankAuth
      duty       = false                      -- ESX does not have a native duty field
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
   ply.setJob(name, grade)
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
   lib.print.warn("setDuty is not natively supported in ESX; consider using a custom duty system")
   -- ESX does not have a native duty system; store in metadata as a fallback
   ply.setMeta("duty", duty)
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
   -- ESX does not have a native SetPlayerData; use set for specific fields
   if key == "firstName" or key == "lastName" or key == "sex" or key == "dateofbirth" then
      ply.set(key, data)
      return true
   end
   lib.print.warn("setPlayerData for arbitrary keys is not natively supported in ESX; use metadata for custom data")
   return false
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
      return ply.get(key) or nil
   end
   return {
      identifier = ply.identifier,
      firstName = ply.get("firstName"),
      lastName = ply.get("lastName"),
      sex = ply.get("sex"),
      dateofbirth = ply.get("dateofbirth"),
      job = ply.job,
      accounts = ply.getAccounts()
   }
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
   if not ply.setMeta then
      lib.print.warn("setMeta is not available in this ESX version")
      return false
   end
   ply.setMeta(key, data)
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
   if not ply.getMeta then
      lib.print.warn("getMeta is not available in this ESX version")
      return nil
   end
   return ply.getMeta(key)
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
   lib.print.warn("jail is not natively supported in ESX; requires a jail system like esx_jail")
   -- Attempt to trigger a jail event if a jail system exists
   TriggerEvent("esx_jail:sendToJail", src, time * 60, reason or "No reason provided")
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
   local acc = ply.getAccount(account)
   return acc and acc.money or 0
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
   ply.addAccountMoney(account, amount)
   return true
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
   local acc = ply.getAccount(account)
   if not acc then
      return false, "no_account"
   end
   if not force and acc.money < amount then
      return false, "insufficient_funds"
   end
   ply.removeAccountMoney(account, amount)
   return true, nil
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
   ply.setAccountMoney(account, amount)
   return true
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
      if other_ply and other_ply.identifier == identifier then
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
   DropPlayer(src, reason or "Kicked from server")
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
   if not ply.getMeta then
      lib.print.warn("getMeta is not available in this ESX version; gang support requires metadata")
      return nil
   end
   local gang = ply.getMeta("gang") or {}
   return {
      name       = gang.name or '',
      label      = gang.label or '',
      grade      = gang.grade or 0,
      gradeLabel = gang.gradeLabel or '',
      isBoss     = gang.isBoss or false
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
   if not ply.setMeta then
      lib.print.warn("setMeta is not available in this ESX version; gang support requires metadata")
      return false
   end
   ply.setMeta("gang", {
      name = name,
      label = name,                   -- ESX does not have a native gang label; use name
      grade = grade,
      gradeLabel = tostring(grade),   -- Use grade as string
      isBoss = grade >= 3             -- Arbitrary rule for isBoss
   })
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
   if metadata then
      lib.print.warn("Item metadata is not natively supported in ESX; metadata ignored")
   end
   ply.addInventoryItem(item, amount)
   return true
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
   local currentAmount = 0
   for _, invItem in ipairs(ply.getInventory()) do
      if invItem.name == item then
         currentAmount = invItem.count
         break
      end
   end
   if currentAmount < amount then
      return false
   end
   ply.removeInventoryItem(item, amount)
   return true
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
   for _, invItem in ipairs(ply.getInventory()) do
      if invItem.name == item and invItem.count >= amount then
         return true
      end
   end
   return false
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
   local accounts = ply.getAccounts()
   local result = {}
   for _, acc in ipairs(accounts) do
      result[acc.name] = acc.money
   end
   return result
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
   lib.print.warn("ban is not natively supported in ESX; requires a ban system like esx_ban")
   -- Attempt to implement a basic ban using MySQL
   local banUntil = duration > 0 and (os.time() + duration * 60) or 0
   MySQL.Sync.execute("INSERT INTO bans (identifier, reason, expire) VALUES (@identifier, @reason, @expire)", {
      ['@identifier'] = ply.identifier,
      ['@reason'] = reason or "Banned from server",
      ['@expire'] = banUntil
   })
   DropPlayer(src, reason or "You have been banned")
   return true
end

return Player
