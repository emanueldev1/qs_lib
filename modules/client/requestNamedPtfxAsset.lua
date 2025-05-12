-- requestNamedPtfxAsset.lua: Loads a named particle effect asset in FiveM, ensuring it is ready for use.
-- This module validates the particle effect name, checks if it is already loaded, and handles the loading process,
-- yielding in a thread until the asset is available or a timeout occurs.

-- Validates that the particle effect name is a string.
---@param effectName string
local function validateEffectName(effectName)
   if type(effectName) ~= "string" then
      error(string.format("Expected ptFxName name to be a string, received %s", type(effectName)))
   end
end

-- Requests the loading of a particle effect asset.
---@param effectName string
---@param maxWaitTime number
---@return string
local function loadParticleEffect(effectName, maxWaitTime)
   return lib.streamingRequest(RequestNamedPtfxAsset, HasNamedPtfxAssetLoaded, "ptFxName", effectName, maxWaitTime)
end

---Load a named particle effect. When called from a thread, it will yield until it has loaded.
---@param ptFxName string
---@param timeout number? Approximate milliseconds to wait for the particle effect to load. Default is 9200.
---@return string ptFxName
function lib.requestNamedPtfxAsset(ptFxName, timeout)
   -- Return immediately if the particle effect is already loaded
   if HasNamedPtfxAssetLoaded(ptFxName) then
      return ptFxName
   end

   -- Validate the particle effect name
   validateEffectName(ptFxName)

   -- Load the particle effect with the specified timeout
   local maxWaitTime = timeout or 9200
   return loadParticleEffect(ptFxName, maxWaitTime)
end

return lib.requestNamedPtfxAsset
