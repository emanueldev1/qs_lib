local noSideAvailable = {
   __index = function(t, k)
      lib.print.warn('the library do not have functions for fuel on server side, please use the client side')
      return function()
         return {}
      end
   end,
}

return noSideAvailable
