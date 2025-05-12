-- requestAudioBank.lua: Loads an audio bank in FiveM, ensuring it is available for use.
-- This module requests the loading of a specified audio bank and waits until it is loaded or a timeout occurs,
-- providing a robust way to handle audio assets in scripts.

-- Requests the loading of an audio bank.
---@param bankName string
---@return boolean
local function tryLoadAudioBank(bankName)
   return RequestScriptAudioBank(bankName, false)
end

-- Waits for the audio bank to load, handling errors and timeouts.
---@param bankName string
---@param waitDuration number
---@return string
local function awaitAudioBank(bankName, waitDuration)
   local errorMessage = string.format(
      "Failed to load audio bank '%s'. Possible causes include:\n- Too many loaded assets\n- Oversized, invalid, or corrupted assets",
      bankName
   )
   return lib.waitFor(function()
      if tryLoadAudioBank(bankName) then
         return bankName
      end
   end, errorMessage, waitDuration)
end

---Loads an audio bank.
---@param audioBank string
---@param timeout number?
---@return string
function lib.requestAudioBank(audioBank, timeout)
   -- Request and wait for the audio bank to load
   local waitDuration = timeout or 25000
   return awaitAudioBank(audioBank, waitDuration)
end

return lib.requestAudioBank
