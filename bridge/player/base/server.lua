-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

--- Player management library template for FiveM frameworks.
--- This module defines a standardized interface for accessing and managing player-related data and actions on the server side in FiveM.
--- It is designed to be implemented for specific frameworks (e.g., ESX, QBCore, QBXCore) to provide a consistent API for scripts.
--- Developers should implement each function to interact with their framework's player data and management systems, ensuring the specified return formats and types.
--- The functions cover essential player operations such as identity, job, inventory, financial transactions, and moderation, enabling cross-framework compatibility for roleplay scripts.
--- @module player

local Player = {}

--- Retrieves a player object by server ID.
--- @param src number The player server ID.
--- @return table|nil The player object, or nil if not found.
--- @example return { PlayerData = { citizenid = "citizenid123" } } -- QBCore/QBXCore example
--- @example return { identifier = "license:abc123" } -- ESX example
function Player.get(src)
   -- Implementing: Retrieve the player object from the framework
   -- Example: return YourFramework.GetPlayer(src)
   return nil
end

--- Retrieves the player's unique identifier.
--- @param src number The player server ID.
--- @return string|nil The player's identifier (e.g., "license:abc123" or "citizenid123"), or nil if not available.
--- @example return "license:abc123" -- ESX example
--- @example return "citizenid123" -- QBCore/QBXCore example
function Player.identifier(src)
   -- Implementing: Access the player's unique identifier
   -- Example: local ply = YourFramework.GetPlayer(src); return ply.identifier or ply.PlayerData.citizenid
   return nil
end

--- Retrieves the player's first and last name.
--- @return string|nil The player's first name, or nil if not available.
--- @return string|nil The player's last name, or nil if not available.
--- @example return "John", "Doe" -- Valid return
--- @example return nil, nil -- If name is not available
function Player.name(src)
   -- Implementing: Extract first and last name from the framework's character info
   -- Example: local ply = YourFramework.GetPlayer(src); return ply.PlayerData.charinfo.firstname, ply.PlayerData.charinfo.lastname
   return nil, nil
end

--- Retrieves the player's phone number.
--- @param src number The player server ID.
--- @return string The player's phone number, or a default value (e.g., "No Number") if not available.
--- @example return "123-456-7890" -- Valid return
--- @example return "No Number" -- If not available
function Player.phoneNumber(src)
   -- Implementing: Retrieve the phone number from character info or database
   -- Example: local ply = YourFramework.GetPlayer(src); return ply.PlayerData.charinfo.phone or "No Number"
   return "No Number"
end

--- Retrieves the player's gender.
--- @param src number The player server ID.
--- @return string The player's gender (e.g., "male", "female"), or "unknown" if not available.
--- @example return "male" -- Valid return
--- @example return "unknown" -- If not available
function Player.gender(src)
   -- Implementing: Access gender from character info or metadata
   -- Example: local ply = YourFramework.GetPlayer(src); return ply.PlayerData.charinfo.gender or "unknown"
   return "unknown"
end

--- Deletes a character for a player.
--- @param src number The player server ID.
--- @param citizenId string The citizen ID of the character to delete.
--- @return boolean Whether the character was successfully deleted.
--- @example return true -- Character deleted
function Player.deleteCharacter(src, citizenId)
   -- Implementing: Delete a character using the framework's character management
   -- Example: return YourFramework.DeleteCharacter(src, citizenId)
   return false
end

--- Logs a player into a character.
--- @param src number The player server ID.
--- @param citizenId string The citizen ID of the character to log into.
--- @param newData table|nil Optional new data for the character.
--- @return boolean Whether the login was successful.
--- @example return true -- Login successful
function Player.loginCharacter(src, citizenId, newData)
   -- Implementing: Log the player into a character
   -- Example: return YourFramework.Login(src, citizenId, newData)
   return false
end

--- Logs a player out of their character.
--- @param src number The player server ID.
--- @param citizenId string|nil The citizen ID of the character to log out (optional).
--- @return boolean Whether the logout was successful.
--- @example return true -- Logout successful
function Player.logoutCharacter(src, citizenId)
   -- Implementing: Log the player out of their character
   -- Example: return YourFramework.Logout(src, citizenId)
   return false
end

--- Retrieves the player's job information.
--- @param src number The player server ID.
--- @return table|nil A table containing job details (name, type, label, grade, gradeLabel, isBoss, bankAuth, duty), or nil if player not found.
--- @example return { name = "police", type = "leo", label = "Police Officer", grade = 2, gradeLabel = "Sergeant", isBoss = false, bankAuth = true, duty = true }
function Player.getJob(src)
   -- Implementing: Retrieve job details from the framework
   -- Example: local ply = YourFramework.GetPlayer(src); local job = ply.PlayerData.job; return { name = job.name, ... }
   return nil
end

--- Sets the player's job and grade.
--- @param src number The player server ID.
--- @param name string The job name.
--- @param grade number The job grade or rank.
--- @return boolean True if the job was set successfully, false otherwise.
--- @example return true -- Job set successfully
function Player.setJob(src, name, grade)
   -- Implementing: Set the player's job and grade
   -- Example: local ply = YourFramework.GetPlayer(src); ply.SetJob(name, grade); return true
   return false
end

--- Sets the player's duty status.
--- @param src number The player server ID.
--- @param duty boolean True to set the player on duty, false otherwise.
--- @return boolean True if the duty status was set successfully, false otherwise.
--- @example return true -- Duty status set
function Player.setDuty(src, duty)
   -- Implementing: Set the player's duty status
   -- Example: local ply = YourFramework.GetPlayer(src); ply.SetJobDuty(duty); return true
   return false
end

--- Sets player data for a specific key.
--- @param src number The player server ID.
--- @param key string The data key to set.
--- @param data any The data to set.
--- @return boolean True if the data was set successfully, false otherwise.
--- @example return true -- Data set successfully
function Player.setPlayerData(src, key, data)
   -- Implementing: Set player data for a specific key
   -- Example: local ply = YourFramework.GetPlayer(src); ply.SetPlayerData(key, data); return true
   return false
end

--- Retrieves the player's data or a specific key from it.
--- @param src number The player server ID.
--- @param key string|nil Optional key to retrieve specific data.
--- @return table|any|nil The player's data, the value of the specified key, or nil if player not found.
--- @example return { job = { name = "police" }, money = { cash = 100 } } -- Full data
--- @example return { name = "police" } -- For key = "job"
function Player.getPlayerData(src, key)
   -- Implementing: Retrieve player data or a specific key
   -- Example: local ply = YourFramework.GetPlayer(src); return key and ply.PlayerData[key] or ply.PlayerData
   return nil
end

--- Sets metadata for a specific key.
--- @param src number The player server ID.
--- @param key string The metadata key.
--- @param data any The metadata value to set.
--- @return boolean True if the metadata was set successfully, false otherwise.
--- @example return true -- Metadata set successfully
function Player.setMetadata(src, key, data)
   -- Implementing: Set metadata for a specific key
   -- Example: local ply = YourFramework.GetPlayer(src); ply.SetMetaData(key, data); return true
   return false
end

--- Retrieves metadata for a specific key.
--- @param src number The player server ID.
--- @param key string The metadata key.
--- @return any|nil The metadata value, or nil if not found.
--- @example return 100 -- For key = "hunger"
function Player.getMetadata(src, key)
   -- Implementing: Retrieve metadata for a specific key
   -- Example: local ply = YourFramework.GetPlayer(src); return ply.GetMetaData(key)
   return nil
end

--- Jails a player for a specified duration.
--- @param src number The player server ID.
--- @param time number The duration of the jail time in minutes.
--- @param reason string|nil Optional reason for jailing.
--- @return boolean True if the player was jailed successfully, false otherwise.
--- @example return true -- Player jailed
function Player.jail(src, time, reason)
   -- Implementing: Jail the player using the framework's jail system
   -- Example: local ply = YourFramework.GetPlayer(src); YourFramework.JailPlayer(src, time, reason); return true
   return false
end

--- Retrieves the player's money for a specific account.
--- @param src number The player server ID.
--- @param account string The account name (e.g., "bank", "cash").
--- @return number|nil The amount of money in the specified account, or nil if player not found.
--- @example return 500 -- For account = "cash"
function Player.getMoney(src, account)
   -- Implementing: Retrieve money for a specific account
   -- Example: local ply = YourFramework.GetPlayer(src); return ply.GetMoney(account)
   return nil
end

--- Adds money to a player's account.
--- @param src number The player server ID.
--- @param account string The account name (e.g., "bank", "cash").
--- @param amount number The amount of money to add.
--- @param reason string|nil Optional reason for the transaction.
--- @return boolean True if the money was added successfully, false otherwise.
--- @example return true -- Money added
function Player.addMoney(src, account, amount, reason)
   -- Implementing: Add money to the player's account
   -- Example: local ply = YourFramework.GetPlayer(src); ply.AddMoney(account, amount, reason); return true
   return false
end

--- Removes money from a player's account.
--- @param src number The player server ID.
--- @param account string The account name (e.g., "bank", "cash").
--- @param amount number The amount of money to remove.
--- @param reason string|nil Optional reason for the transaction.
--- @param force boolean|nil True to force removal even if funds are insufficient.
--- @return boolean Whether the money was successfully removed.
--- @return string|nil Error code (e.g., "no_account", "insufficient_funds") if removal failed.
--- @example return true -- Money removed
--- @example return false, "insufficient_funds" -- Not enough money
function Player.removeMoney(src, account, amount, reason, force)
   -- Implementing: Remove money from the player's account
   -- Example: local ply = YourFramework.GetPlayer(src); return ply.RemoveMoney(account, amount, reason, force)
   return false, nil
end

--- Sets the money in a player's account.
--- @param src number The player server ID.
--- @param account string The account name (e.g., "bank", "cash").
--- @param amount number The amount of money to set.
--- @return boolean True if the money was set successfully, false otherwise.
--- @example return true -- Money set
function Player.setMoney(src, account, amount)
   -- Implementing: Set the money in the player's account
   -- Example: local ply = YourFramework.GetPlayer(src); ply.SetMoney(account, amount); return true
   return false
end

--- Checks if a player is online by their character ID or server ID.
--- @param identifier string|number The character ID or server ID.
--- @return boolean|string False if the player is offline, or the server ID if online.
--- @example return "1" -- Player is online with server ID 1
--- @example return false -- Player is offline
function Player.checkOnline(identifier)
   -- Implementing: Check if a player is online by identifier or server ID
   -- Example: if type(identifier) == "number" then return YourFramework.GetPlayer(identifier) ~= nil; else check all players
   return false
end

--- Kicks a player from the server.
--- @param src number The player server ID.
--- @param reason string|nil Optional reason for the kick.
--- @return boolean True if the player was kicked successfully, false otherwise.
--- @example return true -- Player kicked
function Player.kick(src, reason)
   -- Implementing: Kick the player from the server
   -- Example: local ply = YourFramework.GetPlayer(src); YourFramework.KickPlayer(src, reason); return true
   return false
end

--- Retrieves the player's gang information (if applicable).
--- @param src number The player server ID.
--- @return table|nil A table containing gang details (name, label, grade, gradeLabel, isBoss), or nil if player not found.
--- @example return { name = "ballas", label = "Ballas Gang", grade = 1, gradeLabel = "Member", isBoss = false }
function Player.getGang(src)
   -- Implementing: Retrieve gang details from the framework or metadata
   -- Example: local ply = YourFramework.GetPlayer(src); local gang = ply.PlayerData.gang; return { name = gang.name, ... }
   return nil
end

--- Sets the player's gang and grade.
--- @param src number The player server ID.
--- @param name string The gang name.
--- @param grade number The gang grade or rank.
--- @return boolean True if the gang was set successfully, false otherwise.
--- @example return true -- Gang set successfully
function Player.setGang(src, name, grade)
   -- Implementing: Set the player's gang and grade
   -- Example: local ply = YourFramework.GetPlayer(src); ply.SetGang(name, grade); return true
   return false
end

--- Adds an item to the player's inventory.
--- @param src number The player server ID.
--- @param item string The item name.
--- @param amount number The amount of the item to add.
--- @param metadata table|nil Optional metadata for the item.
--- @return boolean True if the item was added successfully, false otherwise.
--- @example return true -- Item added
function Player.addItem(src, item, amount, metadata)
   -- Implementing: Add an item to the player's inventory
   -- Example: local ply = YourFramework.GetPlayer(src); ply.AddItem(item, amount, metadata); return true
   return false
end

--- Removes an item from the player's inventory.
--- @param src number The player server ID.
--- @param item string The item name.
--- @param amount number The amount of the item to remove.
--- @return boolean True if the item was removed successfully, false otherwise.
--- @example return true -- Item removed
function Player.removeItem(src, item, amount)
   -- Implementing: Remove an item from the player's inventory
   -- Example: local ply = YourFramework.GetPlayer(src); ply.RemoveItem(item, amount); return true
   return false
end

--- Checks if the player has a specific item in their inventory.
--- @param src number The player server ID.
--- @param item string The item name.
--- @param amount number|nil The minimum amount required (default: 1).
--- @return boolean True if the player has the item and amount, false otherwise.
--- @example return true -- Player has 2 "water" and amount = 1
function Player.hasItem(src, item, amount)
   -- Implementing: Check if the player has the specified item and amount
   -- Example: local ply = YourFramework.GetPlayer(src); return ply.HasItem(item, amount)
   return false
end

--- Retrieves all accounts of the player.
--- @param src number The player server ID.
--- @return table|nil A table of account names and their amounts, or nil if player not found.
--- @example return { cash = 100, bank = 500 } -- Valid return
function Player.getAccounts(src)
   -- Implementing: Retrieve all accounts and their balances
   -- Example: local ply = YourFramework.GetPlayer(src); return ply.GetAccounts()
   return nil
end

--- Bans a player from the server.
--- @param src number The player server ID.
--- @param duration number The duration of the ban in minutes (0 for permanent).
--- @param reason string|nil Optional reason for the ban.
--- @return boolean True if the player was banned successfully, false otherwise.
--- @example return true -- Player banned
function Player.ban(src, duration, reason)
   -- Implementing: Ban the player from the server
   -- Example: local ply = YourFramework.GetPlayer(src); YourFramework.BanPlayer(src, duration, reason); return true
   return false
end

return Player
