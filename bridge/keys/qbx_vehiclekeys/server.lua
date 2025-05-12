return {
   addKeys = function(src, veh, plate)
      TriggerServerEvent(GetCurrentResourceName() .. ":bridge:qbkeys:givekeys", src, plate)
   end,

   removeKeys = function(src, veh, plate)
      TriggerServerEvent(GetCurrentResourceName() .. ":bridge:qbkeys:removekeys", src, plate)
   end,
}
