-- Extends Lua's table library for FiveM with advanced functions for table manipulation,
-- including searching, comparing, cloning, merging, shuffling, freezing, and functional operations.

---@class qstable : tablelib
lib.table = table
local pairs = pairs

-- Checks if a table includes a specific value or all values from a subtable.
-- @param inputArray table The table to search.
-- @param targetElement any The value or subtable to find.
-- @return boolean True if found, false otherwise.
local function checkElement(inputArray, targetElement)
   if type(targetElement) ~= 'table' then
      for _, item in pairs(inputArray) do
         if item == targetElement then
            return true
         end
      end
      return false
   end

   for _, subElement in pairs(targetElement) do
      local found = false
      for _, item in pairs(inputArray) do
         if item == subElement then
            found = true
            break
         end
      end
      if not found then
         return false
      end
   end
   return true
end

-- Recursively compares two values or tables for equality.
-- @param primaryData any The first value or table.
-- @param secondaryData any The second value or table.
-- @return boolean True if equal, false otherwise.
local function recursiveCompare(primaryData, secondaryData)
   if type(primaryData) ~= 'table' or type(secondaryData) ~= 'table' then
      return primaryData == secondaryData
   end

   local primaryType = table.type(primaryData)
   if primaryType ~= table.type(secondaryData) or (primaryType == 'array' and #primaryData ~= #secondaryData) then
      return false
   end

   for key, value1 in pairs(primaryData) do
      if secondaryData[key] == nil or not recursiveCompare(value1, secondaryData[key]) then
         return false
      end
   end

   for key in pairs(secondaryData) do
      if primaryData[key] == nil then
         return false
      end
   end
   return true
end

-- Creates a deep copy of a table, ensuring no shared references.
-- @param sourceData table The table to clone.
-- @return table A new table with all nested tables cloned.
local function duplicateTable(sourceData)
   local cloneRegistry = {}
   local function deepDuplicate(data)
      if type(data) ~= 'table' then
         return data
      end
      if cloneRegistry[data] then
         return cloneRegistry[data]
      end

      local copy = table.clone(data)
      cloneRegistry[data] = copy
      for key, value in pairs(copy) do
         copy[key] = deepDuplicate(value)
      end
      return copy
   end
   return deepDuplicate(sourceData)
end

-- Merges two tables, handling duplicate keys based on type.
-- @param baseData table The target table to merge into.
-- @param mergeData table The source table to merge from.
-- @param combineNumbers boolean|nil If true, sum numeric duplicates; otherwise, overwrite (defaults to true).
-- @return table The merged table.
local function blendData(baseData, mergeData, combineNumbers)
   combineNumbers = combineNumbers ~= false
   for key, sourceValue in pairs(mergeData) do
      local targetValue = baseData[key]
      if type(targetValue) == 'table' and type(sourceValue) == 'table' then
         blendData(targetValue, sourceValue, combineNumbers)
      elseif combineNumbers and type(targetValue) == 'number' and type(sourceValue) == 'number' then
         baseData[key] = targetValue + sourceValue
      else
         baseData[key] = sourceValue
      end
   end
   return baseData
end

-- Randomly reorders an array-like table using Fisher-Yates shuffle.
-- @param arrayData table The table to shuffle.
-- @return table The shuffled table.
local function reorderArray(arrayData)
   local length = #arrayData
   for i = 1, length - 1 do
      local j = math.random(i, length)
      arrayData[i], arrayData[j] = arrayData[j], arrayData[i]
   end
   return arrayData
end

-- Prevents modifications to a frozen table.
-- @param targetContainer table The frozen table.
local function blockModification(targetContainer)
   error(("read-only table (%s) cannot be modified"):format(tostring(targetContainer)), 2)
end

-- Filters elements from a table based on a condition.
-- @param sourceArray table The table to filter.
-- @param condition fun(value: any, key: any): boolean The condition to test.
-- @return table A new table with filtered elements.
local function selectElements(sourceArray, condition)
   local result = {}
   local index = 1
   for key, value in pairs(sourceArray) do
      if condition(value, key) then
         result[index] = value
         index = index + 1
      end
   end
   return result
end

-- Transforms a table by applying a function to each element.
-- @param sourceArray table The table to transform.
-- @param transformer fun(value: any, key: any): any The transformation function.
-- @return table A new table with transformed elements.
local function transformElements(sourceArray, transformer)
   local result = {}
   for key, value in pairs(sourceArray) do
      result[key] = transformer(value, key)
   end
   return result
end

-- Reduces a table to a single value.
-- @param sourceArray table The table to reduce.
-- @param reducer fun(accumulator: any, value: any, key: any): any The reducer function.
-- @param initialValue any The initial accumulator value.
-- @return any The reduced value.
local function aggregateElements(sourceArray, reducer, initialValue)
   local accumulator = initialValue
   for key, value in pairs(sourceArray) do
      accumulator = reducer(accumulator, value, key)
   end
   return accumulator
end

-- Finds the first element satisfying a condition.
-- @param sourceArray table The table to search.
-- @param condition fun(value: any, key: any): boolean The condition to test.
-- @return any|nil The first matching value, or nil.
-- @return any|nil The key of the matching value, or nil.
local function locateElement(sourceArray, condition)
   for key, value in pairs(sourceArray) do
      if condition(value, key) then
         return value, key
      end
   end
   return nil, nil
end

-- Extracts values of a specific key from a table of tables.
-- @param sourceArray table The table of tables to process.
-- @param key any The key to extract.
-- @return table A list of values for the key.
local function extractKeyValues(sourceArray, key)
   local result = {}
   local index = 1
   for _, item in pairs(sourceArray) do
      if type(item) == 'table' and item[key] ~= nil then
         result[index] = item[key]
         index = index + 1
      end
   end
   return result
end

-- Groups elements by a key or function.
-- @param sourceArray table The table to group.
-- @param keyOrFunc any|fun(value: any, key: any): any The key or function to group by.
-- @return table A table of groups.
local function groupElements(sourceArray, keyOrFunc)
   local groups = {}
   local getKey = type(keyOrFunc) == 'function' and keyOrFunc or function(v) return v[keyOrFunc] end

   for key, value in pairs(sourceArray) do
      local groupKey = getKey(value, key)
      groups[groupKey] = groups[groupKey] or {}
      table.insert(groups[groupKey], value)
   end
   return groups
end

-- Sorts a table by a key or function.
-- @param sourceArray table The table to sort.
-- @param keyOrFunc any|fun(value: any): any The key or function to sort by.
-- @param ascending boolean|nil If true, sort ascending; otherwise, descending (defaults to true).
-- @return table The sorted table.
local function orderElements(sourceArray, keyOrFunc, ascending)
   local copy = table.clone(sourceArray)
   local getValue = type(keyOrFunc) == 'function' and keyOrFunc or function(v) return v[keyOrFunc] end
   ascending = ascending ~= false

   table.sort(copy, function(a, b)
      local va, vb = getValue(a), getValue(b)
      return ascending and va < vb or va > vb
   end)
   return copy
end

-- Flattens a nested table into a single-level table.
-- @param sourceArray table The table to flatten.
-- @return table A flat table with all values.
local function flattenStructure(sourceArray)
   local result = {}
   local function flatten(data)
      if type(data) ~= 'table' then
         table.insert(result, data)
         return
      end
      for _, value in pairs(data) do
         flatten(value)
      end
   end
   flatten(sourceArray)
   return result
end

-- Returns elements common to two tables.
-- @param firstArray table The first table.
-- @param secondArray table The second table.
-- @return table A table with common elements.
local function commonElements(firstArray, secondArray)
   local set = {}
   local result = {}
   local index = 1

   for _, value in pairs(secondArray) do
      set[value] = true
   end
   for _, value in pairs(firstArray) do
      if set[value] then
         result[index] = value
         index = index + 1
         set[value] = nil
      end
   end
   return result
end

-- Returns elements in the first table but not in the second.
-- @param firstArray table The first table.
-- @param secondArray table The second table.
-- @return table A table with unique elements from the first table.
local function uniqueElements(firstArray, secondArray)
   local set = {}
   local result = {}
   local index = 1

   for _, value in pairs(secondArray) do
      set[value] = true
   end
   for _, value in pairs(firstArray) do
      if not set[value] then
         result[index] = value
         index = index + 1
      end
   end
   return result
end

-- Partitions a table into two based on a condition.
-- @param sourceArray table The table to partition.
-- @param condition fun(value: any, key: any): boolean The condition to test.
-- @return table A table with passing elements.
-- @return table A table with failing elements.
local function splitElements(sourceArray, condition)
   local pass = {}
   local fail = {}
   local passIndex = 1
   local failIndex = 1

   for key, value in pairs(sourceArray) do
      if condition(value, key) then
         pass[passIndex] = value
         passIndex = passIndex + 1
      else
         fail[failIndex] = value
         failIndex = failIndex + 1
      end
   end
   return pass, fail
end

-- Removes duplicate elements from a table.
-- @param sourceArray table The table to process.
-- @return table A table with unique elements.
local function distinctElements(sourceArray)
   local seen = {}
   local result = {}
   local index = 1

   for _, value in pairs(sourceArray) do
      if not seen[value] then
         seen[value] = true
         result[index] = value
         index = index + 1
      end
   end
   return result
end

-- Splits a table into chunks of a specified size.
-- @param sourceArray table The table to chunk.
-- @param chunkSize number The size of each chunk.
-- @return table A table of chunks.
local function divideElements(sourceArray, chunkSize)
   if type(chunkSize) ~= 'number' or chunkSize < 1 then
      error(("expected a positive number for chunkSize, got '%s'"):format(tostring(chunkSize)), 2)
   end

   local result = {}
   local index = 1
   local chunk = {}

   for _, value in pairs(sourceArray) do
      chunk[#chunk + 1] = value
      if #chunk >= chunkSize then
         result[index] = chunk
         index = index + 1
         chunk = {}
      end
   end
   if #chunk > 0 then
      result[index] = chunk
   end
   return result
end

-- Reverses the order of an array-like table.
-- @param sourceArray table The table to reverse.
-- @return table The reversed table.
local function invertOrder(sourceArray)
   local result = {}
   local length = #sourceArray
   for i = 1, length do
      result[i] = sourceArray[length - i + 1]
   end
   return result
end

-- Converts a table to a set (values as keys with true).
-- @param sourceArray table The table to convert.
-- @return table A set-like table.
local function createSet(sourceArray)
   local set = {}
   for _, value in pairs(sourceArray) do
      set[value] = true
   end
   return set
end

-- Exported table functions
table.contains = checkElement
table.matches = recursiveCompare
table.deepclone = duplicateTable
table.merge = blendData
table.shuffle = reorderArray
table.filter = selectElements
table.map = transformElements
table.reduce = aggregateElements
table.find = locateElement
table.pluck = extractKeyValues
table.groupBy = groupElements
table.sortBy = orderElements
table.flatten = flattenStructure
table.intersection = commonElements
table.difference = uniqueElements
table.partition = splitElements
table.unique = distinctElements
table.chunk = divideElements
table.reverse = invertOrder
table.toSet = createSet

local _rawset = rawset

-- Sets a value in a table, respecting frozen state.
-- @param targetContainer table The table to modify.
-- @param key any The key to set.
-- @param value any The value to set.
-- @return table The modified table.
function rawset(targetContainer, key, value)
   if table.isfrozen(targetContainer) then
      blockModification(targetContainer)
   end
   return _rawset(targetContainer, key, value)
end

-- Makes a table read-only, preventing modifications.
-- @param sourceData table The table to freeze.
-- @return table The frozen table.
function table.freeze(sourceData)
   local snapshot = table.clone(sourceData)
   local originalMeta = getmetatable(sourceData)

   table.wipe(sourceData)
   setmetatable(sourceData, {
      __index = originalMeta and setmetatable(snapshot, originalMeta) or snapshot,
      __metatable = 'readonly',
      __newindex = blockModification,
      __len = function() return #snapshot end,
      __pairs = function() return next, snapshot end,
   })
   return sourceData
end

-- Checks if a table is read-only.
-- @param handleInputData table The table to check.
-- @return boolean True if frozen, false otherwise.
function table.isfrozen(handleInputData)
   return getmetatable(handleInputData) == 'readonly'
end

return lib.table
