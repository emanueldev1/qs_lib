-- Módulo interno para la gestión de verificación de versiones
local VersionChecker = {}

-- Obtiene la versión actual del recurso
function VersionChecker:GetCurrentVersion(resourceName)
   local versionString = GetResourceMetadata(resourceName, 'version', 0)
   if not versionString then
      return nil
   end
   local matchedVersion = versionString:match('%d+%.%d+%.%d+')
   if not matchedVersion then
      print(string.format("^1Unable to determine current resource version for '%s' ^0", resourceName))
      return nil
   end
   return matchedVersion
end

-- Realiza la solicitud HTTP para obtener la última versión
function VersionChecker:FetchLatestVersion(repository, callback)
   local apiUrl = string.format('https://api.github.com/repos/%s/releases/latest', repository)
   PerformHttpRequest(apiUrl, function(statusCode, responseData)
      if statusCode ~= 200 then
         return
      end
      local releaseInfo = json.decode(responseData)
      if releaseInfo.prerelease then
         return
      end
      local latestVersion = releaseInfo.tag_name:match('%d+%.%d+%.%d+')
      callback(latestVersion, releaseInfo.html_url)
   end, 'GET')
end

-- Compara dos versiones y determina si hay una actualización
function VersionChecker:CompareVersions(currentVersion, latestVersion, resourceName, updateUrl)
   if not latestVersion or latestVersion == currentVersion then
      return
   end

   local currentParts = { string.strsplit('.', currentVersion) }
   local latestParts = { string.strsplit('.', latestVersion) }

   for index = 1, #currentParts do
      local currentNum = tonumber(currentParts[index])
      local latestNum = tonumber(latestParts[index])

      if currentNum ~= latestNum then
         if currentNum < latestNum then
            print(string.format('^3An update is available for %s (current version: %s)\r\n%s^0', resourceName, currentVersion, updateUrl))
         end
         return
      end
   end
end

-- Función principal para verificar la versión
function lib.versionCheck(repository)
   local resourceName = GetInvokingResource() or GetCurrentResourceName()
   local currentVersion = VersionChecker:GetCurrentVersion(resourceName)

   if not currentVersion then
      return
   end

   SetTimeout(1000, function()
      VersionChecker:FetchLatestVersion(repository, function(latestVersion, updateUrl)
         VersionChecker:CompareVersions(currentVersion, latestVersion, resourceName, updateUrl)
      end)
   end)
end

lib.versionCheck('emanueldev1/qs_lib')
