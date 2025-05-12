--- @alias NotificationPosition 'top'|'top-right'|'top-left'|'bottom'|'bottom-right'|'bottom-left'|'center-right'|'center-left'
--- @alias NotificationType 'info'|'warning'|'success'|'error'
--- @alias IconAnimationType 'spin'|'spinPulse'|'spinReverse'|'pulse'|'beat'|'fade'|'beatFade'|'bounce'|'shake'

--- @class NotifyProps
--- @field id? string Unique identifier for the notification.
--- @field title? string The title of the notification.
--- @field description? string The main content of the notification.
--- @field duration? number Duration in milliseconds the notification is displayed.
--- @field showDuration? boolean If true, shows a duration progress bar.
--- @field position? NotificationPosition Position on the screen.
--- @field type? NotificationType Type of notification (affects styling).
--- @field style? table<string, any> Custom styles for the notification.
--- @field icon? string|{[1]: string, [2]: string} Icon or icon with variant.
--- @field iconAnimation? IconAnimationType Animation effect for the icon.
--- @field iconColor? string Color of the icon.
--- @field alignIcon? 'top'|'center' Vertical alignment of the icon.
--- @field sound? { bank?: string, set: string, name: string } Sound effect to play.

--- @class DefaultNotifyProps
--- @field title? string The title of the notification.
--- @field description? string The main content of the notification.
--- @field duration? number Duration in milliseconds.
--- @field position? NotificationPosition Position on the screen.
--- @field status? 'info'|'warning'|'success'|'error' Legacy type field.
--- @field id? number Legacy identifier.

local settings = require 'src.settings'

--- Plays a sound effect for a notification.
--- @param sound { bank?: string, set: string, name: string } The sound configuration.
local function playNotificationSound(sound)
   if sound.bank then
      lib.requestAudioBank(sound.bank)
   end

   local soundId = GetSoundId()
   PlaySoundFrontend(soundId, sound.name, sound.set, true)
   ReleaseSoundId(soundId)

   if sound.bank then
      ReleaseNamedScriptAudioBank(sound.bank)
   end
end

--- Sends an NUI message to display a notification.
--- @param data NotifyProps The notification data.
local function sendNotifyMessage(data)
   SendNUIMessage({
      action = 'notify',
      data = data
   })
end

--- Displays a notification with the specified properties.
--- @param data NotifyProps The notification data.
function lib.notify(data)
   local sound = settings.notification_audio and data.sound
   data.sound = nil
   data.position = data.position or settings.notification_position

   sendNotifyMessage(data)

   if sound then
      playNotificationSound(sound)
   end
end

--- Displays a notification with legacy format support.
--- @param data DefaultNotifyProps The notification data with legacy fields.
function lib.defaultNotify(data)
   local notifyData = {
      id = data.id,
      title = data.title,
      description = data.description,
      duration = data.duration,
      position = data.position,
      type = data.status == 'inform' and 'info' or data.status
   }
   return lib.notify(notifyData)
end

-- Register network events
RegisterNetEvent('qs_lib:notify', lib.notify)
RegisterNetEvent('qs_lib:defaultNotify', lib.defaultNotify)
