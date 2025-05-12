local keys = lib.loadBridge('keys', lib.bridge.keys, 'server')
local fuel = lib.loadBridge('fuel', lib.bridge.fuel, 'server')

lib.vehicle.addKeys = function(src, veh, plate)
   if not keys.addKeys then return lib.print.error(('No bridge found for adding keys for %s'):format(lib.bridge.keys)) end
   return keys.addKeys(src, veh, plate)
end

lib.vehicle.removeKeys = function(src, veh, plate)
   if not keys.removeKeys then return lib.print.error(('No bridge found for removing keys for %s'):format(lib.bridge.keys)) end
   return keys.removeKeys(src, veh, plate)
end

lib.vehicle.setFuel = function(veh, val, _type)
   if not fuel.setFuel then return lib.print.error(('No bridge found for setting fuel for %s'):format(lib.bridge.fuel)) end
   return fuel.setFuel(veh, val, _type)
end

lib.vehicle.getFuel = function(veh)
   if not fuel.getFuel then return lib.print.error(('No bridge found for getting fuel for %s'):format(lib.bridge.fuel)) end
   return fuel.getFuel(veh)
end

return lib.vehicle
