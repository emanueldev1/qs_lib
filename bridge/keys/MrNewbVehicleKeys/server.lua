return {
   addKeys = function(src, veh, plate)
      TriggerClientEvent(GetCurrentResourceName() .. ":bridge:mrnewvehiclekeys:givekeys", src, plate)
   end,

   removeKeys = function(src, veh, plate)
      TriggerClientEvent(GetCurrentResourceName() .. ":bridge:mrnewvehiclekeys:removekeys", src, plate)
   end,
}
