Script.ReloadScript("Scripts/common.lua");
Script.ReloadScript("Scripts/Utils/Math.lua");
Script.ReloadScript("Scripts/CreativeTools/CustomBehaviors/StateMachine.lua");


function CreateStateManagerBasedOnPreset(typeKey, preset, entity, managerSave)
    Log("["..typeKey.."]: Before entity get")
    local entityObj = nil
    if entity then
        entityObj = entity
    elseif managerSave then
        if managerSave.entityName then
            entityObj = System.GetEntityByName(managerSave.entityName)
            System.Log("["..typeKey.."]: Save name "..managerSave.entityName.." for "..typeKey)
        else
            System.Log("$4 ["..typeKey.."]: Invalid save for load entityName for"..typeKey)
        end
    end

    if not entityObj then
        System.Log("$4["..typeKey.."]: Error: invalid behavior initialization, can't found entity, skipping")

        HUD.DisplayBigOverlayFlashMessage("Error: invalid behavior initialization, can't found entity, skipping",
        4, 400, 275,
        { x = 1, y = 0, z = 0 });

        return nil
    end

    local initialState = preset.initialState
    local onceOperationExecuted = false
    if managerSave then
        if managerSave.initialState then
            initialState = managerSave.initialState
        end
        if managerSave.onceOperationExecuted then
            onceOperationExecuted = managerSave.onceOperationExecuted
        end
    end

    local machineProvider = GetFiniteStateMachine()
    local fsm = machineProvider.create({
        initial = initialState,
        events = preset.fsmTransitionEvents,
        callbacks = preset.fsmCallbacks
    })

    fsm.type = typeKey
    fsm.entity = entityObj
    fsm.entityName = entityObj:GetName()
    fsm.entity.behaviorType = typeKey

    fsm.Actions = preset.fsmStateActions

    fsm.timePointOfOperation = 0
    fsm.onceOperationExecuted = onceOperationExecuted
    fsm.onstatechange = function (self, event, from, to)
        self.timePointOfOperation = 0
        self.onceOperationExecuted = false

        if (preset.defaultOnStateChange) then
            preset.defaultOnStateChange(self, event, from, to)
        end

        System.Log("["..typeKey.."]: State changed from "..from.." to "..to.." ["..self.entity:GetName().."]")
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
            save.initialState = self.current
            save.type = self.type
            save.entityName = self.entity:GetName()
            save.onceOperationExecuted = self.onceOperationExecuted

            if (preset.onSaveAction) then
                preset.onSaveAction(self, save)
            end
        end

        return save
    end

    Log("["..typeKey.."]: Create FSM successfully")
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

    local existingEntity = System.GetEntity(state.entity.id);
    if (not existingEntity or existingEntity:IsDead()) then
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
    Script.SetTimer(500, StateManagerIteration, state)
end
