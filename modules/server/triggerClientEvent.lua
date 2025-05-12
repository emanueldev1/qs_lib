-- triggerClientEvent.lua: Triggers a client event for specified player IDs in FiveM with optimized performance.
-- This module sends an event to one or multiple players, packing arguments once for efficiency, based on a pending pull request.
-- https://github.com/citizenfx/fivem/pull/1210

-- Sends an event to a single player or a list of players.
---@param evtName string
---@param recipients number | ArrayLike<number>
---@param packedData string
---@param dataLength number
local function dispatchEvent(evtName, recipients, packedData, dataLength)
   if lib.array.isArray(recipients) then
       for i = 1, #recipients do
           TriggerClientEventInternal(evtName, recipients[i] --[[@as string]], packedData, dataLength)
       end
   else
       TriggerClientEventInternal(evtName, recipients --[[@as string]], packedData, dataLength)
   end
end

---Triggers an event for the given playerIds, sending additional parameters as arguments.
---Implements functionality from a pending pull request and may be deprecated.
---Provides non-negligible performance gains by msgpacking arguments once.
---@param eventName string
---@param targetIds number | ArrayLike<number>
---@param ... any
function lib.triggerClientEvent(eventName, targetIds, ...)
   local packedData = msgpack.pack_args(...)
   local dataLength = #packedData
   dispatchEvent(eventName, targetIds, packedData, dataLength)
end

return lib.triggerClientEvent
