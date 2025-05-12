--- @class LocaleState
--- @field settings table The loaded settings from src.settings.

local localeState = { settings = require 'src.settings' }

--- Loads a locale file for the given key, falling back to en.json if not found.
--- @param key string The locale key (e.g., 'en', 'es').
--- @return table The decoded JSON locale data, or an empty table if not found.
local function loadLocaleFile(key)
   local file = LoadResourceFile(cache.resource, ('locales/%s.json'):format(key))
       or LoadResourceFile(cache.resource, 'locales/en.json')
   return file and json.decode(file) or {}
end

--- Sends an NUI message to set the locale data.
--- @param key string The locale key to load and send.
local function sendLocaleMessage(key)
   SendNUIMessage({
      action = 'setLocale',
      data = loadLocaleFile(key)
   })
end

--- Gets the current locale key from settings.
--- @return string The current locale key.
function lib.getLocaleKey()
   return localeState.settings.locale
end

--- Sets the locale and notifies the NUI.
--- @param key string The locale key to set (e.g., 'en', 'es').
function lib.setLocale(key)
   TriggerEvent('qs_lib:setLocale', key)
   sendLocaleMessage(key)
end

--- Handles the NUI callback for initialization, sending the current locale.
--- @param data any Data from the NUI callback (ignored).
--- @param cb fun(result: number) Callback to acknowledge the NUI message.
local function handleInitCallback(data, cb)
   cb(1)
   sendLocaleMessage(localeState.settings.locale)
end

-- Register NUI callback
RegisterNUICallback('init', handleInitCallback)

-- Initialize locale
lib.locale(localeState.settings.locale)
