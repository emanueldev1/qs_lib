--- Fuel management library
--- This module provides functions for managing vehicle fuel levels.
--- @module fuel

local Fuel = {}

--- Sets the fuel level for a vehicle.
--- @param veh number|string The vehicle identifier (e.g., vehicle handle or ID).
--- @param val number The fuel level to set (e.g., percentage or absolute value).
--- @param _type string|nil Optional fuel type (defaults to "RON91" if not provided).
--- @return boolean|nil True if the fuel level was set successfully, false or nil otherwise.
function Fuel.setFuel(veh, val, _type)
   return exports["ti_fuel"]:setFuel(veh, val, _type or "RON91")
end

--- Retrieves the fuel level and type of a vehicle.
--- @param veh number|string The vehicle identifier (e.g., vehicle handle or ID).
--- @return number|nil The current fuel level of the vehicle, or nil if not available.
--- @return string|nil The fuel type of the vehicle, or nil if not available.
function Fuel.getFuel(veh)
   local level, type = exports["ti_fuel"]:getFuel(veh)
   return level, type
end

return Fuel
