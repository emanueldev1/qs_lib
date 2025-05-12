-- Extends Lua's string library for FiveM with functions to generate random strings,
-- create unique identifiers, and manipulate text for use in resources or UI.

---@class qsstring : stringlib
lib.string = string

local string_char = string.char
local math_random = math.random

-- Maps pattern symbols to their respective character generators.
local patternMap = {
   ['1'] = function() return math_random(0, 9) end,                                                                -- Digit (0-9)
   ['A'] = function() return string_char(math_random(65, 90)) end,                                                 -- Uppercase letter (A-Z)
   ['a'] = function() return string_char(math_random(97, 122)) end,                                                -- Lowercase letter (a-z)
   ['.'] = function() return math_random(0, 1) == 1 and string_char(math_random(65, 90)) or math_random(0, 9) end  -- Alphanumeric
}

-- Processes a pattern character, applying a generator or returning a literal.
-- @param patternChar string The current character in the pattern.
-- @param isEscaped boolean Whether the character is escaped by '^'.
-- @param nextChar string|nil The next character if escaped.
-- @return string The generated or literal character.
-- @return boolean Whether to skip the next character.
local function handleChar(patternChar, isEscaped, nextChar)
   if isEscaped and nextChar then
      return nextChar, true
   end

   local generator = patternMap[patternChar]
   return generator and generator() or patternChar, false
end

-- Adjusts the result array to match the target length, padding or truncating.
-- @param resultArray table The array of generated characters.
-- @param targetLen integer The desired output length.
-- @return table The adjusted array.
local function adjustLength(resultArray, targetLen)
   local currentLen = #resultArray
   if currentLen < targetLen then
      for i = currentLen + 1, targetLen do
         resultArray[i] = ' '
      end
   elseif currentLen > targetLen then
      for i = targetLen + 1, currentLen do
         resultArray[i] = nil
      end
   end
   return resultArray
end

-- Generates a random string based on a pattern.
-- Pattern symbols:
-- '1': Random digit (0-9).
-- 'A': Random uppercase letter (A-Z).
-- 'a': Random lowercase letter (a-z).
-- '.': Random alphanumeric (A-Z or 0-9).
-- '^': Escapes the next character to include literally.
-- Other characters are included as-is.
-- @param pattern string The pattern to guide string generation.
-- @param length integer|nil Optional length to pad or truncate the output.
-- @return string The generated string.
function string.random(pattern, length)
   local targetLen = length or #pattern:gsub('%^', '')
   local resultArray = {}
   local currentIndex = 1
   local isEscaped = false
   local skipNext = false

   for patternIndex = 1, #pattern do
      if currentIndex > targetLen then
         break
      end

      if skipNext then
         skipNext = false
         goto continue
      end

      local patternChar = pattern:sub(patternIndex, patternIndex)
      if patternChar == '^' and not isEscaped then
         isEscaped = true
         goto continue
      end

      local nextChar = isEscaped and patternIndex < #pattern and pattern:sub(patternIndex + 1, patternIndex + 1) or nil
      local outputChar, skip = handleChar(patternChar, isEscaped, nextChar)
      resultArray[currentIndex] = outputChar
      currentIndex = currentIndex + 1
      skipNext = skip
      isEscaped = false

      ::continue::
   end

   return table.concat(adjustLength(resultArray, targetLen))
end

-- Generates a single hexadecimal digit for UUID generation.
-- @return string A random hex digit (0-9 or a-f).
local function hexDigit()
   local value = math_random(0, 15)
   return value < 10 and tostring(value) or string_char(value + 87)
end

-- Generates a UUID v4 (random) in the format 8-4-4-4-12.
-- Useful for unique identifiers in FiveM resources or player tracking.
-- @return string A UUID (e.g., "123e4567-e89b-12d3-a456-426614174000").
function string.uuid()
   local buffer = {}
   local index = 1
   local segments = { 8, 4, 4, 4, 12 }
   local segmentIndex = 1

   for i = 1, 36 do
      if i == 9 or i == 14 or i == 19 or i == 24 then
         buffer[index] = '-'
         segmentIndex = segmentIndex + 1
      else
         buffer[index] = hexDigit()
         -- Set UUID version (4) and variant (8, 9, a, or b)
         if i == 13 then
            buffer[index] = '4'
         elseif i == 17 then
            buffer[index] = string_char(math_random(8, 11) + 87)
         end
      end
      index = index + 1
   end

   return table.concat(buffer)
end

-- Converts a string to a slug (lowercase, no spaces, hyphens for separators).
-- Useful for resource names, file paths, or URLs in FiveM.
-- @param str string The input string to convert.
-- @return string The slugified string (e.g., "Hello World!" -> "hello-world").
function string.slug(str)
   if type(str) ~= 'string' then
      error(("expected a string, got '%s'"):format(tostring(str)), 2)
   end

   local buffer = {}
   local index = 1
   local lastWasSpace = false

   for i = 1, #str do
      local char = str:sub(i, i):lower()
      local code = char:byte()

      if (code >= 97 and code <= 122) or (code >= 48 and code <= 57) then
         buffer[index] = char
         index = index + 1
         lastWasSpace = false
      elseif not lastWasSpace and (char == ' ' or char == '-' or char == '_') then
         buffer[index] = '-'
         index = index + 1
         lastWasSpace = true
      end
   end

   -- Remove trailing hyphen
   if index > 1 and buffer[index - 1] == '-' then
      index = index - 1
   end

   return table.concat(buffer, '', 1, index - 1)
end

-- Truncates a string to a maximum length, appending an optional suffix.
-- Useful for UI text or chat messages in FiveM.
-- @param str string The input string to truncate.
-- @param maxLen integer The maximum length (including suffix).
-- @param suffix string|nil The suffix to append if truncated (defaults to "...").
-- @return string The truncated string.
function string.truncate(str, maxLen, suffix)
   if type(str) ~= 'string' then
      error(("expected a string, got '%s'"):format(tostring(str)), 2)
   end
   if type(maxLen) ~= 'number' or maxLen < 0 then
      error(("expected a non-negative number for maxLen, got '%s'"):format(tostring(maxLen)), 2)
   end

   suffix = suffix or '...'
   if #str <= maxLen then
      return str
   end

   local suffixLen = #suffix
   if maxLen <= suffixLen then
      return suffix:sub(1, maxLen)
   end

   return str:sub(1, maxLen - suffixLen) .. suffix
end

-- Capitalizes the first letter of a string, leaving the rest unchanged.
-- Useful for formatting player names or messages in FiveM.
-- @param str string The input string to capitalize.
-- @return string The capitalized string (e.g., "hello" -> "Hello").
function string.capitalize(str)
   if type(str) ~= 'string' then
      error(("expected a string, got '%s'"):format(tostring(str)), 2)
   end

   if #str == 0 then
      return str
   end

   return str:sub(1, 1):upper() .. str:sub(2)
end

return lib.string
