-- requestAnimDict.lua: Loads an animation dictionary in FiveM, ensuring it is available for use.
-- This module validates the dictionary, checks if it is already loaded, and handles the loading process,
-- yielding in a thread until the dictionary is ready or a timeout is reached.

-- Validates the animation dictionary and its existence.
---@param dict string
local function validateDictionary(dict)
   if type(dict) ~= "string" then
      error(string.format("Expected dictionary to be a string, received %s", type(dict)))
   end
   if not DoesAnimDictExist(dict) then
      error(string.format("Invalid animation dictionary '%s' provided", dict))
   end
end

-- Requests the loading of an animation dictionary.
---@param dict string
---@param waitTime number
---@return string
local function loadDictionary(dict, waitTime)
   return lib.streamingRequest(RequestAnimDict, HasAnimDictLoaded, "animDict", dict, waitTime)
end

---Load an animation dictionary. When called from a thread, it will yield until it has loaded.
---@param animDict string
---@param timeout number? Approximate milliseconds to wait for the dictionary to load. Default is 8000.
---@return string animDict
function lib.requestAnimDict(animDict, timeout)
   -- Check if the dictionary is already loaded
   if HasAnimDictLoaded(animDict) then
      return animDict
   end

   -- Validate the dictionary
   validateDictionary(animDict)

   -- Load the dictionary with the specified timeout
   local waitTime = timeout or 8000
   return loadDictionary(animDict, waitTime)
end

return lib.requestAnimDict
