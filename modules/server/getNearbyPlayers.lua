-- getNearbyPlayers.lua: Retrieves players within a specified radius of given coordinates in FiveM.
-- This module scans active players and returns those within the defined distance.

-- Calculates the Euclidean distance between two 3D points.
---@param pointA vector3
---@param pointB vector3
---@return number
local function computeDistance(pointA, pointB)
   local diff = pointA - pointB
   return math.sqrt(diff.x ^ 2 + diff.y ^ 2 + diff.z ^ 2)
end

---@param coords vector3 The coords to check from.
---@param maxDistance? number The max distance to check.
---@return { id: number, ped: number, coords: vector3 }[]
function lib.getNearbyPlayers(coords, maxDistance)
   local activePlayers = GetActivePlayers()
   local nearbyPlayers = {}
   local playerCount = 0
   local rangeLimit = maxDistance or 1.8

   for i = 1, #activePlayers do
      local playerId = activePlayers[i]
      local playerPed = GetPlayerPed(playerId)
      local playerPos = GetEntityCoords(playerPed)
      local dist = computeDistance(coords, playerPos)

      if dist < rangeLimit then
         playerCount = playerCount + 1
         nearbyPlayers[playerCount] = {
            id = playerId,
            ped = playerPed,
            coords = playerPos,
         }
      end
   end

   return nearbyPlayers
end

return lib.getNearbyPlayers
