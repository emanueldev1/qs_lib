-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

--- Fuel management library
--- This module provides functions for managing vehicle fuel levels.
--- @module fuel

local Fuel = {}

--- Sets the fuel level for a vehicle.
--- @param veh number|string The vehicle identifier (e.g., vehicle handle or ID).
--- @param val number The fuel level to set (e.g., percentage or absolute value).
--- @param _type any|nil Optional parameter for fuel type (unused in current implementation).
--- @return number|nil The set fuel level, or nil if not available.
function Fuel.setFuel(veh, val, _type)
   Entity(veh).state.fuel = val
   return Entity(veh).state.fuel
end

--- Retrieves the fuel level of a vehicle.
--- @param veh number|string The vehicle identifier (e.g., vehicle handle or ID).
--- @return number|nil The current fuel level of the vehicle, or nil if not available.
function Fuel.getFuel(veh)
   return Entity(veh).state.fuel
end

return Fuel
