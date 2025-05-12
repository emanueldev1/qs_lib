-- callback.lua: Manages client-server callback communication in FiveM.
-- This module facilitates asynchronous event triggering and response handling between server and clients.

local activeCallbacks = {}
local callbackEvent = '__qs_cb_%s'
local timeoutDuration = GetConvarInt('qs:callbackTimeout', 280000)

RegisterNetEvent(callbackEvent:format(cache.resource), function(callbackKey, ...)
   local callbackFunc = activeCallbacks[callbackKey]
   if not callbackFunc then return end

   activeCallbacks[callbackKey] = nil
   callbackFunc(...)
end)

-- Triggers a client callback and handles the response.
---@param _ any
---@param evtName string
---@param clientId number
---@param callback function|false
---@param ... any
---@return ...
local function sendClientCallback(_, evtName, clientId, callback, ...)
   assert(DoesPlayerExist(clientId --[[@as string]]), string.format("Client ID '%s' does not exist", clientId))

   local uniqueKey
   repeat
      uniqueKey = string.format("%s:%s:%s", evtName, math.random(0, 100000), clientId)
   until not activeCallbacks[uniqueKey]

   TriggerClientEvent('qs_lib:validateCallback', clientId, evtName, cache.resource, uniqueKey)
   TriggerClientEvent(callbackEvent:format(evtName), clientId, cache.resource, uniqueKey, ...)

   local promise = not callback and promise.new()
   activeCallbacks[uniqueKey] = function(response, ...)
      if response == 'cb_invalid' then
         response = string.format("Callback '%s' is not registered", evtName)
         return promise and promise:reject(response) or error(response)
      end

      response = { response, ... }
      if promise then
         return promise:resolve(response)
      end

      if callback then
         callback(table.unpack(response))
      end
   end

   if promise then
      SetTimeout(timeoutDuration, function() promise:reject(string.format("Callback event '%s' exceeded timeout", uniqueKey)) end)
      return table.unpack(Citizen.Await(promise))
   end
end

---@overload fun(event: string, playerId: number, cb: function, ...)
lib.callback = setmetatable({}, {
   __call = function(_, event, playerId, cb, ...)
      if not cb then
         warn(string.format("Callback event '%s' lacks a function to return to and will await instead\nUse lib.callback.await or a standard event to suppress this warning", event))
      else
         local cbType = type(cb)
         if cbType == 'table' and getmetatable(cb)?.__call then
            cbType = 'function'
         end
         assert(cbType == 'function', string.format("Argument 3 must be a function, received %s", cbType))
      end

      return sendClientCallback(_, event, playerId, cb, ...)
   end
})

---@param event string
---@param playerId number
---Sends an event to a client and pauses the thread until a response is received.
---@diagnostic disable-next-line: duplicate-set-field
function lib.callback.await(event, playerId, ...)
   return sendClientCallback(nil, event, playerId, false, ...)
end

-- Processes the callback response, handling errors.
local function handleCallbackResponse(success, result, ...)
   if not success then
      if result then
         return print(string.format("^1SCRIPT ERROR: %s^0\n%s", result, Citizen.InvokeNative(`FORMAT_STACK_TRACE` & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString()) or ''))
      end
      return false
   end
   return result, ...
end

local pcall = pcall

---@param name string
---@param cb function
---Registers an event handler to respond to client callback requests.
---@diagnostic disable-next-line: duplicate-set-field
function lib.callback.register(name, cb)
   local event = callbackEvent:format(name)
   lib.setValidCallback(name, true)

   RegisterNetEvent(event, function(resource, key, ...)
      TriggerClientEvent(callbackEvent:format(resource), source, key, handleCallbackResponse(pcall(cb, source, ...)))
   end)
end

return lib.callback
