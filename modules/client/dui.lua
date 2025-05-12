-- dui.lua: Manages Dynamic UI (DUI) instances for FiveM, providing functionality to create, update, and remove DUIs.
-- This module handles the creation of runtime textures and DUI objects, allowing for dynamic web-based UI rendering in-game.

---@class DuiProperties
---@field url string
---@field width number
---@field height number
---@field debug? boolean

---@class Dui : QsClass
---@field private private { id: string, debug: boolean }
---@field url string
---@field duiObject number
---@field duiHandle string
---@field runtimeTxd number
---@field txdObject number
---@field dictName string
---@field txtName string
lib.dui = lib.class('Dui')

---@type table<string, Dui>
local duis = {}

local instanceCounter = 0

-- Generates a unique identifier for a DUI instance based on resource, timestamp, and counter.
---@param resource string
---@return string
local function generateUniqueId(resource)
   local timestamp = GetGameTimer()
   instanceCounter = instanceCounter + 1
   return string.format("%s_%d_%d", resource, timestamp, instanceCounter)
end

-- Creates texture dictionary and texture names for a DUI instance.
---@param uniqueId string
---@return string, string
local function createTextureNames(uniqueId)
   local dictionary = string.format("qs_lib_dui_dict_%s", uniqueId)
   local texture = string.format("qs_lib_dui_txt_%s", uniqueId)
   return dictionary, texture
end

-- Initializes DUI and runtime texture for rendering.
---@param properties DuiProperties
---@param uniqueId string
---@param dictionary string
---@param texture string
---@return number, string, number, number
local function initializeDui(properties, uniqueId, dictionary, texture)
   local duiInstance = CreateDui(properties.url, properties.width, properties.height)
   local duiIdentifier = GetDuiHandle(duiInstance)
   local textureDict = CreateRuntimeTxd(dictionary)
   local textureObj = CreateRuntimeTextureFromDuiHandle(textureDict, texture, duiIdentifier)
   return duiInstance, duiIdentifier, textureDict, textureObj
end

-- Logs debug information if enabled.
---@param isDebug boolean
---@param message string
---@param ... any
local function logDebug(isDebug, message, ...)
   if isDebug then
      print(string.format(message, ...))
   end
end

---@param data DuiProperties
function lib.dui:constructor(data)
   -- Generate a unique ID for this DUI instance
   local uniqueId = generateUniqueId(cache.resource)

   -- Create texture dictionary and texture names
   local dictionary, texture = createTextureNames(uniqueId)

   -- Initialize DUI and runtime texture
   local duiInstance, duiIdentifier, textureDict, textureObj = initializeDui(data, uniqueId, dictionary, texture)

   -- Store instance properties
   self.private = {
      id = uniqueId,
      debug = data.debug or false
   }
   self.url = data.url
   self.duiObject = duiInstance
   self.duiHandle = duiIdentifier
   self.runtimeTxd = textureDict
   self.txdObject = textureObj
   self.dictName = dictionary
   self.txtName = texture

   -- Register instance in global table
   duis[uniqueId] = self

   -- Log creation if debug is enabled
   logDebug(self.private.debug, "DUI instance %s successfully created", uniqueId)
end

-- Cleans up a DUI instance by resetting its URL and destroying it.
function lib.dui:remove()
   -- Reset DUI URL to prevent further rendering
   SetDuiUrl(self.duiObject, "about:blank")

   -- Destroy the DUI instance
   DestroyDui(self.duiObject)

   -- Remove from global table
   duis[self.private.id] = nil

   -- Log removal if debug is enabled
   logDebug(self.private.debug, "DUI instance %s has been removed", self.private.id)
end

-- Updates the URL of an existing DUI instance.
---@param url string
function lib.dui:setUrl(url)
   -- Update stored URL
   self.url = url

   -- Apply new URL to DUI
   SetDuiUrl(self.duiObject, url)

   -- Log URL change if debug is enabled
   logDebug(self.private.debug, "DUI instance %s updated to URL: %s", self.private.id, url)
end

-- Sends a JSON-encoded message to the DUI instance.
---@param message table
function lib.dui:sendMessage(message)
   -- Encode message to JSON
   local encodedData = json.encode(message)

   -- Send message to DUI
   SendDuiMessage(self.duiObject, encodedData)

   -- Log message if debug is enabled
   logDebug(self.private.debug, "DUI instance %s sent message:\n%s", self.private.id, json.encode(message, { indent = true }))
end

-- Cleans up all DUI instances when the resource stops.
AddEventHandler('onResourceStop', function(resourceName)
   if cache.resource ~= resourceName then return end

   for _, dui in pairs(duis) do
      dui:remove()
   end
end)

return lib.dui
