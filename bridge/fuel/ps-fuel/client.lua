-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

--- Fuel management library
--- This module provides functions for managing vehicle fuel levels.
--- @module fuel

local Fuel = {}

--- Sets the fuel level for a vehicle.
--- @param veh number|string The vehicle identifier (e.g., vehicle handle or ID).
--- @param val number The fuel level to set (e.g., percentage or absolute value).
--- @return boolean|nil True if the fuel level was set successfully, false or nil otherwise.
function Fuel.setFuel(veh, val)
   return exports['ps-fuel']:SetFuel(veh, val)
end

--- Retrieves the fuel level of a vehicle.
--- @param veh number|string The vehicle identifier (e.g., vehicle handle or ID).
--- @return number|nil The current fuel level of the vehicle, or nil if not available.
function Fuel.getFuel(veh)
   return exports['ps-fuel']:GetFuel(veh)
end

return Fuel
