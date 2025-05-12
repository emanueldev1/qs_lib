--- @class InputDialogRowProps
--- @field type 'input'|'number'|'checkbox'|'select'|'slider'|'multi-select'|'date'|'date-range'|'time'|'textarea'|'color' The type of input field.
--- @field label string The label for the input field.
--- @field options? { value: string, label: string, default?: string }[] Options for select or multi-select inputs.
--- @field password? boolean If true, masks the input as a password.
--- @field icon? string|{[1]: string, [2]: string} The icon or icon with variant.
--- @field iconColor? string The color of the icon.
--- @field placeholder? string Placeholder text for the input.
--- @field default? string|number The default value for the input.
--- @field disabled? boolean If true, disables the input.
--- @field checked? boolean If true, checks the checkbox by default.
--- @field min? number Minimum value for number or slider inputs.
--- @field max? number Maximum value for number or slider inputs.
--- @field step? number Step value for number or slider inputs.
--- @field autosize? boolean If true, auto-resizes the input field.
--- @field required? boolean If true, the input is required.
--- @field format? string Format for date or time inputs.
--- @field returnString? boolean If true, returns the value as a string.
--- @field clearable? boolean If true, allows clearing the input.
--- @field searchable? boolean If true, enables search for select inputs.
--- @field description? string Description text for the input.
--- @field maxSelectedValues? number Maximum number of values for multi-select.

--- @class InputDialogOptionsProps
--- @field allowCancel? boolean If true, allows canceling the dialog.

--- @class InputDialogState
--- @field promise? any The active promise for the input dialog.
local inputState = { promise = nil }

--- Converts string-based rows to InputDialogRowProps for backward compatibility.
--- @param rows string[]|InputDialogRowProps[] The input rows to process.
--- @return InputDialogRowProps[] The processed rows.
local function normalizeRows(rows)
   local normalized = {}
   for i, row in ipairs(rows) do
      normalized[i] = type(row) == 'string' and { type = 'input', label = row } or row
   end
   return normalized
end

--- Sends an NUI message to open an input dialog.
--- @param heading string The heading of the dialog.
--- @param rows InputDialogRowProps[] The input fields.
--- @param options? InputDialogOptionsProps The dialog options.
local function sendOpenDialogMessage(heading, rows, options)
   SendNUIMessage({
      action = 'openDialog',
      data = {
         heading = heading,
         rows = rows,
         options = options
      }
   })
end

--- Sends an NUI message to close the input dialog.
local function sendCloseDialogMessage()
   SendNUIMessage({
      action = 'closeInputDialog'
   })
end

--- Opens an input dialog and returns the user's input.
--- @param heading string The heading of the dialog.
--- @param rows string[]|InputDialogRowProps[] The input fields.
--- @param options? InputDialogOptionsProps The dialog options.
--- @return string[]|number[]|boolean[]|nil The input values, or nil if already active or canceled.
function lib.inputDialog(heading, rows, options)
   if inputState.promise then return end

   inputState.promise = promise.new()
   local normalizedRows = normalizeRows(rows)

   lib.setNuiFocus(false)
   sendOpenDialogMessage(heading, normalizedRows, options)

   return Citizen.Await(inputState.promise)
end

--- Closes the active input dialog.
function lib.closeInputDialog()
   if not inputState.promise then return end

   lib.resetNuiFocus()
   sendCloseDialogMessage()

   inputState.promise:resolve(nil)
   inputState.promise = nil
end

--- Handles the NUI callback when the user submits input data.
--- @param data string[]|number[]|boolean[]|nil The input values from the dialog.
--- @param cb fun(result: number) The callback to acknowledge the NUI message.
local function handleInputData(data, cb)
   cb(1)
   lib.resetNuiFocus()

   local currentPromise = inputState.promise
   inputState.promise = nil

   if currentPromise then
      currentPromise:resolve(data)
   end
end

-- Register NUI callback
RegisterNUICallback('handleInputData', handleInputData)
