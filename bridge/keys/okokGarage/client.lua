
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
