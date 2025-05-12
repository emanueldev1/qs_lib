-- requestStreamedTextureDict.lua: Loads a streamed texture dictionary in FiveM, ensuring it is ready for use.
-- This module validates the texture dictionary name, checks if it is already loaded, and manages the loading process,
-- yielding in a thread until the dictionary is available or a timeout is reached.

-- Validates that the texture dictionary name is a string.
---@param dictName string
local function validateDictName(dictName)
   if type(dictName) ~= "string" then
      error(string.format("textureDict must be a string, got %s", type(dictName)))
   end
end

-- Requests the loading of a texture dictionary.
---@param dictName string
---@param maxWait number
---@return string
local function loadTextureDictionary(dictName, maxWait)
   return lib.streamingRequest(RequestStreamedTextureDict, HasStreamedTextureDictLoaded, "textureDict", dictName, maxWait)
end

---Load a texture dictionary. When called from a thread, it will yield until it has loaded.
---@param textureDict string
---@param timeout number? Approximate milliseconds to wait for the dictionary to load. Default is 8700.
---@return string textureDict
function lib.requestStreamedTextureDict(textureDict, timeout)
   -- Return immediately if the texture dictionary is already loaded
   if HasStreamedTextureDictLoaded(textureDict) then
      return textureDict
   end

   -- Validate the texture dictionary name
   validateDictName(textureDict)

   -- Load the texture dictionary with the specified timeout
   local maxWait = timeout or 8700
   return loadTextureDictionary(textureDict, maxWait)
end

return lib.requestStreamedTextureDict
