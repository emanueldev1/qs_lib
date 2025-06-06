-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

local TebexHooks  = {}
local TebexHook   = {}
TebexHook.__index = TebexHook

function TebexHook:__init()
   assert(self.id, 'TebexHook requires an id')
   assert(self.label, 'TebexHook requires a label')

   local commands = {
      onPurchase = 'purchase_%s',
      onRemove   = 'remove_%s',
      onRenew    = 'renew_%s'
   }

   for _type, command in pairs(commands) do
      if self[_type] then
         RegisterCommand(string.format(command, self.id), function(src, args, raw)
            local src = src
            if src ~= 0 then return end
            local cfxId = args[1]
            if not cfxId or cfxId == 0 then return end
            self[_type](cfxId, args)
         end, true)
      end
   end

   return true
end

TebexHook.register = function(data)
   local self = setmetatable(data, TebexHook)
   local init, reason = self:__init()
   if not init then
      print('Failed to initialize TebexHook: ' .. reason)
      return
   end
   TebexHooks[self.id] = self
   return self
end

lib.registerTebexHook = TebexHook.register

return lib.registerTebexHook

-- USEAGE
-- lib.registerTebexHook({
--   id = 'vip',
--   label = 'VIP',

--   onPurchase = function(args)

--   end,

--   onRemove = function(args)

--   end,

--   onRenew = function(args)

--   end
-- })
