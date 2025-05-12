-- requestAnimSet.lua: Loads an animation clipset in FiveM, ensuring it is ready for use.
-- This module checks if the clipset is already loaded, validates its type, and handles the loading process,
-- yielding in a thread until the clipset is available or a timeout occurs.

-- Verifies that the clipset is a valid string.
---@param setName string
local function verifyClipset(setName)
   if type(setName) ~= "string" then
      error(string.format("Expected clipset to be a string, received %s", type(setName)))
   end
end

-- Handles the loading of an animation clipset.
---@param setName string
---@param loadTimeout number
---@return string
local function requestClipset(setName, loadTimeout)
   return lib.streamingRequest(RequestAnimSet, HasAnimSetLoaded, "animSet", setName, loadTimeout)
end

---Load an animation clipset. When called from a thread, it will yield until it has loaded.
---@param animSet string
---@param timeout number? Approximate milliseconds to wait for the clipset to load. Default is 9000.
---@return string animSet
function lib.requestAnimSet(animSet, timeout)
   -- Return immediately if the clipset is already loaded
   if HasAnimSetLoaded(animSet) then
      return animSet
   end

   -- Validate the clipset type
   verifyClipset(animSet)

   -- Load the clipset with the specified timeout
   local loadTimeout = timeout or 9000
   return requestClipset(animSet, loadTimeout)
end

return lib.requestAnimSet
