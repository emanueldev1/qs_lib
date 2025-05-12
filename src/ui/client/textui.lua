--- @class TextUIOptions
--- @field position? 'right-center'|'left-center'|'top-center'|'bottom-center' Position of the text UI on the screen.
--- @field icon? string|{[1]: string, [2]: string} Icon or icon with variant.
--- @field iconColor? string Color of the icon.
--- @field style? string|table Custom styles for the text UI.
--- @field alignIcon? 'top'|'center' Vertical alignment of the icon.

--- @class TextUIState
--- @field isOpen boolean Whether the text UI is open.
--- @field currentText? string The currently displayed text.

local textUIState = { isOpen = false, currentText = nil }

--- Sends an NUI message to show or hide the text UI.
--- @param action string The NUI action ('textUi' or 'textUiHide').
--- @param data? table The data to send with the action.
local function sendTextUIMessage(action, data)
   SendNUIMessage({
      action = action,
      data = data
   })
end

--- Displays a text UI with the specified text and options.
--- @param text string The text to display.
--- @param options? TextUIOptions Configuration options for the text UI.
function lib.showTextUI(text, options)
   if textUIState.currentText == text then return end

   options = options or {}
   options.text = text
   textUIState.currentText = text
   textUIState.isOpen = true

   sendTextUIMessage('textUi', options)
end

--- Hides the text UI.
function lib.hideTextUI()
   sendTextUIMessage('textUiHide')
   textUIState.isOpen = false
   textUIState.currentText = nil
end

--- Checks if the text UI is open and returns the current text.
--- @return boolean, string|nil Whether the text UI is open and the current text (if any).
function lib.isTextUIOpen()
   return textUIState.isOpen, textUIState.currentText
end
