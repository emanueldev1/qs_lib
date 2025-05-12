--- Fuel management library
--- This module provides functions for managing vehicle fuel levels.
--- @module fuel

local Fuel = {}

--- Sets the fuel level for a vehicle.
--- @param veh number|string The vehicle identifier (e.g., vehicle handle or ID).
--- @param val number The fuel level to set (e.g., percentage or absolute value).
--- @return boolean|nil True if the fuel level was set successfully, false or nil otherwise.
function Fuel.setFuel(veh, val)
   return exports['LegacyFuel']:SetFuel(veh, val)
end

--- Retrieves the fuel level of a vehicle.
--- @param veh number|string The vehicle identifier (e.g., vehicle handle or ID).
--- @return number|nil The current fuel level of the vehicle, or nil if not available.
function Fuel.getFuel(veh)
   return exports['LegacyFuel']:GetFuel(veh)
end

return Fuel
