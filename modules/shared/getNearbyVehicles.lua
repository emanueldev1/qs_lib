-- Retrieves all vehicles within a specified distance from the given coordinates.
-- @param coords vector3 The coordinates to check from.
-- @param maxDistance? number The maximum distance to consider (defaults to 2.0).
-- @param includePlayerVehicle? boolean Whether to include the player's current vehicle (ignored on server).
-- @returns { vehicle: number, coords: vector3 }[] A list of nearby vehicles with their IDs and coordinates.
function lib.getNearbyVehicles(coords, maxDistance, includePlayerVehicle)
   local vehiclePool = GetGamePool('CVehicle')
   local nearbyVehicles = {}
   local vehicleCount = 0
   local distanceLimit = maxDistance or 2.0

   for _, entity in ipairs(vehiclePool) do
      if lib.context == 'server' or includePlayerVehicle or entity ~= cache.vehicle then
         local entityPos = GetEntityCoords(entity)
         local dist = #(coords - entityPos)

         if dist < distanceLimit then
            vehicleCount = vehicleCount + 1
            nearbyVehicles[vehicleCount] = {
               vehicle = entity,
               coords = entityPos
            }
         end
      end
   end

   return nearbyVehicles
end

return lib.getNearbyVehicles
