--- @class RadialItem
--- @field icon string|{[1]: string, [2]: string} The icon or icon with variant.
--- @field label string The label of the menu item.
--- @field menu? string The ID of a submenu to open.
--- @field onSelect? fun(currentMenu: string|nil, itemIndex: number)|string Callback function or export name to call on selection.
--- @field keepOpen? boolean If true, keeps the menu open after selection.
--- @field iconWidth? number Custom width for the icon.
--- @field iconHeight? number Custom height for the icon.
--- @field [string] any Additional custom fields.

--- @class RadialMenuItem : RadialItem
--- @field id string Unique identifier for the global menu item.
--- @field resource? string The resource that registered the item.

--- @class RadialMenuProps
--- @field id string Unique identifier for the submenu.
--- @field items RadialItem[] Array of submenu items.
--- @field resource? string The resource that registered the submenu.
--- @field [string] any Additional custom fields.

--- @class RadialMenuState
--- @field isOpen boolean Whether the radial menu is open.
--- @field menus table<string, RadialMenuProps> Registered submenus.
--- @field menuItems RadialMenuItem[] Global menu items.
--- @field menuHistory {id: string, option: string}[] Navigation history for submenus.
--- @field currentRadial? RadialMenuProps The currently open submenu.
--- @field isDisabled boolean Whether the radial menu is disabled.
local radialState = {
    isOpen = false,
    menus = {},
    menuItems = {},
    menuHistory = {},
    currentRadial = nil,
    isDisabled = false
}

--- Sends an NUI message to open or close the radial menu.
--- @param data table|boolean The menu data or false to close.
local function sendRadialMenuMessage(data)
    SendNUIMessage({
        action = 'openRadialMenu',
        data = data
    })
end

--- Opens a radial menu or submenu.
--- @param id? string The ID of the submenu to open (nil for global menu).
--- @param option? number The option to highlight (1-based).
local function showRadial(id, option)
    local radial = id and radialState.menus[id]
    if id and not radial then
        error(('No radial menu with id %s found.'):format(id))
    end

    radialState.currentRadial = radial

    -- Close current menu for transition
    sendRadialMenuMessage(false)
    Wait(100)

    -- Check if menu was closed during transition
    if not radialState.isOpen then return end

    sendRadialMenuMessage({
        items = radial and radial.items or radialState.menuItems,
        sub = radial and true or nil,
        option = option
    })
end

--- Refreshes the current menu or navigates back to a parent menu.
--- @param menuId? string The ID of the menu to refresh or return to.
local function refreshRadial(menuId)
    if not radialState.isOpen then return end

    if menuId and radialState.currentRadial then
        if menuId == radialState.currentRadial.id then
            return showRadial(menuId)
        end

        for i = 1, #radialState.menuHistory do
            local subMenu = radialState.menuHistory[i]
            if subMenu.id == menuId then
                local parent = radialState.menus[subMenu.id]
                for j = 1, #parent.items do
                    if parent.items[j].menu == radialState.currentRadial.id then
                        return -- Submenu is still active, no need to navigate back
                    end
                end

                radialState.currentRadial = parent
                for j = #radialState.menuHistory, i, -1 do
                    radialState.menuHistory[j] = nil
                end
                return showRadial(radialState.currentRadial.id)
            end
        end
        return
    end

    table.wipe(radialState.menuHistory)
    showRadial()
end

--- Registers a radial submenu.
--- @param radial RadialMenuProps The submenu data.
function lib.registerRadial(radial)
    radial.resource = GetInvokingResource()
    radialState.menus[radial.id] = radial
    if radialState.currentRadial then
        refreshRadial(radial.id)
    end
end

--- Gets the ID of the currently open submenu.
--- @return string? The ID of the current submenu, or nil if none.
function lib.getCurrentRadialId()
    return radialState.currentRadial and radialState.currentRadial.id
end

--- Hides the radial menu.
function lib.hideRadial()
    if not radialState.isOpen then return end

    sendRadialMenuMessage(false)
    lib.resetNuiFocus()
    table.wipe(radialState.menuHistory)
    radialState.isOpen = false
    radialState.currentRadial = nil
end

--- Adds one or more items to the global radial menu.
--- @param items RadialMenuItem|RadialMenuItem[] A single item or array of items.
function lib.addRadialItem(items)
    local invokingResource = GetInvokingResource()
    items = table.type(items) == 'array' and items or { items }

    for i = 1, #items do
        local item = items[i]
        item.resource = invokingResource
        local found = false

        for j = 1, #radialState.menuItems do
            if radialState.menuItems[j].id == item.id then
                radialState.menuItems[j] = item
                found = true
                break
            end
        end

        if not found then
            radialState.menuItems[#radialState.menuItems + 1] = item
        end
    end

    if radialState.isOpen and not radialState.currentRadial then
        refreshRadial()
    end
end

--- Removes an item from the global radial menu by ID.
--- @param id string The ID of the item to remove.
function lib.removeRadialItem(id)
    for i = 1, #radialState.menuItems do
        if radialState.menuItems[i].id == id then
            table.remove(radialState.menuItems, i)
            break
        end
    end

    if radialState.isOpen then
        refreshRadial(id)
    end
end

--- Clears all items from the global radial menu.
function lib.clearRadialItems()
    table.wipe(radialState.menuItems)
    if radialState.isOpen then
        refreshRadial()
    end
end

--- Disables or enables the radial menu.
--- @param state boolean True to disable, false to enable.
function lib.disableRadial(state)
    radialState.isDisabled = state
    if radialState.isOpen and state then
        lib.hideRadial()
    end
end

--- Handles the NUI callback for clicking a radial menu item.
--- @param index number The 0-based index of the selected item.
--- @param cb fun(result: number) Callback to acknowledge the NUI message.
local function handleRadialClick(index, cb)
    cb(1)
    local itemIndex = index + 1
    local item, currentMenu

    if radialState.currentRadial then
        item = radialState.currentRadial.items[itemIndex]
        currentMenu = radialState.currentRadial.id
    else
        item = radialState.menuItems[itemIndex]
    end

    local menuResource = radialState.currentRadial and radialState.currentRadial.resource or item.resource

    if item.menu then
        radialState.menuHistory[#radialState.menuHistory + 1] = {
            id = radialState.currentRadial and radialState.currentRadial.id,
            option = item.menu
        }
        showRadial(item.menu)
    elseif not item.keepOpen then
        lib.hideRadial()
    end

    local onSelect = item.onSelect
    if onSelect then
        if type(onSelect) == 'string' then
            return exports[menuResource][onSelect](0, currentMenu, itemIndex)
        end
        onSelect(currentMenu, itemIndex)
    end
end

--- Handles the NUI callback for navigating back in the radial menu.
--- @param data any Data from the NUI callback (ignored).
--- @param cb fun(result: number) Callback to acknowledge the NUI message.
local function handleRadialBack(data, cb)
    cb(1)
    local lastMenu = radialState.menuHistory[#radialState.menuHistory]
    if not lastMenu then return end

    radialState.menuHistory[#radialState.menuHistory] = nil
    if lastMenu.id then
        return showRadial(lastMenu.id, lastMenu.option)
    end

    radialState.currentRadial = nil
    sendRadialMenuMessage(false)
    Wait(100)

    if not radialState.isOpen then return end
    sendRadialMenuMessage({
        items = radialState.menuItems,
        option = lastMenu.option
    })
end

--- Handles the NUI callback for closing the radial menu.
--- @param data any Data from the NUI callback (ignored).
--- @param cb fun(result: number) Callback to acknowledge the NUI message.
local function handleRadialClose(data, cb)
    cb(1)
    if not radialState.isOpen then return end
    lib.resetNuiFocus()
    radialState.isOpen = false
    radialState.currentRadial = nil
end

--- Handles the NUI callback for menu transitions.
--- @param data any Data from the NUI callback (ignored).
--- @param cb fun(result: boolean) Callback to acknowledge the NUI message.
local function handleRadialTransition(data, cb)
    Wait(100)
    cb(radialState.isOpen)
end

-- Register NUI callbacks
RegisterNUICallback('handleRadialClick', handleRadialClick)
RegisterNUICallback('handleRadialBack', handleRadialBack)
RegisterNUICallback('handleRadialClose', handleRadialClose)
RegisterNUICallback('handleRadialTransition', handleRadialTransition)

-- Register keybind for radial menu
lib.addKeybind({
    name = 'qs_lib-radial',
    description = locale('open_radial_menu'),
    defaultKey = 'z',
    onPressed = function()
        if radialState.isDisabled or #radialState.menuItems == 0 or IsNuiFocused() or IsPauseMenuActive() then
            return
        end

        radialState.isOpen = true
        sendRadialMenuMessage({ items = radialState.menuItems })
        lib.setNuiFocus(true)
        SetCursorLocation(0.5, 0.5)

        while radialState.isOpen do
            DisablePlayerFiring(cache.playerId, true)
            DisableControlAction(0, 1, true) -- INPUT_LOOK_LR
            DisableControlAction(0, 2, true) -- INPUT_LOOK_UD
            DisableControlAction(0, 142, true) -- INPUT_AIM
            DisableControlAction(2, 199, true) -- INPUT_FRONTEND_PAUSE
            DisableControlAction(2, 200, true) -- INPUT_FRONTEND_PAUSE_ALTERNATE
            Wait(0)
        end
    end
})

-- Clean up menu items on resource stop
AddEventHandler('onClientResourceStop', function(resource)
    for i = #radialState.menuItems, 1, -1 do
        if radialState.menuItems[i].resource == resource then
            table.remove(radialState.menuItems, i)
        end
    end
end)
