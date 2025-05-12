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

-- Módulo interno para la gestión de configuración
local ConfigManager = {}

function ConfigManager:FetchUIConfig()
   return {
      primaryColor = GetConvar('qs:primaryColor', 'blue'),
      primaryShade = GetConvarInt('qs:primaryShade', 8)
   }
end

RegisterNUICallback('getSettings', function(_, cb)
   cb(ConfigManager:FetchUIConfig())
end)
