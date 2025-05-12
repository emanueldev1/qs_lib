-- Retrieves all objects within a specified distance from the given coordinates.
-- @param coords vector3 The coordinates to check from.
-- @param maxDistance? number The maximum distance to consider (defaults to 2.0).
-- @returns { object: number, coords: vector3 }[] A list of nearby objects with their IDs and coordinates.
function lib.getNearbyObjects(coords, maxDistance)
   local objectPool = GetGamePool('CObject')
   local nearbyObjects = {}
   local nearbyCount = 0
   local distanceLimit = maxDistance or 2.0

   for _, entity in ipairs(objectPool) do
      local entityPos = GetEntityCoords(entity)
      local dist = #(coords - entityPos)

      if dist < distanceLimit then
         nearbyCount = nearbyCount + 1
         nearbyObjects[nearbyCount] = {
            object = entity,
            coords = entityPos
         }
      end
   end

   return nearbyObjects
end

return lib.getNearbyObjects
