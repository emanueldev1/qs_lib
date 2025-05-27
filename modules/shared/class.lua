-- This file contains code adapted from ox_lib, developed by the Overextended team.
-- Original repository: https://github.com/overextended/ox_lib
-- License: GNU Lesser General Public License v3.0 (LGPL-3.0), available at https://www.gnu.org/licenses/lgpl-3.0.html
-- Modifications by emanueldev1 for the qs_lib project, licensed under LGPL-3.0.

---@diagnostic disable: invisible
local getinfo = debug.getinfo

-- Módulo para validación de tipos
local TypeChecker = {}

function TypeChecker.validateType(id, value, expectedType)
   local actualType = type(value)
   if actualType ~= expectedType then
      local idKind = type(id) == 'string' and 'field' or 'argument'
      error(string.format("expected %s %s to have type '%s' (received %s)", idKind, id, expectedType, actualType), 3)
   end

   if expectedType == 'table' and table.type(value) ~= 'hash' then
      error(string.format("expected argument %s to have table.type 'hash' (received %s)", id, table.type(value)), 3)
   end

   return true
end

---Ensure the given argument or property has a valid type, otherwise throwing an error.
---@param id number | string
---@param var any
---@param expected type
local function assertType(id, var, expected)
   return TypeChecker.validateType(id, var, expected)
end

---@alias QsClassConstructor<T> fun(self: T, ...: unknown): nil

---@class QsClass
---@field private __index table
---@field protected __name string
---@field protected private? { [string]: unknown }
---@field protected super? QsClassConstructor
---@field protected constructor? QsClassConstructor
local mixins = {}
local constructors = {}

-- Módulo para manejo de constructores
local ConstructorHandler = {}

function ConstructorHandler.extract(class)
   local savedConstructor = constructors[class] or class.constructor
   if class.constructor then
      constructors[class] = class.constructor
      class.constructor = nil
   end
   return savedConstructor
end

---Somewhat hacky way to remove the constructor from the class.__index.
---Maybe add static fields in the future?
---@param class QsClass
local function getConstructor(class)
   return ConstructorHandler.extract(class)
end

local function void()
   return ''
end

-- Módulo para gestión de instancias
local InstanceFactory = {}

function InstanceFactory.configurePrivateFields(instance)
   local privateData = table.clone(instance.private)
   table.wipe(instance.private)

   return setmetatable(instance.private, {
      __metatable = 'private',
      __tostring = void,
      __index = function(_, key)
         local debugInfo = getinfo(2, 'n')
         if debugInfo.namewhat ~= 'method' and debugInfo.namewhat ~= '' then return nil end
         return privateData[key]
      end,
      __newindex = function(_, key, value)
         local debugInfo = getinfo(2, 'n')
         if debugInfo.namewhat ~= 'method' and debugInfo.namewhat ~= '' then
            error(string.format("cannot set value of private field '%s'", key), 2)
         end
         privateData[key] = value
      end
   })
end

function InstanceFactory.createInstance(class, ...)
   local instanceConstructor = ConstructorHandler.extract(class)
   local privateStorage = {}
   local newInstance = setmetatable({ private = privateStorage }, class)

   if instanceConstructor then
      local parentClass = class
      rawset(newInstance, 'super', function(self, ...)
         parentClass = getmetatable(parentClass)
         local parentConstructor = ConstructorHandler.extract(parentClass)
         if parentConstructor then return parentConstructor(self, ...) end
      end)

      instanceConstructor(newInstance, ...)
   end

   rawset(newInstance, 'super', nil)

   if privateStorage ~= newInstance.private or next(newInstance.private) then
      newInstance.private = InstanceFactory.configurePrivateFields(newInstance)
   else
      newInstance.private = nil
   end

   return newInstance
end

function InstanceFactory.checkExactClass(instance, targetClass)
   return getmetatable(instance) == targetClass
end

function InstanceFactory.checkInheritance(instance, targetClass)
   local meta = getmetatable(instance)
   while meta do
      if meta == targetClass then return true end
      meta = getmetatable(meta)
   end
   return false
end

---Creates a new instance of the given class.
---@protected
---@generic T
---@param class T | QsClass
---@return T
function mixins.new(class, ...)
   return InstanceFactory.createInstance(class, ...)
end

---Checks if an object is an instance of the given class.
---@param class QsClass
function mixins:isClass(class)
   return InstanceFactory.checkExactClass(self, class)
end

---Checks if an object is an instance or derivative of the given class.
---@param class QsClass
function mixins:instanceOf(class)
   return InstanceFactory.checkInheritance(self, class)
end

-- Módulo para creación de clases
local ClassBuilder = {}

function ClassBuilder.createClass(className, parentClass)
   assertType(1, className, 'string')
   local newClass = table.clone(mixins)
   newClass.__name = className
   newClass.__index = newClass

   if parentClass then
      assertType('super', parentClass, 'table')
      setmetatable(newClass, parentClass)
   end

   return newClass
end

---Creates a new class.
---@generic S : QsClass
---@generic T : string
---@param name `T`
---@param super? S
---@return `T`
function lib.class(name, super)
   return ClassBuilder.createClass(name, super)
end

return lib.class
