local glm_sincos = require 'glm'.sincos --[[@as fun(n: number): number, number]]
local glm_rad = require 'glm'.rad --[[@as fun(n: number): number]]

-- Módulo para cálculos de rotación
local RotationUtils = {}

-- Calcula coordenadas relativas usando rotación Euler (vector3)
function RotationUtils.computeEulerRelative(baseCoords, eulerRotation, offset)
   local radX = glm_rad(eulerRotation.x)
   local radY = glm_rad(eulerRotation.y)
   local radZ = glm_rad(eulerRotation.z)

   local sinX, cosX = glm_sincos(radX)
   local sinY, cosY = glm_sincos(radY)
   local sinZ, cosZ = glm_sincos(radZ)

   local newX = offset.x * (cosZ * cosY) +
       offset.y * (cosZ * sinY * sinX - sinZ * cosX) +
       offset.z * (cosZ * sinY * cosX + sinZ * sinX)
   local newY = offset.x * (sinZ * cosY) +
       offset.y * (sinZ * sinY * sinX + cosZ * cosX) +
       offset.z * (sinZ * sinY * cosX - cosZ * sinX)
   local newZ = offset.x * (-sinY) +
       offset.y * (cosY * sinX) +
       offset.z * (cosY * cosX)

   return vec3(baseCoords.x + newX, baseCoords.y + newY, baseCoords.z + newZ)
end

-- Calcula coordenadas relativas usando un ángulo (número)
function RotationUtils.computeAngleRelative(baseCoords, angle, displacement)
   local sinAngle, cosAngle = glm_sincos(glm_rad(angle))
   local relX = displacement.x * cosAngle - displacement.y * sinAngle
   local relY = displacement.x * sinAngle + displacement.y * cosAngle

   return vec3(baseCoords.x + relX, baseCoords.y + relY, baseCoords.z + displacement.z)
end

-- Calcula coordenadas relativas para vector4
function RotationUtils.computeVector4Relative(baseCoords, displacement)
   local angle = baseCoords.w
   local sinAngle, cosAngle = glm_sincos(glm_rad(angle))
   local relX = displacement.x * cosAngle - displacement.y * sinAngle
   local relY = displacement.x * sinAngle + displacement.y * cosAngle

   return vec4(baseCoords.x + relX, baseCoords.y + relY, baseCoords.z + displacement.z, baseCoords.w)
end

-- Calculates relative coordinates based on rotation and offset.
-- @param coords vector3|vector4 The base coordinates (vector3 or vector4 with rotation).
-- @param rotation number|vector3 The rotation as a heading (number) or Euler angles (vector3).
-- @param offset? vector3 The offset to apply (defaults to rotation if vector3).
-- @returns vector3|vector4 The relative coordinates (vector3 or vector4 matching input).
function lib.getRelativeCoords(coords, rotation, offset)
   if type(rotation) == 'vector3' and offset then
      return RotationUtils.computeEulerRelative(coords, rotation, offset)
   end

   local displacement = offset or rotation
   if coords.w then
      return RotationUtils.computeVector4Relative(coords, displacement)
   end

   local heading = type(rotation) == 'number' and rotation or coords.w
   return RotationUtils.computeAngleRelative(coords, heading, displacement)
end

return lib.getRelativeCoords
