-- This file contains code adapted from ox_lib, developed by the Overextended team.
-- Original repository: https://github.com/overextended/ox_lib
-- License: GNU Lesser General Public License v3.0 (LGPL-3.0), available at https://www.gnu.org/licenses/lgpl-3.0.html
-- Modifications by emanueldev1 for the qs_lib project, licensed under LGPL-3.0.

-- This script implements a callback system for FiveM, enabling client-server communication through
-- synchronous and asynchronous callbacks. It supports event cooldowns, promise-based awaiting, and
-- server-side callback registration.

local pendingCallbacks = {}
local timers = {}
local cbEvent = '__qs_cb_%s'
local callbackTimeout = GetConvarInt('qs:callbackTimeout', 300000)

-- Handles incoming callback responses from the server
RegisterNetEvent(cbEvent:format(cache.resource), function(callbackId, ...)
   if source == '' then return end

   local handler = pendingCallbacks[callbackId]
   if not handler then return end

   pendingCallbacks[callbackId] = nil
   handler(...)
end)

-- Determines if an event can be triggered based on its cooldown
-- @param eventName string The name of the event
-- @param cooldown number|boolean|nil The cooldown period in milliseconds
-- @return boolean True if the event can be triggered, false otherwise
local function isEventAllowed(eventName, cooldown)
   if not cooldown or type(cooldown) ~= 'number' or cooldown <= 0 then
      return true
   end

   local currentTime = GetGameTimer()
   if (timers[eventName] or 0) > currentTime then
      return false
   end

   timers[eventName] = currentTime + cooldown
   return true
end

-- Creates a unique identifier for a callback
-- @param eventName string The name of the event
-- @return string A unique callback ID
local function createCallbackId(eventName)
   local callbackId
   repeat
      callbackId = string.format('%s_%d', eventName, math.random(10000, 99999))
   until not pendingCallbacks[callbackId]
   return callbackId
end

-- Executes a server callback and processes the response
-- @param _ any Unused parameter for metatable compatibility
-- @param eventName string The name of the event
-- @param cooldown number|boolean|nil The cooldown period or false to bypass
-- @param callbackFn function|boolean The callback function or false for promises
-- @param ... any Arguments to pass to the server
-- @return ... The response from the server
local function performServerCallback(_, eventName, cooldown, callbackFn, ...)
   if not isEventAllowed(eventName, cooldown) then return end

   local callbackId = createCallbackId(eventName)

   -- Trigger server events for validation and callback execution
   TriggerServerEvent('qs_lib:validateCallback', eventName, cache.resource, callbackId)
   TriggerServerEvent(cbEvent:format(eventName), cache.resource, callbackId, ...)

   local isAsync = not callbackFn
   local responsePromise = isAsync and promise.new()

   -- Store the callback handler
   pendingCallbacks[callbackId] = function(responseData, ...)
      if responseData == 'cb_invalid' then
         local errorMsg = string.format("callback '%s' does not exist", eventName)
         if responsePromise then
            responsePromise:reject(errorMsg)
         else
            error(errorMsg)
         end
         return
      end

      local resultData = { responseData, ... }
      if responsePromise then
         responsePromise:resolve(resultData)
      elseif callbackFn then
         callbackFn(table.unpack(resultData))
      end
   end

   -- Handle promise-based awaiting with timeout
   if responsePromise then
      SetTimeout(callbackTimeout, function()
         responsePromise:reject(string.format("callback event '%s' timed out", callbackId))
      end)
      return table.unpack(Citizen.Await(responsePromise))
   end
end

-- Metatable for lib.callback to enable dynamic calls
lib.callback = setmetatable({}, {
   __call = function(_, eventName, cooldown, callbackFn, ...)
      if not callbackFn then
         warn(string.format("callback event '%s' does not have a function to callback to and will instead await\nuse  or a regular event to remove this warning", eventName))
      else
         local fnType = type(callbackFn)
         if fnType == 'table' and getmetatable(callbackFn)?.__call then
            fnType = 'function'
         end
         assert(fnType == 'function', string.format("expected argument 3 to have type 'function' (received %s)", fnType))
      end

      return performServerCallback(_, eventName, cooldown, callbackFn, ...)
   end
})

-- Sends an event to the server and awaits the response
-- @param eventName string The name of the event
-- @param cooldown number|boolean|nil The cooldown period or false to bypass
-- @param ... any Arguments to pass to the server
-- @return ... The response from the server
function lib.callback.await(eventName, cooldown, ...)
   return performServerCallback(nil, eventName, cooldown, false, ...)
end

-- Processes the result of a callback, handling errors
-- @param isSuccess boolean Whether the callback was successful
-- @param resultData any The result or error message
-- @param ... any Additional arguments
-- @return any The processed result
local function handleCallbackResult(isSuccess, resultData, ...)
   if not isSuccess then
      if resultData then
         local stackTrace = Citizen.InvokeNative(`FORMAT_STACK_TRACE` & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString()) or ''
         print(string.format('^1SCRIPT ERROR: %s^0\n%s', resultData, stackTrace))
      end
      return false
   end
   return resultData, ...
end

-- Registers a callback handler for server requests
-- @param callbackName string The name of the callback
-- @param handler function The function to handle the callback
function lib.callback.register(callbackName, handler)
   local eventName = cbEvent:format(callbackName)
   lib.setValidCallback(callbackName, true)

   RegisterNetEvent(eventName, function(resource, callbackId, ...)
      local result = { pcall(handler, ...) }
      TriggerServerEvent(cbEvent:format(resource), callbackId, handleCallbackResult(table.unpack(result)))
   end)
end

return lib.callback


-- //TODO: Pending deep checking of the callback system
