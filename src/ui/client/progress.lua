--- @alias ProgressPosition 'middle'|'bottom'

--- @class ProgressPropProps
--- @field model string The model name of the prop.
--- @field bone? number The bone index to attach the prop to (defaults to 60309).
--- @field pos vector3 The position offset for the prop.
--- @field rot vector3 The rotation of the prop.
--- @field rotOrder? number The rotation order (defaults to 0).

--- @class ProgressProps
--- @field label? string The label displayed during the progress.
--- @field duration number The duration of the progress in milliseconds.
--- @field position? ProgressPosition The position of the progress UI.
--- @field useWhileDead? boolean If true, allows progress while the player is dead.
--- @field allowRagdoll? boolean If true, allows progress while the player is ragdolling.
--- @field allowCuffed? boolean If true, allows progress while the player is cuffed.
--- @field allowFalling? boolean If true, allows progress while the player is falling.
--- @field allowSwimming? boolean If true, allows progress while the player is swimming.
--- @field canCancel? boolean If true, allows canceling the progress.
--- @field anim? { dict?: string, clip: string, flag?: number, blendIn?: number, blendOut?: number, duration?: number, playbackRate?: number, lockX?: boolean, lockY?: boolean, lockZ?: boolean, scenario?: string, playEnter?: boolean } Animation or scenario to play.
--- @field prop? ProgressPropProps|ProgressPropProps[] Prop(s) to attach to the player.
--- @field disable? { move?: boolean, sprint?: boolean, car?: boolean, combat?: boolean, mouse?: boolean } Controls to disable during progress.

--- @class ProgressState
--- @field active? ProgressProps The currently active progress data.
--- @field createdProps table<number, number[]> Map of server IDs to created prop entities.
local progressState = { active = nil, createdProps = {} }

local isFivem = cache.game == 'fivem'

--- Control mappings for disabling player inputs.
local controls = {
   INPUT_LOOK_LR = isFivem and 1 or 0xA987235F,
   INPUT_LOOK_UD = isFivem and 2 or 0xD2047988,
   INPUT_SPRINT = isFivem and 21 or 0x8FFC75D6,
   INPUT_AIM = isFivem and 25 or 0xF84FA74F,
   INPUT_MOVE_LR = isFivem and 30 or 0x4D8FB4C1,
   INPUT_MOVE_UD = isFivem and 31 or 0xFDA83190,
   INPUT_DUCK = isFivem and 36 or 0xDB096B85,
   INPUT_VEH_MOVE_LEFT_ONLY = isFivem and 63 or 0x9DF54706,
   INPUT_VEH_MOVE_RIGHT_ONLY = isFivem and 64 or 0x97A8FD98,
   INPUT_VEH_ACCELERATE = isFivem and 71 or 0x5B9FD4E2,
   INPUT_VEH_BRAKE = isFivem and 72 or 0x6E1F639B,
   INPUT_VEH_EXIT = isFivem and 75 or 0xFEFAB9B4,
   INPUT_VEH_MOUSE_CONTROL_OVERRIDE = isFivem and 106 or 0x39CCABD5
}

--- Creates and attaches a prop to a ped.
--- @param ped number The ped entity to attach the prop to.
--- @param prop ProgressPropProps The prop configuration.
--- @return number The created prop entity.
local function createProp(ped, prop)
   lib.requestModel(prop.model)
   local coords = GetEntityCoords(ped)
   local object = CreateObject(prop.model, coords.x, coords.y, coords.z, false, false, false)
   AttachEntityToEntity(
      object, ped, GetPedBoneIndex(ped, prop.bone or 60309),
      prop.pos.x, prop.pos.y, prop.pos.z,
      prop.rot.x, prop.rot.y, prop.rot.z,
      true, true, false, true, prop.rotOrder or 0, true
   )
   SetModelAsNoLongerNeeded(prop.model)
   return object
end

--- Deletes all props associated with a server ID.
--- @param serverId number The server ID of the player.
local function deleteProgressProps(serverId)
   local playerProps = progressState.createdProps[serverId]
   if not playerProps then return end
   for i = 1, #playerProps do
      local prop = playerProps[i]
      if DoesEntityExist(prop) then
         DeleteEntity(prop)
      end
   end
   progressState.createdProps[serverId] = nil
end

--- Checks if the progress should be interrupted based on player state.
--- @param data ProgressProps The progress configuration.
--- @return boolean True if the progress should be interrupted, false otherwise.
local function shouldInterruptProgress(data)
   return (not data.useWhileDead and IsEntityDead(cache.ped))
       or (not data.allowRagdoll and IsPedRagdoll(cache.ped))
       or (not data.allowCuffed and IsPedCuffed(cache.ped))
       or (not data.allowFalling and IsPedFalling(cache.ped))
       or (not data.allowSwimming and IsPedSwimming(cache.ped))
end

--- Plays an animation or scenario for the progress.
--- @param ped number The ped entity to play the animation on.
--- @param anim? { dict?: string, clip: string, flag?: number, blendIn?: number, blendOut?: number, duration?: number, playbackRate?: number, lockX?: boolean, lockY?: boolean, lockZ?: boolean, scenario?: string, playEnter?: boolean } The animation configuration.
local function playProgressAnimation(ped, anim)
   if not anim then return end
   if anim.dict then
      lib.requestAnimDict(anim.dict)
      TaskPlayAnim(
         ped, anim.dict, anim.clip,
         anim.blendIn or 3.0, anim.blendOut or 1.0,
         anim.duration or -1, anim.flag or 49,
         anim.playbackRate or 0,
         anim.lockX, anim.lockY, anim.lockZ
      )
      RemoveAnimDict(anim.dict)
   elseif anim.scenario then
      TaskStartScenarioInPlace(ped, anim.scenario, 0, anim.playEnter == nil or anim.playEnter)
   end
end

--- Stops an animation or scenario.
--- @param ped number The ped entity to stop the animation on.
--- @param anim? { dict?: string, clip: string, scenario?: string } The animation configuration.
local function stopProgressAnimation(ped, anim)
   if not anim then return end
   if anim.dict then
      StopAnimTask(ped, anim.dict, anim.clip, 1.0)
      Wait(0)   -- Prevent StopAnimTask cancellation
   else
      ClearPedTasks(ped)
   end
end

--- Disables player controls based on progress configuration.
--- @param disable? { move?: boolean, sprint?: boolean, car?: boolean, combat?: boolean, mouse?: boolean } Controls to disable.
local function disableControls(disable)
   if not disable then return end
   if disable.mouse then
      DisableControlAction(0, controls.INPUT_LOOK_LR, true)
      DisableControlAction(0, controls.INPUT_LOOK_UD, true)
      DisableControlAction(0, controls.INPUT_VEH_MOUSE_CONTROL_OVERRIDE, true)
   end
   if disable.move then
      DisableControlAction(0, controls.INPUT_SPRINT, true)
      DisableControlAction(0, controls.INPUT_MOVE_LR, true)
      DisableControlAction(0, controls.INPUT_MOVE_UD, true)
      DisableControlAction(0, controls.INPUT_DUCK, true)
   end
   if disable.sprint and not disable.move then
      DisableControlAction(0, controls.INPUT_SPRINT, true)
   end
   if disable.car then
      DisableControlAction(0, controls.INPUT_VEH_MOVE_LEFT_ONLY, true)
      DisableControlAction(0, controls.INPUT_VEH_MOVE_RIGHT_ONLY, true)
      DisableControlAction(0, controls.INPUT_VEH_ACCELERATE, true)
      DisableControlAction(0, controls.INPUT_VEH_BRAKE, true)
      DisableControlAction(0, controls.INPUT_VEH_EXIT, true)
   end
   if disable.combat then
      DisableControlAction(0, controls.INPUT_AIM, true)
      DisablePlayerFiring(cache.playerId, true)
   end
end

--- Starts a progress sequence (bar or circle).
--- @param data ProgressProps The progress configuration.
--- @return boolean True if the progress completed, false if canceled or interrupted.
local function startProgress(data)
   progressState.active = data
   local ped = cache.ped
   LocalPlayer.state.invBusy = true

   playProgressAnimation(ped, data.anim)
   if data.prop then
      LocalPlayer.state:set('lib:progressProps', data.prop, true)
   end

   local disable = data.disable
   local startTime = GetGameTimer()

   while progressState.active do
      disableControls(disable)
      if shouldInterruptProgress(data) then
         progressState.active = false
      end
      Wait(0)
   end

   if data.prop then
      LocalPlayer.state:set('lib:progressProps', nil, true)
   end
   stopProgressAnimation(ped, data.anim)
   LocalPlayer.state.invBusy = false

   local duration = progressState.active ~= false and GetGameTimer() - startTime + 100
   if progressState.active == false or duration <= data.duration then
      SendNUIMessage({ action = 'progressCancel' })
      return false
   end
   return true
end

--- Displays a linear progress bar.
--- @param data ProgressProps The progress configuration.
--- @return boolean? True if completed, false if canceled or interrupted, nil if invalid state.
function lib.progressBar(data)
   while progressState.active do Wait(0) end
   if shouldInterruptProgress(data) then return end

   SendNUIMessage({
      action = 'progress',
      data = {
         label = data.label,
         duration = data.duration
      }
   })
   return startProgress(data)
end

--- Displays a circular progress bar.
--- @param data ProgressProps The progress configuration.
--- @return boolean? True if completed, false if canceled or interrupted, nil if invalid state.
function lib.progressCircle(data)
   while progressState.active do Wait(0) end
   if shouldInterruptProgress(data) then return end

   SendNUIMessage({
      action = 'circleProgress',
      data = {
         duration = data.duration,
         position = data.position,
         label = data.label
      }
   })
   return startProgress(data)
end

--- Cancels the active progress.
function lib.cancelProgress()
   if not progressState.active then
      error('No progress bar is active')
   end
   if not progressState.active.canCancel then
      error('Progress cannot be canceled')
   end
   progressState.active = false
end

--- Checks if a progress is currently active.
--- @return boolean True if a progress is active, false otherwise.
function lib.progressActive()
   return progressState.active and true or false
end

--- Handles the NUI callback for progress completion.
--- @param data any Data from the NUI callback (ignored).
--- @param cb fun(result: number) Callback to acknowledge the NUI message.
local function handleProgressComplete(data, cb)
   cb(1)
   progressState.active = nil
end

-- Register NUI callback
RegisterNUICallback('handleProgressComplete', handleProgressComplete)

-- Register cancel command
RegisterCommand('cancelprogress', function()
   if progressState.active?.canCancel then
      progressState.active = false
   end
end)

if isFivem then
   RegisterKeyMapping('cancelprogress', locale('cancel_progress'), 'keyboard', 'x')
end

-- Handle player dropped event
RegisterNetEvent('onPlayerDropped', function(serverId)
   deleteProgressProps(serverId)
end)

-- Handle state bag changes for progress props
AddStateBagChangeHandler('lib:progressProps', nil, function(bagName, key, value, reserved, replicated)
   if replicated then return end

   local ply = GetPlayerFromStateBagName(bagName)
   if ply == 0 then return end

   local ped = GetPlayerPed(ply)
   local serverId = GetPlayerServerId(ply)

   if not value then
      return deleteProgressProps(serverId)
   end

   progressState.createdProps[serverId] = {}
   local playerProps = progressState.createdProps[serverId]

   if value.model then
      playerProps[#playerProps + 1] = createProp(ped, value)
   else
      for i = 1, #value do
         local prop = value[i]
         if prop then
            playerProps[#playerProps + 1] = createProp(ped, prop)
         end
      end
   end
end)
