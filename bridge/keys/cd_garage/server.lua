return {
   addKeys = function(src, veh, plate)
      TriggerClientEvent('cd_garage:AddKeys', src, plate)
   end,

   removeKeys = function(src, veh, plate)
      lib.print.warn('This function is not available on cd_garage')
   end,
}
