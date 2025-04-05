Script.ReloadScript("Scripts/CreativeTools/Utils/AllHelpers.lua");
Script.ReloadScript("Scripts/CreativeTools/CustomBehaviors/StateManager.lua");


local behaviorOptions = 
{
  flyingVehicleZOffset = 50,

  rangeBetweenTargetToFollowOnFight = 40,
  rangeBetweenTargetToFollowOnIdle = 20,

  rangeBetweenTargetToStopFollowing = 300,
  rangeBetweenTargetToStopFollowingForAircraft = 450,

	distanceAroundToFollowingPoint = 15,

  timeoutToRetryFollowing = 10,
}

local function getRangeBetweenTargetToStopFollowing(state)
  if IsFlyingVehicles(state.entity) then
    return behaviorOptions.rangeBetweenTargetToStopFollowingForAircraft
  else
    return behaviorOptions.rangeBetweenTargetToStopFollowing
  end
end

local behaviorSetup =
{
  initialState = 'Start',

  fsmTransitionEvents = {
    { name = 'Initialized',      from = 'Start',                     to = 'Normal'     },
    { name = 'TargetTooFar',     from = 'Normal',                    to = 'Following'  },
    { name = 'TargetInRange',    from = 'Following',                 to = 'Normal'     },
    { name = 'TargetOutOfRange', from = 'Following',                 to = 'Normal'     },
  },

  fsmCallbacks = {
  },

  fsmStateActions =
  {
    Start = function (state)
      if state.needAircraftStartImpulseUp == true and IsFlyingVehicles(state.entity) then
        Log("Push forced")
        DisablePhysicsAndLaterEnabledWithUpPush(state.entity, 2000)
      end

      state:Initialized()
    end,

    Normal = function(state)
      local entityToFollow = state.target

      if entityToFollow.actor:IsPlayer() then
        if entityToFollow.followingDisabled == true then
          Log("Skip following, player disable that feature")
          return 10000
        end
      end

      if entityToFollow:IsOnVehicle() then
        entityToFollow = System.GetEntity(entityToFollow.actor:GetLinkedVehicleId());
      end

      local stopFollowingRange = getRangeBetweenTargetToStopFollowing(state)
      local rangeBetweenTarget = GetLengthBetweenEntities(state.entity, entityToFollow)
      if rangeBetweenTarget <= stopFollowingRange then

        local attentionTarget = AI.GetAttentionTargetEntity(state.entity.id);
        if (attentionTarget and AI.Hostile(state.entity.id, attentionTarget.id)) then
          if rangeBetweenTarget > behaviorOptions.rangeBetweenTargetToFollowOnFight then
            state:TargetTooFar()
            return 500
          end

          return 8000
        elseif rangeBetweenTarget > behaviorOptions.rangeBetweenTargetToFollowOnIdle then
          state:TargetTooFar()
          return 500
        end
      end
    end,

    Following = function (state)
      local entityToFollow = state.target

      if entityToFollow.actor:IsPlayer() then
        if entityToFollow.followingDisabled == true then
          Log("Skip following, player disable that feature")
          state:TargetInRange()
          return 500
        end
      end

      if entityToFollow:IsOnVehicle() then
        entityToFollow = System.GetEntity(entityToFollow.actor:GetLinkedVehicleId());
      end

      local rangeBetweenTarget = GetLengthBetweenEntities(state.entity, entityToFollow)
      local stopFollowingRange = getRangeBetweenTargetToStopFollowing(state)
      if (rangeBetweenTarget > stopFollowingRange) then
        state:TargetOutOfRange()
        return 100
      end

      if rangeBetweenTarget < behaviorOptions.rangeBetweenTargetToFollowOnIdle then
        state:TargetInRange()
        return 100
      end

		  local curTime = _time;
      if (curTime - state.timePointOfOperation) > behaviorOptions.timeoutToRetryFollowing then
        local orderPoint = GetPointNearTargetPosition(state.entity:GetPos(), entityToFollow:GetPos(), behaviorOptions.distanceAroundToFollowingPoint)

        -- AI.CanMoveStraightToPoint(state.entity.id, orderPoint)
        if IsFlyingVehicles(state.entity) then
          InPlaceVectorApplyTerrainOffset(orderPoint, behaviorOptions.flyingVehicleZOffset)
        end
        OrderEntityGoToPosition(state.entity, orderPoint)
        System.Log("["..state.type.."]: Follow ordered")
        state.timePointOfOperation = curTime
      end

    end,
  },

  onCompleteAction = function(state)
    if (state.entity:IsDead()) then
      KillAllPassengersInVehicle(state.entity)
    end
  end,

  onSaveAction = function (self, save)
    save.targetName = self.target:GetName()
  end
}

function CreateAndRunMachineFollowerManager(typeKey, entity, target, needAircraftStartImpulseUp)
  local fsm = CreateStateManagerBasedOnPreset(typeKey, behaviorSetup, entity)
  fsm.target = target
  fsm.needAircraftStartImpulseUp = needAircraftStartImpulseUp or false

	HUD.AddEntityToRadar(entity.id);

  RunStateManagerAsync(fsm)

  return fsm
end

function LoadAndRunMachineFollowerManager(typeKey, behaviorSave)
  local fsm = CreateStateManagerBasedOnPreset(typeKey, behaviorSetup, nil, behaviorSave)
  if not fsm then
    return nil
  end

  fsm.needAircraftStartImpulseUp = false
  fsm.target = System.GetEntityByName(behaviorSave.targetName)

  RunStateManagerAsync(fsm)

  return fsm
end