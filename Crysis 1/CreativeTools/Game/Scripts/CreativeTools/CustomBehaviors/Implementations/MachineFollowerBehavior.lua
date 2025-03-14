Script.ReloadScript("SCRIPTS/UI/UI.lua");
Script.ReloadScript("SCRIPTS/HUD/Hud.lua");
Script.ReloadScript("Scripts/Utils/Math.lua");
Script.ReloadScript("Scripts/CreativeTools/EntityHelpers.lua");
Script.ReloadScript("Scripts/CreativeTools/CustomBehaviors/StateManager.lua");


local behaviorOptions = 
{
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
  initialState = 'Normal',

  fsmTransitionEvents = {
    { name = 'TargetTooFar',     from = 'Normal',                    to = 'Following'  },
    { name = 'TargetInRange',    from = 'Following',                 to = 'Normal'     },
    { name = 'TargetOutOfRange', from = 'Following',                 to = 'Normal'     },
  },

  fsmCallbacks = {
  },

  fsmStateActions =
  {
    Normal = function(state)

      local entityToFollow = state.target
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

        if IsFlyingVehicles(state.entity) then
          InPlaceVectorApplyTerrainOffset(orderPoint, 50)
        end
        OrderEntityGoToPosition(state.entity, orderPoint)
        state.timePointOfOperation = curTime
      end

    end,
  },

  onCompleteAction = function(state)
    if (state.entity:IsDead()) then
      KillAllPassengersInVehicle(state.entity)
    end
  end
}

function CreateAndRunMachineFollowerManager(entity, target)
  local fsm = CreateStateManagerBasedOnPreset(behaviorSetup, entity)
  fsm.target = target

	HUD.AddEntityToRadar(entity.id);

  RunStateManagerAsync(fsm)
end
