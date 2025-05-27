-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

return {
   addKeys = function(veh, plate)
      return exports['Renewed-Vehiclekeys']:addKey(plate) -- Adds a key to the specified player
   end,

   removeKeys = function(veh, plate)
      return exports['Renewed-Vehiclekeys']:removeKey(plate) -- Removes a key from the specified player
   end,
}
