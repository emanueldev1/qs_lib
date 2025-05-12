-- Módulo interno para la gestión de localizaciones
local LocaleManager = {}

function LocaleManager:LoadLocaleFile(resource, fileName)
   local fileContent = LoadResourceFile(resource, string.format('locales/%s', fileName)) or ''
   return json.decode(fileContent) or {}
end

function LocaleManager:ProcessLocaleEntry(fileName)
   local localeValue = fileName:gsub('%.json', '')
   local localeData = self:LoadLocaleFile(lib.name, fileName)
   local localeLabel = localeData.language or localeValue
   return { label = localeLabel, value = localeValue }
end

function LocaleManager:SortLocales(localeEntries)
   table.sort(localeEntries, function(entryA, entryB)
      return entryA.label < entryB.label
   end)
   return localeEntries
end

local locales, localesN = lib.getFilesInDirectory('locales', '%.json')

for i = 1, localesN do
   locales[i] = LocaleManager:ProcessLocaleEntry(locales[i])
end

table.sort(locales, function(a, b)
   return a.label < b.label
end)

GlobalState['qs_lib:locales'] = locales
