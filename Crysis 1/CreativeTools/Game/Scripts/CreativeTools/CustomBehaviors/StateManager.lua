Script.ReloadScript("SCRIPTS/HUD/Hud.lua");
Script.ReloadScript("Scripts/Utils/Math.lua");
Script.ReloadScript("Scripts/CreativeTools/CustomBehaviors/StateMachine.lua");


function CreateStateManagerBasedOnPreset(preset, entity)
    local machineProvider = GetFiniteStateMachine()
    local fsm = machineProvider.create({
        initial = preset.initialState,
        events = preset.fsmTransitionEvents,
        callbacks = preset.fsmCallbacks
    })

    fsm.entity = entity
    fsm.Actions = preset.fsmStateActions

    fsm.timePointOfOperation = 0
    fsm.onstatechange = function (self, event, from, to)
        self.timePointOfOperation = 0
        self.onceOperationExecuted = false

        if (preset.defaultOnStateChange) then
            preset.defaultOnStateChange(self, event, from, to)
        end
    end

    fsm.enableBehavior = true
    fsm.CompleteBehavior = function (self)
        self.enableBehavior = false
        if (preset.onCompleteAction) then
            preset.onCompleteAction(self)
        end
    end

    return fsm
end


local function safetyIterationHelper(state)
  if state.enableBehavior and not state.nextIterationTimer then
    state.nextIterationTimer = Script.SetTimer(1000, StateManagerIteration, state)
  end
end


function StateManagerIteration(state)
    state.nextIterationTimer = nil

    if (not state.enableBehavior) then return end

    if (state.entity:IsDead()) then
        state:CompleteBehavior()
        return
    end

    local action = state.Actions[state.current]
    if (not action) then
        HUD.DisplayBigOverlayFlashMessage("Can't find action for "..state.current, 2, 400, 375, { x=0.3, y=1, z=0.3 });
        return
    end

    Script.SetTimer(5000, safetyIterationHelper, state)
    local resultTime = action(state)

    state.nextIterationTimer = Script.SetTimer(resultTime or 1000, StateManagerIteration, state)
end

function RunStateManagerAsync(state)
    Script.SetTimer(1000, StateManagerIteration, state)
end