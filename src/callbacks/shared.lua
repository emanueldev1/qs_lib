--- @class RegisteredCallbacks
--- @field [string] string Maps callback names to their owning resource names.
local registeredCallbacks = {}

--- Removes callbacks registered by a stopping resource, except for the current resource.
--- @param resourceName string The name of the resource being stopped.
local function handleResourceStop(resourceName)
   if cache.resource == resourceName then return end
   for callbackName, owner in pairs(registeredCallbacks) do
      if owner == resourceName then
         registeredCallbacks[callbackName] = nil
      end
   end
end

--- Gets the invoking resource name or falls back to the current resource.
--- @return string The resource name.
local function getInvokingResourceName()
   return GetInvokingResource() or cache.resource
end

--- Logs a verbose message about callback registration.
--- @param callbackName string The name of the callback.
--- @param resourceName string The name of the resource registering the callback.
local function logVerboseCallback(callbackName, resourceName)
   lib.print.verbose(('set valid callback \'%s\' for resource \'%s\''):format(callbackName, resourceName))
end

--- Reports an error when a callback is attempted to be overwritten.
--- @param callbackName string The name of the callback.
--- @param resourceName string The name of the resource attempting to overwrite.
--- @param owner string The name of the resource that owns the callback.
local function reportOverwriteError(callbackName, resourceName, owner)
   local errorMessage = ("^1resource '%s' attempted to overwrite callback '%s' owned by resource '%s'^0"):format(
      resourceName, callbackName, owner)
   local stackTrace = Citizen.InvokeNative(0x6F0D37F9, nil, 0, Citizen.ResultAsString()) or ''
   print(('^1SCRIPT ERROR: %s^0\n%s'):format(errorMessage, stackTrace))
end

--- Registers a callback as valid for a specific resource.
--- Prevents overwriting callbacks owned by other resources.
--- @param callbackName string The name of the callback to register.
--- @param isValid boolean Whether the callback is valid (true) or should be unregistered (false).
function lib.setValidCallback(callbackName, isValid)
   local resourceName = getInvokingResourceName()
   local currentOwner = registeredCallbacks[callbackName]

   if currentOwner then
      if not isValid then
         registeredCallbacks[callbackName] = nil
         return
      end
      if currentOwner == resourceName then return end
      return reportOverwriteError(callbackName, resourceName, currentOwner)
   end

   logVerboseCallback(callbackName, resourceName)
   registeredCallbacks[callbackName] = resourceName
end

--- Checks if a callback is valid for the invoking resource.
--- @param callbackName string The name of the callback to check.
--- @return boolean True if the callback is valid for the invoking resource, false otherwise.
function lib.isCallbackValid(callbackName)
   local invokingResource = getInvokingResourceName()
   return registeredCallbacks[callbackName] == invokingResource
end

--- Handles callback validation requests and triggers invalid callback events.
--- @param callbackName string The name of the callback to validate.
--- @param invokingResource string The resource requesting validation.
--- @param key string The key associated with the callback event.
local function handleCallbackValidation(callbackName, invokingResource, key)
   if registeredCallbacks[callbackName] then return end
   local event = ('__qs_cb_%s'):format(invokingResource)
   if cache.game == 'fxserver' then
      TriggerClientEvent(event, source, key, 'cb_invalid')
   else
      TriggerServerEvent(event, key, 'cb_invalid')
   end
end

-- Register event handlers
AddEventHandler('onResourceStop', handleResourceStop)
RegisterNetEvent('qs_lib:validateCallback', handleCallbackValidation)
