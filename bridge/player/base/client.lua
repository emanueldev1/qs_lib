--- Player management library template for FiveM frameworks.
--- This module defines a standardized interface for accessing player-related data on the client side in FiveM.
--- It is designed to be implemented for specific frameworks (e.g., ESX, QBCore, QBXCore) to provide a consistent API for scripts.
--- Developers should implement each function to retrieve data from their framework's player data structure, ensuring the specified return formats and types.
--- The functions cover essential player information such as identity, inventory, job, and status, enabling cross-framework compatibility for roleplay scripts.
--- @module player

local Player = {}

--- Retrieves the player's unique identifier.
--- @return string|nil The player's identifier (e.g., "license:abc123" or "citizenid123"), or nil if not available.
--- @example return "license:abc123" -- ESX example
--- @example return "citizenid123" -- QBCore/QBXCore example
function Player.identifier()
   --.Concurrent: Accessing the framework's player data to retrieve the unique identifier
   -- Example: return YourFramework.PlayerData.identifier
   return nil
end

--- Retrieves the player's first and last name.
--- @return string|nil The player's first name, or nil if not available.
--- @return string|nil The player's last name, or nil if not available.
--- @example return "John", "Doe" -- Valid return
--- @example return nil, nil -- If name is not available
function Player.name()
   -- Implementing: Extract first and last name from the framework's character info
   -- Example: return YourFramework.PlayerData.firstName, YourFramework.PlayerData.lastName
   return nil, nil
end

--- Retrieves the player's username.
--- @return string|nil The player's username, or nil if not available.
--- @example return "Knoblauchbrot" -- Valid return
function Player.getUsername()
   -- Implementing: Retrieve the username or account name from the framework
   -- Example: return YourFramework.PlayerData.name
   return nil
end

--- Retrieves the player's date of birth.
--- @return string|nil The player's date of birth (e.g., "01/01/2000"), or nil if not available.
--- @example return "01/01/2000" -- Valid return
function Player.getBirth()
   -- Implementing: Access the date of birth from character info or metadata
   -- Example: return YourFramework.PlayerData.dateofbirth
   return nil
end

--- Retrieves the player's height.
--- @return number|nil The player's height in cm (e.g., 181), or nil if not available.
--- @example return 181 -- Valid return
function Player.getHeight()
   -- Implementing: Retrieve height from character info or metadata
   -- Example: return YourFramework.PlayerData.height
   return nil
end

--- Retrieves the player's sex.
--- @return number|nil The player's sex (0 for male, 1 for female), or nil if not available.
--- @example return 0 -- Male
--- @example return 1 -- Female
function Player.getSex()
   -- Implementing: Access sex or gender from character info or metadata
   -- Example: return YourFramework.PlayerData.sex
   return nil
end

--- Retrieves the player's license.
--- @return string|nil The player's license (e.g., "license:abc123"), or nil if not available.
--- @example return "license:abc123" -- Valid return
function Player.getLicense()
   -- Implementing: Retrieve the license or secondary identifier from the framework
   -- Example: return YourFramework.PlayerData.license
   return nil
end

--- Retrieves the player's permission group.
--- @return string|nil The player's group (e.g., "user", "admin"), or nil if not available.
--- @example return "user" -- Valid return
function Player.getGroup()
   -- Implementing: Access the permission group from the framework
   -- Example: return YourFramework.PlayerData.group
   return nil
end

--- Checks if the player is an admin.
--- @return boolean True if the player is an admin, false otherwise.
--- @example return true -- Player is admin
--- @example return false -- Player is not admin
function Player.isAdmin()
   -- Implementing: Check admin status from the framework's player data
   -- Example: return YourFramework.PlayerData.admin
   return false
end

--- Checks if the player is dead.
--- @return boolean True if the player is dead, false otherwise.
--- @example return true -- Player is dead
--- @example return false -- Player is alive
function Player.isDead()
   -- Implementing: Check death status from the framework's player data
   -- Example: return YourFramework.PlayerData.dead
   return false
end

--- Retrieves the current weight of the player's inventory.
--- @return number The current inventory weight (e.g., 12), or 0 if not available.
--- @example return 12 -- Valid return
function Player.getWeight()
   -- Implementing: Retrieve current inventory weight from the framework
   -- Example: return YourFramework.PlayerData.weight
   return 0
end

--- Retrieves the maximum weight of the player's inventory.
--- @return number The maximum inventory weight (e.g., 24), or 0 if not available.
--- @example return 24 -- Valid return
function Player.getMaxWeight()
   -- Implementing: Retrieve maximum inventory weight from the framework
   -- Example: return YourFramework.PlayerData.maxWeight
   return 0
end

--- Retrieves the player's ped ID.
--- @return number The player's ped ID, or 0 if not available.
--- @example return 123 -- Valid ped ID
function Player.getPed()
   -- Implementing: Retrieve the ped ID from the framework or native functions
   -- Example: return YourFramework.PlayerData.ped or GetPlayerPed(-1)
   return 0
end

--- Retrieves the player's ID.
--- @return number The player's ID (e.g., 1), or 0 if not available.
--- @example return 1 -- Valid player ID
function Player.getPlayerId()
   -- Implementing: Retrieve the player ID from the framework
   -- Example: return YourFramework.PlayerData.playerId
   return 0
end

--- Retrieves the player's server source ID.
--- @return number The player's source ID (e.g., 1), or 0 if not available.
--- @example return 1 -- Valid source ID
function Player.getSource()
   -- Implementing: Retrieve the server source ID from the framework
   -- Example: return YourFramework.PlayerData.source
   return 0
end

--- Retrieves the player's data or a specific key from it.
--- @param _key string|nil Optional key to retrieve specific data.
--- @return table|any The player's data or the value of the specified key, or nil if not available.
--- @example return { job = { name = "police" }, money = { cash = 100 } } -- Full data
--- @example return { name = "police" } -- For _key = "job"
function Player.getPlayerData(_key)
   -- Implementing: Access the full player data or a specific key
   -- Example: local data = YourFramework.PlayerData; return _key and data[_key] or data
   return nil
end

--- Retrieves player metadata or a specific key from it.
--- @param _key string|nil Optional key to retrieve specific metadata.
--- @return table|any The player's metadata or the value of the specified key, or nil if not available.
--- @example return { hunger = 100, thirst = 50 } -- Full metadata
--- @example return 100 -- For _key = "hunger"
function Player.getMetadata(_key)
   -- Implementing: Access metadata from the framework's player data
   -- Example: local metadata = YourFramework.PlayerData.metadata; return _key and metadata[_key] or metadata
   return nil
end

--- Retrieves the player's inventory.
--- @return table The player's inventory items, or an empty table if not available.
--- @example return { { name = "water", count = 2 }, { name = "bread", count = 1 } }
function Player.getInventory()
   -- Implementing: Retrieve the inventory items from the framework
   -- Example: return YourFramework.PlayerData.inventory or {}
   return {}
end

--- Retrieves the player's money for a specific account.
--- @param _account string The account name (e.g., "bank", "cash").
--- @return number The amount of money in the specified account, or 0 if not found.
--- @example return 500 -- For _account = "cash"
function Player.getMoney(_account)
   -- Implementing: Retrieve money for a specific account
   -- Example: return YourFramework.PlayerData.money[_account] or 0
   return 0
end

--- Retrieves the player's job information.
--- @return table A table containing job details (name, type, label, grade, gradeLabel, isBoss, bankAuth, duty).
--- @example return { name = "police", type = "leo", label = "Police Officer", grade = 2, gradeLabel = "Sergeant", isBoss = false, bankAuth = true, duty = true }
function Player.getJob()
   -- Implementing: Retrieve job details from the framework
   -- Example: local job = YourFramework.PlayerData.job; return { name = job.name, ... }
   return {
      name       = '',
      type       = '',
      label      = '',
      grade      = 0,
      gradeLabel = '',
      isBoss     = false,
      bankAuth   = false,
      duty       = false
   }
end

--- Shows a notification to the player.
--- @param message string The notification message.
--- @param type string|nil The notification type (e.g., "success", "error", "info").
--- @param duration number|nil Duration in milliseconds (optional).
--- @return nil
--- @example Player.notify("You received $100!", "success", 5000)
function Player.notify(message, type, duration)
   -- Implementing: Display a notification using the framework's notification system
   -- Example: YourFramework.ShowNotification(message, type, duration)
end

--- Retrieves the player's current coordinates.
--- @return table A table with x, y, z coordinates.
--- @example return { x = 100.0, y = 200.0, z = 30.0 }
function Player.getCoords()
   -- Implementing: Retrieve the player's coordinates from the framework
   -- Example: return YourFramework.PlayerData.coords or { x = 0.0, y = 0.0, z = 0.0 }
   return { x = 0.0, y = 0.0, z = 0.0 }
end

--- Retrieves the player's gang information (if applicable).
--- @return table A table containing gang details (name, label, grade, gradeLabel, isBoss).
--- @example return { name = "ballas", label = "Ballas Gang", grade = 1, gradeLabel = "Member", isBoss = false }
function Player.getGang()
   -- Implementing: Retrieve gang details from the framework or metadata
   -- Example: local gang = YourFramework.PlayerData.gang; return { name = gang.name, ... }
   return {
      name       = '',
      label      = '',
      grade      = 0,
      gradeLabel = '',
      isBoss     = false
   }
end

--- Checks if the player has a specific item in their inventory.
--- @param item string The item name.
--- @param amount number|nil The minimum amount required (default: 1).
--- @return boolean True if the player has the item and amount, false otherwise.
--- @example return true -- If player has 2 "water" and amount = 1
function Player.hasItem(item, amount)
   -- Implementing: Check if the player has the specified item and amount in inventory
   -- Example: local items = YourFramework.PlayerData.inventory; check if item exists with amount
   return false
end

return Player
