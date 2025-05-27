-- This file contains code adapted from ox_lib, developed by the Overextended team.
-- Original repository: https://github.com/overextended/ox_lib
-- License: GNU Lesser General Public License v3.0 (LGPL-3.0), available at https://www.gnu.org/licenses/lgpl-3.0.html
-- Modifications by emanueldev1 for the qs_lib project, licensed under LGPL-3.0.

if cache.game == 'redm' then return end

---@class VehicleProperties
---@field model? number
---@field plate? string
---@field plateIndex? number
---@field bodyHealth? number
---@field engineHealth? number
---@field tankHealth? number
---@field fuelLevel? number
---@field oilLevel? number
---@field dirtLevel? number
---@field paintType1? number
---@field paintType2? number
---@field color1? number | number[]
---@field color2? number | number[]
---@field pearlescentColor? number
---@field interiorColor? number
---@field dashboardColor? number
---@field wheelColor? number
---@field wheelWidth? number
---@field wheelSize? number
---@field wheels? number
---@field windowTint? number
---@field xenonColor? number
---@field neonEnabled? boolean[]
---@field neonColor? number | number[]
---@field extras? table<number | string, 0 | 1>
---@field tyreSmokeColor? number | number[]
---@field modSpoilers? number
---@field modFrontBumper? number
---@field modRearBumper? number
---@field modSideSkirt? number
---@field modExhaust? number
---@field modFrame? number
---@field modGrille? number
---@field modHood? number
---@field modFender? number
---@field modRightFender? number
---@field modRoof? number
---@field modEngine? number
---@field modBrakes? number
---@field modTransmission? number
---@field modHorns? number
---@field modSuspension? number
---@field modArmor? number
---@field modNitrous? number
---@field modTurbo? boolean
---@field modSubwoofer? boolean
---@field modSmokeEnabled? boolean
---@field modHydraulics? boolean
---@field modXenon? boolean
---@field modFrontWheels? number
---@field modBackWheels? number
---@field modCustomTiresF? boolean
---@field modCustomTiresR? boolean
---@field modPlateHolder? number
---@field modVanityPlate? number
---@field modTrimA? number
---@field modOrnaments? number
---@field modDashboard? number
---@field modDial? number
---@field modDoorSpeaker? number
---@field modSeats? number
---@field modSteeringWheel? number
---@field modShifterLeavers? number
---@field modAPlate? number
---@field modSpeakers? number
---@field modTrunk? number
---@field modHydrolic? number
---@field modEngineBlock? number
---@field modAirFilter? number
---@field modStruts? number
---@field modArchCover? number
---@field modAerials? number
---@field modTrimB? number
---@field modTank? number
---@field modWindows? number
---@field modDoorR? number
---@field modLivery? number
---@field modRoofLivery? number
---@field modLightbar? number
---@field livery? number
---@field windows? number[]
---@field doors? number[]
---@field tyres? table<number | string, 1 | 2>
---@field bulletProofTyres? boolean
---@field driftTyres? boolean

lib = lib or {}

-- Módulo interno para la gestión de propiedades
local PropertyUtils = {}

-- Obtiene colores y pinturas del vehículo
function PropertyUtils:FetchVehicleColors(entity)
   local primary, secondary = GetVehicleColours(entity)
   local pearl, wheel = GetVehicleExtraColours(entity)
   local paintPrimary = GetVehicleModColor_1(entity)
   local paintSecondary = GetVehicleModColor_2(entity)

   if GetIsVehiclePrimaryColourCustom(entity) then
      primary = { GetVehicleCustomPrimaryColour(entity) }
   end
   if GetIsVehicleSecondaryColourCustom(entity) then
      secondary = { GetVehicleCustomSecondaryColour(entity) }
   end

   return {
      primary = primary,
      secondary = secondary,
      pearlescent = pearl,
      wheel = wheel,
      paint1 = paintPrimary,
      paint2 = paintSecondary
   }
end

-- Obtiene los extras del vehículo
function PropertyUtils:FetchVehicleExtras(entity)
   local vehicleExtras = {}
   for index = 1, 15 do
      if DoesExtraExist(entity, index) then
         vehicleExtras[index] = IsVehicleExtraTurnedOn(entity, index) and 0 or 1
      end
   end
   return vehicleExtras
end

-- Obtiene el estado de daño del vehículo
function PropertyUtils:FetchVehicleDamage(entity)
   local damageData = { windows = {}, doors = {}, tyres = {} }
   local windowCounter, doorCounter = 0, 0

   for windowIndex = 0, 7 do
      RollUpWindow(entity, windowIndex)
      if not IsVehicleWindowIntact(entity, windowIndex) then
         windowCounter = windowCounter + 1
         damageData.windows[windowCounter] = windowIndex
      end
   end

   for doorIndex = 0, 5 do
      if IsVehicleDoorDamaged(entity, doorIndex) then
         doorCounter = doorCounter + 1
         damageData.doors[doorCounter] = doorIndex
      end
   end

   for tyreIndex = 0, 7 do
      if IsVehicleTyreBurst(entity, tyreIndex, false) then
         damageData.tyres[tyreIndex] = IsVehicleTyreBurst(entity, tyreIndex, true) and 2 or 1
      end
   end

   return damageData
end

-- Obtiene el estado de las luces neón
function PropertyUtils:FetchNeonStatus(entity)
   local neonStatus = {}
   for neonIndex = 0, 3 do
      neonStatus[neonIndex + 1] = IsVehicleNeonLightEnabled(entity, neonIndex)
   end
   return neonStatus
end

-- Obtiene todas las propiedades del vehículo
function lib.getVehicleProperties(vehicle)
   if not DoesEntityExist(vehicle) then return end

   local colorData = PropertyUtils:FetchVehicleColors(vehicle)
   local extrasData = PropertyUtils:FetchVehicleExtras(vehicle)
   local damageData = PropertyUtils:FetchVehicleDamage(vehicle)
   local neonData = PropertyUtils:FetchNeonStatus(vehicle)

   local properties = {
      model = GetEntityModel(vehicle),
      plate = GetVehicleNumberPlateText(vehicle),
      plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
      bodyHealth = math.floor(GetVehicleBodyHealth(vehicle) + 0.5),
      engineHealth = math.floor(GetVehicleEngineHealth(vehicle) + 0.5),
      tankHealth = math.floor(GetVehiclePetrolTankHealth(vehicle) + 0.5),
      fuelLevel = math.floor(GetVehicleFuelLevel(vehicle) + 0.5),
      oilLevel = math.floor(GetVehicleOilLevel(vehicle) + 0.5),
      dirtLevel = math.floor(GetVehicleDirtLevel(vehicle) + 0.5),
      paintType1 = colorData.paint1,
      paintType2 = colorData.paint2,
      color1 = colorData.primary,
      color2 = colorData.secondary,
      pearlescentColor = colorData.pearlescent,
      interiorColor = GetVehicleInteriorColor(vehicle),
      dashboardColor = GetVehicleDashboardColour(vehicle),
      wheelColor = colorData.wheel,
      wheelWidth = GetVehicleWheelWidth(vehicle),
      wheelSize = GetVehicleWheelSize(vehicle),
      wheels = GetVehicleWheelType(vehicle),
      windowTint = GetVehicleWindowTint(vehicle),
      xenonColor = GetVehicleXenonLightsColor(vehicle),
      neonEnabled = neonData,
      neonColor = { GetVehicleNeonLightsColour(vehicle) },
      extras = extrasData,
      tyreSmokeColor = { GetVehicleTyreSmokeColor(vehicle) },
      modSpoilers = GetVehicleMod(vehicle, 0),
      modFrontBumper = GetVehicleMod(vehicle, 1),
      modRearBumper = GetVehicleMod(vehicle, 2),
      modSideSkirt = GetVehicleMod(vehicle, 3),
      modExhaust = GetVehicleMod(vehicle, 4),
      modFrame = GetVehicleMod(vehicle, 5),
      modGrille = GetVehicleMod(vehicle, 6),
      modHood = GetVehicleMod(vehicle, 7),
      modFender = GetVehicleMod(vehicle, 8),
      modRightFender = GetVehicleMod(vehicle, 9),
      modRoof = GetVehicleMod(vehicle, 10),
      modEngine = GetVehicleMod(vehicle, 11),
      modBrakes = GetVehicleMod(vehicle, 12),
      modTransmission = GetVehicleMod(vehicle, 13),
      modHorns = GetVehicleMod(vehicle, 14),
      modSuspension = GetVehicleMod(vehicle, 15),
      modArmor = GetVehicleMod(vehicle, 16),
      modNitrous = GetVehicleMod(vehicle, 17),
      modTurbo = IsToggleModOn(vehicle, 18),
      modSubwoofer = GetVehicleMod(vehicle, 19),
      modSmokeEnabled = IsToggleModOn(vehicle, 20),
      modHydraulics = IsToggleModOn(vehicle, 21),
      modXenon = IsToggleModOn(vehicle, 22),
      modFrontWheels = GetVehicleMod(vehicle, 23),
      modBackWheels = GetVehicleMod(vehicle, 24),
      modCustomTiresF = GetVehicleModVariation(vehicle, 23),
      modCustomTiresR = GetVehicleModVariation(vehicle, 24),
      modPlateHolder = GetVehicleMod(vehicle, 25),
      modVanityPlate = GetVehicleMod(vehicle, 26),
      modTrimA = GetVehicleMod(vehicle, 27),
      modOrnaments = GetVehicleMod(vehicle, 28),
      modDashboard = GetVehicleMod(vehicle, 29),
      modDial = GetVehicleMod(vehicle, 30),
      modDoorSpeaker = GetVehicleMod(vehicle, 31),
      modSeats = GetVehicleMod(vehicle, 32),
      modSteeringWheel = GetVehicleMod(vehicle, 33),
      modShifterLeavers = GetVehicleMod(vehicle, 34),
      modAPlate = GetVehicleMod(vehicle, 35),
      modSpeakers = GetVehicleMod(vehicle, 36),
      modTrunk = GetVehicleMod(vehicle, 37),
      modHydrolic = GetVehicleMod(vehicle, 38),
      modEngineBlock = GetVehicleMod(vehicle, 39),
      modAirFilter = GetVehicleMod(vehicle, 40),
      modStruts = GetVehicleMod(vehicle, 41),
      modArchCover = GetVehicleMod(vehicle, 42),
      modAerials = GetVehicleMod(vehicle, 43),
      modTrimB = GetVehicleMod(vehicle, 44),
      modTank = GetVehicleMod(vehicle, 45),
      modWindows = GetVehicleMod(vehicle, 46),
      modDoorR = GetVehicleMod(vehicle, 47),
      modLivery = GetVehicleMod(vehicle, 48),
      modRoofLivery = GetVehicleRoofLivery(vehicle),
      modLightbar = GetVehicleMod(vehicle, 49),
      livery = GetVehicleLivery(vehicle),
      windows = damageData.windows,
      doors = damageData.doors,
      tyres = damageData.tyres,
      bulletProofTyres = GetVehicleTyresCanBurst(vehicle),
      driftTyres = GetGameBuildNumber() >= 2372 and GetDriftTyresEnabled(vehicle)
   }

   return properties
end

-- Módulo interno para establecer propiedades
local PropertyApplier = {}

-- Aplica colores al vehículo
function PropertyApplier:SetVehicleColors(entity, props, currentPrimary, currentSecondary, currentPearl, currentWheel)
   if props.color1 then
      if type(props.color1) == 'number' then
         ClearVehicleCustomPrimaryColour(entity)
         SetVehicleColours(entity, props.color1, currentSecondary)
      else
         if props.paintType1 then
            SetVehicleModColor_1(entity, props.paintType1, 0, props.pearlescentColor or 0)
         end
         SetVehicleCustomPrimaryColour(entity, props.color1[1], props.color1[2], props.color1[3])
      end
   end

   if props.color2 then
      if type(props.color2) == 'number' then
         ClearVehicleCustomSecondaryColour(entity)
         SetVehicleColours(entity, props.color1 or currentPrimary, props.color2)
      else
         if props.paintType2 then
            SetVehicleModColor_2(entity, props.paintType2, 0)
         end
         SetVehicleCustomSecondaryColour(entity, props.color2[1], props.color2[2], props.color2[3])
      end
   end

   if props.pearlescentColor or props.wheelColor then
      SetVehicleExtraColours(entity, props.pearlescentColor or currentPearl, props.wheelColor or currentWheel)
   end
end

-- Aplica modificaciones al vehículo
function PropertyApplier:SetVehicleMods(entity, props)
   local modList = {
      { index = 0,  value = props.modSpoilers },
      { index = 1,  value = props.modFrontBumper },
      { index = 2,  value = props.modRearBumper },
      { index = 3,  value = props.modSideSkirt },
      { index = 4,  value = props.modExhaust },
      { index = 5,  value = props.modFrame },
      { index = 6,  value = props.modGrille },
      { index = 7,  value = props.modHood },
      { index = 8,  value = props.modFender },
      { index = 9,  value = props.modRightFender },
      { index = 10, value = props.modRoof },
      { index = 11, value = props.modEngine },
      { index = 12, value = props.modBrakes },
      { index = 13, value = props.modTransmission },
      { index = 14, value = props.modHorns },
      { index = 15, value = props.modSuspension },
      { index = 16, value = props.modArmor },
      { index = 17, value = props.modNitrous },
      { index = 19, value = props.modSubwoofer },
      { index = 25, value = props.modPlateHolder },
      { index = 26, value = props.modVanityPlate },
      { index = 27, value = props.modTrimA },
      { index = 28, value = props.modOrnaments },
      { index = 29, value = props.modDashboard },
      { index = 30, value = props.modDial },
      { index = 31, value = props.modDoorSpeaker },
      { index = 32, value = props.modSeats },
      { index = 33, value = props.modSteeringWheel },
      { index = 34, value = props.modShifterLeavers },
      { index = 35, value = props.modAPlate },
      { index = 36, value = props.modSpeakers },
      { index = 37, value = props.modTrunk },
      { index = 38, value = props.modHydrolic },
      { index = 39, value = props.modEngineBlock },
      { index = 40, value = props.modAirFilter },
      { index = 41, value = props.modStruts },
      { index = 42, value = props.modArchCover },
      { index = 43, value = props.modAerials },
      { index = 44, value = props.modTrimB },
      { index = 45, value = props.modTank },
      { index = 46, value = props.modWindows },
      { index = 47, value = props.modDoorR },
      { index = 48, value = props.modLivery },
      { index = 49, value = props.modLightbar }
   }

   for _, mod in ipairs(modList) do
      if mod.value then
         SetVehicleMod(entity, mod.index, mod.value, false)
      end
   end
end

-- Aplica modificaciones de tipo toggle
function PropertyApplier:SetToggleMods(entity, props)
   if props.modTurbo ~= nil then ToggleVehicleMod(entity, 18, props.modTurbo) end
   if props.modSmokeEnabled ~= nil then ToggleVehicleMod(entity, 20, props.modSmokeEnabled) end
   if props.modHydraulics ~= nil then ToggleVehicleMod(entity, 21, props.modHydraulics) end
   if props.modXenon ~= nil then ToggleVehicleMod(entity, 22, props.modXenon) end
end

-- Establece todas las propiedades del vehículo
function lib.setVehicleProperties(vehicle, props, fixVehicle)
   if not DoesEntityExist(vehicle) then
      error(("Unable to set vehicle properties for '%s' (entity does not exist)"):format(vehicle))
   end

   SetVehicleModKit(vehicle, 0)
   local currentPrimary, currentSecondary = GetVehicleColours(vehicle)
   local currentPearl, currentWheel = GetVehicleExtraColours(vehicle)

   if props.extras then
      for extraId, state in pairs(props.extras) do
         SetVehicleExtra(vehicle, tonumber(extraId), state == 1)
      end
   end

   if props.plate then SetVehicleNumberPlateText(vehicle, props.plate) end
   if props.plateIndex then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
   if props.bodyHealth then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
   if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
   if props.tankHealth then SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0) end
   if props.fuelLevel then SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0) end
   if props.oilLevel then SetVehicleOilLevel(vehicle, props.oilLevel + 0.0) end
   if props.dirtLevel then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end

   PropertyApplier:SetVehicleColors(vehicle, props, currentPrimary, currentSecondary, currentPearl, currentWheel)

   if props.interiorColor then SetVehicleInteriorColor(vehicle, props.interiorColor) end
   if props.dashboardColor then SetVehicleDashboardColor(vehicle, props.dashboardColor) end
   if props.wheels then SetVehicleWheelType(vehicle, props.wheels) end
   if props.wheelSize then SetVehicleWheelSize(vehicle, props.wheelSize) end
   if props.wheelWidth then SetVehicleWheelWidth(vehicle, props.wheelWidth) end
   if props.windowTint then SetVehicleWindowTint(vehicle, props.windowTint) end

   if props.neonEnabled then
      for index, enabled in ipairs(props.neonEnabled) do
         SetVehicleNeonLightEnabled(vehicle, index - 1, enabled)
      end
   end

   if props.windows then
      for _, windowId in ipairs(props.windows) do
         RemoveVehicleWindow(vehicle, windowId)
      end
   end

   if props.doors then
      for _, doorId in ipairs(props.doors) do
         SetVehicleDoorBroken(vehicle, doorId, true)
      end
   end

   if props.tyres then
      for tyreId, state in pairs(props.tyres) do
         SetVehicleTyreBurst(vehicle, tonumber(tyreId), state == 2, 1000.0)
      end
   end

   if props.neonColor then
      SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
   end

   if props.tyreSmokeColor then
      SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
   end

   PropertyApplier:SetVehicleMods(vehicle, props)
   PropertyApplier:SetToggleMods(vehicle, props)

   if props.xenonColor then SetVehicleXenonLightsColor(vehicle, props.xenonColor) end
   if props.modFrontWheels then SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomTiresF) end
   if props.modBackWheels then SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomTiresR) end
   if props.modRoofLivery then SetVehicleRoofLivery(vehicle, props.modRoofLivery) end
   if props.livery then SetVehicleLivery(vehicle, props.livery) end
   if props.bulletProofTyres ~= nil then SetVehicleTyresCanBurst(vehicle, props.bulletProofTyres) end
   if GetGameBuildNumber() >= 2372 and props.driftTyres then SetDriftTyresEnabled(vehicle, true) end
   if fixVehicle then SetVehicleFixed(vehicle) end

   return not NetworkGetEntityIsNetworked(vehicle) or NetworkGetEntityOwner(vehicle) == cache.playerId
end

-- Módulo interno para manejar eventos de red
local NetworkHandler = {}

function NetworkHandler:WaitForNetworkEntity(netId)
   local attemptsRemaining = 100
   while not NetworkDoesEntityExistWithNetworkId(netId) and attemptsRemaining > 0 do
      Wait(0)
      attemptsRemaining = attemptsRemaining - 1
   end
   return attemptsRemaining > 0 and NetToVeh(netId) or nil
end

---@deprecated
---Not recommended. Entity owners can change rapidly and sporadically.
RegisterNetEvent('qs_lib:setVehicleProperties', function(netid, data)
   local vehicleEntity = NetworkHandler:WaitForNetworkEntity(netid)
   if vehicleEntity then
      lib.setVehicleProperties(vehicleEntity, data)
   end
end)

-- Módulo interno para manejar state bags
local StateBagHandler = {}

function StateBagHandler:FetchEntityFromBag(bagName)
   local success, entityId = pcall(function()
      while NetworkIsInTutorialSession() do Wait(0) end
      local timeoutMs = 10000
      local startTime = GetGameTimer()
      while GetGameTimer() - startTime < timeoutMs do
         local entity = GetEntityFromStateBagName(bagName)
         if entity > 0 then return entity end
         Wait(0)
      end
   end)
   return success and entityId or nil
end

AddStateBagChangeHandler('qs_lib:setVehicleProperties', '', function(bagName, _, value)
   if not value or not GetEntityFromStateBagName then return end

   local entity = StateBagHandler:FetchEntityFromBag(bagName)
   if not entity then return end

   lib.setVehicleProperties(entity, value)
   Wait(200)

   if NetworkGetEntityOwner(entity) == cache.playerId then
      lib.setVehicleProperties(entity, value)
      Entity(entity).state:set('qs_lib:setVehicleProperties', nil, true)
   end
end)




-- //TODO: TEST PENDING
