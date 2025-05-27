-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

---@class qsmath : mathlib
lib.math = math

-- Module for number parsing
local MathParser = {}

-- Parses a value to a number with constraints
-- @param input any Value to parse.
-- @param minimum? number Minimum allowed value.
-- @param maximum? number Maximum allowed value.
-- @param roundToInt? boolean Whether to round to nearest integer.
-- @returns number Parsed number.
function MathParser.convertToNumber(input, minimum, maximum, roundToInt)
   local numValue = tonumber(input)
   if not numValue then
      error(string.format("cannot convert to number (received %s)", input), 3)
   end

   numValue = roundToInt and math.floor(numValue + 0.5) or numValue

   if minimum and numValue < minimum then
      error(string.format("value below minimum '%s' (got %s)", minimum, numValue), 3)
   end
   if maximum and numValue > maximum then
      error(string.format("value above maximum '%s' (got %s)", maximum, numValue), 3)
   end

   return numValue
end

-- Converts radians to degrees
-- @param radians number Angle in radians.
-- @returns number Angle in degrees.
function math.toDegrees(radians)
   return radians * (180.0 / math.pi)
end

-- Clamps a number between bounds
-- @param value number Value to clamp.
-- @param minBound number Minimum bound.
-- @param maxBound number Maximum bound.
-- @returns number Clamped value.
function math.clamp(value, minBound, maxBound)
   local low, high = math.min(minBound, maxBound), math.max(minBound, maxBound)
   return math.max(low, math.min(high, value))
end

-- Rounds a number to specified decimal places
-- @param num number|string Number to round.
-- @param decimalPlaces? number|string Decimal places.
-- @returns number Rounded number.
function math.round(num, decimalPlaces)
   local value = type(num) == 'string' and tonumber(num) or num
   if type(value) ~= 'number' then error("input must be a number") end

   if decimalPlaces then
      local places = type(decimalPlaces) == 'string' and tonumber(decimalPlaces) or decimalPlaces
      if type(places) ~= 'number' then error("decimal places must be a number") end

      if places > 0 then
         local scaleFactor = 10 ^ places
         return math.floor(value * scaleFactor + 0.5) / scaleFactor
      end
   end

   return math.floor(value + 0.5)
end

-- Formats a number as a hexadecimal string
-- @param value number|string Number to format.
-- @param uppercase? boolean Use uppercase hex digits.
-- @returns string Hexadecimal string.
function math.tohex(value, uppercase)
   return string.format(uppercase and "0x%X" or "0x%x", value)
end

-- Converts a number to a byte string
-- @param num number Number to convert.
-- @param byteCount? number Number of bytes (1-4, defaults to 1).
-- @returns string Byte string.
function math.tobytes(num, byteCount)
   byteCount = byteCount or 1
   if byteCount < 1 or byteCount > 4 then error("byte count must be 1-4") end

   local bytes = ""
   for _ = 1, byteCount do
      bytes = string.char(num % 256) .. bytes
      num = math.floor(num / 256)
   end
   return bytes
end

-- Converts a number to scientific notation
-- @param num number Number to convert.
-- @param precision? number Decimal places for coefficient (defaults to 2).
-- @returns string Scientific notation string.
function math.toScientific(num, precision)
   if num == 0 then return "0.00e0" end
   precision = precision or 2
   local exponent = math.floor(math.log10(math.abs(num)))
   local coefficient = num / (10 ^ exponent)
   return string.format("%." .. precision .. "fe%d", coefficient, exponent)
end

-- Converts a number to binary string
-- @param num number Number to convert.
-- @param bits? number Number of bits (defaults to 8).
-- @returns string Binary string.
function math.toBinary(num, bits)
   bits = bits or 8
   local binary = ""
   num = math.floor(num)
   while num > 0 do
      binary = (num % 2) .. binary
      num = math.floor(num / 2)
   end
   return string.rep("0", math.max(0, bits - #binary)) .. binary
end

-- Converts a string to scalar values
-- @param source string Input string with numbers.
-- @param minimum? number Minimum value.
-- @param maximum? number Maximum value.
-- @param roundLimit? boolean|number Round all or first n values.
-- @returns number? ... Scalar values.
function math.toscalars(source, minimum, maximum, roundLimit)
   local results = {}
   local counter = 0

   for digit in source:gsub('%w+%w?%(', ''):gmatch('-?%d*%.?%d+') do
      counter = counter + 1
      results[counter] = MathParser.convertToNumber(digit, minimum, maximum, roundLimit and (roundLimit == true or counter <= roundLimit))
   end

   return table.unpack(results)
end

-- Normalizes a vector to unit length
-- @param vec vector2|vector3|vector4 Vector to normalize.
-- @returns vector2|vector3|vector4 Normalized vector.
function math.normalize(vec)
   local vecType = type(vec)
   if vecType == 'vector2' or vecType == 'vector3' or vecType == 'vector4' then
      local magnitude = math.sqrt(vec.x ^ 2 + vec.y ^ 2 + (vec.z or 0) ^ 2 + (vec.w or 0) ^ 2)
      if magnitude == 0 then return vec end
      return vecType == 'vector2' and vec2(vec.x / magnitude, vec.y / magnitude) or
          vecType == 'vector3' and vec3(vec.x / magnitude, vec.y / magnitude, vec.z / magnitude) or
          vec4(vec.x / magnitude, vec.y / magnitude, vec.z / magnitude, vec.w / magnitude)
   end
   error(string.format("expected vector2|vector3|vector4, got %s", vecType), 2)
end

-- Converts input to an RGBA vector4
-- @param source string|table Input to convert.
-- @returns vector4 RGBA vector.
function math.torgba(source)
   local colorVec = math.tovector(source, 0, 255, 3)
   assert(type(colorVec) == 'vector4', "input must yield vector4 for rgba")
   MathParser.convertToNumber(colorVec.a, 0, 1)
   return colorVec
end

-- Converts a hexadecimal string to RGB integers
-- @param hex string Hexadecimal color string.
-- @returns integer, integer, integer RGB values.
function math.hextorgb(hex)
   local rHex, gHex, bHex = hex:match('#?(%w%w)(%w%w)(%w%w)')
   return tonumber(rHex, 16), tonumber(gHex, 16), tonumber(bHex, 16)
end

-- Converts input to a vector
-- @param source string|table Input to convert.
-- @param minimum? number Minimum component value.
-- @param maximum? number Maximum component value.
-- @param roundLimit? boolean|number Round all or first n components.
-- @returns number|vector2|vector3|vector4 Converted vector or number.
function math.tovector(source, minimum, maximum, roundLimit)
   local sourceType = type(source)

   if sourceType == 'string' then
      local scalars = { math.toscalars(source, minimum, maximum, roundLimit) }
      return vector(table.unpack(scalars))
   elseif sourceType == 'table' then
      for _, value in pairs(source) do
         MathParser.convertToNumber(value, minimum, maximum, roundLimit)
      end

      if table.type(source) == 'array' then
         return vector(table.unpack(source))
      end

      return source.w and vector4(source.x, source.y, source.z, source.w) or
          source.z and vector3(source.x, source.y, source.z) or
          source.y and vector2(source.x, source.y) or
          source.x + 0.0
   end

   error(string.format("cannot convert %s to vector", sourceType), 2)
end

-- Converts a surface normal to a rotation
-- @param normal vector3 Normal vector.
-- @returns vector3 Rotation vector.
function math.normaltorotation(normal)
   local normalType = type(normal)
   if normalType == 'vector3' then
      local xAngle = -math.asin(normal.y) * (180.0 / math.pi)
      local yAngle = math.atan(normal.x, normal.z) * (180.0 / math.pi)
      return vec3(xAngle, yAngle, 0.0)
   end
   error(string.format("expected vector3, got %s", normalType), 2)
end

-- Converts a number to radians
-- @param degrees number Angle in degrees.
-- @returns number Angle in radians.
function math.toangle(degrees)
   return degrees * (math.pi / 180.0)
end

-- Formats a number with grouped digits
-- @param num number Number to format.
-- @param separator? string Separator (defaults to ',').
-- @returns string Formatted string.
function math.groupdigits(num, separator)
   local sign, digits, rest = string.match(tostring(num), '^([+-]?%d)(%d*)(.*)$')
   local groupedDigits = digits:reverse():gsub('(%d%d%d)', '%1' .. (separator or ',')):reverse()
   return sign .. groupedDigits .. rest
end

-- Interpolates between two values
-- @param begin number|table|vector2|vector3|vector4 Start value.
-- @param endVal number|table|vector2|vector3|vector4 End value.
-- @param progress number Interpolation factor (0 to 1).
-- @returns number|table|vector2|vector3|vector4 Interpolated value.
function math.interp(begin, endVal, progress)
   if type(begin) == 'table' then
      local result = {}
      for key, value in pairs(begin) do
         result[key] = math.interp(value, endVal[key], progress)
      end
      return result
   end
   return begin + (endVal - begin) * progress
end

-- Creates a linear interpolation iterator
-- @param begin number|table|vector2|vector3|vector4 Start value.
-- @param endVal number|table|vector2|vector3|vector4 End value.
-- @param duration number Duration in milliseconds.
-- @returns fun(): T, number Iterator returning interpolated value and progress.
function math.lerp(begin, endVal, duration)
   local timerStart = GetGameTimer()
   local beginType = type(begin)
   if not (beginType == 'number' or beginType == 'table' or beginType == 'vector2' or beginType == 'vector3' or beginType == 'vector4') then
      error(string.format("expected number|table|vector2|vector3|vector4, got %s", beginType))
   end
   assert(type(endVal) == beginType, string.format("end type must match begin type (%s), got %s", beginType, type(endVal)))

   local progress = nil

   return function()
      if progress == nil then
         progress = 0
         return begin, progress
      end
      if progress == 1 then return end

      Wait(0)
      progress = math.min((GetGameTimer() - timerStart) / duration, 1)

      return progress < 1 and math.interp(begin, endVal, progress) or endVal, progress
   end
end

return lib.math
