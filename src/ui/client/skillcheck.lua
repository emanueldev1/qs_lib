--- @alias SkillCheckDifficulty 'easy'|'medium'|'hard'|{ areaSize: number, speedMultiplier: number }

--- @class SkillCheckState
--- @field promise? any The active skill check promise.

local skillCheckState = { promise = nil }

--- Sends an NUI message to start a skill check.
--- @param difficulty SkillCheckDifficulty|SkillCheckDifficulty[] The difficulty level(s) for the skill check.
--- @param inputs string[]? The input keys required for the skill check.
local function sendStartSkillCheckMessage(difficulty, inputs)
   SendNUIMessage({
      action = 'startSkillCheck',
      data = {
         difficulty = difficulty,
         inputs = inputs
      }
   })
end

--- Sends an NUI message to cancel a skill check.
local function sendCancelSkillCheckMessage()
   SendNUIMessage({ action = 'skillCheckCancel' })
end

--- Starts a skill check with the specified difficulty and inputs.
--- @param difficulty SkillCheckDifficulty|SkillCheckDifficulty[] The difficulty level(s) for the skill check.
--- @param inputs string[]? The input keys required for the skill check.
--- @return boolean? True if the skill check was successful, false if failed, nil if already active.
function lib.skillCheck(difficulty, inputs)
   if skillCheckState.promise then return end

   skillCheckState.promise = promise:new()
   lib.setNuiFocus(false, true)
   sendStartSkillCheckMessage(difficulty, inputs)

   return Citizen.Await(skillCheckState.promise)
end

--- Cancels the active skill check.
function lib.cancelSkillCheck()
   if not skillCheckState.promise then
      error('No skill check is active')
   end
   sendCancelSkillCheckMessage()
end

--- Checks if a skill check is currently active.
--- @return boolean True if a skill check is active, false otherwise.
function lib.skillCheckActive()
   return skillCheckState.promise ~= nil
end

--- Handles the NUI callback for skill check completion.
--- @param success boolean Whether the skill check was successful.
--- @param cb fun(result: number) Callback to acknowledge the NUI message.
local function handleSkillCheckOver(success, cb)
   cb(1)
   if not skillCheckState.promise then return end

   lib.resetNuiFocus()
   skillCheckState.promise:resolve(success)
   skillCheckState.promise = nil
end

-- Register NUI callback
RegisterNUICallback('handleSkillCheckOver', handleSkillCheckOver)
