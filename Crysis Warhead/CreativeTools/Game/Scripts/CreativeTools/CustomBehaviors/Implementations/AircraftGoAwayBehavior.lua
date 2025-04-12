Script.ReloadScript("Scripts/CreativeTools/Utils/AllHelpers.lua");
Script.ReloadScript("Scripts/CreativeTools/CustomBehaviors/StateManager.lua");

-- https://www.cryengine.com/docs/static/engines/cryengine-5/categories/23756813/pages/23306485#introduction
local behaviorOptions =
{
  heightToFly = 50,

  speedToAbleToRotate = 10
}

local behaviorSetup =
{
  initialState = 'Start',

  fsmTransitionEvents = {
    { name = 'TakeOff',           from = 'Start',                  to = 'FlyingUp'  },
    { name = 'WayStart',          from = { 'FlyingUp', 'Start' },  to = 'OnTheWay'  },
    { name = 'ReachedTarget',     from = 'OnTheWay',               to = 'Finished'   },
  },

  fsmCallbacks = {
    onOnTheWay = function (self, event, from, to)
      self.wayDirection = self.entity:GetDirectionVector(1)
    end,
  },

  fsmStateActions =
  {
    Start = function(state)
      state.entity.vehicle:DisableEngine(0);
      state.entity.vehicle:BlockAutomaticDoors(true);
      state.entity.vehicle:CloseAutomaticDoors();

      SetGunnerIgnorant(state.entity, 1)

      local currentPos = state.entity:GetPos()
      local height = currentPos.z - System.GetTerrainElevation(currentPos)
      if currentPos.z < state.targetPosition.z or height < behaviorOptions.heightToFly then
        state:TakeOff()
        return 100
      end

      state:WayStart()
      return 500
    end,

    FlyingUp = function (state)
      local currentPos = state.entity:GetPos()
      local height = currentPos.z - System.GetTerrainElevation(currentPos)
      if height >= behaviorOptions.heightToFly then
        state:WayStart()
        return 500
      end

      if state.onceOperationExecuted == false then
        TakeoffAirVehicle(state.entity, behaviorOptions.heightToFly)
        state.onceOperationExecuted = true
        return 2000
      end
    end,

    OnTheWay = function (state)
      local entitySpeed = state.entity:GetSpeed()
      if entitySpeed < behaviorOptions.speedToAbleToRotate and IsEntityRotatedXYToTargetMoreThan(state.entity, state.targetPosition, 2) then
        SetNavigationToRotateAndGetIsRotated(state.entity, state.targetPosition, state.wayDirection)
        System.Log("Rotate ordered")
        return 500
      end

      state.entity.vehicle:SetMovementMode(1);
      local isReached = SetNavigationToFastFlyAndGetIsCrossed(state.entity, state.targetPosition, state.wayDirection, behaviorOptions.heightToFly)
      if isReached then
        Log("Reached successfully")
        state:ReachedTarget()
        return 150
      end
      return 500
    end,

    Finished = function (state)
      DestroyEntity(state.entity)
      state:CompleteBehavior()
    end,
  },

  onCompleteAction = function(state)
    if (state.entity and state.entity:IsDead()) then
      KillAllPassengersInVehicle(state.entity)
    end
  end,

  onSaveAction = function (self, save)
    save.targetPosition = self.targetPosition
  end
}

function CreateAndRunAircraftGoAwayManager(typeKey, entity, targetPosition)
  local fsm = CreateStateManagerBasedOnPreset(typeKey, behaviorSetup, entity)
  fsm.targetPosition = targetPosition

	HUD.AddEntityToRadar(entity.id);

  RunStateManagerAsync(fsm)

  return fsm
end

function LoadAndRunAircraftGoAwayManager(typeKey, behaviorSave)
  local fsm = CreateStateManagerBasedOnPreset(typeKey, behaviorSetup, nil, behaviorSave)
  if not fsm then
    return nil
  end

  fsm.targetPosition = behaviorSave.targetPosition

  RunStateManagerAsync(fsm)

  return fsm
end
