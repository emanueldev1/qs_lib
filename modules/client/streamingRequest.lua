-- This file contains code adapted from ox_lib, developed by the Overextended team.
-- Original repository: https://github.com/overextended/ox_lib
-- License: GNU Lesser General Public License v3.0 (LGPL-3.0), available at https://www.gnu.org/licenses/lgpl-3.0.html
-- Modifications by emanueldev1 for the qs_lib project, licensed under LGPL-3.0.

-- streamingRequest.lua: Handles asynchronous loading of streaming assets in FiveM.
-- This internal utility function manages the request and verification of asset loading,
-- waiting until the asset is ready or a timeout occurs, and supports various asset types.

---@async
---@generic T : string | number
---@param request function
---@param hasLoaded function
---@param assetType string
---@param asset T
---@param timeout? number
---@param ... any
---Used internally.
function lib.streamingRequest(request, hasLoaded, assetType, asset, timeout, ...)
   -- Check if the asset is already loaded
   if hasLoaded(asset) then
      return asset
   end

   -- Request the asset with additional parameters
   local function initiateRequest(...)
      request(asset, ...)
   end

   -- Wait for the asset to load, handling errors and timeout
   local function awaitAssetLoad()
      local errorMessage = string.format(
         "Unable to load %s '%s'. Possible causes:\n- Excessive loaded assets\n- Invalid, oversized, or corrupted assets",
         assetType,
         asset
      )
      local waitDuration = timeout or 28000
      return lib.waitFor(function()
         if hasLoaded(asset) then
            return asset
         end
      end, errorMessage, waitDuration)
   end

   -- Execute the request and wait for completion
   initiateRequest(...)
   return awaitAssetLoad()
end

return lib.streamingRequest
