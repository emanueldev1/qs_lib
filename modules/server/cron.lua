-- cron.lua: Implements a cron-like scheduler in FiveM for task execution at specified intervals.
-- This module supports cron expressions to schedule tasks with flexible timing and debugging options.

lib.cron = {}

---@alias Date { year: number, month: number, day: number, hour: number, min: number, sec: number, wday: number, yday: number, isdst: boolean }
---@type Date
local dateCache = {}

setmetatable(dateCache, {
   __index = function(self, key)
      local freshDate = os.date('*t') --[[@as Date]]
      for k, v in pairs(freshDate) do
         self[k] = v
      end
      SetTimeout(900, function() table.wipe(self) end)
      return self[key]
   end
})

---@class QsTaskProperties
---@field minute? number|string|function
---@field hour? number|string|function
---@field day? number|string|function
---@field month? number|string|function
---@field year? number|string|function
---@field weekday? number|string|function
---@field job fun(task: QsTask, date: osdate)
---@field isActive boolean
---@field id number
---@field debug? boolean
---@field lastRun? number
---@field maxDelay? number Maximum allowed delay in seconds before skipping (0 to disable)

---@class QsTask : QsTaskProperties
---@field expression string
---@field private scheduleTask fun(self: QsTask): boolean?
local TaskScheduler = {}
TaskScheduler.__index = TaskScheduler

local timeRanges = {
   min = { min = 0, max = 59 },
   hour = { min = 0, max = 23 },
   day = { min = 1, max = 31 },
   month = { min = 1, max = 12 },
   wday = { min = 0, max = 7 },
}

local maxTimeUnits = {
   min = 60,
   hour = 24,
   wday = 7,
   day = 31,
   month = 12,
}

local dayOfWeekMap = {
   sun = 1, mon = 2, tue = 3, wed = 4, thu = 5, fri = 6, sat = 7,
}

local monthNames = {
   jan = 1,
   feb = 2,
   mar = 3,
   apr = 4,
   may = 5,
   jun = 6,
   jul = 7,
   aug = 8,
   sep = 9,
   oct = 10,
   nov = 11,
   dec = 12,
}

-- Calculates the last day of a given month.
---@param monthNum number
---@param yearNum? number
---@return number
local function getLastDayOfMonth(monthNum, yearNum)
   return os.date('*t', os.time({ year = yearNum or dateCache.year, month = monthNum + 1, day = -1 })).day --[[@as number]]
end

-- Checks if a value is within the valid range for a unit.
---@param val string|number
---@param timeUnit string
---@return boolean
local function isWithinRange(val, timeUnit)
   local range = timeRanges[timeUnit]
   if not range then return true end
   return val >= range.min and val <= range.max
end

-- Parses a cron expression component.
---@param input string
---@param timeUnit string
---@return number|string|function|nil
local function parseCronUnit(input, timeUnit)
   if not input or input == '*' then return end

   if timeUnit == 'day' and input:lower() == 'l' then
      return function() return getLastDayOfMonth(dateCache.month, dateCache.year) end
   end

   local numericVal = tonumber(input)
   if numericVal then
      if not isWithinRange(numericVal, timeUnit) then
         error(string.format("^1Cron expression error: '%s' exceeds valid range for %s^0", input, timeUnit), 3)
      end
      return numericVal
   end

   if timeUnit == 'wday' then
      local startDay, endDay = input:match('(%a+)-(%a+)')
      if startDay and endDay then
         startDay = dayOfWeekMap[startDay:lower()]
         endDay = dayOfWeekMap[endDay:lower()]
         if startDay and endDay then
            if endDay < startDay then endDay = endDay + 7 end
            return string.format("%d-%d", startDay, endDay)
         end
      end
      local mappedDay = dayOfWeekMap[input:lower()]
      if mappedDay then return mappedDay end
   end

   if timeUnit == 'month' then
      local monthList = {}
      for monthName in input:gmatch('[^,]+') do
         local monthNum = monthNames[monthName:lower()]
         if monthNum then
            monthList[#monthList + 1] = tostring(monthNum)
         end
      end
      if #monthList > 0 then
         return table.concat(monthList, ',')
      end
   end

   local stepVal = input:match('^%*/(%d+)$')
   if stepVal then
      local stepNum = tonumber(stepVal)
      if not stepNum or stepNum == 0 then
         error(string.format("^1Cron expression error: Invalid step value '%s'^0", stepNum or 'nil'), 3)
      end
      return input
   end

   local rangeStart, rangeEnd = input:match('^(%d+)-(%d+)$')
   if rangeStart and rangeEnd then
      rangeStart, rangeEnd = tonumber(rangeStart), tonumber(rangeEnd)
      if not rangeStart or not rangeEnd or not isWithinRange(rangeStart, timeUnit) or not isWithinRange(rangeEnd, timeUnit) then
         error(string.format("^1Cron expression error: Range '%s' is not valid for %s^0", input, timeUnit), 3)
      end
      return input
   end

   local isValidList = true
   for item in input:gmatch('[^,]+') do
      local numItem = tonumber(item)
      if not numItem or not isWithinRange(numItem, timeUnit) then
         isValidList = false
         break
      end
   end
   if isValidList then return input end

   error(string.format("^1Cron expression error: Unsupported value '%s' for %s^0", input, timeUnit), 3)
end

-- Determines the next time unit value based on the cron expression.
---@param val string|number|function|nil
---@param timeUnit string
---@return number|false|nil
local function computeNextUnit(val, timeUnit)
   local currentUnit = dateCache[timeUnit]

   if not val then
      return timeUnit == 'min' and currentUnit + 1 or currentUnit
   end

   if type(val) == 'function' then
      return val()
   end

   local unitMax = maxTimeUnits[timeUnit]

   if type(val) == 'string' then
      local stepMatch = string.match(val, '*/(%d+)')
      if stepMatch then
         local step = tonumber(stepMatch)
         for i = currentUnit + 1, unitMax do
            if i % step == 0 then return i end
         end
         return step + unitMax
      end

      local rangeMatch = string.match(val, '%d+-%d+')
      if rangeMatch then
         local minVal, maxVal = string.strsplit('-', rangeMatch)
         minVal, maxVal = tonumber(minVal, 10), tonumber(maxVal, 10)

         if timeUnit == 'min' then
            if currentUnit >= maxVal then
               return minVal + unitMax
            end
         elseif currentUnit > maxVal then
            return minVal + unitMax
         end

         return currentUnit < minVal and minVal or currentUnit
      end

      local listMatch = string.match(val, '%d+,%d+')
      if listMatch then
         local values = {}
         for listItem in string.gmatch(val, '%d+') do
            values[#values + 1] = tonumber(listItem)
         end
         table.sort(values)

         for i = 1, #values do
            local listVal = values[i]
            if timeUnit == 'min' then
               if currentUnit < listVal then
                  return listVal
               end
            elseif currentUnit <= listVal then
               return listVal
            end
         end

         return values[1] + unitMax
      end

      return false
   end

   if timeUnit == 'min' then
      return val <= currentUnit and val + unitMax or val --[[@as number]]
   end

   return val < currentUnit and val + unitMax or val --[[@as number]]
end

-- Calculates the next scheduled time for the task.
---@return number?
function TaskScheduler:computeNextRunTime()
   if not self.isActive then return end

   local dayVal = computeNextUnit(self.day, 'day')
   if dayVal == 0 then
      dayVal = getLastDayOfMonth(dateCache.month)
   end
   if dayVal ~= dateCache.day then return end

   local monthVal = computeNextUnit(self.month, 'month')
   if monthVal ~= dateCache.month then return end

   local weekdayVal = computeNextUnit(self.weekday, 'wday')
   if weekdayVal and weekdayVal ~= dateCache.wday then return end

   local minuteVal = computeNextUnit(self.minute, 'min')
   if not minuteVal then return end

   local hourVal = computeNextUnit(self.hour, 'hour')
   if not hourVal then return end

   if minuteVal >= maxTimeUnits.min then
      if not self.hour then
         hourVal = hourVal + math.floor(minuteVal / maxTimeUnits.min)
      end
      minuteVal = minuteVal % maxTimeUnits.min
   end

   if hourVal >= maxTimeUnits.hour and dayVal then
      if not self.day then
         dayVal = dayVal + math.floor(hourVal / maxTimeUnits.hour)
      end
      hourVal = hourVal % maxTimeUnits.hour
   end

   local nextRunTime = os.time({
      min = minuteVal,
      hour = hourVal,
      day = dayVal or dateCache.day,
      month = monthVal or dateCache.month,
      year = dateCache.year,
   })

   if self.lastRun and nextRunTime - self.lastRun < 60 then
      if self.debug then
         lib.print.debug(string.format("Skipping duplicate run of task %s - Last executed: %s, Next scheduled: %s",
            self.id, os.date('%c', self.lastRun), os.date('%c', nextRunTime)))
      end
      return
   end

   return nextRunTime
end

-- Determines the absolute next run time for the task.
---@return number
function TaskScheduler:computeAbsoluteNextRun()
   local minuteVal = computeNextUnit(self.minute, 'min')
   local hourVal = computeNextUnit(self.hour, 'hour')
   local dayVal = computeNextUnit(self.day, 'day')
   local monthVal = computeNextUnit(self.month, 'month')
   local yearVal = computeNextUnit(self.year, 'year')

   if self.day then
      if dateCache.hour < hourVal or (dateCache.hour == hourVal and dateCache.min < minuteVal) then
         dayVal = dayVal - 1
         if dayVal < 1 then
            dayVal = getLastDayOfMonth(dateCache.month)
         end
      end

      if dateCache.hour > hourVal or (dateCache.hour == hourVal and dateCache.min >= minuteVal) then
         dayVal = dayVal + 1
         if dayVal > getLastDayOfMonth(dateCache.month) or dayVal == 1 then
            dayVal = 1
            monthVal = monthVal + 1
         end
      end
   end

   ---@diagnostic disable-next-line: assign-type-mismatch
   if os.time({ year = yearVal, month = monthVal, day = dayVal, hour = hourVal, min = minuteVal }) < os.time() then
      yearVal = yearVal and yearVal + 1 or dateCache.year + 1
   end

   return os.time({
      min = minuteVal < 60 and minuteVal or 0,
      hour = hourVal < 24 and hourVal or 0,
      day = dayVal or dateCache.day,
      month = monthVal or dateCache.month,
      year = yearVal or dateCache.year,
   })
end

-- Formats a timestamp as a readable string.
---@param timestamp number
function TaskScheduler:formatRunTime(timestamp)
   return os.date('%A %H:%M, %d %B %Y', timestamp or self:computeAbsoluteNextRun())
end

---@type QsTask[]
local scheduledTasks = {}

-- Schedules and executes the task at the appropriate time.
---@return boolean?
function TaskScheduler:manageSchedule()
   local nextRun = self:computeNextRunTime()
   if not nextRun then
      return self:halt('No valid next run time computed')
   end

   local now = os.time()
   local delay = nextRun - now

   if delay < 0 then
      if not self.maxDelay or -delay > self.maxDelay then
         return self:halt(self.debug and string.format("Run time missed by %s seconds", -delay))
      end

      if self.debug then
         lib.print.debug(string.format("Task %s is delayed by %s seconds, running now (maxDelay=%s)", self.id, -delay, self.maxDelay))
      end

      delay = 0
   end

   local formattedTime = self:formatRunTime(nextRun)
   if self.debug then
      lib.print.debug(string.format("Task %s scheduled to run at %s in %d seconds (%0.2f minutes / %0.2f hours)", self.id, formattedTime, delay, delay / 60, delay / 60 / 60))
   end

   if delay > 0 then
      Wait(delay * 1000)
   else
      Wait(0)
      return true
   end

   if self.isActive then
      if self.debug then
         lib.print.debug(string.format("Executing task %s at %s", self.id, formattedTime))
      end

      Citizen.CreateThreadNow(function()
         self:job(dateCache)
         self.lastRun = os.time()
      end)

      return true
   end
end

-- Starts the task scheduling loop.
function TaskScheduler:activate()
   if self.isActive then return end

   self.isActive = true
   CreateThread(function()
      while self:manageSchedule() do end
   end)
end

-- Stops the task with an optional message.
---@param reason string?
function TaskScheduler:halt(reason)
   self.isActive = false
   if self.debug then
      if reason then
         return lib.print.debug(string.format("Halting task %s (%s)", self.id, reason))
      end
      lib.print.debug(string.format("Halting task %s", self.id))
   end
end

---@param expression string A cron expression such as `* * * * *` representing minute, hour, day, month, and day of the week.
---@param job fun(task: QsTask, date: osdate)
---@param options? { debug?: boolean }
---Creates a new cronjob, scheduling a task to run at fixed times or intervals.
---Supports numbers, any value `*`, lists `1,2,3`, ranges `1-3`, and steps `*/4`.
---Day of the week is a range of `1-7` starting from Sunday and allows short-names (i.e. sun, mon, tue).
---@note maxDelay: Maximum allowed delay in seconds before skipping (0 to disable)
function lib.cron.new(expression, job, options)
   if not job or type(job) ~= 'function' then
      error(string.format("Job must be a function, received %s", type(job)))
   end

   local min, hr, dy, mth, wdy = string.strsplit(' ', string.lower(expression))
   ---@type QsTask
   local task = setmetatable(options or {}, TaskScheduler)

   task.expression = expression
   task.minute = parseCronUnit(min, 'min')
   task.hour = parseCronUnit(hr, 'hour')
   task.day = parseCronUnit(dy, 'day')
   task.month = parseCronUnit(mth, 'month')
   task.weekday = parseCronUnit(wdy, 'wday')
   task.id = #scheduledTasks + 1
   task.job = job
   task.lastRun = nil
   task.maxDelay = task.maxDelay or 2
   scheduledTasks[task.id] = task
   task:activate()

   return task
end

-- Reschedules any inactive tasks daily.
lib.cron.new('0 0 * * *', function()
   for i = 1, #scheduledTasks do
      local task = scheduledTasks[i]
      if not task.isActive then
         task:activate()
      end
   end
end)

return lib.cron
