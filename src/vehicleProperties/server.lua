-- This file contains code adapted from ox_lib, developed by the Overextended team.
-- Original repository: https://github.com/overextended/ox_lib
-- License: GNU Lesser General Public License v3.0 (LGPL-3.0), available at https://www.gnu.org/licenses/lgpl-3.0.html
-- Modifications by emanueldev1 for the qs_lib project, licensed under LGPL-3.0.

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
