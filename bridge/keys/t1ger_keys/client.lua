-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

return {
   addKeys = function(veh, plate)
      local vehicle_display_name = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
      return exports['t1ger_keys']:GiveTemporaryKeys(plate, vehicle_display_name, 'some_keys')
   end,

   removeKeys = function(veh, plate)

   end,
}
