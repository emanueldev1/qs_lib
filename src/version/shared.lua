-- Módulo interno para la gestión de dependencias
local DependencyManager = {}

-- Obtiene y valida la versión de un recurso
function DependencyManager:FetchResourceVersion(resourceName)
   local versionString = GetResourceMetadata(resourceName, 'version', 0)
   if not versionString then
      return 'unknown'
   end
   local matchedVersion = versionString:match('%d+%.%d+%.%d+')
   return matchedVersion or 'unknown'
end

-- Compara dos versiones y determina si la versión actual cumple con la mínima requerida
function DependencyManager:CompareVersions(currentVersion, requiredVersion, resourceName)
   if currentVersion == requiredVersion then
      return true
   end

   local currentParts = { string.strsplit('.', currentVersion) }
   local requiredParts = { string.strsplit('.', requiredVersion) }
   local invokingResource = GetInvokingResource() or GetCurrentResourceName()
   local errorMessage = string.format(
      '^1%s requires version \'%s\' of \'%s\' (current version: %s)^0',
      invokingResource, requiredVersion, resourceName, currentVersion
   )

   for index = 1, #currentParts do
      local currentNum = tonumber(currentParts[index])
      local requiredNum = tonumber(requiredParts[index])

      if currentNum ~= requiredNum then
         if not currentNum or currentNum < requiredNum then
            return false, errorMessage
         end
         return true
      end
   end

   return true
end

-- Función principal para verificar dependencias
function lib.checkDependency(resource, minimumVersion, printMessage)
   local currentVersion = DependencyManager:FetchResourceVersion(resource)
   local isValid, errorMsg = DependencyManager:CompareVersions(currentVersion, minimumVersion, resource)

   if not isValid and printMessage then
      print(errorMsg)
   end

   return isValid, errorMsg
end
