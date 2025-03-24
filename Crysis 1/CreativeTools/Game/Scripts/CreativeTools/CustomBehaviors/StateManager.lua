Script.ReloadScript("Scripts/Utils/Math.lua");
Script.ReloadScript("Scripts/CreativeTools/CustomBehaviors/StateMachine.lua");


function CreateStateManagerBasedOnPreset(typeKey, preset, entity, managerSave)
    local entityObj = nil
    if entity then
        entityObj = entity
    elseif managerSave then
        entityObj = System.GetEntityByName(managerSave.entityName)
    end

    if not entityObj then
        HUD.DisplayBigOverlayFlashMessage("Error: invalid behavior initialization, can't found entity, skipping", 
        4, 400, 275,
        { x = 1, y = 0, z = 0 });

        return nil
    end

    local machineProvider = GetFiniteStateMachine()
    local fsm = machineProvider.create({
        initial = (managerSave and managerSave.initialState) or preset.initialState,
        events = preset.fsmTransitionEvents,
        callbacks = preset.fsmCallbacks
    })

    fsm.type = typeKey
    fsm.entity = entityObj

    fsm.Actions = preset.fsmStateActions

    fsm.timePointOfOperation = 0
    fsm.onceOperationExecuted = (managerSave and managerSave.onceOperationExecuted) or false
    fsm.onstatechange = function (self, event, from, to)
        self.timePointOfOperation = 0
        self.onceOperationExecuted = false

        if (preset.defaultOnStateChange) then
            preset.defaultOnStateChange(self, event, from, to)
        end

        HUD.DrawStatusText("State changed from "..from.." to "..to.." ["..self.entity:GetName().."]")
    end

    fsm.enableBehavior = true
    fsm.CompleteBehavior = function (self)
        self.enableBehavior = false
        if (preset.onCompleteAction) then
            preset.onCompleteAction(self)
        end
    end

    fsm.GetSave = function (self)
        local save = nil
        if self.enableBehavior then
            save = {}
            save.type = self.type
            save.entityName = self.entity:GetName()
            save.onceOperationExecuted = self.onceOperationExecuted

            if (preset.onSaveAction) then
                preset.onSaveAction(self, save)
            end
        end

        return save
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
