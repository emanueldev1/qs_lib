-- Finds the closest non-player ped to the specified coordinates.
-- @param coords vector3 The coordinates to check from.
-- @param maxDistance? number The maximum distance to consider (defaults to 2.0).
-- @returns number? The closest ped, if found.
-- @returns vector3? The coordinates of the closest ped, if found.
function lib.getClosestPed(coords, maxDistance)
   local pedPool = GetGamePool('CPed')
   local nearestPed = nil
   local nearestPosition = nil
   local currentLimit = maxDistance or 2.0

   for _, entity in ipairs(pedPool) do
      if not IsPedAPlayer(entity) then
         local entityPos = GetEntityCoords(entity)
         local dist = #(coords - entityPos)

         if dist < currentLimit then
            currentLimit = dist
            nearestPed = entity
            nearestPosition = entityPos
         end
      end
   end

   return nearestPed, nearestPosition
end

return lib.getClosestPed
