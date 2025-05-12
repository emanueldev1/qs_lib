return {
   addKeys = function(src, veh, plate)
      local nvmodel = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
      exports['qs-vehiclekeys']:GiveServerKeys(src, plate, nvmodel)
   end,

   removeKeys = function(src, veh, plate)
      local nvmodel = GetDisplayNameFromVehicleModel(GetEntityModel(veh))

      exports['qs-vehiclekeys']:RemoveServerKeys(src, plate, nvmodel)
   end,
}
