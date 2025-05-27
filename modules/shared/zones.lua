-- This file contains code adapted from ox_lib, developed by the Overextended team.
-- Original repository: https://github.com/overextended/ox_lib
-- License: GNU Lesser General Public License v3.0 (LGPL-3.0), available at https://www.gnu.org/licenses/lgpl-3.0.html
-- Modifications by emanueldev1 for the qs_lib project, licensed under LGPL-3.0.

local glm = require 'glm'

---@class ZoneProperties
---@field debug? boolean
---@field debugColour? vector4
---@field onEnter fun(self: CZone)?
---@field onExit fun(self: CZone)?
---@field inside fun(self: CZone)?
---@field [string] any

---@class CZone : PolyZone, BoxZone, SphereZone
---@field id number
---@field __type 'poly' | 'sphere' | 'box'
---@field remove fun(self: self)
---@field setDebug fun(self: CZone, enable?: boolean, colour?: vector)
---@field contains fun(self: CZone, coords?: vector3, updateDistance?: boolean): boolean

---@type table<number, CZone>
local Zones = {}
_ENV.Zones = Zones

-- Finds the next valid point index in a polygon for triangulation.
-- @param pointList table Array of points with boolean flags indicating availability.
-- @param currentIndex number Current point index to start searching from.
-- @param totalPoints number Total number of points in the polygon.
-- @return number|nil The next valid point index or nil if none found.
local function findNextValidPoint(pointList, currentIndex, totalPoints)
   for i = 1, totalPoints do
      local nextIndex = (i + currentIndex) % totalPoints
      nextIndex = nextIndex ~= 0 and nextIndex or totalPoints
      if pointList[nextIndex] then
         return nextIndex
      end
   end
end

-- Logs an error message when a polygon cannot be split into triangles for debug rendering.
-- @param polygon table The polygon data to display in the error message.
local function logPolygonSplitError(polygon)
   print('Error: Unable to split malformed polygon into triangles for debug rendering.')
   for key, value in pairs(polygon) do
      print(key, value)
   end
end

-- Processes a single triangle for a non-convex polygon, updating the point list and triangle array.
-- @param polygon table The polygon data containing points.
-- @param pointList table Array tracking available points.
-- @param triangles table Array to store generated triangles.
-- @param indexA number First point index of the triangle.
-- @param indexB number Second point index of the triangle.
-- @param indexC number Third point index of the triangle.
-- @param zValue number Z-coordinate for 2D segment checks.
-- @return boolean True if the triangle was added, false otherwise.
local function processTriangle(polygon, pointList, triangles, indexA, indexB, indexC, zValue)
   local pointA2D = polygon[indexA].xy
   local pointC2D = polygon[indexC].xy
   local segmentStart = vec3(glm.segment2d.getPoint(pointA2D, pointC2D, 0.01), zValue)
   local segmentEnd = vec3(glm.segment2d.getPoint(pointA2D, pointC2D, 0.99), zValue)

   if polygon:containsSegment(segmentStart, segmentEnd) then
      triangles[#triangles + 1] = mat(polygon[indexA], polygon[indexB], polygon[indexC])
      pointList[indexB] = false
      return true
   end
   return false
end

-- Splits a polygon into triangles for debug rendering, handling convex and non-convex cases.
-- @param polygon table The polygon to triangulate.
-- @return table Array of triangles (matrices) for rendering.
local function triangulatePolygon(polygon)
   local triangles = {}

   -- Handle convex polygons efficiently
   if polygon:isConvex() then
      for i = 2, #polygon - 1 do
         triangles[#triangles + 1] = mat(polygon[1], polygon[i], polygon[i + 1])
      end
      return triangles
   end

   -- Non-convex polygons require complex triangulation
   if not polygon:isSimple() then
      logPolygonSplitError(polygon)
      return triangles
   end

   local pointList = {}
   local totalPoints = #polygon
   for i = 1, totalPoints do
      pointList[i] = polygon[i]
   end

   local indexA, indexB, indexC = 1, 2, 3
   local zValue = polygon[1].z
   local iterationCount = 0

   while totalPoints - #triangles > 2 do
      if processTriangle(polygon, pointList, triangles, indexA, indexB, indexC, zValue) then
         indexB = indexC
         indexC = findNextValidPoint(pointList, indexB, totalPoints)
      else
         indexA = indexB
         indexB = indexC
         indexC = findNextValidPoint(pointList, indexB, totalPoints)
      end

      iterationCount = iterationCount + 1
      if iterationCount > totalPoints and #triangles == 0 then
         logPolygonSplitError(polygon)
         return triangles
      end

      Wait(0)
   end

   return triangles
end

-- Client-side zone tracking for enter/exit events and debug rendering
local insideZones = lib.context == 'client' and {} --[[@as table<number, CZone>]]
local exitingZones = lib.context == 'client' and lib.array:new() --[[@as Array<CZone>]]
local enteringZones = lib.context == 'client' and lib.array:new() --[[@as Array<CZone>]]
local nearbyZones = lib.array:new() --[[@as Array<CZone>]]
local glm_polygon_contains = glm.polygon.contains
local tick

-- Removes a zone from tracking and grid systems.
-- @param zone CZone The zone to remove.
local function deleteZone(zone)
   Zones[zone.id] = nil
   lib.grid.removeEntry(zone)

   if lib.context == 'server' then return end

   insideZones[zone.id] = nil
   table.remove(exitingZones, exitingZones:indexOf(zone))
   table.remove(enteringZones, enteringZones:indexOf(zone))
end

-- Main client-side loop for zone detection and event handling
CreateThread(function()
   if lib.context == 'server' then return end

   while true do
      local playerCoords = GetEntityCoords(cache.ped)
      local nearbyEntries = lib.grid.getNearbyEntries(playerCoords, function(entry) return entry.remove == deleteZone end) --[[@as Array<CZone>]]
      local cellX, cellY = lib.grid.getCellPosition(playerCoords)
      cache.coords = playerCoords

      -- Check for cell changes to update zone states
      if cellX ~= cache.lastCellX or cellY ~= cache.lastCellY then
         for i = 1, #nearbyZones do
            local zone = nearbyZones[i]
            if zone.insideZone then
               local isInside = zone:contains(playerCoords, true)
               if not isInside then
                  zone.insideZone = false
                  insideZones[zone.id] = nil
                  if zone.onExit then
                     exitingZones:push(zone)
                  end
               end
            end
         end
         cache.lastCellX = cellX
         cache.lastCellY = cellY
      end

      nearbyZones = nearbyEntries

      -- Update zone states based on player position
      for i = 1, #nearbyEntries do
         local zone = nearbyEntries[i]
         local isInside = zone:contains(playerCoords, true)

         if isInside then
            if not zone.insideZone then
               zone.insideZone = true
               if zone.onEnter then
                  enteringZones:push(zone)
               end
               if zone.inside or zone.debug then
                  insideZones[zone.id] = zone
               end
            end
         else
            if zone.insideZone then
               zone.insideZone = false
               insideZones[zone.id] = nil
               if zone.onExit then
                  exitingZones:push(zone)
               end
            end
            if zone.debug then
               insideZones[zone.id] = zone
            end
         end
      end

      -- Process zone exit events
      local exitCount = #exitingZones
      if exitCount > 0 then
         table.sort(exitingZones, function(a, b) return a.distance < b.distance end)
         for i = exitCount, 1, -1 do
            exitingZones[i]:onExit()
         end
         table.wipe(exitingZones)
      end

      -- Process zone enter events
      local enterCount = #enteringZones
      if enterCount > 0 then
         table.sort(enteringZones, function(a, b) return a.distance < b.distance end)
         for i = 1, enterCount do
            enteringZones[i]:onEnter()
         end
         table.wipe(enteringZones)
      end

      -- Manage debug and inside function ticks
      if not tick and next(insideZones) then
         tick = SetInterval(function()
            for _, zone in pairs(insideZones) do
               if zone.debug then
                  zone:debug()
                  if zone.inside and zone.insideZone then
                     zone:inside()
                  end
               else
                  zone:inside()
               end
            end
         end)
      elseif tick and not next(insideZones) then
         tick = ClearInterval(tick)
      end

      Wait(300)
   end
end)

local DrawLine = DrawLine
local DrawPoly = DrawPoly

-- Renders debug visualization for polygon zones.
-- @param self CZone The zone to render.
local function renderPolyDebug(self)
   for i = 1, #self.triangles do
      local triangle = self.triangles[i]
      DrawPoly(triangle[1].x, triangle[1].y, triangle[1].z, triangle[2].x, triangle[2].y, triangle[2].z, triangle[3].x, triangle[3].y, triangle[3].z,
         self.debugColour.r, self.debugColour.g, self.debugColour.b, self.debugColour.a)
      DrawPoly(triangle[2].x, triangle[2].y, triangle[2].z, triangle[1].x, triangle[1].y, triangle[1].z, triangle[3].x, triangle[3].y, triangle[3].z,
         self.debugColour.r, self.debugColour.g, self.debugColour.b, self.debugColour.a)
   end
   for i = 1, #self.polygon do
      local thickness = vec(0, 0, self.thickness / 2)
      local pointA = self.polygon[i] + thickness
      local pointB = self.polygon[i] - thickness
      local pointC = (self.polygon[i + 1] or self.polygon[1]) + thickness
      local pointD = (self.polygon[i + 1] or self.polygon[1]) - thickness
      DrawLine(pointA.x, pointA.y, pointA.z, pointB.x, pointB.y, pointB.z, self.debugColour.r, self.debugColour.g, self.debugColour.b, 225)
      DrawLine(pointA.x, pointA.y, pointA.z, pointC.x, pointC.y, pointC.z, self.debugColour.r, self.debugColour.g, self.debugColour.b, 225)
      DrawLine(pointB.x, pointB.y, pointB.z, pointD.x, pointD.y, pointD.z, self.debugColour.r, self.debugColour.g, self.debugColour.b, 225)
      DrawPoly(pointA.x, pointA.y, pointA.z, pointB.x, pointB.y, pointB.z, pointC.x, pointC.y, pointC.z, self.debugColour.r, self.debugColour.g, self.debugColour.b, self.debugColour.a)
      DrawPoly(pointC.x, pointC.y, pointC.z, pointB.x, pointB.y, pointB.z, pointA.x, pointA.y, pointA.z, self.debugColour.r, self.debugColour.g, self.debugColour.b, self.debugColour.a)
      DrawPoly(pointB.x, pointB.y, pointB.z, pointC.x, pointC.y, pointC.z, pointD.x, pointD.y, pointD.z, self.debugColour.r, self.debugColour.g, self.debugColour.b, self.debugColour.a)
      DrawPoly(pointD.x, pointD.y, pointD.z, pointC.x, pointC.y, pointC.z, pointB.x, pointB.y, pointB.z, self.debugColour.r, self.debugColour.g, self.debugColour.b, self.debugColour.a)
   end
end

-- Renders debug visualization for sphere zones.
-- @param self CZone The zone to render.
local function renderSphereDebug(self)
   DrawMarker(28, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, self.radius, self.radius, self.radius, self.debugColour.r,
      self.debugColour.g, self.debugColour.b, self.debugColour.a, false, false, 0, false, false, false, false)
end

-- Checks if a point is inside a polygon zone.
-- @param self CZone The zone to check.
-- @param coords vector3 The coordinates to test.
-- @param updateDistance boolean Whether to update the zone's distance field.
-- @return boolean True if the point is inside the zone.
local function checkPolyContains(self, coords, updateDistance)
   if updateDistance then
      self.distance = #(self.coords - coords)
   end
   return glm_polygon_contains(self.polygon, coords, self.thickness / 4)
end

-- Checks if a point is inside a sphere zone.
-- @param self CZone The zone to check.
-- @param coords vector3 The coordinates to test.
-- @param updateDistance boolean Whether to update the zone's distance field.
-- @return boolean True if the point is inside the sphere.
local function checkSphereContains(self, coords, updateDistance)
   local distance = #(self.coords - coords)
   if updateDistance then
      self.distance = distance
   end
   return distance < self.radius
end

-- Converts input coordinates to a vector3 format.
-- @param coords vector3|table The input coordinates.
-- @return vector3 The converted vector3.
local function toVector3(coords)
   local inputType = type(coords)
   if inputType ~= 'vector3' then
      if inputType == 'table' or inputType == 'vector4' then
         return vec3(coords[1] or coords.x, coords[2] or coords.y, coords[3] or coords.z)
      end
      error(("Expected type 'vector3' or 'table', received %s"):format(inputType))
   end
   return coords
end

-- Enables or disables debug rendering for a zone.
-- @param self CZone The zone to modify.
-- @param enable boolean Whether to enable debug mode.
-- @param colour vector|nil Optional debug colour (defaults to red).
local function configureDebug(self, enable, colour)
   if not enable and insideZones[self.id] then
      insideZones[self.id] = nil
   end

   self.debugColour = enable and {
      r = glm.tointeger(colour?.r or self.debugColour?.r or 255),
      g = glm.tointeger(colour?.g or self.debugColour?.g or 42),
      b = glm.tointeger(colour?.b or self.debugColour?.b or 24),
      a = glm.tointeger(colour?.a or self.debugColour?.a or 100)
   } or nil

   if not enable and self.debug then
      self.triangles = nil
      self.debug = nil
      return
   end

   if enable and self.debug and self.debug ~= true then
      return
   end

   self.triangles = self.__type == 'poly' and triangulatePolygon(self.polygon) or
       self.__type == 'box' and {
          mat(self.polygon[1], self.polygon[2], self.polygon[3]),
          mat(self.polygon[1], self.polygon[3], self.polygon[4])
       } or nil
   self.debug = self.__type == 'sphere' and renderSphereDebug or renderPolyDebug or nil
end

-- Registers a zone with the system and assigns its properties.
-- @param data ZoneProperties The zone configuration.
-- @return CZone The configured zone.
local function registerZone(data)
   ---@cast data CZone
   data.remove = deleteZone
   data.contains = data.contains or checkPolyContains

   if lib.context == 'client' then
      data.setDebug = configureDebug
      if data.debug then
         data.debug = nil
         data:setDebug(true, data.debugColour)
      end
   else
      data.debug = nil
   end

   Zones[data.id] = data
   lib.grid.addEntry(data)
   return data
end

lib.zones = {}

---@class PolyZone : ZoneProperties
---@field points vector3[]
---@field thickness? number

-- Creates a polygon zone with the specified points and properties.
-- @param data PolyZone The zone configuration.
-- @return CZone The created zone.
function lib.zones.poly(data)
   data.id = #Zones + 1
   data.thickness = data.thickness or 4

   local pointCount = #data.points
   local points = table.create(pointCount, 0)
   for i = 1, pointCount do
      points[i] = toVector3(data.points[i])
   end

   data.polygon = glm.polygon.new(points)

   -- Adjust non-planar polygons by averaging Z coordinates
   if not data.polygon:isPlanar() then
      local zCounts = {}
      for i = 1, pointCount do
         local z = points[i].z
         zCounts[z] = (zCounts[z] or 0) + 1
      end

      local zEntries = {}
      for z, count in pairs(zCounts) do
         zEntries[#zEntries + 1] = { coord = z, count = count }
      end
      table.sort(zEntries, function(a, b) return a.count > b.count end)

      local avgZ = zEntries[1].coord
      local avgCount = 1
      for i = 2, #zEntries do
         if zEntries[i].count < zEntries[1].count then
            break
         end
         avgZ = avgZ + zEntries[i].coord
         avgCount = avgCount + 1
      end
      avgZ = avgZ / avgCount

      for i = 1, pointCount do
         points[i] = vec3(data.points[i].xy, avgZ)
      end
      data.polygon = glm.polygon.new(points)
   end

   data.coords = data.polygon:centroid()
   data.__type = 'poly'
   data.radius = lib.array.reduce(data.polygon, function(maxDist, point)
      local dist = #(point - data.coords)
      return dist > maxDist and dist or maxDist
   end, 0)

   return registerZone(data)
end

---@class BoxZone : ZoneProperties
---@field coords vector3
---@field size? vector3
---@field rotation? number | vector3 | vector4 | matrix

-- Creates a box zone with the specified coordinates, size, and rotation.
-- @param data BoxZone The zone configuration.
-- @return CZone The created zone.
function lib.zones.box(data)
   data.id = #Zones + 1
   data.coords = toVector3(data.coords)
   data.size = data.size and toVector3(data.size) / 2 or vec3(2)
   data.thickness = data.size.z * 2
   data.rotation = quat(data.rotation or 0, vec3(0, 0, 1))
   data.__type = 'box'
   data.width = data.size.x * 2
   data.length = data.size.y * 2
   data.polygon = (data.rotation * glm.polygon.new({
      vec3(data.size.x, data.size.y, 0),
      vec3(-data.size.x, data.size.y, 0),
      vec3(-data.size.x, -data.size.y, 0),
      vec3(data.size.x, -data.size.y, 0),
   }) + data.coords)

   return registerZone(data)
end

---@class SphereZone : ZoneProperties
---@field coords vector3
---@field radius? number

-- Creates a sphere zone with the specified coordinates and radius.
-- @param data SphereZone The zone configuration.
-- @return CZone The created zone.
function lib.zones.sphere(data)
   data.id = #Zones + 1
   data.coords = toVector3(data.coords)
   data.radius = (data.radius or 2) + 0.0
   data.__type = 'sphere'
   data.contains = checkSphereContains

   return registerZone(data)
end

-- Returns all registered zones.
-- @return table<number, CZone>
function lib.zones.getAllZones() return Zones end

-- Returns zones the player is currently inside.
-- @return table<number, CZone>
function lib.zones.getCurrentZones() return insideZones end

-- Returns zones near the player's current position.
-- @return Array<CZone>
function lib.zones.getNearbyZones() return nearbyZones end

return lib.zones
