-- Finds the closest vehicle to the specified coordinates.
-- @param coords vector3 The coordinates to check from.
-- @param maxDistance? number The maximum distance to consider (defaults to 2.0).
-- @param includePlayerVehicle? boolean Whether to include the player's current vehicle (ignored on the server).
-- @returns number? The closest vehicle, if found.
-- @returns vector3? The coordinates of the closest vehicle, if found.
function lib.getClosestVehicle(coords, maxDistance, includePlayerVehicle)
   local vehiclePool = GetGamePool('CVehicle')
   local nearestVehicle = nil
   local nearestPosition = nil
   local currentLimit = maxDistance or 2.0

   for _, entity in ipairs(vehiclePool) do
      if lib.context == 'server' or includePlayerVehicle or entity ~= cache.vehicle then
         local entityPos = GetEntityCoords(entity)
         local dist = #(coords - entityPos)

         if dist < currentLimit then
            currentLimit = dist
            nearestVehicle = entity
            nearestPosition = entityPos
         end
      end
   end

   return nearestVehicle, nearestPosition
end

return lib.getClosestVehicle
