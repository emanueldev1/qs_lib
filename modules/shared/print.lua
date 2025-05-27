-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

---@enum LogLevel
local LogLevel = {
   ERROR = 1,
   WARN = 2,
   INFO = 3,
   VERBOSE = 4,
   DEBUG = 5,
}

local logPrefixes = {
   '[ERROR]',
   '[WARN]',
   '[INFO]',
   '[VERBOSE]',
   '[DEBUG]',
}

local logColors = {
   '^1',
   '^3',
   '^7',
   '^4',
   '^6',
}

local globalConvar = 'qs:loglevel'

local function fetchLogLevel()
   local resourceConvar = 'qs:loglevel:' .. cache.resource
   return LogLevel[GetConvar(resourceConvar, GetConvar(globalConvar, 'INFO')):upper()] or LogLevel.INFO
end

local currentLogLevel = fetchLogLevel()
local logTemplate = ('^5[%s] %%s%%s ^6[%%s:%%s] %%s%%s^7'):format(cache.resource)

local function handleSerializationError(reason, value)
   if type(value) == 'function' then return tostring(value) end
   return reason
end

local jsonConfig = { sort_keys = true, indent = true, exception = handleSerializationError }

---Logs messages to the console based on the current log level.
---@param level LogLevel
---@param ... any
local function logMessage(level, ...)
   if level > currentLogLevel then return end

   local arguments = { ... }
   for i = 1, #arguments do
      local arg = arguments[i]
      arguments[i] = type(arg) == 'table' and json.encode(arg, jsonConfig) or tostring(arg)
   end

   local callerInfo = debug.getinfo(3, "Sl")
   local fullSource = callerInfo.source or "unknown"
   local lineNumber = callerInfo.currentline or -1
   local slashIndex = fullSource:find("/")
   local shortSource = slashIndex and fullSource:sub(slashIndex + 1) or fullSource
   local logMessage = logTemplate:format(logColors[level], logPrefixes[level], shortSource, lineNumber, logColors[level], table.concat(arguments, '\t'))

   print(logMessage)
end

local function separator(length)
   local sep = ('─'):rep(length or 30)
   return sep
end

local logger = {}
logger.error = function(...) logMessage(LogLevel.ERROR, ...) end
logger.warn = function(...) logMessage(LogLevel.WARN, ...) end
logger.info = function(...) logMessage(LogLevel.INFO, ...) end
logger.verbose = function(...) logMessage(LogLevel.VERBOSE, ...) end
logger.debug = function(...) logMessage(LogLevel.DEBUG, ...) end
logger.separator = function(length) return separator(length) end

-- Update the log level dynamically when the convar changes
if AddConvarChangeListener then
   AddConvarChangeListener('qs:loglevel*', function(convarName, _)
      if convarName ~= resourceConvar and convarName ~= globalConvar then return end
      currentLogLevel = fetchLogLevel()
   end)
else
   logMessage(LogLevel.VERBOSE, 'Convar change listener not available, log level will not update dynamically.')
end

return logger
