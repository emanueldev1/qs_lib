return {
   addKeys = function(src, veh, plate)
      exports['Renewed-Vehiclekeys']:addKey(src, plate)
   end,

   removeKeys = function(src, veh, plate)
      exports['Renewed-Vehiclekeys']:removeKey(src, plate)
   end,
}
