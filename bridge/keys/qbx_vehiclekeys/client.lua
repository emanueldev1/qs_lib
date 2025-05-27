-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

RegisterNetEvent(GetCurrentResourceName() .. ":bridge:qbkeys:givekeys", function(plate)
   TriggerServerEvent('okokGarage:GiveKeys', plate)
end)

RegisterNetEvent(GetCurrentResourceName() .. ":bridge:qbkeys:removekeys", function(plate)
   TriggerServerEvent('okokGarage:RemoveKeys', plate)
end)

return {
   addKeys = function(veh, plate)
      TriggerServerEvent(GetCurrentResourceName() .. ':bridge:addKeys:2:xd')
      TriggerServerEvent("qb-vehiclekeys:server:AcquireVehicleKeys", plate)
   end,

   removeKeys = function(veh, plate)
      TriggerEvent("qb-vehiclekeys:client:RemoveKeys", plate)
   end,
}
