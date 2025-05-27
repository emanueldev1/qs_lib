-- This file contains code adapted from ox_lib, developed by the Overextended team.
-- Original repository: https://github.com/overextended/ox_lib
-- License: GNU Lesser General Public License v3.0 (LGPL-3.0), available at https://www.gnu.org/licenses/lgpl-3.0.html
-- Modifications by emanueldev1 for the qs_lib project, licensed under LGPL-3.0.

-- raycast.lua: Facilitates raycast operations in FiveM to detect collisions in the game world.
-- This module enables tracing lines between points or from the camera, providing details about
-- hit entities, impact coordinates, surface normals, and materials, with customizable options.

lib.raycast = {}

local StartShapeTestLosProbe = StartShapeTestLosProbe
local GetShapeTestResultIncludingMaterial = GetShapeTestResultIncludingMaterial
local glm_sincos = require 'glm'.sincos
local glm_rad = require 'glm'.rad
local math_abs = math.abs
local GetFinalRenderedCamCoord = GetFinalRenderedCamCoord
local GetFinalRenderedCamRot = GetFinalRenderedCamRot

---@alias ShapetestIgnore
---| 1 GLASS
---| 2 SEE_THROUGH
---| 3 GLASS | SEE_THROUGH
---| 4 NO_COLLISION
---| 7 GLASS | SEE_THROUGH | NO_COLLISION

---@alias ShapetestFlags integer
---| 1 INCLUDE_MOVER
---| 2 INCLUDE_VEHICLE
---| 4 INCLUDE_PED
---| 8 INCLUDE_RAGDOLL
---| 16 INCLUDE_OBJECT
---| 32 INCLUDE_PICKUP
---| 64 INCLUDE_GLASS
---| 128 INCLUDE_RIVER
---| 256 INCLUDE_FOLIAGE
---| 511 INCLUDE_ALL

-- Normalizes raycast parameters with default values.
---@param input table
---@return table
local function prepareRaycastParams(input)
   return {
      flags = input.flags or 511,   -- INCLUDE_ALL
      ignore = input.ignore or 4    -- NO_COLLISION
   }
end

-- Performs a raycast and retrieves the result.
---@param origin vector3
---@param target vector3
---@param rayFlags ShapetestFlags
---@param ignoreType ShapetestIgnore
---@return boolean, number, vector3, vector3, number
local function executeRaycast(origin, target, rayFlags, ignoreType)
   local rayHandle = StartShapeTestLosProbe(
      origin.x, origin.y, origin.z,
      target.x, target.y, target.z,
      rayFlags, cache.ped, ignoreType
   )

   while true do
      Wait(0)
      local resultStatus, wasHit, impactPoint, surfaceNormal, materialHash, hitEntity = GetShapeTestResultIncludingMaterial(rayHandle)
      if resultStatus ~= 1 then
         return wasHit, hitEntity, impactPoint, surfaceNormal, materialHash
      end
   end
end

-- Computes the forward direction vector from the camera's rotation.
---@return vector3
local function calculateCameraDirection()
   local rotation = glm_rad(GetFinalRenderedCamRot(2))
   local sin, cos = glm_sincos(rotation)
   return vec3(-sin.z * math_abs(cos.x), cos.z * math_abs(cos.x), sin.x)
end

---@param coords vector3
---@param destination vector3
---@param flags ShapetestFlags? Defaults to 511.
---@param ignore ShapetestIgnore? Defaults to 4.
---@return boolean hit
---@return number entityHit
---@return vector3 endCoords
---@return vector3 surfaceNormal
---@return number materialHash
function lib.raycast.fromCoords(coords, destination, flags, ignore)
   local params = prepareRaycastParams({ flags = flags, ignore = ignore })
   return executeRaycast(coords, destination, params.flags, params.ignore)
end

---@param flags ShapetestFlags? Defaults to 511.
---@param ignore ShapetestIgnore? Defaults to 4.
---@param distance number? Defaults to 8.
function lib.raycast.fromCamera(flags, ignore, distance)
   local origin = GetFinalRenderedCamCoord()
   local range = distance or 8
   local target = origin + calculateCameraDirection() * range
   local params = prepareRaycastParams({ flags = flags, ignore = ignore })
   return executeRaycast(origin, target, params.flags, params.ignore)
end

---@deprecated -- OLD... FOR OXLIB COMPATIBILITY WITH OLDER VERSIONS // REMOVE IN THE FUTURE
lib.raycast.cam = lib.raycast.fromCamera

return lib.raycast
