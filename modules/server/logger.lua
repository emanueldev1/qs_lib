-- logger.lua: Facilitates logging to external services in FiveM.
-- This module supports logging to services like Datadog, FiveManage, and Loki, with configurable endpoints, authentication, and batching for efficient log submission.

-- Buffer for batching logs before sending to the logging service.
local logBuffer
local logBufferSize = 0

-- Identifies the logging service to use, defaulting to 'datadog'.
local logService = GetConvar('qs:logger', 'datadog')

-- Removes color codes and special formatting from a string.
-- @param input string The input string to clean.
-- @return string The cleaned string without color codes.
local function cleanString(input)
   input = string.gsub(input, "%^%d", "")           -- Remove ^[0-9] color codes.
   input = string.gsub(input, "%^#[%dA-Fa-f]+", "") -- Remove ^#[0-9A-F] color codes.
   input = string.gsub(input, "~[%a]~", "")         -- Remove ~[a-z]~ formatting.
   return input
end

-- Hostname for logs, cleaned of any color codes.
local hostName = cleanString(GetConvar('qs:logger:hostname', GetConvar('sv_projectName', 'fxserver')))

-- Base64 character set for encoding.
local base64Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

-- Encodes a string into base64 format.
-- @param data string The string to encode.
-- @return string The base64-encoded string.
local function encodeToBase64(data)
   return ((data:gsub(".", function(char)
      local binary = ""
      local byte = char:byte()
      for i = 8, 1, -1 do
         binary = binary .. (byte % 2 ^ i - byte % 2 ^ (i - 1) > 0 and "1" or "0")
      end
      return binary
   end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(bits)
      if #bits < 6 then return "" end
      local value = 0
      for i = 1, 6 do
         value = value + (bits:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
      end
      return base64Alphabet:sub(value + 1, value + 1)
   end) .. ({ "", "==", "=" })[#data % 3 + 1])
end

-- Creates an HTTP Basic Authorization header using a username and password.
-- @param user string The username for authentication.
-- @param password string The password for authentication.
-- @return string The Authorization header value.
local function buildAuthHeader(user, password)
   return "Basic " .. encodeToBase64(user .. ":" .. password)
end

-- Logs a warning for unsuccessful HTTP responses from the logging service.
-- @param url string The endpoint URL where the logs were sent.
-- @param status number The HTTP status code received.
-- @param details any The response details or error message.
local function warnOnFailedRequest(url, status, details)
   warn(string.format("Could not send logs to %s (status code: %s)\n%s", url, status, json.encode(details, { indent = true })))
end

-- Stores player data for tagging logs with identifiers.
local playerInfoCache = {}

-- Clears player data when a player disconnects.
AddEventHandler('playerDropped', function()
   playerInfoCache[source] = nil
end)

-- Formats tags for logging, including player identifiers.
-- @param playerSrc number The source ID of the player.
-- @param extraTags string|nil Additional tags to include.
-- @return string|nil The formatted tags string.
local function formatLogTags(playerSrc, extraTags)
   if type(playerSrc) == 'number' and playerSrc > 0 then
      local cachedData = playerInfoCache[playerSrc]
      if not cachedData then
         local tagsList = { string.format("username:%s", GetPlayerName(playerSrc)) }
         local tagCount = 1
         ---@cast playerSrc string
         for i = 0, GetNumPlayerIdentifiers(playerSrc) - 1 do
            local identifier = GetPlayerIdentifier(playerSrc, i)
            if not identifier:find('ip') then
               tagCount = tagCount + 1
               tagsList[tagCount] = identifier
            end
         end
         cachedData = table.concat(tagsList, ',')
         playerInfoCache[playerSrc] = cachedData
      end
      extraTags = extraTags and string.format("%s,%s", extraTags, cachedData) or cachedData
   end
   return extraTags
end

if logService == 'fivemanage' then
   local apiKey = GetConvar('fivemanage:key', '')
   if apiKey ~= '' then
      local logEndpoint = 'https://api.fivemanage.com/api/logs/batch'
      local requestHeaders = {
         ['Content-Type'] = 'application/json',
         ['Authorization'] = apiKey,
         ['User-Agent'] = 'qs_lib'
      }

      -- Logs a message to FiveManage, batching requests for efficiency.
      -- @param playerSrc number The source ID of the player triggering the log.
      -- @param evt string The event or service name for the log.
      -- @param msg string The log message.
      -- @param ... any Additional tags to include.
      function lib.logger(playerSrc, evt, msg, ...)
         if not logBuffer then
            logBuffer = {}
            SetTimeout(600, function()
               PerformHttpRequest(logEndpoint, function(status, _, _, response)
                  if status ~= 200 then
                     if type(response) == 'string' then
                        response = json.decode(response) or response
                        warnOnFailedRequest(logEndpoint, status, response)
                     end
                  end
               end, 'POST', json.encode(logBuffer), requestHeaders)
               logBuffer = nil
               logBufferSize = 0
            end)
         end

         logBufferSize = logBufferSize + 1
         logBuffer[logBufferSize] = {
            level = "info",
            message = msg,
            resource = cache.resource,
            metadata = {
               hostname = hostName,
               service = evt,
               source = playerSrc,
               tags = formatLogTags(playerSrc, ... and string.strjoin(',', string.tostringall(...)) or nil),
            }
         }
      end
   end
end

if logService == 'datadog' then
   local apiKey = GetConvar('datadog:key', ''):gsub("[\'\"]", '')
   if apiKey ~= '' then
      local logEndpoint = string.format("https://http-intake.logs.%s/api/v2/logs", GetConvar('datadog:site', 'datadoghq.com'))
      local requestHeaders = {
         ['Content-Type'] = 'application/json',
         ['DD-API-KEY'] = apiKey,
      }

      -- Logs a message to Datadog, batching requests for efficiency.
      -- @param playerSrc number The source ID of the player triggering the log.
      -- @param evt string The event or service name for the log.
      -- @param msg string The log message.
      -- @param ... any Additional tags to include.
      function lib.logger(playerSrc, evt, msg, ...)
         if not logBuffer then
            logBuffer = {}
            SetTimeout(600, function()
               PerformHttpRequest(logEndpoint, function(status, _, _, response)
                  if status ~= 202 then
                     if type(response) == 'string' then
                        response = json.decode(response:sub(10)) or response
                        warnOnFailedRequest(logEndpoint, status, type(response) == 'table' and response.errors[1] or response)
                     end
                  end
               end, 'POST', json.encode(logBuffer), requestHeaders)
               logBuffer = nil
               logBufferSize = 0
            end)
         end

         logBufferSize = logBufferSize + 1
         logBuffer[logBufferSize] = {
            hostname = hostName,
            service = evt,
            message = msg,
            resource = cache.resource,
            ddsource = tostring(playerSrc),
            ddtags = formatLogTags(playerSrc, ... and string.strjoin(',', string.tostringall(...)) or nil),
         }
      end
   end
end

if logService == 'loki' then
   local lokiUser = GetConvar('loki:user', '')
   local lokiPass = GetConvar('loki:password', GetConvar('loki:key', ''))
   local lokiUrl = GetConvar('loki:endpoint', '')
   local lokiTenant = GetConvar('loki:tenant', '')
   local urlPattern = '^http[s]?://'
   local requestHeaders = {
      ['Content-Type'] = 'application/json'
   }

   if lokiUser ~= '' then
      requestHeaders['Authorization'] = buildAuthHeader(lokiUser, lokiPass)
   end

   if lokiTenant ~= '' then
      requestHeaders['X-Scope-OrgID'] = lokiTenant
   end

   if not lokiUrl:find(urlPattern) then
      lokiUrl = 'https://' .. lokiUrl
   end

   local logEndpoint = string.format("%s/loki/api/v1/push", lokiUrl)

   -- Converts a comma-separated key-value pair string into a table.
   -- Example: `discord:blah,fivem:blah` -> `{discord="blah", fivem="blah"}`
   -- @param tags string The tags string to parse.
   -- @return table The parsed key-value pair table.
   local function parseTagsToTable(tags)
      if not tags or type(tags) ~= 'string' then
         return {}
      end
      local tempList = { string.strsplit(',', tags) }
      local resultTable = table.create(0, #tempList)

      for _, entry in pairs(tempList) do
         local key, val = string.strsplit(':', entry)
         resultTable[key] = val
      end

      return resultTable
   end

   -- Logs a message to Loki, batching requests for efficiency.
   -- @param playerSrc number The source ID of the player triggering the log.
   -- @param evt string The event or service name for the log.
   -- @param msg string The log message.
   -- @param ... any Additional tags to include.
   function lib.logger(playerSrc, evt, msg, ...)
      if not logBuffer then
         logBuffer = {}
         SetTimeout(600, function()
            local tempLogs = {}
            for _, logEntry in pairs(logBuffer) do
               tempLogs[#tempLogs + 1] = logEntry
            end

            local requestBody = json.encode({ streams = tempLogs })
            PerformHttpRequest(logEndpoint, function(status, _, _, _)
               if status ~= 204 then
                  warnOnFailedRequest(logEndpoint, status, string.format("%s", status, requestBody))
               end
            end, 'POST', requestBody, requestHeaders)

            logBuffer = nil
         end)
      end

      local timestampNano = string.format("%s000000000", os.time(os.date('*t')))
      local logValues = { message = msg }
      local tags = formatLogTags(playerSrc, ... and string.strjoin(',', string.tostringall(...)) or nil)
      local tagsTable = parseTagsToTable(tags)

      for key, val in pairs(tagsTable) do
         logValues[key] = val
      end

      local logEntry = {
         stream = {
            server = hostName,
            resource = cache.resource,
            event = evt
         },
         values = {
            { timestampNano, json.encode(logValues) }
         }
      }

      if not logBuffer then
         logBuffer = {}
      end

      if not logBuffer[evt] then
         logBuffer[evt] = logEntry
      else
         local entryIndex = #logBuffer[evt].values + 1
         logBuffer[evt].values[entryIndex] = { timestampNano, json.encode(logValues) }
      end
   end
end

if logService == 'sentry' then
   local sentryDsn = GetConvar('sentry:dsn', '')
   if sentryDsn ~= '' then
      local logEndpoint = string.format("%s/api/store/", sentryDsn:match("^(https?://[^@]+@[^/]+)/%d+"))
      local requestHeaders = {
         ['Content-Type'] = 'application/json',
         ['User-Agent'] = 'qs_lib',
         ['X-Sentry-Auth'] = string.format("Sentry sentry_version=7, sentry_client=qs_lib, sentry_key=%s", sentryDsn:match("https?://([^:]+)"))
      }

      -- Logs a message to Sentry, batching requests for efficiency.
      -- @param playerSrc number The source ID of the player triggering the log.
      -- @param evt string The event or service name for the log.
      -- @param msg string The log message.
      -- @param ... any Additional tags to include.
      function lib.logger(playerSrc, evt, msg, ...)
         if not logBuffer then
            logBuffer = {}
            SetTimeout(600, function()
               PerformHttpRequest(logEndpoint, function(status, _, _, response)
                  if status ~= 200 then
                     if type(response) == 'string' then
                        response = json.decode(response) or response
                        warnOnFailedRequest(logEndpoint, status, response)
                     end
                  end
               end, 'POST', json.encode(logBuffer), requestHeaders)
               logBuffer = nil
               logBufferSize = 0
            end)
         end

         logBufferSize = logBufferSize + 1
         logBuffer[logBufferSize] = {
            message = msg,
            level = "info",
            logger = evt,
            extra = {
               resource = cache.resource,
               source = tostring(playerSrc),
               tags = formatLogTags(playerSrc, ... and string.strjoin(',', string.tostringall(...)) or nil),
            },
            timestamp = os.time(),
            server_name = hostName
         }
      end
   end
end

if logService == 'fivemanage' then
   local apiKey = GetConvar('fivemanage:key', '')
   if apiKey ~= '' then
      local logEndpoint = 'https://api.fivemanage.com/api/logs'
      local requestHeaders = {
         ['Content-Type'] = 'application/json',
         ['Authorization'] = apiKey,   -- No Bearer prefix, as per the documentation example
         ['User-Agent'] = 'qs_lib'
      }

      -- Logs a message to FiveManage, sending each log immediately as an individual request.
      -- @param playerSrc number The source ID of the player triggering the log.
      -- @param evt string The event or service name for the log.
      -- @param msg string The log message.
      -- @param ... any Additional tags to include.
      function lib.logger(playerSrc, evt, msg, ...)
         local logData = {
            level = "info",
            message = msg,
            metadata = {
               action = string.format("%s (event: %s, resource: %s)", evt, cache.resource),
               hostname = hostName,
               source = playerSrc,
               tags = formatLogTags(playerSrc, ... and string.strjoin(',', string.tostringall(...)) or nil),
            }
         }

         PerformHttpRequest(logEndpoint, function(status, _, _, response)
            if status ~= 200 then
               if type(response) == 'string' then
                  response = json.decode(response) or response
                  warnOnFailedRequest(logEndpoint, status, response)
               end
            end
         end, 'POST', json.encode(logData), requestHeaders)
      end
   end
end

return lib.logger
