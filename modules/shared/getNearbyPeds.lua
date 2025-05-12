-- Retrieves all non-player peds within a specified distance from the given coordinates.
-- @param coords vector3 The coordinates to check from.
-- @param maxDistance? number The maximum distance to consider (defaults to 2.0).
-- @returns { ped: number, coords: vector3 }[] A list of nearby peds with their IDs and coordinates.
function lib.getNearbyPeds(coords, maxDistance)
   local pedPool = GetGamePool('CPed')
   local nearbyPeds = {}
   local pedCount = 0
   local distanceLimit = maxDistance or 2.0

   for _, entity in ipairs(pedPool) do
      if not IsPedAPlayer(entity) then
         local entityPos = GetEntityCoords(entity)
         local dist = #(coords - entityPos)

         if dist < distanceLimit then
            pedCount = pedCount + 1
            nearbyPeds[pedCount] = {
               ped = entity,
               coords = entityPos
            }
         end
      end
   end

   return nearbyPeds
end

return lib.getNearbyPeds
