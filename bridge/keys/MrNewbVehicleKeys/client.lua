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
