-- This file contains code adapted from ox_lib, developed by the Overextended team.
-- Original repository: https://github.com/overextended/ox_lib
-- License: GNU Lesser General Public License v3.0 (LGPL-3.0), available at https://www.gnu.org/licenses/lgpl-3.0.html
-- Modifications by emanueldev1 for the qs_lib project, licensed under LGPL-3.0.


-- Module loader for FiveM. Loads Lua scripts and JSON files from resource directories,
-- with support for custom module resolution and caching.

local loaded = {}
local _require = require

-- Package configuration for module resolution
package = {
   path = './?.lua;./?/init.lua', -- Search paths for Lua modules
   preload = {},                  -- Storage for preloaded modules
   loaded = setmetatable({}, {
      __index = loaded,           -- Access cached modules
      __newindex = noop,          -- Prevent direct modification
      __metatable = false         -- Lock metatable
   })
}

-- Extracts resource name and module path from a module identifier.
-- @param moduleId string Module name, possibly prefixed with '@resourceName/'.
-- @return string resource The resource name.
-- @return string modulePath The module path without the prefix.
local function parseModuleSpec(moduleId)
   local resourcePrefix = moduleId:match('^@(.-)/.+')
   if resourcePrefix then
      return resourcePrefix, moduleId:sub(#resourcePrefix + 3)
   end

   local depth = 5 -- !!!IMPORTANT!!! Start at a safe stack depth (this is very important DO NOT CHANGE IT, this indicates to the function how many levels of stack (calls) to go up)
   while true do
      local info = debug.getinfo(depth, 'S')
      if not info or not info.source then
         return cache.resource, moduleId -- Fallback to cached resource
      end

      local source = info.source
      local resource = source:match('^@@([^/]+)/.+')
      if resource and not source:find('^@@qs_lib/modules/require') then
         return resource, moduleId
      end
      depth = depth + 1
   end
end

-- Temporary storage for file data
local cacheBuffer = {}

-- Combines error messages into a single string.
-- @param errorList table Array of error messages.
-- @return string Concatenated error message with newlines.
local function mergeErrors(errorList)
   return table.concat(errorList, "\n\t")
end

-- Clears the temporary storage buffer.
local function clearCache()
   table.wipe(cacheBuffer)
end

-- Searches for a module file in the specified paths.
-- @param name string Module name to locate.
-- @param path string Search path pattern (e.g., './?.lua;./?/init.lua').
-- @return string|nil resourcePath The found file path, or nil if not found.
-- @return string|nil errorMsg Error message if not found.
function package.searchpath(name, path)
   local resource, modulePath = parseModuleSpec(name:gsub('%.', '/'))
   local errors = {}

   for pattern in path:gmatch('[^;]+') do
      local cleanPattern = pattern:gsub('^%./', '')
      local resourcePath = cleanPattern:gsub('?', modulePath:gsub('%.', '/') or modulePath)
      local content = LoadResourceFile(resource, resourcePath)

      if content then
         cacheBuffer.data = content
         cacheBuffer.resource = resource
         return resourcePath
      end

      errors[#errors + 1] = ("missing resource '%s/%s'"):format(resource, resourcePath)
   end

   return nil, mergeErrors(errors)
end

-- Loads a module's Lua code for execution.
-- @param moduleId string Module name to load.
-- @param env table|nil Environment for the module (defaults to _ENV).
-- @return function|nil chunk The executable chunk, or nil if failed.
-- @return string|nil errorMsg Error message if loading fails.
local function retrieveModuleCode(moduleId, env)
   local resourcePath, errorMsg = package.searchpath(moduleId, package.path)
   -- lib.print.debug(('Module %s loaded from %s'):format(moduleId, resourcePath))
   if not resourcePath then
      return nil, errorMsg or 'failed to process module'
   end

   local content = cacheBuffer.data
   local resource = cacheBuffer.resource
   clearCache()
   local chunk, err = load(content, ('@@%s/%s'):format(resource, resourcePath), 't', env or _ENV)
   if not chunk then
      error(err)
   end
   return chunk
end

-- Module resolution strategies
package.searchers = {
   -- Tries loading with native Lua require.
   -- @param moduleId string Module name.
   -- @return function|nil Loader function, or nil if not found.
   -- @return string|nil Error message if not found.
   function(moduleId)
      local success, result = pcall(_require, moduleId)
      if success then
         return result
      end
      return nil, result
   end,
   -- Checks for a preloaded module.
   -- @param moduleId string Module name.
   -- @return function|nil Preload function, or nil if not found.
   -- @return string|nil Error message if not found.
   function(moduleId)
      local preload = package.preload[moduleId]
      if preload then
         return preload
      end
      return nil, ("no preload entry for '%s'"):format(moduleId)
   end,
   -- Loads a module from a resource file.
   -- @param moduleId string Module name.
   -- @return function|nil Loader function, or nil if not found.
   -- @return string|nil Error message if not found.
   function(moduleId)
      return retrieveModuleCode(moduleId)
   end,
}

-- Loads and executes a Lua file without caching.
-- @param filePath string Path to the Lua file.
-- @param env table|nil Environment for execution (defaults to _ENV).
-- @return any Result of executing the file.
-- @error If filePath is not a string or the file is not found.
function lib.load(filePath, env)
   if type(filePath) ~= 'string' then
      error(("file path must be a string, got '%s'"):format(filePath), 2)
   end

   local chunk, errorMsg = retrieveModuleCode(filePath, env)
   if not chunk then
      error(("script '%s' could not be located:\n\t%s"):format(filePath, errorMsg))
   end

   return chunk()
end

-- Loads and decodes a JSON file.
-- @param filePath string Path to the JSON file.
-- @return table Decoded JSON data.
-- @error If filePath is not a string or the file is not found.
function lib.loadJson(filePath)
   if type(filePath) ~= 'string' then
      error(("file path must be a string, got '%s'"):format(filePath), 2)
   end

   local resource, modulePath = parseModuleSpec(filePath:gsub('%.', '/'))
   local jsonPath = ('%s.json'):format(modulePath)
   local data = LoadResourceFile(resource, jsonPath)

   if data then
      return json.decode(data)
   end

   error(("JSON file '%s' could not be found:\n\tmissing '%s/%s'"):format(filePath, resource, jsonPath))
end

-- Loads a module, caching it to avoid reloading.
-- @param modName string Module name, optionally with '@resourceName/' prefix.
-- @return any Loaded module or true if the module returns nil.
-- @error If modName is not a string, cyclic dependency detected, or module not found.
function lib.require(modName)
   if type(modName) ~= 'string' then
      error(("module name must be a string, received '%s'"):format(modName), 3)
   end

   local cachedModule = loaded[modName]
   if cachedModule == '__loading' then
      error(("^1module '%s' has a cyclic reference^0"):format(modName), 2)
   end

   if cachedModule ~= nil then
      return cachedModule
   end

   loaded[modName] = '__loading'
   local errors = {}

   for _, searcher in ipairs(package.searchers) do
      local result, err = searcher(modName)
      if result then
         local value = type(result) == 'function' and result() or result
         loaded[modName] = value or value == nil
         return loaded[modName]
      end
      errors[#errors + 1] = err
   end

   error(mergeErrors(errors))
end

return lib.require
