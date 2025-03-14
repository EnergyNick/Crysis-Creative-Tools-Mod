Script.ReloadScript("SCRIPTS/UI/UI.lua");
Script.ReloadScript("SCRIPTS/HUD/Hud.lua");
Script.ReloadScript("Scripts/Utils/Math.lua");
Script.ReloadScript("Scripts/CreativeTools/EntityHelpers.lua");
Script.ReloadScript("Scripts/CreativeTools/CustomBehaviors/StateManager.lua");

local behaviorOptions =
{
	distanceAroundToLandingPoint = 8,

  terrainOffset = 50,

  timeoutToRetryGoToOrderWhenFar = 15,
  timeoutToRetryGoToOrderWhenNear = 5,
  timeoutToRetryLandingOrder = 5,
}

local behaviorSetup =
{
  initialState = 'Normal',

  fsmTransitionEvents = {
    { name = 'WayStart',          from = 'Normal',                 to = 'OnTheWay'  },
    { name = 'InRangeToLand',     from = 'OnTheWay',               to = 'Landing'   },
    { name = 'Landed',            from = 'Landing',                to = 'Unloading' },
    { name = 'ReinforcementOut',  from = 'Unloading',              to = 'Finished'  },
  },

  fsmCallbacks = {
  },

  fsmStateActions =
  {
    Normal = function(state)
      state.entity.vehicle:DisableEngine(0);
      state.entity.vehicle:BlockAutomaticDoors(true);
      state.entity.vehicle:CloseAutomaticDoors();

      AIBehaviour.HELIDEFAULT:heliRequest2ndGunnerStopShoot(state.entity);

      local rangeBetweenTarget = GetLengthBetweenPositions(state.entity:GetPos(), state.target)
      if rangeBetweenTarget > behaviorOptions.distanceAroundToLandingPoint then
        state:WayStart()
        return 500
      end

      state:InRangeToLand()
    end,

    OnTheWay = function (state)
      local rangeBetweenTarget = GetLengthBetweenPositionsOnXY(state.entity:GetPos(), state.target)
      local timeOfOperation = behaviorOptions.timeoutToRetryGoToOrderWhenNear
      if rangeBetweenTarget > 100 then
        timeOfOperation = behaviorOptions.timeoutToRetryGoToOrderWhenFar
      end

		  local curTime = _time;
      if (curTime - state.timePointOfOperation) > timeOfOperation then
        if rangeBetweenTarget < behaviorOptions.distanceAroundToLandingPoint and state.entity:GetSpeed() < 5.0 then
          state:InRangeToLand()
          return 100
        end

        if (rangeBetweenTarget < 100.0) then
          AIBehaviour.HELIDEFAULT:heliRequest2ndGunnerShoot( state.entity );
        end

        local orderPoint = GetPointNearTargetPosition(state.entity:GetPos(), state.target, behaviorOptions.distanceAroundToLandingPoint)
        InPlaceVectorApplyTerrainOffset(orderPoint, behaviorOptions.terrainOffset)

        OrderEntityGoToPosition(state.entity, orderPoint)

        AI.SetRefPointPosition(state.entity.id, orderPoint);

        AI.CreateGoalPipe("heliRunToTheDestination");
        AI.PushGoal("heliRunToTheDestination","continuous",0,0);
        if (rangeBetweenTarget > 50.0) then
          AI.PushGoal("heliRunToTheDestination","run",0,1);
        else
          AI.PushGoal("heliRunToTheDestination","run",0,0);
        end
        AI.PushGoal("heliRunToTheDestination","locate",0,"refpoint");
        AI.PushGoal("heliRunToTheDestination","approach",1,3.0,AILASTOPRES_USE,10);
        state.entity:InsertSubpipe(0,"heliRunToTheDestination");

        HUD.DrawStatusText("GoTo ordered")
        state.timePointOfOperation = curTime
      end

    end,

    Landing = function (state)
      local myPos = state.entity:GetPos()

      local distance = System.GetTerrainElevation(myPos);
      distance = myPos.z - distance;
      if(distance < 8) then
        state:Landed()
        return 2000
      end

		  local curTime = _time;
      if (curTime - state.timePointOfOperation) > behaviorOptions.timeoutToRetryLandingOrder then

        local direction = g_Vectors.temp_v1;
        SubVectors(direction, state.target, state.entity:GetPos())
        NormalizeVector(direction)
        direction.z = - (1 + math.max(1, distance / 50.0))

        AI.SetForcedNavigation(state.entity.id, direction);
        state.timePointOfOperation = curTime
      end
    end,

    Unloading = function (state)
      local toExit = GetReinforcementsPassengerEntitiesFromVehicle(state.entity)

      if (count(toExit) == 0) then
        state:ReinforcementOut()
        return 100
      end

      if (not state.onceOperationExecuted) then
        state.entity.vehicle:BlockAutomaticDoors(true);
        state.entity.vehicle:OpenAutomaticDoors();
        state.entity.vehicle:DisableEngine(1);

        local previous = nil
        for i = #toExit, 1, -1 do
            local member = toExit[i]
            StartExitByChainAndGoToRandomPointAsync(toExit[i], i, previous)
            previous = member
        end

        state.onceOperationExecuted = true
      end

      return 5000
    end,

    Finished = function (state)
      state.finishAction(state.entity)
      state:CompleteBehavior()
    end,
  },

  onCompleteAction = function(state, isDead)
    if (isDead) then
      KillAllPassengersInVehicle(state.entity)
    end
  end
}

function CreateAndRunMachineLandingManager(entity, target, afterLandMachineAction)
  local fsm = CreateStateManagerBasedOnPreset(behaviorSetup, entity)
  fsm.target = target

  fsm.finishAction = afterLandMachineAction

	HUD.AddEntityToRadar(entity.id);

  RunStateManagerAsync(fsm)
end
