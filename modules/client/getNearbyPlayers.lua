-- getNearbyPlayers.lua: Retrieves a list of players within a specified radius of given coordinates in FiveM.
-- This module scans active players, calculates their distance from the provided coordinates, and returns
-- an array of nearby players' details, respecting distance limits and player inclusion rules.

---@param coords vector3 The coords to check from.
---@param maxDistance? number The max distance to check.
---@param includePlayer? boolean Whether or not to include the current player.
---@return { id: number, ped: number, coords: vector3 }[]
function lib.getNearbyPlayers(coords, maxDistance, includePlayer)
   -- Set default search radius if not specified
   local radius = maxDistance or 2.0
   local nearbyPlayers = {}

   -- Helper function to compute the Euclidean distance between two 3D points
   ---@param pointA vector3
   ---@param pointB vector3
   ---@return number
   local function computeDistance(pointA, pointB)
      local diff = pointA - pointB
      return math.sqrt(diff.x ^ 2 + diff.y ^ 2 + diff.z ^ 2)
   end

   -- Helper function to determine if a player should be included in the search
   ---@param playerId number
   ---@return boolean
   local function isPlayerEligible(playerId)
      return includePlayer or playerId ~= cache.playerId
   end

   -- Helper function to gather player data
   ---@param playerId number
   ---@return table
   local function collectPlayerData(playerId)
      local ped = GetPlayerPed(playerId)
      local position = GetEntityCoords(ped)
      return {
         id = playerId,
         ped = ped,
         coords = position
      }
   end

   -- Retrieve all active players in the session
   local allPlayers = GetActivePlayers()

   -- Iterate through active players to identify those within the radius
   for _, playerId in ipairs(allPlayers) do
      if isPlayerEligible(playerId) then
         local playerData = collectPlayerData(playerId)
         local distance = computeDistance(coords, playerData.coords)

         if distance < radius then
            table.insert(nearbyPlayers, playerData)
         end
      end
   end

   -- Return the list of nearby players
   return nearbyPlayers
end

return lib.getNearbyPlayers
