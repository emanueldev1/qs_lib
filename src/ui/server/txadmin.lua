--- @class TxAdminEventData
--- @field author? string The author of the event (e.g., admin name).
--- @field message? string The message content.
--- @field target? number The target player server ID.
--- @field reason? string The reason for the warning.
--- @field actionId? string The ID of the warning action.
--- @field translatedMessage? string The translated restart message.

--- Checks if txAdmin notifications are enabled.
--- @return boolean True if enabled, false otherwise.
local function isTxAdminNotificationsEnabled()
   return GetConvarInt('qs:txAdminNotifications', 0) == 1
end

--- Sends a notification to clients.
--- @param target number|-1 The target player server ID or -1 for all players.
--- @param data table The notification data.
local function sendNotification(target, data)
   TriggerClientEvent('qs_lib:notify', target, data)
end

--- Sends an alert dialog to a client.
--- @param target number The target player server ID.
--- @param data table The alert dialog data.
local function sendAlertDialog(target, data)
   TriggerClientEvent('qs_lib:alertDialog', target, data)
end

--- Handles txAdmin announcement events if default announcement is hidden.
local function handleAnnouncement()
   if GetConvarInt('txAdmin-hideDefaultAnnouncement', 0) ~= 1 then return end
   AddEventHandler('txAdmin:events:announcement', function(eventData)
      sendNotification(-1, {
         id = 'txAdmin:announcement',
         title = locale('txadmin_announcement', eventData.author),
         description = eventData.message,
         duration = 5000
      })
   end)
end

--- Handles txAdmin direct message events if default direct message is hidden.
local function handleDirectMessage()
   if GetConvarInt('txAdmin-hideDefaultDirectMessage', 0) ~= 1 then return end
   AddEventHandler('txAdmin:events:playerDirectMessage', function(eventData)
      sendNotification(eventData.target, {
         id = 'txAdmin:playerDirectMessage',
         title = locale('txadmin_dm', eventData.author),
         description = eventData.message,
         duration = 5000
      })
   end)
end

--- Handles txAdmin warning events if default warning is hidden.
local function handleWarning()
   if GetConvarInt('txAdmin-hideDefaultWarning', 0) ~= 1 then return end
   AddEventHandler('txAdmin:events:playerWarned', function(eventData)
      sendAlertDialog(eventData.target, {
         header = locale('txadmin_warn', eventData.author),
         content = locale('txadmin_warn_content', eventData.reason, eventData.actionId),
         centered = true
      })
   end)
end

--- Handles txAdmin scheduled restart events if default warning is hidden.
local function handleScheduledRestart()
   if GetConvarInt('txAdmin-hideDefaultScheduledRestartWarning', 0) ~= 1 then return end
   AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
      sendNotification(-1, {
         id = 'txAdmin:scheduledRestart',
         title = locale('txadmin_scheduledrestart'),
         description = eventData.translatedMessage,
         duration = 5000
      })
   end)
end

-- Initialize event handlers if txAdmin notifications are enabled
if isTxAdminNotificationsEnabled() then
   handleAnnouncement()
   handleDirectMessage()
   handleWarning()
   handleScheduledRestart()
end
