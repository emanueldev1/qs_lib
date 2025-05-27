-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

RegisterNetEvent(GetCurrentResourceName() .. ":bridge:okokGarage:givekeys", function(plate)
   exports.okokGarage:GiveKeysByPlate(plate)
end)

return {
   addKeys = function(veh, plate)
      TriggerServerEvent('okokGarage:GiveKeys', plate)
   end,

   removeKeys = function(veh, plate)
      lib.print.warn('This function is not available on okokGarage')
   end,
}
