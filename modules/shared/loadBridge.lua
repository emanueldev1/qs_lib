-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

function lib.loadBridge(_type, resource, _context, silent)
   lib.print.debug(('Loading bridge %s with resource %s'):format(_type, resource))
   -- Recursion guard to prevent stack overflow
   local loading = false

   -- Helper function to load the bridge resource
   local function loadBridgeResource(res)
      if not res then
         return {}
      end

      -- Prevent recursive calls
      if loading then
         lib.print.error(('Recursive call detected while loading bridge %s with resource %s'):format(_type, res))
         return {}
      end

      loading = true
      local loaded = lib.load(('@qs_lib.bridge.%s.%s.%s'):format(_type, res, _context), nil, true)
      loading = false

      if not loaded then
         lib.print.error(('Bridge %s for resource %s not found. Context is %s'):format(_type, res, _context))
         return noop
      end
      return loaded
   end

   if _type == 'framework' then
      -- Check if the resource is a string and not empty
      if type(resource) ~= 'string' or resource == '' then
         lib.print.error(('Invalid resource name for %s, expected a non-empty string'):format(_type))
         return {}
      end

      -- Load the bridge resource
      local loadedBridge = loadBridgeResource(resource)
      if not loadedBridge then
         lib.print.error(('Failed to load bridge %s with resource %s'):format(_type, resource))
         return {}
      end

      return loadedBridge
   end

   if not resource then

      if not silent then
         lib.print.warn(('No bridge found for %s, try installing one script for %s or add your bridge for your script on qs_lib/bridge/%s/scriptname/client.lua and qs_lib/bridge/%s/scriptname/server.lua, make those files taking the others already created as an example and base, once done you can send pull request to github')
            :format(_type, _type, _type, _type))
      end

      -- Crear un proxy que almacenará el bridge cargado
      local proxy = {}
      local loadedBridge
      local lastResource = nil -- Track the last resource used to avoid redundant loads

      return setmetatable(proxy, {
         __index = function(t, k)
            -- Obtener el recurso actual desde settings
            local currentResource = lib.bridge[_type]

            -- Invalidar el bridge si el recurso es falsy/nullish o ha cambiado
            if (not currentResource or currentResource ~= lastResource) then
               loadedBridge = nil
               lastResource = nil
            end

            -- Si el bridge ya está cargado y el recurso no ha cambiado, devolver sus valores
            if loadedBridge and currentResource == lastResource then
               return loadedBridge[k]
            end

            -- Intentar cargar el bridge con el recurso actualizado solo si hay un recurso válido
            if currentResource then
               loadedBridge = loadBridgeResource(currentResource)
               lastResource = currentResource
               if loadedBridge and next(loadedBridge) then
                  return loadedBridge[k]
               end
            end

            -- Si no se cargó, devolver nil (el proxy seguirá intentando en el próximo acceso)
            lib.print.warn(('Bridge %s for resource %s not found. Context is %s'):format(_type, currentResource, _context))
            return noop
         end,
         __newindex = function(t, k, v)
            -- Obtener el recurso actual desde settings
            local currentResource = lib.bridge[_type]

            -- Actualizar el bridge si es necesario antes de escribir
            if (not currentResource or currentResource ~= lastResource) then
               loadedBridge = nil
               lastResource = nil
            end

            if currentResource and not loadedBridge then
               loadedBridge = loadBridgeResource(currentResource)
               lastResource = currentResource
            end

            -- Escribir en el bridge cargado si existe
            if loadedBridge then
               loadedBridge[k] = v
            end
         end
      })
   end

   -- Crear el objeto bridge con un metatable para manejar accesos dinámicos
   local bridge = {}
   local loadedBridge = loadBridgeResource(resource)
   local lastResource = lib.bridge[_type]

   return setmetatable(bridge, {
      __index = function(t, k)
         -- Obtener el recurso actual desde settings
         local currentResource = lib.bridge[_type]

         -- Invalidar y recargar el bridge si el recurso es falsy/nullish o ha cambiado
         if (not currentResource or currentResource ~= lastResource) then
            loadedBridge = loadBridgeResource(currentResource)
            lastResource = currentResource
         end
         local currentBridgeFunction = loadedBridge[k]
         if not currentBridgeFunction then
            lib.print.warn(('Bridge %s for resource %s not found. Context is %s'):format(_type, currentResource, _context))
         end
         -- Devolver el valor del bridge cargado
         return currentBridgeFunction or noop
      end,
      __newindex = function(t, k, v)
         -- Obtener el recurso actual desde settings
         local currentResource = lib.bridge[_type]

         -- Actualizar el bridge si es necesario antes de escribir
         if (not currentResource or currentResource ~= lastResource) then
            loadedBridge = loadBridgeResource(currentResource)
            lastResource = currentResource
         end

         -- Escribir en el bridge cargado
         loadedBridge[k] = v or noop
      end
   })
end

return lib.loadBridge
