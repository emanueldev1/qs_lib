-- Módulo interno para la gestión de propiedades del state bag
local StateBagUtils = {}

-- Función auxiliar para establecer propiedades en el state bag
function StateBagUtils:StoreVehicleProperties(entity, properties)
   if not DoesEntityExist(entity) then
      return false
   end
   local entityState = Entity(entity).state
   entityState:set('qs_lib:setVehicleProperties', properties, true)
   return true
end

---@param vehicle number
---@param props VehicleProperties
---@diagnostic disable-next-line: duplicate-set-field
function lib.setVehicleProperties(vehicle, props)
   StateBagUtils:StoreVehicleProperties(vehicle, props)
end

-- //TODO: TEST PENDING
