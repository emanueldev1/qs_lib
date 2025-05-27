-- This file contains code adapted from ox_lib, developed by the Overextended team.
-- Original repository: https://github.com/overextended/ox_lib
-- License: GNU Lesser General Public License v3.0 (LGPL-3.0), available at https://www.gnu.org/licenses/lgpl-3.0.html
-- Modifications by emanueldev1 for the qs_lib project, licensed under LGPL-3.0.

local mapMinX = -3700
local mapMinY = -4400
local mapMaxX = 4500
local mapMaxY = 8000
local xDelta = (mapMaxX - mapMinX) / 34
local yDelta = (mapMaxY - mapMinY) / 50
local grid = {}
local lastCell = {}
local gridCache = {}
local entrySet = {}

lib.grid = {}

---@class GridEntry
---@field coords vector
---@field length? number
---@field width? number
---@field radius? number
---@field [string] any

-- Módulo para cálculos de cuadrícula
local GridCalculator = {}

-- Calculates grid cell boundaries for a point and dimensions
-- @param point vector The center point.
-- @param length number The length dimension.
-- @param width number The width dimension.
-- @returns number, number, number, number Minimum and maximum X and Y cell indices.
function GridCalculator.getCellBounds(point, length, width)
   local xMin = math.floor((point.x - width - mapMinX) / xDelta)
   local xMax = math.floor((point.x + width - mapMinX) / xDelta)
   local yMin = math.floor((point.y - length - mapMinY) / yDelta)
   local yMax = math.floor((point.y + length - mapMinY) / yDelta)

   return xMin, xMax, yMin, yMax
end

-- Calculates the grid cell position for a point
-- @param point vector The point to locate.
-- @returns number, number The X and Y cell indices.
function GridCalculator.getCellIndex(point)
   local cellX = math.floor((point.x - mapMinX) / xDelta)
   local cellY = math.floor((point.y - mapMinY) / yDelta)

   return cellX, cellY
end

-- Módulo para gestión de celdas
local CellManager = {}

-- Retrieves entries in the cell containing a point
-- @param point vector The point to check.
-- @returns GridEntry[] The entries in the cell.
function CellManager.getCellEntries(point)
   local cellX, cellY = GridCalculator.getCellIndex(point)

   if lastCell.x ~= cellX or lastCell.y ~= cellY then
      lastCell.x = cellX
      lastCell.y = cellY
      lastCell.cell = (grid[cellY] and grid[cellY][cellX]) or {}
   end

   return lastCell.cell
end

-- Módulo para gestión de entradas cercanas
local NearbyEntries = {}

-- Collects nearby entries within a grid area, optionally filtered
-- @param point vector The center point.
-- @param filter? fun(entry: GridEntry): boolean Optional filter function.
-- @returns Array<GridEntry> The collected entries.
function NearbyEntries.collect(point, filter)
   local xMin, xMax, yMin, yMax = GridCalculator.getCellBounds(point, xDelta, yDelta)

   if gridCache.filter == filter and
       gridCache.xMin == xMin and
       gridCache.xMax == xMax and
       gridCache.yMin == yMin and
       gridCache.yMax == yMax then
      return gridCache.entries
   end

   local result = lib.array:new()
   local entryCount = 0
   table.wipe(entrySet)

   for rowIdx = yMin, yMax do
      local rowData = grid[rowIdx]
      if rowData then
         for colIdx = xMin, xMax do
            local cellData = rowData[colIdx]
            if cellData then
               for _, entry in ipairs(cellData) do
                  if not entrySet[entry] and (not filter or filter(entry)) then
                     entryCount = entryCount + 1
                     entrySet[entry] = true
                     result[entryCount] = entry
                  end
               end
            end
         end
      end
   end

   gridCache.xMin = xMin
   gridCache.xMax = xMax
   gridCache.yMin = yMin
   gridCache.yMax = yMax
   gridCache.entries = result
   gridCache.filter = filter

   return result
end

-- Módulo para gestión de entradas en la cuadrícula
local GridEntryManager = {}

-- Adds an entry to the grid
-- @param entry { coords: vector, length?: number, width?: number, radius?: number, [string]: any } The entry to add.
function GridEntryManager.add(entry)
   entry.length = entry.length or (entry.radius and entry.radius * 2) or 0
   entry.width = entry.width or (entry.radius and entry.radius * 2) or 0
   local xMin, xMax, yMin, yMax = GridCalculator.getCellBounds(entry.coords, entry.length, entry.width)

   for rowIdx = yMin, yMax do
      grid[rowIdx] = grid[rowIdx] or {}
      for colIdx = xMin, xMax do
         grid[rowIdx][colIdx] = grid[rowIdx][colIdx] or {}
         table.insert(grid[rowIdx][colIdx], entry)
      end
   end

   table.wipe(gridCache)
end

-- Removes an entry from the grid
-- @param entry table The entry to remove.
-- @returns boolean Whether the entry was removed.
function GridEntryManager.remove(entry)
   local xMin, xMax, yMin, yMax = GridCalculator.getCellBounds(entry.coords, entry.length, entry.width)
   local wasRemoved = false

   for rowIdx = yMin, yMax do
      local rowData = grid[rowIdx]
      if not rowData then goto skip end

      for colIdx = xMin, xMax do
         local cellData = rowData[colIdx]
         if cellData then
            for idx, cellEntry in ipairs(cellData) do
               if cellEntry == entry then
                  table.remove(cellData, idx)
                  wasRemoved = true
                  break
               end
            end

            if #cellData == 0 then
               rowData[colIdx] = nil
            end
         end
      end

      if not next(rowData) then
         grid[rowIdx] = nil
      end

      ::skip::
   end

   table.wipe(gridCache)
   return wasRemoved
end

-- Calculates the grid cell position for a point
-- @param point vector The point to locate.
-- @returns number, number The X and Y cell indices.
function lib.grid.getCellPosition(point)
   return GridCalculator.getCellIndex(point)
end

-- Retrieves entries in the cell containing a point
-- @param point vector The point to check.
-- @returns GridEntry[] The entries in the cell.
function lib.grid.getCell(point)
   return CellManager.getCellEntries(point)
end

-- Collects nearby entries within a grid area, optionally filtered
-- @param point vector The center point.
-- @param filter? fun(entry: GridEntry): boolean Optional filter function.
-- @returns Array<GridEntry> The collected entries.
function lib.grid.getNearbyEntries(point, filter)
   return NearbyEntries.collect(point, filter)
end

-- Adds an entry to the grid
-- @param entry { coords: vector, length?: number, width?: number, radius?: number, [string]: any } The entry to add.
function lib.grid.addEntry(entry)
   GridEntryManager.add(entry)
end

-- Removes an entry from the grid
-- @param entry table The entry to remove.
-- @returns boolean Whether the entry was removed.
function lib.grid.removeEntry(entry)
   return GridEntryManager.remove(entry)
end

return lib.grid
