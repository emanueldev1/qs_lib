-- This file contains code adapted from ox_lib, developed by the Overextended team.
-- Original repository: https://github.com/overextended/ox_lib
-- License: GNU Lesser General Public License v3.0 (LGPL-3.0), available at https://www.gnu.org/licenses/lgpl-3.0.html
-- Modifications by emanueldev1 for the qs_lib project, licensed under LGPL-3.0.

-- addCommand.lua: Registers server-side commands in FiveM with support for permissions and argument parsing.
-- This module enables the creation of commands with custom properties, handling backward compatibility and chat suggestions.

---@class QsCommandParams
---@field name string
---@field help? string
---@field type? 'number' | 'playerId' | 'string' | 'longString'
---@field optional? boolean

---@class QsCommandProperties
---@field help string?
---@field params QsCommandParams[]?
---@field restricted boolean | string | string[]?

---@type QsCommandProperties[]
local commandList = {}
local sendSuggestions = false

SetTimeout(1200, function()
   sendSuggestions = true
   TriggerClientEvent('chat:addSuggestions', -1, commandList)
end)

AddEventHandler('playerJoining', function()
   TriggerClientEvent('chat:addSuggestions', source, commandList)
end)

-- Parses command arguments based on parameter definitions.
---@param playerSrc number
---@param cmdArgs table
---@param rawCmd string
---@param cmdParams QsCommandParams[]?
---@return table?
local function processArguments(playerSrc, cmdArgs, rawCmd, cmdParams)
   if not cmdParams then return cmdArgs end

   local paramCount = #cmdParams
   for i = 1, paramCount do
      local arg, param = cmdArgs[i], cmdParams[i]
      local parsedValue

      if param.type == 'number' then
         parsedValue = tonumber(arg)
      elseif param.type == 'string' then
         parsedValue = not tonumber(arg) and arg
      elseif param.type == 'playerId' then
         parsedValue = arg == 'me' and playerSrc or tonumber(arg)
         if not parsedValue or not DoesPlayerExist(parsedValue --[[@as string]]) then
            parsedValue = false
         end
      elseif param.type == 'longString' and i == paramCount then
         if arg then
            local startPos = rawCmd:find(arg, 1, true)
            parsedValue = startPos and rawCmd:sub(startPos)
         else
            parsedValue = nil
         end
      else
         parsedValue = arg
      end

      if not parsedValue and (not param.optional or param.optional and arg) then
         return Citizen.Trace(string.format("^1Invalid %s for argument %s (%s) in command '%s', got '%s'^0\n", param.type, i, param.name, string.strsplit(' ', rawCmd) or rawCmd, arg))
      end

      arg = parsedValue
      cmdArgs[param.name] = arg
      cmdArgs[i] = nil
   end

   return cmdArgs
end

-- Registers a command and handles permissions.
---@param cmdNames string | string[]
---@param props QsCommandProperties | false
---@param callback fun(source: number, args: table, raw: string)
---@param ... any
function lib.addCommand(cmdNames, props, callback, ...)
   -- Handle backward compatibility
   local accessRestricted, argParams

   if props then
      accessRestricted = props.restricted
      argParams = props.params
   end

   if argParams then
      for i = 1, #argParams do
         local param = argParams[i]
         if param.type then
            param.help = param.help and string.format("%s (type: %s)", param.help, param.type) or string.format("(type: %s)", param.type)
         end
      end
   end

   local commandSet = type(cmdNames) ~= 'table' and { cmdNames } or cmdNames
   local commandCount = #commandSet
   local registeredCount = #commandList

   local function executeCommand(source, args, raw)
      local processedArgs = processArguments(source, args, raw, argParams)
      if not processedArgs then return end

      local success, result = pcall(callback, source, processedArgs, raw)
      if not success then
         Citizen.Trace(string.format("^1Error executing command '%s':\n%s^0", string.strsplit(' ', raw) or raw, result))
      end
   end

   for i = 1, commandCount do
      registeredCount = registeredCount + 1
      cmdNames = commandSet[i]

      RegisterCommand(cmdNames, executeCommand, accessRestricted and true)

      if accessRestricted then
         local acePermission = string.format("command.%s", cmdNames)
         local restrictedType = type(accessRestricted)

         if restrictedType == 'string' and not IsPrincipalAceAllowed(accessRestricted, acePermission) then
            lib.addAce(accessRestricted, acePermission)
         elseif restrictedType == 'table' then
            for j = 1, #accessRestricted do
               if not IsPrincipalAceAllowed(accessRestricted[j], acePermission) then
                  lib.addAce(accessRestricted[j], acePermission)
               end
            end
         end
      end

      if props then
         ---@diagnostic disable-next-line: inject-field
         props.name = string.format("/%s", cmdNames)
         props.restricted = nil
         commandList[registeredCount] = props

         if i ~= commandCount and commandCount ~= 1 then
            props = table.clone(props)
         end

         if sendSuggestions then TriggerClientEvent('chat:addSuggestions', -1, props) end
      end
   end
end

return lib.addCommand
