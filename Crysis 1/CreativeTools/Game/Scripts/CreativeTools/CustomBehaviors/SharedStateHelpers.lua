Script.ReloadScript("SCRIPTS/HUD/Hud.lua");
Script.ReloadScript("Scripts/Utils/Math.lua");
Script.ReloadScript("Scripts/CreativeTools/CustomBehaviors/StateMachine.lua");

local function defaultOnStateChange(self, event, from, to)
    self.timePointOfOperation = 0
end

function CreateStateManagerBasedOnPreset(preset, entity)
    local machineProvider = GetFiniteStateMachine()
    local fsm = machineProvider.create({
        initial = preset.initialState,
        events = preset.fsmTransitionEvents,
        callbacks = preset.fsmCallbacks
    })

    fsm.Actions = preset.fsmStateActions
    fsm.onstatechange = preset.defaultOnStateChange or defaultOnStateChange
    fsm.timePointOfOperation = 0

    fsm.entity = entity
    return fsm
end


local function safetyIterationHelper(state)
  if not state.nextIterationTimer then
    state.nextIterationTimer = Script.SetTimer(1000, StateManagerIteration, state)
  end
end

function StateManagerIteration(state)
    state.nextIterationTimer = nil

    if (state.entity:IsDead()) then return end

    local action = state.Actions[state.current]
    if (not action) then
        HUD.DisplayBigOverlayFlashMessage("Can't find action for "..state.current, 2, 400, 375, { x=0.3, y=1, z=0.3 });
        return
    end

    Script.SetTimer(5000, safetyIterationHelper, state)
    local resultTime = action(state)

    state.nextIterationTimer = Script.SetTimer(resultTime or 1000, StateManagerIteration, state)
end
