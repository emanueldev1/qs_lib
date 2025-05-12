--- @class ContextMenuItem
--- @field title? string The title of the menu item.
--- @field menu? string The ID of a submenu to open.
--- @field icon? string|{[1]: string, [2]: string} The icon or icon with variant.
--- @field iconColor? string The color of the icon.
--- @field image? string URL or path to an image.
--- @field progress? number Progress bar value (0-100).
--- @field onSelect? fun(args: any) Callback function when the item is selected.
--- @field arrow? boolean If true, shows an arrow indicating a submenu.
--- @field description? string Description text for the item.
--- @field metadata? string|{[string]: any}|string[] Additional metadata.
--- @field disabled? boolean If true, the item is disabled.
--- @field readOnly? boolean If true, the item is read-only.
--- @field event? string Client-side event to trigger on selection.
--- @field serverEvent? string Server-side event to trigger on selection.
--- @field args? any Arguments to pass to the event or onSelect callback.

--- @class ContextMenuArrayItem : ContextMenuItem
--- @field title string The title of the menu item (required for array items).

--- @class ContextMenuProps
--- @field id string Unique identifier for the context menu.
--- @field title string The title of the context menu.
--- @field menu? string The ID of the parent menu.
--- @field onExit? fun() Callback function when the menu is closed.
--- @field onBack? fun() Callback function when navigating back.
--- @field canClose? boolean If false, prevents closing the menu.
--- @field options { [string]: ContextMenuItem } | ContextMenuArrayItem[] Menu items.

--- @class ContextMenuState
--- @field menus table<string, ContextMenuProps> Registered context menus.
--- @field currentMenuId? string The ID of the currently open context menu.
local menuState = { menus = {}, currentMenuId = nil }

--- Sends an NUI message to show a context menu.
--- @param menu ContextMenuProps The context menu to display.
--- @return boolean True if the message was sent successfully, false otherwise.
local function sendShowContextMessage(menu)
   local success, encoded = pcall(json.encode, {
      action = 'showContext',
      data = {
         title = menu.title,
         canClose = menu.canClose,
         menu = menu.menu,
         options = menu.options
      }
   }, { sort_keys = true })
   
   if not success then
      print(('^1Error encoding JSON for showContext: %s^0'):format(tostring(encoded)))
      return false
   end
   SendNuiMessage(encoded)
   return true
end

--- Sends an NUI message to hide the context menu.
local function sendHideContextMessage()
   SendNuiMessage(json.encode({ action = 'hideContext' }))
end

--- Closes the current context menu and performs cleanup.
--- @param data any Data from the NUI callback (ignored).
--- @param cb? fun(result: number) Callback to acknowledge the NUI message.
--- @param triggerOnExit? boolean If true, triggers the onExit callback.
local function closeCurrentMenu(data, cb, triggerOnExit)
   if cb then cb(1) end
   lib.resetNuiFocus()

   local menuId = menuState.currentMenuId
   if not menuId then return end

   local menu = menuState.menus[menuId]
   if (cb or triggerOnExit) and menu and menu.onExit then
      menu.onExit()
   end

   if not cb then
      sendHideContextMessage()
   end

   menuState.currentMenuId = nil
end

--- Shows a context menu by its ID.
--- @param id string The ID of the context menu to show.
function lib.showContext(id)
   local menu = menuState.menus[id]
   if not menu then
      error(('No context menu with id \'%s\' found'):format(id))
   end

   menuState.currentMenuId = id
   lib.setNuiFocus(false)
   if not sendShowContextMessage(menu) then
      menuState.currentMenuId = nil
      error(('Failed to show context menu \'%s\' due to JSON encoding error'):format(id))
   end
end

--- Registers one or more context menus.
--- @param context ContextMenuProps|ContextMenuProps[] A single menu or array of menus.
function lib.registerContext(context)
   if type(context) == 'table' and context.id then
      menuState.menus[context.id] = context
   else
      for _, menu in ipairs(context) do
         menuState.menus[menu.id] = menu
      end
   end
end

--- Gets the ID of the currently open context menu.
--- @return string? The ID of the open menu, or nil if none.
function lib.getOpenContextMenu()
   return menuState.currentMenuId
end

--- Hides the current context menu.
--- @param triggerOnExit? boolean If true, triggers the onExit callback.
function lib.hideContext(triggerOnExit)
   closeCurrentMenu(nil, nil, triggerOnExit)
end

--- Handles the NUI callback for opening a context menu or navigating back.
--- @param data {id: string, back?: boolean} The NUI callback data.
--- @param cb fun(result: number) Callback to acknowledge the NUI message.
local function handleOpenContext(data, cb)
   cb(1)
   if not data.id then
      print('^1Error: handleOpenContext callback received invalid data (missing id)^0')
      return
   end
   if data.back and menuState.currentMenuId then
      local menu = menuState.menus[menuState.currentMenuId]
      if menu and menu.onBack then
         menu.onBack()
      end
   end
   lib.showContext(data.id)
end

--- Handles the NUI callback for clicking a context menu item.
--- @param id string|number The index or key of the selected item.
--- @param cb fun(result: number) Callback to acknowledge the NUI message.
local function handleClickContext(id, cb)
   cb(1)
   local menuId = menuState.currentMenuId
   if not menuId then
      print('^1Error: handleClickContext called with no open menu^0')
      return
   end

   local menu = menuState.menus[menuId]
   if not menu then
      print(('^1Error: Menu \'%s\' not found in handleClickContext^0'):format(menuId))
      return
   end

   -- Normalize id for array-based options
   local index = id
   if type(id) == 'string' then
      local numId = tonumber(id)
      if numId then
         if math.type(numId) == 'float' then
            index = math.tointeger(numId)
         else
            index = numId + 1
         end
      end
   end

   local item = menu.options[index]
   if not item then
      print(('^1Error: Invalid menu item index \'%s\' for menu \'%s\'^0'):format(tostring(index), menuId))
      return
   end
   if not (item.event or item.serverEvent or item.onSelect) then return end

   menuState.currentMenuId = nil
   sendHideContextMessage()
   lib.resetNuiFocus()

   if item.onSelect then item.onSelect(item.args) end
   if item.event then TriggerEvent(item.event, item.args) end
   if item.serverEvent then TriggerServerEvent(item.serverEvent, item.args) end
end

-- Register NUI callbacks
RegisterNUICallback('handleOpenContext', handleOpenContext)
RegisterNUICallback('handleClickContext', handleClickContext)
RegisterNUICallback('closeCurrentMenu', closeCurrentMenu)
