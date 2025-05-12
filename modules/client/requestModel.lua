-- requestModel.lua: Loads a model in FiveM, ensuring it is available for use.
-- This module handles both string and numeric model inputs, validates their integrity,
-- and waits until the model is loaded or a timeout is reached, yielding in a thread if necessary.

-- Normalizes and validates the model input.
---@param input number | string
---@return number
local function normalizeModel(input)
   local modelHash = type(input) == "number" and input or joaat(input)
   if not IsModelValid(modelHash) and not IsModelInCdimage(modelHash) then
      error(string.format("Attempted to load invalid model '%s'", modelHash))
   end
   return modelHash
end

-- Requests the loading of a model.
---@param modelHash number
---@param waitTime number
---@return number
local function loadModel(modelHash, waitTime)
   return lib.streamingRequest(RequestModel, HasModelLoaded, "model", modelHash, waitTime)
end

---Load a model. When called from a thread, it will yield until it has loaded.
---@param model number | string
---@param timeout number? Approximate milliseconds to wait for the model to load. Default is 9500.
---@return number model
function lib.requestModel(model, timeout)
   -- Normalize the model input to a hash
   local modelHash = normalizeModel(model)

   -- Return immediately if the model is already loaded
   if HasModelLoaded(modelHash) then
      return modelHash
   end

   -- Request the model with the specified timeout
   local waitTime = timeout or 9500
   return loadModel(modelHash, waitTime)
end

return lib.requestModel
