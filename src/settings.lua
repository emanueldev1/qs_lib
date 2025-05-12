-- Módulo interno para la gestión de configuraciones
local ConfigManager = {}

function ConfigManager:ResetLegacyLocale()
   if GetResourceKvpInt('reset_locale') ~= 1 then
      DeleteResourceKvp('locale')
      SetResourceKvpInt('reset_locale', 1)
   end
end

-- Ejecutar la limpieza de locale heredado de qs_lib v2
ConfigManager:ResetLegacyLocale()

-- Módulo interno para operaciones KVP seguras
local KvpUtils = {}

function KvpUtils:SafeRetrieve(fn, key, fallback)
   local success, result = pcall(fn, key)
   if not success then
      DeleteResourceKvp(key)
      return nil
   end
   return result or fallback
end

---@generic T
---@param fn fun(key): unknown
---@param key string
---@param default? T
---@return T
local function safeGetKvp(fn, key, default)
   return KvpUtils:SafeRetrieve(fn, key, default)
end

-- Inicializar configuraciones
local settings = {
   default_locale = GetConvar('qs:locale', 'en'),
   notification_position = KvpUtils:SafeRetrieve(GetResourceKvpString, 'notification_position', 'top-right'),
   notification_audio = KvpUtils:SafeRetrieve(GetResourceKvpInt, 'notification_audio', 0) == 1,
}

local userLocales = GetConvarInt('qs:userLocales', 1) == 1

settings.locale = userLocales and KvpUtils:SafeRetrieve(GetResourceKvpString, 'locale', settings.default_locale) or settings.default_locale

-- Módulo interno para almacenamiento de configuraciones
local StorageManager = {}

function StorageManager:SaveSetting(key, value)
   if settings[key] == value then
      return false
   end

   settings[key] = value
   local valueType = type(value)

   if valueType == 'nil' then
      DeleteResourceKvp(key)
   elseif valueType == 'string' then
      SetResourceKvp(key, value)
   elseif valueType == 'table' then
      SetResourceKvp(key, json.encode(value))
   elseif valueType == 'number' then
      SetResourceKvpInt(key, value)
   elseif valueType == 'boolean' then
      SetResourceKvpInt(key, value and 1 or 0)
   else
      return false
   end

   return true
end

local function set(key, value)
   return StorageManager:SaveSetting(key, value)
end

-- Módulo interno para la interfaz de configuración
local SettingsUI = {}

function SettingsUI:BuildInputOptions(currentSettings, enableLocales)
   local options = {
      {
         type = 'checkbox',
         label = locale('settings_ui.notification_audio'),
         checked = currentSettings.notification_audio,
      },
      {
         type = 'select',
         label = locale('settings_ui.notification_position'),
         options = {
            { label = locale('position.top-right'),    value = 'top-right' },
            { label = locale('position.top'),          value = 'top' },
            { label = locale('position.top-left'),     value = 'top-left' },
            { label = locale('position.center-right'), value = 'center-right' },
            { label = locale('position.center-left'),  value = 'center-left' },
            { label = locale('position.bottom-right'), value = 'bottom-right' },
            { label = locale('position.bottom'),       value = 'bottom' },
            { label = locale('position.bottom-left'),  value = 'bottom-left' },
         },
         default = currentSettings.notification_position,
         required = true,
         icon = 'message',
      },
   }

   if enableLocales then
      table.insert(options, {
         type = 'select',
         label = locale('settings_ui.locale'),
         searchable = true,
         description = locale('settings_ui.locale_description', currentSettings.locale),
         options = GlobalState['qs_lib:locales'],
         default = currentSettings.locale,
         required = true,
         icon = 'book',
      })
   end

   return options
end

function SettingsUI:ApplySettings(handleInputData)
   local audioEnabled, position, language = table.unpack(handleInputData or {})

   if language and set('locale', language) then
      lib.setLocale(language)
   end

   if position then
      set('notification_position', position)
   end

   if audioEnabled ~= nil then
      set('notification_audio', audioEnabled)
   end
end

RegisterCommand('qs_lib', function()
   local inputOptions = SettingsUI:BuildInputOptions(settings, userLocales)
   local userInput = lib.inputDialog(locale('settings'), inputOptions) --[[@as table?]]
   if userInput then
      SettingsUI:ApplySettings(userInput)
   end
end)

return settings
