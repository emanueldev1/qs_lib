-- requestScaleformMovie.lua: Loads a scaleform movie in FiveM, ensuring it is ready for use.
-- This module validates the scaleform name, requests its loading, and waits until the movie is available
-- or a timeout occurs, yielding in a thread if necessary.

-- Validates that the scaleform name is a string.
---@param movieName string
local function validateScaleformName(movieName)
   if type(movieName) ~= "string" then
      error(string.format("scaleformName must be a string, received %s", type(movieName)))
   end
end

-- Requests and waits for a scaleform movie to load.
---@param movieName string
---@param waitDuration number
---@return number
local function loadScaleformMovie(movieName, waitDuration)
   local movieHandle = RequestScaleformMovie(movieName)
   local errorMessage = string.format("Unable to load scaleform movie '%s'", movieName)
   return lib.waitFor(function()
      if HasScaleformMovieLoaded(movieHandle) then
         return movieHandle
      end
   end, errorMessage, waitDuration)
end

---Load a scaleform movie. When called from a thread, it will yield until it has loaded.
---@param scaleformName string
---@param timeout number? Approximate milliseconds to wait for the scaleform movie to load. Default is 1100.
---@return number? scaleform
function lib.requestScaleformMovie(scaleformName, timeout)
   -- Validate the scaleform name
   validateScaleformName(scaleformName)

   -- Request and wait for the scaleform to load
   local waitDuration = timeout or 1100
   return loadScaleformMovie(scaleformName, waitDuration)
end

return lib.requestScaleformMovie
