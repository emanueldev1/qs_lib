return {
   addKeys = function(veh, plate)
      local model = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
      exports['qs-vehiclekeys']:GiveKeys(plate, model, true)
   end,

   removeKeys = function(veh, plate)
      local model = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
      exports['qs-vehiclekeys']:RemoveKeys(plate, model)
   end,
}
