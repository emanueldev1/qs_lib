-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

--- Framework resource management library
--- This module provides functions for accessing framework resources.
--- Replace the placeholder logic with your own implementation to interface with your framework.
--- @module framework

local Framework = {}

--- Retrieves the shared object from the framework.
--- @return table|nil A table containing the shared object, or nil if not available.
function Framework.getObject()
   -- Replace with your custom logic to fetch the shared object.
   -- Example: return YourFramework:GetSharedObject()
   return exports['es_extended']:getSharedObject()
end

return Framework
