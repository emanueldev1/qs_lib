local context = IsDuplicityVersion() and 'server' or 'client'

lib = setmetatable({
   name = 'qs_lib',
   context = context,
}, {
   __newindex = function(self, key, fn)
      rawset(self, key, fn)

      if debug.getinfo(2, 'S').short_src:find('@qs_lib/src') then
         exports(key, fn)
      end
   end,

   __index = function(self, key)
      local baseDir = "modules"
      local dir = ('%s/%s'):format(baseDir, self.context)
      local sharedDir = ('%s/shared'):format(baseDir)
      local chunk = LoadResourceFile(self.name, ('%s/%s.lua'):format(dir, key))
      local shared = LoadResourceFile(self.name, ('%s/%s.lua'):format(sharedDir, key))

      if shared then chunk = chunk and string.format('%s\n%s', shared, chunk) or shared end

      if not chunk then return nil end

      local fn, err = load(chunk, ('@@qs_lib/%s/%s/%s.lua'):format(baseDir, self.context, key))

      if not fn or err then
         return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
      end

      rawset(self, key, fn() or noop)

      return self[key]
   end
})

cache = {
   resource = lib.name,
   game = GetGameName(),
}

if not LoadResourceFile(lib.name, 'web/build/index.html') then
   local err =
   '^1Unable to load UI. Build qs_lib or download the latest release.\n	^3https://github.com/emanueldev1/qs_lib/releases/latest/download/qs_lib.zip^0'
   function lib.hasLoaded() return err end

   error(err)
end

function lib.hasLoaded() return true end

require = lib.require

if not lib.settings then
   -- AUTODETECT SCRIPTS AND FRAMEWORKS IMPORTING SETTINGS
   local settings = require 'src.settings'
   lib.settings = settings
end

local bridgeData = require 'src.autodetect'
lib.bridge = bridgeData

lib.print.debug(bridgeData)

-- FRAMEWORKS BRIDGE
local frameworkBridge = lib.loadBridge('framework', lib.bridge.framework, 'shared')

lib.framework = setmetatable(frameworkBridge, {
   __index = function(self, index)
      local fw_obj = frameworkBridge.getObject()
      -- print(index)
      return fw_obj[index]
   end
})

lib.fw = lib.framework
lib.FW = lib.framework


-- Automatically detects and displays resource settings for specified systems in a server context.
-- Prints a formatted table with system names and their detected values, including version and notes.
-- Optimized for readability, minimal space, and functionality.

function DetectedResourcesLog()
   local version = GetResourceMetadata('qs_lib', 'version') or 'Unknown'
   local detectables = {
      'framework', 'inventory', 'target', 'time', 'keys', 'fuel', 'phone',
      'garage', 'ambulance', 'prison', 'dispatch', 'clothing', 'skills'
   }

   -- Calculate maximum key length for alignment
   local maxKeyLength = 0
   for _, key in ipairs(detectables) do
      maxKeyLength = math.max(maxKeyLength, #key)
   end
   
   lib.print.debug(lib.bridge)

   -- Print formatted detection table
   local border = '┌' .. string.rep('─', 46) .. ''
   print(border)
   print(string.format('│ ^2QS_LIB ^3V%-34s^7', version))
   print('│ ^6RESOURCE AUTO-DETECTION' .. string.rep(' ', 22) .. '^7')
   print('│' .. string.rep('─', 46) .. '')

   for _, system in ipairs(detectables) do
      local value = lib.bridge[system] or 'NOT FOUND'
      local color = value == 'NOT FOUND' and '^1' or '^2'
      local key = string.upper(system)
      print(string.format('│ ^5%-13s %s%-20s^7', key, color, value))
   end

   -- Print footer with notes
   print('│' .. string.rep(' ', 46) .. '')
   print('│ ^7Note: Detection based on GetResourceState fivem native.^7')
   print('│ ^7Override with convars if needed.             ^7')
   print('└' .. string.rep('─', 46) .. '')
end

if context == 'server' then
   CreateThread(function()
      SetTimeout(1000, function()
         DetectedResourcesLog()
      end)
   end)

   RegisterCommand('checkbridge', function(source, args, raw)
      DetectedResourcesLog()
   end, true)
end

lib.print.debug(lib.bridge)
