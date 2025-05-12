-- getClosestPlayer.lua: Finds the closest active player to specified coordinates in FiveM.
-- This module efficiently scans active players, calculates squared distances, and excludes the local player.

---@param coords vector3 The coords to check from.
---@param maxDistance? number The max distance to check.
---@return number? playerId
---@return number? playerPed
---@return vector3? playerCoords
function lib.getClosestPlayer(coords, maxDistance)
   local activePlayers = GetActivePlayers()
   local closestId, closestPed, closestPos
   local searchRangeSquared = (maxDistance or 1.5) ^ 2

   for i = 1, #activePlayers do
      local playerId = activePlayers[i]
      if playerId ~= cache.playerId then -- Exclude the local player
         local playerPed = GetPlayerPed(playerId)
         local playerPos = GetEntityCoords(playerPed)
         local delta = coords - playerPos
         local distSquared = delta.x ^ 2 + delta.y ^ 2 + delta.z ^ 2

         if distSquared < searchRangeSquared then
            searchRangeSquared = distSquared
            closestId = playerId
            closestPed = playerPed
            closestPos = playerPos
         end
      end
   end

   return closestId, closestPed, closestPos
end

return lib.getClosestPlayer
