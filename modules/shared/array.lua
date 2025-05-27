-- This file contains code adapted from ox_lib, developed by the Overextended team.
-- Original repository: https://github.com/overextended/ox_lib
-- License: GNU Lesser General Public License v3.0 (LGPL-3.0), available at https://www.gnu.org/licenses/lgpl-3.0.html
-- Modifications by emanueldev1 for the qs_lib project, licensed under LGPL-3.0.

-- array.lua: Provides an Array class in FiveM for advanced array manipulation.
-- This module offers methods for array operations like mapping, filtering, and merging, with support for array-like tables.

---@class Array<T> : QsClass, { [number]: T }
lib.array = lib.class('Array')

local tUnpack = table.unpack
local tRemove = table.remove
local tClone = table.clone
local tConcat = table.concat
local tType = table.type

---@alias ArrayLike<T> Array | { [number]: T }

-- Initializes a new Array instance with the given elements.
-- @param ... any The elements to initialize the array with.
---@private
function lib.array:constructor(...)
   local elements = { ... }
   for i = 1, #elements do
      self[i] = elements[i]
   end
end

-- Enforces numeric indices for array elements.
-- @param idx any The index being set.
-- @param val any The value to set.
---@private
function lib.array:__newindex(idx, val)
   if type(idx) ~= 'number' then
      error(string.format("Array indices must be numbers, received '%s'", idx))
   end
   rawset(self, idx, val)
end

-- Creates a new array from an iterable value.
-- @param iterable table|function|string The iterable value to convert.
-- @return Array The new array instance.
function lib.array:from(iterable)
   local iterableType = type(iterable)
   if iterableType == 'table' then
      return lib.array:new(tUnpack(iterable))
   end
   if iterableType == 'string' then
      return lib.array:new(string.strsplit('', iterable))
   end
   if iterableType == 'function' then
      local newArr = lib.array:new()
      local arrLen = 0
      for item in iterable do
         arrLen = arrLen + 1
         newArr[arrLen] = item
      end
      return newArr
   end
   error(string.format("Cannot create array from non-iterable value of type '%s'", iterableType))
end

-- Retrieves an element at the specified index, supporting negative indices.
-- @param idx number The index of the element to retrieve.
-- @return any The element at the specified index.
function lib.array:at(idx)
   if idx < 0 then
      idx = #self + idx + 1
   end
   return self[idx]
end

-- Merges multiple arrays into a new array.
-- @param ... ArrayLike Arrays to merge with the current array.
-- @return Array The new merged array.
function lib.array:merge(...)
   local mergedArr = tClone(self)
   local currentLen = #self
   local inputArrs = { ... }
   for i = 1, #inputArrs do
      local arr = inputArrs[i]
      for j = 1, #arr do
         currentLen = currentLen + 1
         mergedArr[currentLen] = arr[j]
      end
   end
   return lib.array:new(tUnpack(mergedArr))
end

-- Checks if all elements pass the test function.
-- @param predicate fun(element: any): boolean The test function.
-- @return boolean True if all elements pass the test.
function lib.array:every(predicate)
   for i = 1, #self do
      if not predicate(self[i]) then
         return false
      end
   end
   return true
end

-- Fills a range of elements with a specified value.
-- @param val any The value to fill the array with.
-- @param startIdx? number The starting index (default: 1).
-- @param endIdx? number The ending index (default: array length).
-- @return Array The modified array.
function lib.array:fill(val, startIdx, endIdx)
   local arrLen = #self
   startIdx = startIdx or 1
   endIdx = endIdx or arrLen
   if startIdx < 1 then startIdx = 1 end
   if endIdx > arrLen then endIdx = arrLen end
   for i = startIdx, endIdx do
      self[i] = val
   end
   return self
end

-- Creates a new array with elements that pass the test function.
-- @param predicate fun(element: any): boolean The test function.
-- @return Array The filtered array.
function lib.array:filter(predicate)
   local filtered = {}
   local filteredLen = 0
   for i = 1, #self do
      local item = self[i]
      if predicate(item) then
         filteredLen = filteredLen + 1
         filtered[filteredLen] = item
      end
   end
   return lib.array:new(tUnpack(filtered))
end

-- Finds the first or last element that passes the test function.
-- @param predicate fun(element: any): boolean The test function.
-- @param fromEnd? boolean If true, search from the end.
-- @return any|nil The found element or nil.
function lib.array:find(predicate, fromEnd)
   local startIdx = fromEnd and #self or 1
   local endIdx = fromEnd and 1 or #self
   local step = fromEnd and -1 or 1
   for i = startIdx, endIdx, step do
      local item = self[i]
      if predicate(item) then
         return item
      end
   end
end

-- Finds the index of the first or last element that passes the test function.
-- @param predicate fun(element: any): boolean The test function.
-- @param fromEnd? boolean If true, search from the end.
-- @return number|nil The found index or nil.
function lib.array:findIndex(predicate, fromEnd)
   local startIdx = fromEnd and #self or 1
   local endIdx = fromEnd and 1 or #self
   local step = fromEnd and -1 or 1
   for i = startIdx, endIdx, step do
      if predicate(self[i]) then
         return i
      end
   end
end

-- Finds the index of the first or last occurrence of a value.
-- @param val any The value to find.
-- @param fromEnd? boolean If true, search from the end.
-- @return number|nil The found index or nil.
function lib.array:indexOf(val, fromEnd)
   local startIdx = fromEnd and #self or 1
   local endIdx = fromEnd and 1 or #self
   local step = fromEnd and -1 or 1
   for i = startIdx, endIdx, step do
      if self[i] == val then
         return i
      end
   end
end

-- Executes a callback for each element in the array.
-- @param callback fun(element: any) The callback function.
function lib.array:forEach(callback)
   for i = 1, #self do
      callback(self[i])
   end
end

-- Checks if an element exists in the array.
-- @param element any The element to search for.
-- @param startIdx? number The starting index for the search.
-- @return boolean True if the element is found.
function lib.array:includes(element, startIdx)
   for i = (startIdx or 1), #self do
      if self[i] == element then
         return true
      end
   end
   return false
end

-- Joins array elements into a string with a separator.
-- @param sep? string The separator (default: ',').
-- @return string The concatenated string.
function lib.array:join(sep)
   return tConcat(self, sep or ',')
end

-- Maps array elements to a new array using a callback.
-- @param callback fun(element: any, index: number, array: self): any The mapping function.
-- @return Array The new mapped array.
function lib.array:map(callback)
   local mapped = {}
   for i = 1, #self do
      mapped[i] = callback(self[i], i, self)
   end
   return lib.array:new(tUnpack(mapped))
end

-- Removes and returns the last element of the array.
-- @return any|nil The removed element.
function lib.array:pop()
   return tRemove(self)
end

-- Adds elements to the end of the array and returns the new length.
-- @param ... any Elements to add.
-- @return number The new array length.
function lib.array:push(...)
   local items = { ... }
   local len = #self
   for i = 1, #items do
      len = len + 1
      self[len] = items[i]
   end
   return len
end

-- Reduces the array to a single value using a reducer function.
-- @generic T
-- @param reducer fun(accumulator: T, currentValue: T, index?: number): T The reducer function.
-- @param initVal? T The initial value for the accumulator.
-- @param rev? boolean If true, reduce from right to left.
-- @return T The reduced value.
function lib.array:reduce(reducer, initVal, rev)
   local len = #self
   local startIdx = initVal and 1 or 2
   local accumulator = initVal or self[1]
   if rev then
      for i = startIdx, len do
         local idx = len - i + startIdx
         accumulator = reducer(accumulator, self[idx], idx)
      end
   else
      for i = startIdx, len do
         accumulator = reducer(accumulator, self[i], i)
      end
   end
   return accumulator
end

-- Reverses the array in place.
-- @return Array The reversed array.
function lib.array:reverse()
   local left, right = 1, #self
   while left < right do
      self[left], self[right] = self[right], self[left]
      left = left + 1
      right = right - 1
   end
   return self
end

-- Removes and returns the first element of the array.
-- @return any|nil The removed element.
function lib.array:shift()
   return tRemove(self, 1)
end

-- Creates a new array with a subset of elements.
-- @param startIdx? number The starting index.
-- @param endIdx? number The ending index.
-- @return Array The sliced array.
function lib.array:slice(startIdx, endIdx)
   local len = #self
   startIdx = startIdx or 1
   endIdx = endIdx or len
   if startIdx < 0 then startIdx = len + startIdx + 1 end
   if endIdx < 0 then endIdx = len + endIdx + 1 end
   if startIdx < 1 then startIdx = 1 end
   if endIdx > len then endIdx = len end

   local sliced = lib.array:new()
   local idx = 0
   for i = startIdx, endIdx do
      idx = idx + 1
      sliced[idx] = self[i]
   end
   return sliced
end

-- Creates a new array with elements in reversed order.
-- @return Array The reversed array.
function lib.array:toReversed()
   local revArr = lib.array:new()
   for i = #self, 1, -1 do
      revArr:push(self[i])
   end
   return revArr
end

-- Adds elements to the start of the array and returns the new length.
-- @param ... any Elements to add.
-- @return number The new array length.
function lib.array:unshift(...)
   local items = { ... }
   local len = #self
   local itemCount = #items
   for i = len, 1, -1 do
      self[i + itemCount] = self[i]
   end
   for i = 1, #items do
      self[i] = items[i]
   end
   return len + itemCount
end

-- Checks if a table is an array or array-like.
-- @param tbl ArrayLike The table to check.
-- @return boolean True if the table is array-like.
function lib.array.isArray(tbl)
   local tblType = tType(tbl)
   if not tblType then return false end
   if tblType == 'array' or tblType == 'empty' or lib.array.instanceOf(tbl, lib.array) then
      return true
   end
   return false
end

return lib.array
