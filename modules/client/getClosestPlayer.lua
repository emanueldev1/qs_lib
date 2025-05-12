-- getClosestPlayer.lua: Finds the closest active player to a given set of coordinates in FiveM.
-- This module evaluates active players, calculates their distance from the provided coordinates,
-- and returns the closest player's ID, ped, and coordinates, respecting distance and inclusion rules.

---@param coords vector3 The coords to check from.
---@param maxDistance? number The max distance to check.
---@param includePlayer? boolean Whether or not to include the current player.
---@return number? playerId
---@return number? playerPed
---@return vector3? playerCoords
function lib.getClosestPlayer(coords, maxDistance, includePlayer)
   -- Set default maximum distance if not provided
   local searchRadius = maxDistance or 2.2

   -- Retrieve all active players in the session
   local activePlayers = GetActivePlayers()
   local closestCandidate = nil
   local shortestDistance = searchRadius

   -- Helper function to calculate distance between two 3D points
   ---@param pointA vector3
   ---@param pointB vector3
   ---@return number
   local function calculateDistance(pointA, pointB)
      local delta = pointA - pointB
      return math.sqrt(delta.x * delta.x + delta.y * delta.y + delta.z * delta.z)
   end

   -- Helper function to check if a player should be considered
   ---@param playerId number
   ---@return boolean
   local function shouldConsiderPlayer(playerId)
      return includePlayer or playerId ~= cache.playerId
   end

   -- Iterate through active players to find the closest one
   for _, playerId in ipairs(activePlayers) do
      if shouldConsiderPlayer(playerId) then
         local ped = GetPlayerPed(playerId)
         local playerPos = GetEntityCoords(ped)
         local distance = calculateDistance(coords, playerPos)

         if distance < shortestDistance then
            shortestDistance = distance
            closestCandidate = {
               id = playerId,
               ped = ped,
               coords = playerPos
            }
         end
      end
   end

   -- Return the closest player's details or nil if none found
   if closestCandidate then
      return closestCandidate.id, closestCandidate.ped, closestCandidate.coords
   end
   return nil, nil, nil
end
