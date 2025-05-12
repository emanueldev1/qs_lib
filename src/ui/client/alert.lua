--- @class AlertDialogProps
--- @field header string The title of the alert dialog.
--- @field content string The main content of the alert dialog.
--- @field centered? boolean If true, centers the dialog on the screen.
--- @field size? 'xs'|'sm'|'md'|'lg'|'xl' The size of the dialog.
--- @field overflow? boolean If true, allows content to overflow.
--- @field cancel? boolean If true, shows a cancel button.
--- @field labels? {cancel?: string, confirm?: string} Custom labels for buttons.

--- @class AlertState
--- @field promise? any The active promise for the alert dialog.
--- @field id number The unique ID of the current alert dialog.
local alertState = { promise = nil, id = 0 }

--- Sends an NUI message to display an alert dialog.
--- @param data AlertDialogProps The properties of the alert dialog.
local function sendAlertMessage(data)
   SendNUIMessage({ action = 'sendAlert', data = data })
end

--- Sends an NUI message to close the alert dialog.
local function sendCloseAlertMessage()
   SendNUIMessage({ action = 'closeAlertDialog' })
end

--- Sets up a timeout to close the alert dialog after a specified duration.
--- @param timeout number The duration in milliseconds before closing the dialog.
--- @param currentId number The ID of the current alert dialog.
local function setupAlertTimeout(timeout, currentId)
   SetTimeout(timeout, function()
      if alertState.id == currentId then
         lib.closeAlertDialog('timeout')
      end
   end)
end

--- Displays an alert dialog and returns the user's response.
--- @param data AlertDialogProps The properties of the alert dialog.
--- @param timeout? number Optional timeout in milliseconds to close the dialog.
--- @return 'cancel'|'confirm'|nil The result of the dialog, or nil if already active.
function lib.alertDialog(data, timeout)
   if alertState.promise then return end

   alertState.id = alertState.id + 1
   alertState.promise = promise.new()

   lib.setNuiFocus(false)
   sendAlertMessage(data)

   if timeout then
      setupAlertTimeout(timeout, alertState.id)
   end

   return Citizen.Await(alertState.promise)
end

--- Closes the active alert dialog with an optional reason.
--- @param reason? string The reason for closing the dialog (e.g., 'timeout').
function lib.closeAlertDialog(reason)
   if not alertState.promise then return end

   lib.resetNuiFocus()
   sendCloseAlertMessage()

   local currentPromise = alertState.promise
   alertState.promise = nil

   if reason then
      currentPromise:reject(reason)
   else
      currentPromise:resolve()
   end
end

--- Handles the NUI callback when the alert dialog is closed by the user.
--- @param data 'cancel'|'confirm' The user's response from the dialog.
--- @param cb fun(result: number) The callback to acknowledge the NUI message.
local function handleAlertClose(data, cb)
   cb(1)
   lib.resetNuiFocus()

   local currentPromise = alertState.promise
   alertState.promise = nil

   if currentPromise then
      currentPromise:resolve(data)
   end
end

-- Register NUI callback and network event
RegisterNUICallback('handleAlertClose', handleAlertClose)
RegisterNetEvent('qs_lib:alertDialog', lib.alertDialog)
