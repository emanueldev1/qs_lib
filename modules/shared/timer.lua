-- Implements an enhanced timer class for FiveM, providing methods to start, pause, resume, end, and manage timers
-- with support for synchronous/asynchronous execution, progress tracking, repetition, and custom time formats.

---@class TimerPrivateProps
---@field baseDuration number The initial duration of the timer.
---@field isAsync boolean|nil Whether the timer runs asynchronously.
---@field startTimestamp number The game timer stamp when the timer starts, updated on pause/play.
---@field endCallbackEnabled boolean Whether the onEnd callback is triggered when force-ending early.
---@field remainingTime number Current time left on the timer.
---@field isHalted boolean The pause state of the timer.
---@field repeatCount number|nil Number of times to repeat (-1 for infinite, nil for no repeat).
---@field intervalCallback fun(self: QsTimer)|nil Callback to run at regular intervals.
---@field intervalDuration number|nil Duration between interval callbacks (ms).
---@field progressCallback fun(self: QsTimer, percentage: number)|nil Callback for progress updates.
---@field pauseCallback fun(self: QsTimer)|nil Callback when the timer is paused.
---@field resumeCallback fun(self: QsTimer)|nil Callback when the timer is resumed.

---@class QsTimer : QsClass
---@field private _props TimerPrivateProps
---@field start fun(self: self, isAsync?: boolean) Starts the timer.
---@field onEnd fun(self: QsTimer)|nil Callback triggered when the timer finishes.
---@field forceEnd fun(self: self, triggerCallback: boolean) Ends the timer early, optionally triggering onEnd.
---@field isPaused fun(self: self): boolean Returns whether the timer is paused.
---@field pause fun(self: self) Pauses the timer until resumed.
---@field play fun(self: self) Resumes the timer if paused.
---@field getTimeLeft fun(self: self, unit?: 'ms' | 's' | 'm' | 'h' | 'mm:ss'): number | string | table Returns the time left in the specified unit or a table of all.
---@field restart fun(self: self, isAsync?: boolean) Restarts the timer with the initial duration.
---@field setDuration fun(self: self, duration: number) Adjusts the timer's duration dynamically.
---@field onProgress fun(self: self, callback: fun(self: QsTimer, percentage: number)) Sets a callback for progress updates.
---@field setRepeat fun(self: self, count: number) Sets the timer to repeat a number of times (-1 for infinite).
---@field getElapsedTime fun(self: self, unit?: 'ms' | 's' | 'm' | 'h' | 'mm:ss'): number | string | table Returns the elapsed time in the specified unit.
---@field addTime fun(self: self, milliseconds: number) Adds time to the remaining duration.
---@field removeTime fun(self: self, milliseconds: number) Removes time from the remaining duration.
---@field isActive fun(self: self): boolean Returns whether the timer is running.
---@field onPause fun(self: self, callback: fun(self: QsTimer)) Sets a callback for when the timer is paused.
---@field onResume fun(self: self, callback: fun(self: QsTimer)) Sets a callback for when the timer is resumed.
---@field destroy fun(self: self) Destroys the timer, stopping execution and clearing resources.
---@field setInterval fun(self: self, interval: number, callback: fun(self: QsTimer)) Sets a callback to run at regular intervals.
---@field getStatus fun(self: self): table Returns the complete status of the timer.
---@field clone fun(self: self): QsTimer Creates a copy of the timer with the same configuration.

local timerClass = lib.class('QsTimer')

-- Validates constructor inputs.
-- @param duration number The timer duration in milliseconds.
-- @param callback function|nil The onEnd callback.
-- @param isAsync boolean|nil Whether to run asynchronously.
local function validateInputs(duration, callback, isAsync)
   if type(duration) ~= 'number' or duration <= 0 then
      error("Duration must be a positive number", 2)
   end
   if callback ~= nil and type(callback) ~= 'function' then
      error("Callback must be a function or nil", 2)
   end
   if isAsync ~= nil and type(isAsync) ~= 'boolean' then
      error("Async flag must be a boolean or nil", 2)
   end
end

-- Formats time in various units.
-- @param milliseconds number The time to format.
-- @param unit string|nil The desired unit ('ms', 's', 'm', 'h', 'mm:ss') or nil for all.
-- @return number|string|table The formatted time.
local function formatTime(milliseconds, unit)
   local function round(value)
      return tonumber(string.format('%.2f', value))
   end

   local formats = {
      ms = round(milliseconds),
      s = round(milliseconds / 1000),
      m = round(milliseconds / 1000 / 60),
      h = round(milliseconds / 1000 / 60 / 60)
   }

   if unit == 'mm:ss' then
      local seconds = math.floor(milliseconds / 1000)
      local minutes = math.floor(seconds / 60)
      seconds = seconds % 60
      return string.format("%02d:%02d", minutes, seconds)
   end

   return unit and formats[unit] or formats
end

-- Constructor for the timer class.
-- @param duration number The duration in milliseconds.
-- @param callback fun(self: QsTimer)|nil Optional callback to run when the timer ends.
-- @param isAsync boolean|nil If true, runs asynchronously.
function timerClass:constructor(duration, callback, isAsync)
   validateInputs(duration, callback, isAsync)

   self.onEnd = callback
   self._props = {
      baseDuration = duration,
      remainingTime = duration,
      startTimestamp = 0,
      isHalted = false,
      endCallbackEnabled = true,
      isAsync = isAsync,
      repeatCount = nil,
      intervalCallback = nil,
      intervalDuration = nil,
      progressCallback = nil,
      pauseCallback = nil,
      resumeCallback = nil
   }

   self:start(isAsync)
end

-- Executes the timer loop, handling intervals and progress.
-- @protected
function timerClass:executeTimer()
   local lastInterval = 0
   while self._props.isHalted or self:getTimeLeft('ms') > 0 do
      Wait(0)
      if self._props.isHalted then
         goto continue
      end

      local elapsed = GetGameTimer() - self._props.startTimestamp
      if self._props.intervalCallback and self._props.intervalDuration then
         if elapsed - lastInterval >= self._props.intervalDuration then
            self._props.intervalCallback(self)
            lastInterval = elapsed
         end
      end

      if self._props.progressCallback then
         local percentage = 100 * (1 - (self._props.remainingTime - elapsed) / self._props.baseDuration)
         self._props.progressCallback(self, math.max(0, math.min(100, percentage)))
      end

      ::continue::
   end

   if self._props.endCallbackEnabled and self.onEnd then
      self:onEnd()
   end
   self._props.endCallbackEnabled = true

   if self._props.repeatCount then
      if self._props.repeatCount == -1 or self._props.repeatCount > 0 then
         if self._props.repeatCount > 0 then
            self._props.repeatCount = self._props.repeatCount - 1
         end
         self:restart(self._props.isAsync)
      end
   end
end

-- Starts the timer, either synchronously or asynchronously.
-- @param isAsync boolean|nil If true, runs in a new thread.
function timerClass:start(isAsync)
   if self._props.startTimestamp > 0 then
      error("Timer is already active and cannot be restarted", 2)
   end

   self._props.startTimestamp = GetGameTimer()
   if isAsync then
      Citizen.CreateThreadNow(function()
         self:executeTimer()
      end)
   else
      self:executeTimer()
   end
end

-- Forces the timer to end early.
-- @param triggerCallback boolean Whether to trigger the onEnd callback.
function timerClass:forceEnd(triggerCallback)
   if self:getTimeLeft('ms') <= 0 then
      return
   end

   self._props.isHalted = false
   self._props.remainingTime = 0
   self._props.endCallbackEnabled = triggerCallback
   Wait(0)
end

-- Pauses the timer, saving the current time left.
function timerClass:pause()
   if self._props.isHalted then
      return
   end

   self._props.remainingTime = self:getTimeLeft('ms')
   self._props.isHalted = true
   if self._props.pauseCallback then
      self._props.pauseCallback(self)
   end
end

-- Resumes a paused timer.
function timerClass:play()
   if not self._props.isHalted then
      return
   end

   self._props.startTimestamp = GetGameTimer()
   self._props.isHalted = false
   if self._props.resumeCallback then
      self._props.resumeCallback(self)
   end
end

-- Checks if the timer is paused.
-- @return boolean True if paused, false otherwise.
function timerClass:isPaused()
   return self._props.isHalted
end

-- Restarts the timer with the initial duration.
-- @param isAsync boolean|nil If true, runs asynchronously.
function timerClass:restart(isAsync)
   self:forceEnd(false)
   Wait(0)
   self._props.remainingTime = self._props.baseDuration
   self._props.startTimestamp = 0
   self._props.isAsync = isAsync or self._props.isAsync
   self:start(isAsync)
end

-- Adjusts the timer's duration dynamically.
-- @param duration number The new duration in milliseconds.
function timerClass:setDuration(duration)
   if type(duration) ~= 'number' or duration <= 0 then
      error("New duration must be a positive number", 2)
   end

   local timeLeft = self:getTimeLeft('ms')
   self._props.baseDuration = duration
   if timeLeft > 0 then
      local progress = timeLeft / self._props.baseDuration
      self._props.remainingTime = duration * progress
      self._props.startTimestamp = GetGameTimer() - (duration - self._props.remainingTime)
   else
      self._props.remainingTime = duration
   end
end

-- Sets a callback for progress updates.
-- @param callback fun(self: QsTimer, percentage: number) The callback to run with progress percentage.
function timerClass:onProgress(callback)
   if type(callback) ~= 'function' then
      error("Progress callback must be a function", 2)
   end
   self._props.progressCallback = callback
end

-- Sets the timer to repeat a number of times.
-- @param count number Number of repetitions (-1 for infinite).
function timerClass:setRepeat(count)
   if type(count) ~= 'number' or count < -1 then
      error("Repeat count must be a number >= -1", 2)
   end
   self._props.repeatCount = count
end

-- Gets the elapsed time since the timer started.
-- @param unit string|nil The unit ('ms', 's', 'm', 'h', 'mm:ss') or nil for all formats.
-- @return number|string|table The elapsed time.
function timerClass:getElapsedTime(unit)
   local elapsed = self._props.baseDuration - self:getTimeLeft('ms')
   return formatTime(elapsed, unit)
end

-- Adds time to the remaining duration.
-- @param milliseconds number The time to add in milliseconds.
function timerClass:addTime(milliseconds)
   if type(milliseconds) ~= 'number' or milliseconds <= 0 then
      error("Time to add must be a positive number", 2)
   end
   self._props.remainingTime = self:getTimeLeft('ms') + milliseconds
   self._props.baseDuration = math.max(self._props.baseDuration, self._props.remainingTime)
   if not self._props.isHalted then
      self._props.startTimestamp = GetGameTimer() - (self._props.baseDuration - self._props.remainingTime)
   end
end

-- Removes time from the remaining duration.
-- @param milliseconds number The time to remove in milliseconds.
function timerClass:removeTime(milliseconds)
   if type(milliseconds) ~= 'number' or milliseconds <= 0 then
      error("Time to remove must be a positive number", 2)
   end
   self._props.remainingTime = math.max(0, self:getTimeLeft('ms') - milliseconds)
   if not self._props.isHalted then
      self._props.startTimestamp = GetGameTimer() - (self._props.baseDuration - self._props.remainingTime)
   end
end

-- Checks if the timer is actively running.
-- @return boolean True if running, false otherwise.
function timerClass:isActive()
   return not self._props.isHalted and self:getTimeLeft('ms') > 0
end

-- Sets a callback for when the timer is paused.
-- @param callback fun(self: QsTimer) The callback to run.
function timerClass:onPause(callback)
   if type(callback) ~= 'function' then
      error("Pause callback must be a function", 2)
   end
   self._props.pauseCallback = callback
end

-- Sets a callback for when the timer is resumed.
-- @param callback fun(self: QsTimer) The callback to run.
function timerClass:onResume(callback)
   if type(callback) ~= 'function' then
      error("Resume callback must be a function", 2)
   end
   self._props.resumeCallback = callback
end

-- Destroys the timer, stopping execution and clearing resources.
function timerClass:destroy()
   self:forceEnd(false)
   self._props = nil
   self.onEnd = nil
end

-- Sets a callback to run at regular intervals.
-- @param interval number The interval duration in milliseconds.
-- @param callback fun(self: QsTimer) The callback to run.
function timerClass:setInterval(interval, callback)
   if type(interval) ~= 'number' or interval <= 0 then
      error("Interval must be a positive number", 2)
   end
   if type(callback) ~= 'function' then
      error("Interval callback must be a function", 2)
   end
   self._props.intervalDuration = interval
   self._props.intervalCallback = callback
end

-- Gets the complete status of the timer.
-- @return table The timer's status.
function timerClass:getStatus()
   return {
      baseDuration = self._props.baseDuration,
      remainingTime = self:getTimeLeft('ms'),
      isHalted = self._props.isHalted,
      isActive = self:isActive(),
      isAsync = self._props.isAsync,
      repeatCount = self._props.repeatCount,
      hasInterval = self._props.intervalCallback ~= nil,
      hasProgressCallback = self._props.progressCallback ~= nil
   }
end

-- Creates a copy of the timer with the same configuration.
-- @return QsTimer A new timer instance.
function timerClass:clone()
   local newTimer = timerClass:new(self._props.baseDuration, self.onEnd, self._props.isAsync)
   newTimer._props.remainingTime = self._props.remainingTime
   newTimer._props.isHalted = self._props.isHalted
   newTimer._props.startTimestamp = self._props.isHalted and self._props.startTimestamp or GetGameTimer()
   newTimer._props.repeatCount = self._props.repeatCount
   newTimer._props.intervalCallback = self._props.intervalCallback
   newTimer._props.intervalDuration = self._props.intervalDuration
   newTimer._props.progressCallback = self._props.progressCallback
   newTimer._props.pauseCallback = self._props.pauseCallback
   newTimer._props.resumeCallback = self._props.resumeCallback
   return newTimer
end

-- Gets the time left on the timer.
-- @param unit string|nil The unit ('ms', 's', 'm', 'h', 'mm:ss') or nil for all formats.
-- @return number|string|table The time left.
function timerClass:getTimeLeft(unit)
   local elapsed = self._props.isHalted and 0 or (GetGameTimer() - self._props.startTimestamp)
   local remaining = math.max(0, self._props.remainingTime - elapsed)
   return formatTime(remaining, unit)
end

-- Creates a new timer instance.
-- @param duration number The duration in milliseconds.
-- @param callback fun(self: QsTimer)|nil Optional callback to run when the timer ends.
-- @param isAsync boolean|nil If true, runs asynchronously.
-- @return QsTimer The new timer instance.
function lib.timer(duration, callback, isAsync)
   return timerClass:new(duration, callback, isAsync)
end

return lib.timer
