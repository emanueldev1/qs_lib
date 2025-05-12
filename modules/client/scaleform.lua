-- scaleform.lua: Manages scaleform movies in FiveM for displaying graphical interfaces.
-- This module provides a class to create, configure, and render scaleform movies, supporting render targets,
-- fullscreen or custom-positioned rendering, and method calls for interaction.

---@class renderTargetTable
---@field name string
---@field model string | number

---@class detailsTable
---@field name string
---@field fullScreen? boolean
---@field x? number
---@field y? number
---@field width? number
---@field height? number
---@field renderTarget? renderTargetTable

---@class Scaleform : QsClass
---@field scaleform number
---@field draw boolean
---@field target number
---@field targetName string
---@field sfHandle? number
---@field fullScreen boolean
---@field private private { isDrawing: boolean }
lib.scaleform = lib.class('Scaleform')

-- Converts method arguments into scaleform-compatible data types.
---@param methodArgs (number | string | boolean)[]
local function formatMethodArgs(methodArgs)
   for i = 1, #methodArgs do
      local value = methodArgs[i]
      local valueType = type(value)
      if valueType == "string" then
         ScaleformMovieMethodAddParamPlayerNameString(value)
      elseif valueType == "number" then
         if math.type(value) == "integer" then
            ScaleformMovieMethodAddParamInt(value)
         else
            ScaleformMovieMethodAddParamFloat(value)
         end
      elseif valueType == "boolean" then
         ScaleformMovieMethodAddParamBool(value)
      else
         error(string.format("Parameter type not supported: %s", valueType))
      end
   end
end

-- Retrieves the return value from a scaleform method.
---@param returnType "boolean" | "integer" | "string"
---@return boolean | integer | string
local function fetchMethodResult(returnType)
   local resultHandle = EndScaleformMovieMethodReturnValue()
   lib.waitFor(function()
      if IsScaleformMovieMethodReturnValueReady(resultHandle) then
         return true
      end
   end, "Could not obtain return value", 1300)

   if returnType == "integer" then
      return GetScaleformMovieMethodReturnValueInt(resultHandle)
   elseif returnType == "boolean" then
      return GetScaleformMovieMethodReturnValueBool(resultHandle)
   end
   return GetScaleformMovieMethodReturnValueString(resultHandle)
end

-- Sets up the render target for the scaleform.
---@param scaleform Scaleform
---@param renderName string
---@param modelRef string | number
local function setupRenderTarget(scaleform, renderName, modelRef)
   if scaleform.target then
      ReleaseNamedRendertarget(scaleform.targetName)
   end

   local modelHash = type(modelRef) == "string" and joaat(modelRef) or modelRef
   if not IsNamedRendertargetRegistered(renderName) then
      RegisterNamedRendertarget(renderName, false)
      if not IsNamedRendertargetLinked(modelHash) then
         LinkNamedRendertarget(modelHash)
      end
      scaleform.target = GetNamedRendertargetRenderId(renderName)
      scaleform.targetName = renderName
   end
end

-- Renders the scaleform based on its configuration.
---@param scaleform Scaleform
local function displayScaleform(scaleform)
   if scaleform.target then
      SetTextRenderId(scaleform.target)
      SetScriptGfxDrawOrder(4)
      SetScriptGfxDrawBehindPausemenu(true)
      SetScaleformFitRendertarget(scaleform.scaleformHandle, true)
   end

   if scaleform.fullScreen then
      DrawScaleformMovieFullscreen(scaleform.scaleformHandle, 255, 255, 255, 255, 0)
   else
      if not scaleform.x or not scaleform.y or not scaleform.width or not scaleform.height then
         error("Cannot render scaleform without defining position and size")
      end
      DrawScaleformMovie(scaleform.scaleformHandle, scaleform.x, scaleform.y, scaleform.width, scaleform.height, 255, 255, 255, 255, 0)
   end

   if scaleform.target then
      SetTextRenderId(1)
   end
end

---@param details detailsTable | string
function lib.scaleform:constructor(details)
   -- Normalize details to a table
   local options = type(details) == "table" and details or { name = details }

   -- Load the scaleform movie
   local handle = lib.requestScaleformMovie(options.name)

   -- Initialize instance properties
   self.scaleformHandle = handle
   self.private = { isDrawing = false }
   self.fullScreen = options.fullScreen or false
   self.x = options.x or 0.5
   self.y = options.y or 0.5
   self.width = options.width or 0.8
   self.height = options.height or 0.8

   -- Configure render target if provided
   if options.renderTarget then
      setupRenderTarget(self, options.renderTarget.name, options.renderTarget.model)
   end
end

---@param name string
---@param args? (number | string | boolean)[]
---@param returnValue? string
---@return any
function lib.scaleform:callMethod(name, args, returnValue)
   if not self.scaleformHandle then
      error("Cannot invoke method with an invalid scaleform handle")
   end

   BeginScaleformMovieMethod(self.scaleformHandle, name)
   if args and type(args) == "table" then
      formatMethodArgs(args)
   end

   if returnValue then
      return fetchMethodResult(returnValue)
   end

   EndScaleformMovieMethod()
end

---@param isFullscreen boolean
function lib.scaleform:setFullScreen(isFullscreen)
   self.fullScreen = isFullscreen
end

---@param x number
---@param y number
---@param width number
---@param height number
function lib.scaleform:setProperties(x, y, width, height)
   if self.fullScreen then
      lib.print.info("Unable to adjust properties in fullscreen mode")
      return
   end

   self.x = x
   self.y = y
   self.width = width
   self.height = height
end

---@param name string
---@param model string|number
function lib.scaleform:setRenderTarget(name, model)
   setupRenderTarget(self, name, model)
end

function lib.scaleform:isDrawing()
   return self.private.isDrawing
end

function lib.scaleform:draw()
   displayScaleform(self)
end

function lib.scaleform:startDrawing()
   if self.private.isDrawing then
      return
   end

   self.private.isDrawing = true
   CreateThread(function()
      while self:isDrawing() do
         displayScaleform(self)
         Wait(0)
      end
   end)
end

function lib.scaleform:stopDrawing()
   if not self.private.isDrawing then
      return
   end

   self.private.isDrawing = false
end

function lib.scaleform:dispose()
   if self.scaleformHandle then
      SetScaleformMovieAsNoLongerNeeded(self.scaleformHandle)
      self.scaleformHandle = nil
   end

   if self.target then
      ReleaseNamedRendertarget(self.targetName)
      self.target = nil
      self.targetName = nil
   end

   self.private.isDrawing = false
end

---@return Scaleform
return lib.scaleform
