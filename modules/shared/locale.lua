---@type { [string]: string }
local dict = {}

-- Módulo para manejo de diccionarios
local DictUtils = {}

-- Flattens a nested dictionary into a single-level dictionary with dot-separated keys
-- @param source { [string]: string } The source dictionary.
-- @param target { [string]: string } The target dictionary to store flattened keys.
-- @param prefix? string The prefix for nested keys.
-- @returns { [string]: string } The flattened dictionary.
function DictUtils.flatten(source, target, prefix)
   for k, v in pairs(source) do
      local keyPath = prefix and string.format('%s.%s', prefix, k) or k
      if type(v) == 'table' then
         DictUtils.flatten(v, target, keyPath)
      else
         target[keyPath] = v
      end
   end
   return target
end

-- Módulo para manejo de localización
local LocaleUtils = {}

-- Loads a locale file from the resource
-- @param localeKey string The locale key (e.g., 'en').
-- @returns table The loaded locale data or an empty table if failed.
function LocaleUtils.loadLocaleFile(localeKey)
   local fileData = LoadResourceFile(cache.resource, string.format('locales/%s.json', localeKey))
   if not fileData then
      warn(string.format("could not load 'locales/%s.json'", localeKey))
      return {}
   end
   return json.decode(fileData) or {}
end

-- Formats a locale string with substitutions
-- @param localeKey string The locale key.
-- @param ... string|number Arguments for string formatting.
-- @returns string The formatted string or the original key if not found.
function LocaleUtils.formatLocale(localeKey, ...)
   local translated = dict[localeKey]
   if translated then
      return select(1, ...) and string.format(translated, ...) or translated
   end
   return localeKey
end

-- Processes locale data, resolving variables and updating the dictionary
-- @param localeData table The locale data to process.
-- @param targetDict { [string]: string } The dictionary to update.
function LocaleUtils.processLocaleData(localeData, targetDict)
   local flattened = DictUtils.flatten(localeData, {})
   table.wipe(targetDict)

   for key, value in pairs(flattened) do
      if type(value) == 'string' then
         for var in value:gmatch('${[%w%s%p]-}') do
            local varKey = var:sub(3, -2)
            local varValue = flattened[varKey]
            if varValue then
               varValue = varValue:gsub('%%', '%%%%')
               value = value:gsub(var, varValue, 1)
            end
         end
      end
      targetDict[key] = value
   end
end

-- Retrieves and adds a locale string from another resource
-- @param resName string The resource name.
-- @param localeKey string The locale key.
-- @returns string? The locale string or nil if not found.
function LocaleUtils.importLocale(resName, localeKey)
   if dict[localeKey] then
      warn(string.format("overwriting existing locale '%s' (%s)", localeKey, dict[localeKey]))
   end
   local localeValue = exports[resName]:getLocale(localeKey)
   dict[localeKey] = localeValue
   if not localeValue then
      warn(string.format("no locale exists with key '%s' in resource '%s'", localeKey, resName))
   end
   return localeValue
end

-- Formats a locale string with substitutions
-- @param str string The locale key.
-- @param ... string|number Arguments for string formatting.
-- @returns string The formatted string or the original key if not found.
function locale(str, ...)
   return LocaleUtils.formatLocale(str, ...)
end

-- Gets the current locale dictionary
-- @returns { [string]: string } The locale dictionary.
function lib.getLocales()
   return dict
end

-- Loads the qs_lib locale module. Prefer using fxmanifest instead (see [docs](https://quasar_store.dev/qs_lib#usage)).
-- @param key? string The locale key to load (defaults to lib.getLocaleKey()).
function lib.locale(key)
   local localeKey = key or lib.getLocaleKey()
   local baseLocales = LocaleUtils.loadLocaleFile('en')
   if localeKey ~= 'en' then
      local additionalLocales = LocaleUtils.loadLocaleFile(localeKey)
      lib.table.merge(baseLocales, additionalLocales)
   end
   LocaleUtils.processLocaleData(baseLocales, dict)
end

-- Gets a locale string from another resource and adds it to the dict.
-- @param resource string The resource name.
-- @param key string The locale key.
-- @returns string? The locale string or nil if not found.
function lib.getLocale(resource, key)
   return LocaleUtils.importLocale(resource, key)
end

-- Backing function for lib.getLocale.
-- @param key string The locale key.
-- @returns string? The locale string or nil if not found.
exports('getLocale', function(key)
   return dict[key]
end)

AddEventHandler('qs_lib:setLocale', function(key)
   lib.locale(key)
end)

return lib.locale
