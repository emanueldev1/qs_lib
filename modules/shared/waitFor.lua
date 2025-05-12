-- Waits asynchronously for a callback to return a non-nil value, with optional timeout and error message.
-- Errors out if the timeout is reached, or continues indefinitely if timeout is disabled.

---@generic T
---@param callback fun(): T? The function to poll for a non-nil value.
---@param errorText string? Custom error message if the timeout is reached.
---@param maxWait number|false|nil Timeout duration in milliseconds (defaults to 1000 if nil, no timeout if false).
---@return T The non-nil value returned by the callback.
---@async
function lib.waitFor(callback, errorText, maxWait)
   -- Validates and initializes the wait parameters.
   -- @return number|nil The start time for timeout, or nil if no timeout.
   local function initializeWait()
      if type(callback) ~= 'function' then
         error("Callback must be a function", 2)
      end

      if maxWait == nil then
         return GetGameTimer(), 1000
      elseif maxWait == false then
         return nil, nil
      elseif type(maxWait) ~= 'number' or maxWait <= 0 then
         error("Max wait must be a positive number or false", 2)
      else
         return GetGameTimer(), maxWait
      end
   end

   -- Checks if the timeout has been reached.
   -- @param beginTime number The start time of the wait.
   -- @param duration number The timeout duration.
   -- @return boolean True if timed out, false otherwise.
   local function checkTimeout(beginTime, duration)
      local timePassed = GetGameTimer() - beginTime
      return timePassed > duration
   end

   -- Polls the callback for a non-nil value.
   -- @return any|nil The callback result.
   local function pollCallback()
      return callback()
   end

   local result = pollCallback()
   if result ~= nil then
      return result
   end

   local beginTime, duration = initializeWait()
   local errorMsg = errorText or "Callback did not resolve to a non-nil value"

   for _ = 1, math.huge do
      Wait(0)
      result = pollCallback()

      if result ~= nil then
         return result
      end

      if beginTime and checkTimeout(beginTime, duration) then
         error(("%s after %.1fms timeout"):format(errorMsg, GetGameTimer() - beginTime), 2)
      end
   end
end

return lib.waitFor
