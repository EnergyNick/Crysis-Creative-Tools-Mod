Script.ReloadScript("Scripts/CreativeTools/Utils/AllHelpers.lua");
Script.ReloadScript("Scripts/CreativeTools/CustomBehaviors/StateManager.lua");


local behaviorOptions =
{
  rangeBetweenTargetToFollowOnFight = 20,
  rangeBetweenTargetToFollowOnIdle = 8,
  rangeBetweenTargetToStopFollowing = 150,

	distanceAroundToFollowingPoint = 5,
  distanceToRunOnFollowing = 15,
  distanceAroundToFindEnemies = 30,
  distanceAroundToAttackPoint = 15,

  timeoutToRetryFollowing = 10,
  timeoutToRetryEntering = 10,
  timeoutToRetryExiting = 10,
}

local behaviorSetup =
{
  initialState = 'Normal',

  fsmTransitionEvents = {
    { name = 'TargetTooFar',     from = 'Normal',                    to = 'Following'  },
    { name = 'TargetInRange',    from = 'Following',                 to = 'Normal'     },
    { name = 'TargetOutOfRange', from = 'Following',                 to = 'Normal'     },
    { name = 'TargetEnter',      from = { 'Normal', 'Following'},    to = 'Entering'   },
    { name = 'TargetExit',       from = 'InVehicle',                 to = 'Exiting'    },
    { name = 'Entered',          from = 'Entering',                  to = 'InVehicle'  },
    { name = 'Exited',           from = 'Exiting',                   to = 'Normal'     },
    { name = 'CancelEnter',      from = 'Entering',                  to = 'Normal'     }
  },

  fsmCallbacks = {
    onbeforeTargetEnter = function(self, event, from, to, targetVehicle)
      self.enteringVehicle = targetVehicle
      self.useEnteringFastAnimation = IsFlyingVehicles(targetVehicle)
    end,

    onEntering = function (self, event, from, to)
      self.requestedSeatIndex = nil
      self.retriesOfSeat = 0
    end,
  },

  fsmStateActions =
  {
    Normal = function(state)
      if state.target.actor:IsPlayer() then
        if state.target.followingDisabled == true then
          Log("Skip following, player disable that feature")
          return 10000
        end

        if state.target:IsOnVehicle() then
          local vehicle = System.GetEntity(state.target.actor:GetLinkedVehicleId());
          local seatIndex = RequestMorePriorityOrClosestSeatExcludeDriver(vehicle, state.entity.id)
          if seatIndex then
            state:TargetEnter(vehicle)
          end

          return 100
        end

        local rangeBetweenTarget = GetLengthBetweenEntities(state.entity, state.target)
        if (rangeBetweenTarget <= behaviorOptions.rangeBetweenTargetToStopFollowing) then
          if (IsEntityAttentionOnHostile(state.entity)) then
            if rangeBetweenTarget > behaviorOptions.rangeBetweenTargetToFollowOnFight then
              state:TargetTooFar()
              return 500
            end

            return 5000
          elseif rangeBetweenTarget > behaviorOptions.rangeBetweenTargetToFollowOnIdle then
            state:TargetTooFar()
            return 500
          end
        end
      end

		  local curTime = _time;
      if (curTime - state.timePointOfOperation) > 20 then
        -- Ignore manual state setup, if entity with attention on hostile
        if (IsEntityAttentionOnHostile(state.entity)) then
          return 4000
        end

        local timeoutTime = nil
        local randResult = random(1, 3)
        if randResult == 1 then
          Log("[%s] Select patrol walking", state.entity:GetName())
          AI.SetStance(state.entity.id, BODYPOS_STAND)
			    state.entity:SelectPipe(0, "patrol_random_walk")
          timeoutTime = 15000
        elseif randResult == 2 then
          Log("[%s] Select random look", state.entity:GetName())
          state.entity:SelectPipe(0, "patrol_random_look"); -- random_look_around
          timeoutTime = 6000
        else
          local targets = GetNearestEnemiesEntities(state.entity, behaviorOptions.distanceAroundToFindEnemies, AIOBJECT_PUPPET)
          if targets and count(targets) > 0 then
            local enemyChoose = random(1, count(targets))

            local orderPoint = GetPointNearTargetPosition(state.entity:GetPos(), targets[enemyChoose]:GetPos(), behaviorOptions.distanceAroundToAttackPoint)
            AI.SetStance(state.entity.id, BODYPOS_STAND)
            OrderEntitySpeedOfAction(state.entity, 4)
            OrderEntityGoToPosition(state.entity, orderPoint)

            Log("[%s] Found target, go to that", state.entity:GetName())
            timeoutTime = 12000
          end
        end

        state.timePointOfOperation = curTime
        return timeoutTime
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
      if (rangeBetweenTarget > behaviorOptions.rangeBetweenTargetToStopFollowing) then
        System.Log("Out of range, stop")
        state:TargetOutOfRange()
        return 100
      end

      if rangeBetweenTarget < behaviorOptions.rangeBetweenTargetToFollowOnIdle then
        state:TargetInRange()
        return 100
      end

		  local curTime = _time;
      if (curTime - state.timePointOfOperation) > behaviorOptions.timeoutToRetryFollowing then
        local orderPoint = GetPointNearTargetPosition(state.entity:GetPos(), state.target:GetPos(), behaviorOptions.distanceAroundToFollowingPoint)
        -- if (not AI.CanMoveStraightToPoint(state.entity.id, orderPoint)) then
        --   HUD.DrawStatusText("Can't move to that point directly")
        -- end

        AI.SetStance(state.entity.id, BODYPOS_STAND)
        OrderEntitySpeedOfAction(state.entity, 4)
        OrderEntityGoToPosition(state.entity, orderPoint)
        state.timePointOfOperation = curTime
      end

    end,

    Entering = function(state)

      if state.target.actor:IsPlayer() then
        if state.target.followingDisabled == true then
          Log("Skip following, player disable that feature")
          state:CancelEnter()
          return 500
        end
      end

      if not state.target:IsOnVehicle() then
        state:CancelEnter()
        return
      end

      if state.entity:IsOnVehicle() then
        state:Entered()
        return
      end

      local curTime = _time;
      if (curTime - state.timePointOfOperation) > behaviorOptions.timeoutToRetryEntering then

        local seatIndex = state.requestedSeatIndex
        if (not seatIndex) then
          seatIndex = RequestMorePriorityOrClosestSeatExcludeDriver(state.enteringVehicle, state.entity.id)
        end

        if (not seatIndex) then
          state:CancelEnter()
          return
        end

        local seat = state.enteringVehicle:GetSeatByIndex(seatIndex)
        if (not seat) then
          state:CancelEnter()
          return
        end

        local retriesIncremented = state.retriesOfSeat + 1
        state.retriesOfSeat = retriesIncremented

        if retriesIncremented > 3 then
          state.useEnteringFastAnimation = true
        end

        local passengerId = seat:GetPassengerId()

        if passengerId and passengerId ~= state.entity.id then
          state.requestedSeatIndex = nil
          return 300
        else
          state.requestedSeatIndex = seatIndex
          state.timePointOfOperation = _time

          state.entity:SelectPipe(0, "do_nothing");
          EnterVehicle(state.entity, state.enteringVehicle, seatIndex, state.useEnteringFastAnimation)
        end
      end
    end,

    Exiting = function(state)
      if not state.entity:IsOnVehicle() then
        state:Exited()
        return
      end

      local curTime = _time;
      if (curTime - state.timePointOfOperation) > behaviorOptions.timeoutToRetryExiting then
        ExitVehicle(state.entity)
        state.timePointOfOperation = curTime
        return 3000
      end
    end,

    InVehicle = function(state)
      if not state.target:IsOnVehicle() then
        state:TargetExit()
        return
      end

      local vehicleId = state.target.actor:GetLinkedVehicleId()
      if vehicleId and vehicleId ~= state.entity.AI.theVehicle.id then
        state:TargetExit()
        return
      end
    end,
  },

  onSaveAction = function (self, save)
    save.targetName = self.target:GetName()
  end
}


function CreateAndRunHumanFollowerManager(typeKey, entity, target)
  local fsm = CreateStateManagerBasedOnPreset(typeKey, behaviorSetup, entity)
  fsm.target = target
  fsm.vehicle = nil

	HUD.AddEntityToRadar(entity.id);

  RunStateManagerAsync(fsm)

  return fsm
end

function LoadAndRunHumanFollowerManager(typeKey, behaviorSave)
  local fsm = CreateStateManagerBasedOnPreset(typeKey, behaviorSetup, nil, behaviorSave)
  if not fsm then
    return nil
  end

  fsm.target = System.GetEntityByName(behaviorSave.targetName)
  fsm.vehicle = fsm.entity.AI.theVehicle

  RunStateManagerAsync(fsm)

  return fsm
end