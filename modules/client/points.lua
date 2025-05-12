-- points.lua: Manages dynamic points of interest in FiveM, tracking their proximity to the player.
-- This module allows developers to create points with custom behaviors for entering, exiting, and staying nearby,
-- efficiently handling spatial queries and event triggers based on player position.

---@class PointProperties
---@field coords vector3
---@field distance number
---@field onEnter? fun(self: CPoint)
---@field onExit? fun(self: CPoint)
---@field nearby? fun(self: CPoint)
---@field [string] any

---@class CPoint : PointProperties
---@field id number
---@field currentDistance number
---@field isClosest? boolean
---@field remove fun()

---@type table<number, CPoint>
local pointRegistry = {}
---@type CPoint[]
local activePoints = {}
local activePointCount = 0
---@type CPoint?
local nearestPoint
local intervalHandle

-- Converts coordinates to a vector3, supporting tables and vector4.
---@param input any
---@return vector3
local function normalizeCoords(input)
   local inputType = type(input)
   if inputType == "vector3" then
      return input
   elseif inputType == "table" or inputType == "vector4" then
      return vec3(input[1] or input.x, input[2] or input.y, input[3] or input.z)
   end
   error(string.format("Expected coordinates as vector3 or table, received %s", inputType))
end

-- Removes a point from the registry and updates the nearest point if necessary.
---@param point CPoint
local function deletePoint(point)
   if nearestPoint and nearestPoint.id == point.id then
      nearestPoint = nil
   end
   lib.grid.removeEntry(point)
   pointRegistry[point.id] = nil
end

-- Updates the state of a point based on its distance from the player.
---@param point CPoint
---@param playerPos vector3
local function updatePointState(point, playerPos)
   local distance = math.sqrt((playerPos.x - point.coords.x) ^ 2 + (playerPos.y - point.coords.y) ^ 2 + (playerPos.z - point.coords.z) ^ 2)

   if distance <= point.radius then
      point.currentDistance = distance
      table.insert(activePoints, point)
      activePointCount = activePointCount + 1

      if not nearestPoint or distance < (nearestPoint.currentDistance or point.radius) then
         if nearestPoint then nearestPoint.isClosest = nil end
         point.isClosest = true
         nearestPoint = point
      end

      if point.onEnter and not point.inside then
         point.inside = true
         point:onEnter()
      end
   elseif point.currentDistance then
      if point.onExit then point:onExit() end
      point.inside = nil
      point.currentDistance = nil
   end
end

-- Manages the interval for nearby point updates.
local function manageNearbyInterval()
   if activePointCount > 0 and not intervalHandle then
      intervalHandle = SetInterval(function()
         for i = 1, activePointCount do
            local point = activePoints[i]
            if point and point.nearby then
               point:nearby()
            end
         end
      end)
   elseif activePointCount == 0 and intervalHandle then
      intervalHandle = ClearInterval(intervalHandle)
   end
end

-- Main loop to track player position and update nearby points.
CreateThread(function()
   while true do
      local playerPos = GetEntityCoords(cache.ped)
      local cellX, cellY = lib.grid.getCellPosition(playerPos)
      local nearbyEntries = lib.grid.getNearbyEntries(playerPos, function(entry) return entry.remove == deletePoint end) --[[@as CPoint[] ]]
      cache.coords = playerPos
      nearestPoint = nil

      -- Check if the player has moved to a new grid cell
      if cellX ~= cache.lastCellX or cellY ~= cache.lastCellY then
         for i = 1, activePointCount do
            local point = activePoints[i]
            if point and point.inside then
               local distance = math.sqrt((playerPos.x - point.coords.x) ^ 2 + (playerPos.y - point.coords.y) ^ 2 + (playerPos.z - point.coords.z) ^ 2)
               if distance > point.radius then
                  if point.onExit then point:onExit() end
                  point.inside = nil
                  point.currentDistance = nil
               end
            end
         end
         cache.lastCellX = cellX
         cache.lastCellY = cellY
      end

      -- Reset active points
      activePointCount = 0
      table.wipe(activePoints)

      -- Process nearby points
      for _, point in ipairs(nearbyEntries) do
         updatePointState(point, playerPos)
      end

      -- Manage the nearby interval
      manageNearbyInterval()

      Wait(250)
   end
end)

lib.points = {}

---@return CPoint
---@overload fun(data: PointProperties): CPoint
---@overload fun(coords: vector3, distance: number, data?: PointProperties): CPoint
function lib.points.new(...)
   local args = { ... }
   local pointId = #pointRegistry + 1
   local pointData

   -- Handle single table argument or multiple arguments
   if type(args[1]) == "table" then
      pointData = args[1]
      pointData.id = pointId
      pointData.remove = deletePoint
   else
      pointData = {
         id = pointId,
         coords = args[1],
         distance = args[2],
         remove = deletePoint
      }
      if args[3] then
         for key, value in pairs(args[3]) do
            pointData[key] = value
         end
      end
   end

   -- Normalize coordinates and set radius
   pointData.coords = normalizeCoords(pointData.coords)
   pointData.radius = pointData.distance or args[2]

   -- Register the point
   lib.grid.addEntry(pointData)
   pointRegistry[pointId] = pointData

   return pointData
end

function lib.points.getAllPoints() return pointRegistry end

function lib.points.getNearbyPoints() return activePoints end

---@return CPoint?
function lib.points.getClosestPoint() return nearestPoint end

---@deprecated
lib.points.closest = lib.points.getClosestPoint

return lib.points
