-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

local tbl = require 'modules.shared.table'

-- Resource types and bridge configuration data
local data = {
   bridgeTypes = { 'fuel', 'inventory', 'keys', 'player', 'time' }, -- this bridges will load on startup of the resource (NOT IN THE LIB, FOR THE LIB YOU WILL USE THE lib.loadBridge)
   preloadedTypes = { 'framework' },                                -- this bridges are preloaded on the qs_lib/init.lua, so, its not needed load it on the script startup again and has custom logic to load and get the shared object of the framework in this case
   bridgeResourceOverride = { player = 'framework' },               -- this override the bridge resource map, in this case the player bridge has the scructute /player/<framework> and the resource is the framework, so, we need to override the resource name to load the bridge and not have an specific resource list
   -- NOTE FOR DEVELOPERS: If you need to add a new thing here, make sure the name is not on the bridge types or its a key on the resourceMap, if so the script will override an bridge or will broke the lib...
}

-- Mapping of system types to their respective resources
local resourceMap = {
   framework = { 'es_extended', 'qbx_core', 'qb-core', 'nd-framework' },
   fuel = { 'cdn-fuel', 'LegacyFuel', 'ox_fuel', 'ps-fuel', 'Renewed-Fuel', 'ti_fuel', 'x-fuel', 'wasabi_fuel' },
   inventory = { 'dirk_inventory', 'ox_inventory', 'qb-inventory', 'qs-inventory', 'codem-inventory', 'tgiann_inventory', 'mf-inventory', 'core_inventory' },
   keys = { 'cd_garage', 'MrNewbVehicleKeys', 'okokGarage', 'qb-vehiclekeys', 'qbx_vehiclekeys', 'qs-vehiclekeys', 'Renewed-Vehiclekeys', 't1ger_keys', 'vehicles_keys', 'wasabi_carlock', 'ludaro-keys' },
   time = { 'av_weather', 'cd_easytime', 'qb-weathersync', 'Renewed-Weathersync', 'vSync', 'wasabi_wheather' },

   -- target = { 'ox_target', 'qb-target', 'q-target', 'bt-target' },
   -- interact = { 'sleepless_interact' },
   -- phone = { 'lb-phone', 'qb-phone', 'gksphone', 'high-phone', 'npwd' },
   -- garage = { 'qb-garages', 'wasabi_garage', 'renewed-garage' },
   -- clothing = { 'qb-clothing', 'rcore_clothing', 'illenium_appearance', 'fivem-appearance', 'dirk_charCreator', 'tgiann_clothing' },
   -- ambulance = { 'qb-ambulancejob', 'wasabi_ambulance', 'core_ambulance' },
   -- prison = { 'qb-prison', 'rcore_prison', 'wasabi_jail' },
   -- dispatch = { 'bub_mdt', 'cd_dispatch', 'linden_outlawalert', 'qs-dispatch', 'ps-dispatch', 'tk_dispatch' },
   -- skills = { 'sd_skills', 'evolent_skills', 'core_skills', 'B1-skillz', 'skill_system_v1.5', 'skillsystem_v3', 'boii_skills', 'skillsystem_v2', 'ot_skill_system' },
}

-- Store autodetected resources
local detectedResources = {}

-- Update bridge data with autodetected resources and convar overrides
local function reloadAutodetect(autodetected)
   for system, resource in pairs(autodetected) do
      local convarKey = ('qs_lib:%s'):format(system)
      local value
      if resource == false then
         value = false
      else
         local convarValue = GetConvar(convarKey, resource)
         value = (convarValue == 'false') and false or convarValue
      end
      data[system] = value
   end
end

-- Detect active resources for each system type
local function performInitialDetection()
   -- division of "-"
   lib.print.debug(lib.print.separator())
   lib.print.debug('Performing initial autodetection of resources')
   for systemType, resourceList in pairs(resourceMap) do
      for _, resName in ipairs(resourceList) do
         local resState = GetResourceState(resName)
         lib.print.debug(('Resource %s, state: %s'):format(resName, resState))
         if resState == 'starting' or resState == 'started' then
            detectedResources[systemType] = resName
            goto nextSystem
         elseif systemType == 'framework' and resState ~= 'missing' then
            detectedResources[systemType] = resName
            goto nextSystem
         end
      end
      detectedResources[systemType] = false
      ::nextSystem::
   end
   lib.print.debug(lib.print.separator())
   reloadAutodetect(detectedResources)
end

-- Find the system type for a given resource
local function findResourceInMap(resourceName)
   for systemType, resourceList in pairs(resourceMap) do
      if tbl.contains(resourceList, resourceName) then  -- Using tbl.contains for table lookup
         if not tbl.contains(data.bridgeTypes, systemType) and GetCurrentResourceName() ~= lib.name then
            lib.print.warn(('System type %s for resource %s is not in bridgeTypes'):format(systemType, resourceName))
            return nil
         end
         return systemType
      end
   end
   return nil
end

-- Update resource status and log changes
local function updateResourceStatus(resourceName, systemType, isStarting)
   if not systemType then return end

   local currentResource = GetCurrentResourceName()
   local resState = GetResourceState(resourceName)

   if isStarting and (resState == 'starting' or resState == 'started') then
      detectedResources[systemType] = resourceName
      if currentResource == lib.name then
         lib.print.info(('Resource %s (type: %s) started and now used by qs_lib'):format(resourceName, systemType))
      end
   elseif not isStarting and detectedResources[systemType] == resourceName then
      detectedResources[systemType] = false
      if currentResource == lib.name then
         lib.print.info(('Resource %s (type: %s) stopped and no longer used by qs_lib'):format(resourceName, systemType))
      end
   end

   reloadAutodetect(detectedResources)
   if currentResource == lib.name then
      TriggerEvent('qs_lib:bridge:refreshBridge', systemType, data)
   end
end

-- Set up event handlers for resource start/stop
local function setupEventHandlers()
   AddEventHandler('onResourceStart', function(resourceName)
      Citizen.Wait(500)  -- Reduced delay for faster response
      updateResourceStatus(resourceName, findResourceInMap(resourceName), true)
   end)

   AddEventHandler('onResourceStop', function(resourceName)
      Citizen.Wait(500)  -- Reduced delay for faster response
      updateResourceStatus(resourceName, findResourceInMap(resourceName), false)
   end)
end

-- Initialize detection and event handlers
performInitialDetection()
setupEventHandlers()

return data
