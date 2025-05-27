-- This file contains code adapted from ox_lib, developed by the Overextended team.
-- Original repository: https://github.com/overextended/ox_lib
-- License: GNU Lesser General Public License v3.0 (LGPL-3.0), available at https://www.gnu.org/licenses/lgpl-3.0.html
-- Modifications by emanueldev1 for the qs_lib project, licensed under LGPL-3.0.

local _registerCommand = RegisterCommand

-- Módulo interno para la gestión de comandos
local CommandManager = {}

function CommandManager:VerifyAccess(source, command, restricted)
   if not restricted then
      return true
   end
   local permission = string.format('command.%s', command)
   return lib.callback.await('qs_lib:checkPlayerAce', 100, permission)
end

function CommandManager:RegisterSecureCommand(name, handler, restricted)
   _registerCommand(name, function(src, arguments, rawInput)
      if self:VerifyAccess(src, name, restricted) then
         handler(src, arguments, rawInput)
      end
   end)
end

---@param commandName string
---@param callback fun(source, args, raw)
---@param restricted boolean?
function RegisterCommand(commandName, callback, restricted)
   CommandManager:RegisterSecureCommand(commandName, callback, restricted)
end
