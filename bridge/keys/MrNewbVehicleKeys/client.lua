-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

RegisterNetEvent(GetCurrentResourceName() .. ":bridge:mrnewvehiclekeys:givekeys", function(plate)
   exports.MrNewbVehicleKeys:GiveKeysByPlate(plate)
end)

RegisterNetEvent(GetCurrentResourceName() .. ":bridge:mrnewvehiclekeys:removekeys", function(plate)
   exports.MrNewbVehicleKeys:RemoveKeysByPlate(plate)
end)


return {
   addKeys = function(veh, plate)
      return exports.MrNewbVehicleKeys:GiveKeysByPlate(plate)
   end,

   removeKeys = function(veh, plate)
      return exports.MrNewbVehicleKeys:RemoveKeysByPlate(plate)
   end,
}
