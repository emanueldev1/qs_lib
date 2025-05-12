-- getFilesInDirectory.lua: Retrieves files in a directory matching a pattern in FiveM.
-- This module executes a system command to list files and filters them based on the given pattern.

-- Determines the appropriate system command for listing files.
---@param dirPath string
---@return string
local function buildCommand(dirPath)
   local isWindows = string.match(os.getenv('OS') or '', 'Windows')
   return string.format(
      '%s%s%s',
      isWindows and 'dir "' or 'ls "',
      dirPath:gsub('\\', '/'),
      isWindows and '/" /b' or '/"'
   )
end

-- Lists files in a directory and filters by pattern.
---@param path string
---@param pattern string
---@return table string[]
---@return integer fileCount
function lib.getFilesInDirectory(path, pattern)
   local resName = cache.resource
   if path:find('^@') then
      resName = path:gsub('^@(.-)/.+', '%1')
      path = path:sub(#resName + 3)
   end

   local matchedFiles = {}
   local matchedCount = 0
   local fullPath = (GetResourcePath(resName):gsub('//', '/') .. '/' .. path):gsub('\\', '/')
   local cmd = buildCommand(fullPath)

   local dirHandle = io.popen(cmd)
   if dirHandle then
      for fileName in dirHandle:lines() do
         if fileName:match(pattern) then
            matchedCount = matchedCount + 1
            matchedFiles[matchedCount] = fileName
         end
      end
      dirHandle:close()
   end

   return matchedFiles, matchedCount
end

return lib.getFilesInDirectory
