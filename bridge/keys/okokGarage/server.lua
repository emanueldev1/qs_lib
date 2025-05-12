return {
   addKeys = function(src, veh, plate)
      TriggerClientEvent(GetCurrentResourceName() .. ":bridge:mrnewvehiclekeys:givekeys", src, plate)
   end,

   removeKeys = function(src, veh, plate)
      lib.print.warn('This function is not available on okokGarage')
   end,
}
