-- This module enables developers to define markers with specific types, positions, and visual attributes,
-- providing a robust interface for displaying interactive or decorative-- visual elements in the game environment.

---@diagnostic disable: param-type-mismatch
lib.marker = {}

local defaultRotation = vector3(0, 0, 0)
local defaultDirection = vector3(0, 0, 0)
local defaultColor = { r = 200, g = 200, b = 200, a = 120 }
local defaultSize = { width = 1.5, height = 0.8 }
local defaultTextureDict = nil
local defaultTextureName = nil

local markerTypesMap = {
   UpsideDownCone = 0,
   VerticalCylinder = 1,
   ThickChevronUp = 2,
   ThinChevronUp = 3,
   CheckeredFlagRect = 4,
   CheckeredFlagCircle = 5,
   VerticleCircle = 6,
   PlaneModel = 7,
   LostMCTransparent = 8,
   LostMC = 9,
   Number0 = 10,
   Number1 = 11,
   Number2 = 12,
   Number3 = 13,
   Number4 = 14,
   Number5 = 15,
   Number6 = 16,
   Number7 = 17,
   Number8 = 18,
   Number9 = 19,
   ChevronUpx1 = 20,
   ChevronUpx2 = 21,
   ChevronUpx3 = 22,
   HorizontalCircleFat = 23,
   ReplayIcon = 24,
   HorizontalCircleSkinny = 25,
   HorizontalCircleSkinny_Arrow = 26,
   HorizontalSplitArrowCircle = 27,
   DebugSphere = 28,
   DollarSign = 29,
   HorizontalBars = 30,
   WolfHead = 31,
   QuestionMark = 32,
   PlaneSymbol = 33,
   HelicopterSymbol = 34,
   BoatSymbol = 35,
   CarSymbol = 36,
   MotorcycleSymbol = 37,
   BikeSymbol = 38,
   TruckSymbol = 39,
   ParachuteSymbol = 40,
   Unknown41 = 41,
   SawbladeSymbol = 42,
   Unknown43 = 43,
}

---@alias MarkerType
---| "UpsideDownCone"
---| "VerticalCylinder"
---| "ThickChevronUp"
---| "ThinChevronUp"
---| "CheckeredFlagRect"
---| "CheckeredFlagCircle"
---| "VerticleCircle"
---| "PlaneModel"
---| "LostMCTransparent"
---| "LostMC"
---| "Number0"
---| "Number1"
---| "Number2"
---| "Number3"
---| "Number4"
---| "Number5"
---| "Number6"
---| "Number7"
---| "Number8"
---| "Number9"
---| "ChevronUpx1"
---| "ChevronUpx2"
---| "ChevronUpx3"
---| "HorizontalCircleFat"
---| "ReplayIcon"
---| "HorizontalCircleSkinny"
---| "HorizontalCircleSkinny_Arrow"
---| "HorizontalSplitArrowCircle"
---| "DebugSphere"
---| "DollarSign"
---| "HorizontalBars"
---| "WolfHead"
---| "QuestionMark"
---| "PlaneSymbol"
---| "HelicopterSymbol"
---| "BoatSymbol"
---| "CarSymbol"
---| "MotorcycleSymbol"
---| "BikeSymbol"
---| "TruckSymbol"
---| "ParachuteSymbol"
---| "Unknown41"
---| "SawbladeSymbol"
---| "Unknown43"

---@class MarkerProps
---@field type MarkerType | number
---@field coords { x: number, y: number, z: number }
---@field width? number
---@field height? number
---@field color? { r: number, g: number, b: number, a: number }
---@field rotation? { x: number, y: number, z: number }
---@field direction? { x: number, y: number, z: number }
---@field bobUpAndDown? boolean
---@field faceCamera? boolean
---@field rotate? boolean
---@field textureDict? string
---@field textureName? string

-- Converts a marker type to its corresponding numeric ID.
---@param inputType MarkerType | number
---@return number
local function getMarkerId(inputType)
   if type(inputType) == "string" then
      local id = markerTypesMap[inputType]
      if id == nil then
         error(string.format("Unknown marker type: %s", inputType))
      end
      return id
   elseif type(inputType) == "number" then
      return inputType
   end
   error(string.format("Expected marker type to be string or number, received %s", type(inputType)))
end

-- Sets default values for optional marker properties.
---@param config MarkerProps
---@return table
local function applyDefaults(config)
   local props = {}
   props.color = config.color or defaultColor
   props.width = config.width or defaultSize.width
   props.height = config.height or defaultSize.height
   props.rotation = config.rotation or defaultRotation
   props.direction = config.direction or defaultDirection
   props.bobUpAndDown = config.bobUpAndDown == true
   props.faceCamera = config.faceCamera ~= false
   props.rotate = config.rotate == true
   props.textureDict = config.textureDict or defaultTextureDict
   props.textureName = config.textureName or defaultTextureName
   return props
end

-- Draws a marker in the game world with the specified properties.
---@param instance table
local function displayMarker(instance)
   DrawMarker(
      instance.type,
      instance.coords.x, instance.coords.y, instance.coords.z,
      instance.direction.x, instance.direction.y, instance.direction.z,
      instance.rotation.x, instance.rotation.y, instance.rotation.z,
      instance.width, instance.width, instance.height,
      instance.color.r, instance.color.g, instance.color.b, instance.color.a,
      instance.bobUpAndDown, instance.faceCamera, 2, instance.rotate,
      instance.textureDict, instance.textureName, false
   )
end

---@param options MarkerProps
function lib.marker.new(options)
   -- Resolve marker type to numeric ID
   local markerId = getMarkerId(options.type)

   -- Apply default values to optional properties
   local properties = applyDefaults(options)

   -- Build marker instance
   local instance = {
      type = markerId,
      coords = options.coords,
      color = properties.color,
      width = properties.width + 0.0,
      height = properties.height + 0.0,
      rotation = properties.rotation,
      direction = properties.direction,
      bobUpAndDown = properties.bobUpAndDown,
      faceCamera = properties.faceCamera,
      rotate = properties.rotate,
      textureDict = properties.textureDict,
      textureName = properties.textureName,
      draw = displayMarker
   }

   return instance
end

return lib.marker
