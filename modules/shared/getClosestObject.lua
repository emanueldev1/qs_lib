-- Finds the closest object to the specified coordinates.
-- @param coords vector3 The coordinates to check from.
-- @param maxDistance? number The maximum distance to consider (defaults to 2.0).
-- @returns number? The closest object, if found.
-- @returns vector3? The coordinates of the closest object, if found.
function lib.getClosestObject(coords, maxDistance)
   local objectPool = GetGamePool('CObject')
   local closestEntity = nil
   local closestPosition = nil
   local currentLimit = maxDistance or 2.0

   for _, entity in ipairs(objectPool) do
      local entityPos = GetEntityCoords(entity)
      local dist = #(coords - entityPos)

      if dist < currentLimit then
         currentLimit = dist
         closestEntity = entity
         closestPosition = entityPos
      end
   end

   return closestEntity, closestPosition
end

return lib.getClosestObject
