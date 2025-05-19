--[[
   init.lua
   Core bootstrap and API module for qs_lib integration.

   Copyright (C) 2024 Emanuel_Dev <https://github.com/emanuel_dev>
   Licensed under LGPL-3.0-or-later <https://www.gnu.org/licenses/lgpl-3.0.en.html>
--]]

function noop() end

cache = {
   game = GetGameName(),
   resource = GetCurrentResourceName(),
}

--- @class QSLibCore
--- @field private config QSLibConfig
--- @field private modules table<string, any>
--- @field private cache QSLibCache
--- @field private intervals table<number, number>
--- @field private export any
local QSLibCore = {}
QSLibCore.__index = QSLibCore

--- @class QSLibConfig
--- @field libraryName string
--- @field requiredLuaVersion string
--- @field resourceName string
--- @field context 'client' | 'server'

--- @class QSLibCache
--- @field game string
--- @field resource string
--- @field playerId? number
--- @field serverId? number

--- Creates a new QSLibCore instance.
--- @param config? QSLibConfig
--- @return QSLibCore
function QSLibCore.new(config)
   local self = setmetatable({}, QSLibCore)
   self.config = config or {
      libraryName = 'qs_lib',
      requiredLuaVersion = '5.4',
      resourceName = GetCurrentResourceName(),
      context = IsDuplicityVersion() and 'server' or 'client',
   }
   self.modules = {}
   self.cache = { game = GetGameName(), resource = GetCurrentResourceName() }
   self.intervals = {}
   self.export = exports[self.config.libraryName]
   return self
end

--- Validates the runtime environment.
--- @private
function QSLibCore:_validateEnvironment()
   if not _VERSION:match(self.config.requiredLuaVersion) then
      error(string.format('Lua %s is required. Check resource manifest.', self.config.requiredLuaVersion), 2)
   end

   if self.config.resourceName == self.config.libraryName then
      print(string.format('^3%s is the library resource. Skipping initialization.^0', self.config.resourceName))
      return false
   end

   if _ENV.lib and _ENV.lib.name == self.config.libraryName then
      error(string.format('Duplicate %s load detected in %s. Fix fxmanifest.lua.', self.config.libraryName, self.config.resourceName), 2)
   end

   if GetResourceState(self.config.libraryName) ~= 'started' then
      error(string.format('%s must be started before %s.', self.config.libraryName, self.config.resourceName), 0)
   end

   if not self.export then
      error(string.format('No exports for %s found.', self.config.libraryName), 2)
   end

   local status, err = pcall(self.export.hasLoaded)
   if not status or err ~= true then
      error(err or string.format('%s initialization failed.', self.config.libraryName), 2)
   end

   if msgpack and msgpack.setoption then
      msgpack.setoption('ignore_invalid', true)
   end

   return true
end

--- Carga un módulo dinámicamente.
--- @private
--- @param moduleName string
--- @return any
function QSLibCore:_loadModule(moduleName)
   local baseDir = "modules"
   local dir = string.format('%s/%s', baseDir, self.config.context)
   local sharedDir = string.format('%s/shared', baseDir)
   -- local chunk, shared = LoadResourceFile(self.config.libraryName, string.format('%s/%s.lua', dir, self.config.context)), LoadResourceFile(self.config.libraryName, string.format('%s/shared.lua', dir))
   local chunk = LoadResourceFile(self.config.libraryName, string.format('%s/%s.lua', dir, moduleName))
   local shared = LoadResourceFile(self.config.libraryName, string.format('%s/%s.lua', sharedDir, moduleName))

   if shared then chunk = chunk and string.format('%s\n%s', shared, chunk) or shared end
   if chunk then
      local fn, err = load(chunk, string.format('@@%s/modules/%s/%s.lua', self.config.libraryName, self.config.context, moduleName))
      if not fn then
         fn, err = load(shared, string.format('@@%s/modules/shared/%s.lua', self.config.libraryName, moduleName))
         if not fn then error(string.format('Failed to load module %s: %s', moduleName, err), 3) end
      end

      local result = fn()
      return result or noop
   end
end

--- Provides dynamic module access.
--- @private
--- @param index string
--- @param ... any
--- @return any
function QSLibCore:_resolveModule(index, ...)
   local module = self.modules[index]
   if not module then
      module = self:_loadModule(index)
      if not module then
         local function fallback(...) return self.export[index](nil, ...) end
         self.modules[index] = ... and function() end or fallback
         return fallback
      end
      self.modules[index] = module
   end
   return module
end

--- Initializes client-specific features.
--- @private
function QSLibCore:_setupClient()
   self.cache.playerId = PlayerId()
   self.cache.serverId = GetPlayerServerId(self.cache.playerId)

   local notifyEvent = ('__qs_notify_%s'):format(self.config.resourceName)
   RegisterNetEvent(notifyEvent, function(data)
      if _ENV.locale and data.title then
         data.title = _ENV.locale(data.title) or data.title
      end
      if _ENV.locale and data.description then
         data.description = _ENV.locale(data.description) or data.description
      end
      self.export:notify(data)
   end)
end

--- Initializes server-specific features.
--- @private
function QSLibCore:_setupServer()
   self.modules.notify = function(playerId, data)
      TriggerClientEvent(('__qs_notify_%s'):format(self.config.resourceName), playerId, data)
   end

   local entitySources = {
      CPed = GetAllPeds,
      CObject = GetAllObjects,
      CVehicle = GetAllVehicles,
   }

   self.modules.GetGamePool = function(entityType)
      local sourceFn = entitySources[entityType]
      return sourceFn and sourceFn() or {}
   end

   self.modules.GetActivePlayers = function()
      local count = GetNumPlayerIndices()
      local activeList = table.create(count, 0)
      for idx = 0, count - 1 do
         activeList[idx + 1] = tonumber(GetPlayerFromIndex(idx))
      end
      return activeList
   end
end

--- Sets up interval management.
--- @private
function QSLibCore:_setupIntervals()
   _ENV.SetInterval = function(callback, interval, ...)
      interval = interval or 0
      if type(interval) ~= 'number' then
         error(string.format('Interval must be a number, got %s', type(interval)), 2)
      end

      if type(callback) == 'number' and self.intervals[callback] then
         self.intervals[callback] = interval
         return
      end

      if type(callback) ~= 'function' then
         error(string.format('Callback must be a function, got %s', type(callback)), 2)
      end

      local args = { ... }
      local id
      Citizen.CreateThreadNow(function(ref)
         id = ref
         self.intervals[id] = interval
         while self.intervals[id] >= 0 do
            Wait(self.intervals[id])
            callback(table.unpack(args))
         end
         self.intervals[id] = nil
      end)
      return id
   end

   _ENV.ClearInterval = function(id)
      if type(id) ~= 'number' then
         error(string.format('Interval ID must be a number, got %s', type(id)), 2)
      end
      if not self.intervals[id] then
         error(string.format('No interval with ID %s exists', id), 2)
      end
      self.intervals[id] = -1
   end
end

--- Sets up cache management.
--- @private
function QSLibCore:_setupCache()
   local cacheEvents = {}
   local cacheMeta = {
      __index = lib.context == 'client' and function(t, key)
         cacheEvents[key] = {}
         AddEventHandler(('qs_lib:cache:%s'):format(key), function(value)
            local oldValue = t[key]
            for _, cb in ipairs(cacheEvents[key]) do
               Citizen.CreateThreadNow(function() cb(value, oldValue) end)
            end
            t[key] = value
         end)
         t[key] = self.export.cache(nil, key) or false
         return t[key]
      end or nil,
      __call = function(t, key, func, timeout)
         local value = rawget(t, key)
         if value == nil then
            value = func()
            rawset(t, key, value)
            if timeout then
               SetTimeout(timeout, function() t[key] = nil end)
            end
         end
         return value
      end
   }
   self.cache = setmetatable({
      game = self.cache.game,
      resource = self.cache.resource,
   }, cacheMeta)
   self.modules.onCache = function(key, cb)
      if not cacheEvents[key] then
         cacheMeta.__index(self.cache, key)
      end
      table.insert(cacheEvents[key], cb)
   end
   cache = self.cache
   _ENV.cache = self.cache
   lib.onCache = self.modules.onCache
end

function QSLibCore:initializeBridges()
   if self.bridgeToRefreshSystem then
      local bridgeType = self.bridgeToRefreshSystem
      local bridgeResource = self.bridgeData[bridgeType]

      if lib.table.contains(self.bridgeData.preloadedTypes, bridgeType) then
         lib.print.debug(string.format('^3%s bridge is preloaded. Skipping initialization.^0', bridgeType))
         return
      end

      -- check if the bridge type its on the list of bridge types, if not or if in the list of preloaded then return
      if not lib.table.contains(self.bridgeData.bridgeTypes, bridgeType) then
         lib.print.debug(string.format('^3%s bridge not configured to auto load. Check settings.^0', bridgeType))
         return
      end

      if not bridgeResource then
         print(string.format('^3%s bridge not found. Check settings.^0', bridgeType))
         return
      end
      local bridge = lib.loadBridge(bridgeType, bridgeResource, self.config.context, true)
      if not bridge then
         print(string.format('^3%s bridge not found. Check settings.^0', bridgeType))
         return
      end
      self.modules[bridgeType] = bridge
      self.bridgeToRefreshSystem = nil
      return
   else
      -- lib.print.info('Initializing bridges...', self.bridgeData)
      local bridgeData = self.bridgeData
      self.modules = {}
      for _, bridgeType in ipairs(bridgeData.bridgeTypes) do
         local bridgeResource = bridgeData.bridgeResourceOverride[bridgeType] and bridgeData[bridgeData.bridgeResourceOverride[bridgeType]] or bridgeData[bridgeType]
         local bridge = lib.loadBridge(bridgeType, bridgeResource, self.config.context, true)
         if not bridge then
            print(string.format('^3%s bridge not found. Check settings.^0', bridgeType))
            return
         end
         self.modules[bridgeType] = bridge
      end
   end
end

--- Initializes the core system.
function QSLibCore:initialize()
   if not self:_validateEnvironment() then return end
   print(string.format('^3Initializing %s with %s...^0', self.config.resourceName, self.config.libraryName))
   local libMeta = {
      __index = function(t, k) return self:_resolveModule(k) end,
      __call = function(t, _, k, ...) return self:_resolveModule(k, ...) end
   }
   _ENV.lib = setmetatable({ name = self.config.libraryName, context = self.config.context }, libMeta)
   require = lib.require

   -- AUTODETECT SCRIPTS AND FRAMEWORKS IMPORTING SETTINGS
   local settings = require 'src.settings'
   lib.settings = settings

   local bridgeData = require 'src.autodetect'
   self.bridgeData = bridgeData
   lib.bridge = bridgeData

   -- FRAMEWORKS BRIDGE
   local frameworkBridge = lib.loadBridge('framework', lib.bridge.framework, 'shared')

   ---@diagnostic disable-next-line: param-type-mismatch
   lib.framework = setmetatable(frameworkBridge, {
      __index = function(self, index)
         -- print(index)
         local fw_obj = frameworkBridge.getObject()
         return fw_obj[index]
      end
   })
   lib.fw = lib.framework
   lib.FW = lib.framework

   self:_setupIntervals()
   self:_setupCache()
   if self.config.context == 'client' then
      self:_setupClient()
   else
      self:_setupServer()
   end

   self:initializeBridges()

   AddEventHandler("qs_lib:bridge:refreshBridge", function(systemType, data)
      self.bridgeToRefreshSystem = systemType
      lib.bridge = data
      self.bridgeData = data
      self:initializeBridges()
   end)

   for i = 1, GetNumResourceMetadata(self.config.resourceName, 'qs_lib') do
      local name = GetResourceMetadata(self.config.resourceName, 'qs_lib', i - 1)
      if not self.modules[name] then
         local module = self:_loadModule(name)
         if type(module) == 'function' then
            pcall(module)
         end
      end
   end

   print(string.format('^2%s initialized with %s dependency.^0', self.config.resourceName, self.config.libraryName))
end

-- Bootstrap the system
QSLibCore.new():initialize()
