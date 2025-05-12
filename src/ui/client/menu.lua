--- @class MenuOptions
--- @field label string The label of the menu option.
--- @field progress? number Progress bar value (0-100).
--- @field colorScheme? string Color scheme for the option.
--- @field icon? string|{[1]: string, [2]: string} The icon or icon with variant.
--- @field iconColor? string The color of the icon.
--- @field values? table<string | { label: string, description: string }> List of values for scrolling options.
--- @field checked? boolean If true, the option is checked.
--- @field description? string Description text for the option.
--- @field defaultIndex? number Default scroll index for values.
--- @field args? table Additional arguments for callbacks.
--- @field close? boolean If false, prevents closing the menu on selection.

--- @class MenuProps
--- @field id string Unique identifier for the menu.
--- @field title string The title of the menu.
--- @field options MenuOptions[] Array of menu options.
--- @field position? 'top-left'|'top-right'|'bottom-left'|'bottom-right' Menu position on the screen.
--- @field disableInput? boolean If true, disables player input while the menu is open.
--- @field canClose? boolean If false, prevents closing the menu.
--- @field onClose? fun(keyPressed?: 'Escape'|'Backspace') Callback when the menu is closed.
--- @field onSelected? fun(selected: number, scrollIndex?: number, args?: table, checked?: boolean) Callback when an option is selected.
--- @field onSideScroll? fun(selected: number, scrollIndex?: number, args?: table) Callback when scrolling through values.
--- @field onCheck? fun(selected: number, checked: boolean, args?: table) Callback when a checkbox is toggled.
--- @field cb? fun(selected: number, scrollIndex?: number, args?: table, checked?: boolean) General callback for menu actions.

--- @class MenuState
--- @field menus table<string, MenuProps> Registered menus.
--- @field currentMenu? MenuProps The currently open menu.
local menuState = { menus = {}, currentMenu = nil }

--- Validates menu data before registration.
--- @param data MenuProps The menu data to validate.
local function validateMenuData(data)
   if not data.id then error('No menu id was provided.') end
   if not data.title then error('No menu title was provided.') end
   if not data.options then error('No menu options were provided.') end
end

--- Disables player input while the menu is open.
local function disablePlayerInput()
   local control = cache.game == 'fivem' and 140 or 0xE30CD707
   CreateThread(function()
      while menuState.currentMenu do
         local menu = menuState.currentMenu
         if menu.disableInput == nil or menu.disableInput then
            DisablePlayerFiring(cache.playerId, true)
            if cache.game == 'fivem' then
               HudWeaponWheelIgnoreSelection()
            end
            DisableControlAction(0, control, true)
         end
         Wait(0)
      end
   end)
end

--- Sends an NUI message to display a menu.
--- @param menu MenuProps The menu to display.
--- @param startIndex? number The starting item index (1-based).
local function sendShowMenuMessage(menu, startIndex)
   SendNUIMessage({
      action = 'setMenu',
      data = {
         position = menu.position,
         canClose = menu.canClose,
         title = menu.title,
         items = menu.options,
         startItemIndex = startIndex and startIndex - 1 or 0
      }
   })
end

--- Sends an NUI message to close the menu.
local function sendCloseMenuMessage()
   SendNUIMessage({ action = 'handleCloseMenu' })
end

--- Registers a menu with the given data and callback.
--- @param data MenuProps The menu data to register.
--- @param cb? fun(selected: number, scrollIndex?: number, args?: table, checked?: boolean) Optional callback for menu actions.
function lib.registerMenu(data, cb)
   validateMenuData(data)
   data.cb = cb
   menuState.menus[data.id] = data
end

--- Shows a menu by its ID.
--- @param id string The ID of the menu to show.
--- @param startIndex? number The starting item index (1-based).
function lib.showMenu(id, startIndex)
   local menu = menuState.menus[id]
   if not menu then
      error(('No menu with id %s was found'):format(id))
   end
   if table.type(menu.options) == 'empty' then
      error(('Can\'t open empty menu with id %s'):format(id))
   end

   if not menuState.currentMenu then
      disablePlayerInput()
   end

   menuState.currentMenu = menu
   lib.setNuiFocus(not menu.disableInput, true)
   sendShowMenuMessage(menu, startIndex)
end

--- Hides the current menu.
--- @param onExit? boolean If true, triggers the onClose callback.
function lib.hideMenu(onExit)
   local menu = menuState.currentMenu
   menuState.currentMenu = nil

   if not menu then return end

   lib.resetNuiFocus()
   sendCloseMenuMessage()

   if onExit and menu.onClose then
      menu.onClose()
   end
end

--- Updates menu options for a specific menu.
--- @param id string The ID of the menu to update.
--- @param options MenuOptions|MenuOptions[] The new options or a single option.
--- @param index? number The index to update (if updating a single option).
function lib.setMenuOptions(id, options, index)
   local menu = menuState.menus[id]
   if not menu then
      error(('No menu with id %s was found'):format(id))
   end
   if index then
      menu.options[index] = options
   else
      if not options[1] then
         error('Invalid override format used, expected table of options.')
      end
      menu.options = options
   end
end

--- Gets the ID of the currently open menu.
--- @return string? The ID of the open menu, or nil if none.
function lib.getOpenMenu()
   return menuState.currentMenu and menuState.currentMenu.id
end

--- Handles the NUI callback for confirming a selected option.
--- @param data table Contains selected (0-based), scrollIndex (0-based), and checked status.
--- @param cb fun(result: number) Callback to acknowledge the NUI message.
local function handleConfirmSelected(data, cb)
   cb(1)
   local selected = data[1] + 1
   local scrollIndex = data[2] and data[2] + 1 or nil
   local checked = data[3]

   local menu = menuState.currentMenu
   if not menu then return end

   if menu.options[selected].close ~= false then
      menuState.currentMenu = nil
      lib.resetNuiFocus()
   end

   if menu.cb then
      menu.cb(selected, scrollIndex, menu.options[selected].args, checked)
   end
end

--- Handles the NUI callback for changing the scroll index.
--- @param data table Contains selected (0-based) and scrollIndex (0-based).
--- @param cb fun(result: number) Callback to acknowledge the NUI message.
local function handleChangeIndex(data, cb)
   cb(1)
   local menu = menuState.currentMenu
   if not menu or not menu.onSideScroll then return end

   local selected = data[1] + 1
   local scrollIndex = data[2] and data[2] + 1 or nil
   menu.onSideScroll(selected, scrollIndex, menu.options[selected].args)
end

--- Handles the NUI callback for changing the selected option.
--- @param data table Contains selected (0-based), scrollIndex (0-based), and optional args key.
--- @param cb fun(result: number) Callback to acknowledge the NUI message.
local function handleChangeSelected(data, cb)
   cb(1)
   local menu = menuState.currentMenu
   if not menu or not menu.onSelected then return end

   local selected = data[1] + 1
   local scrollIndex = data[2] and data[2] + 1 or nil
   local args = menu.options[selected].args or {}

   if type(args) ~= 'table' then
      error('Menu args must be passed as a table')
   end
   if data[2] and data[3] then
      args[data[3]] = true
   end

   menu.onSelected(selected, scrollIndex, args)
end

--- Handles the NUI callback for toggling a checkbox.
--- @param data table Contains selected (0-based) and checked status.
--- @param cb fun(result: number) Callback to acknowledge the NUI message.
local function handleChangeChecked(data, cb)
   cb(1)
   local menu = menuState.currentMenu
   if not menu or not menu.onCheck then return end

   local selected = data[1] + 1
   local checked = data[2]
   menu.onCheck(selected, checked, menu.options[selected].args)
end

--- Handles the NUI callback for closing the menu.
--- @param data 'Escape'|'Backspace'|nil The key pressed to close the menu.
--- @param cb fun(result: number) Callback to acknowledge the NUI message.
local function handleCloseMenu(data, cb)
   cb(1)
   local menu = menuState.currentMenu
   menuState.currentMenu = nil

   if not menu then return end

   lib.resetNuiFocus()
   if menu.onClose then
      menu.onClose(data)
   end
end

-- Register NUI callbacks
RegisterNUICallback('handleConfirmSelected', handleConfirmSelected)
RegisterNUICallback('handleChangeIndex', handleChangeIndex)
RegisterNUICallback('handleChangeSelected', handleChangeSelected)
RegisterNUICallback('handleChangeChecked', handleChangeChecked)
RegisterNUICallback('handleCloseMenu', handleCloseMenu)

-- // TODO: CHECK IF IT WORKS
