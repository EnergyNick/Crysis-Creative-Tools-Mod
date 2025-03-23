Script.ReloadScript("Scripts/CreativeTools/Utils/AllHelpers.lua");
Script.ReloadScript("Scripts/CreativeTools/CustomBehaviors/StateManager.lua");

-- https://www.cryengine.com/docs/static/engines/cryengine-5/categories/23756813/pages/23306485#introduction
local behaviorOptions =
{
	distanceAroundToLandingPoint = 8,
	distanceAroundToLandingPointToStopGoUp = 15,
  distanceToLandPointToLowerSpeed = 100,

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
    onOnTheWay = function (self, event, from, to)
      self.wayDirection = self.entity:GetDirectionVector(1)
    end,
  },

  fsmStateActions =
  {
    Normal = function(state)
      state.entity.vehicle:DisableEngine(0);
      state.entity.vehicle:BlockAutomaticDoors(true);
      state.entity.vehicle:CloseAutomaticDoors();

      -- AIBehaviour.HELIDEFAULT:heliRequest2ndGunnerStopShoot( state.entity );
      SetGunnerIgnorant(state.entity, 1)

      local rangeBetweenTarget = GetLengthBetweenPositions(state.entity:GetPos(), state.target)
      if rangeBetweenTarget > behaviorOptions.distanceAroundToLandingPoint then
        state:WayStart()
        return 500
      end

      state:InRangeToLand()
    end,

    OnTheWay = function (state)
      local rangeBetweenTarget = GetLengthBetweenPositionsOnXY(state.entity:GetPos(), state.target)
      local entitySpeed = state.entity:GetSpeed()
      local timeOfOperation = behaviorOptions.timeoutToRetryGoToOrderWhenNear

      if (rangeBetweenTarget > behaviorOptions.distanceToLandPointToLowerSpeed) then
        local orderPointOfSprint = GetPointNearTargetPosition(state.entity:GetPos(), state.target, behaviorOptions.distanceToLandPointToLowerSpeed)
        InPlaceVectorApplyTerrainOffset(orderPointOfSprint, behaviorOptions.terrainOffset)

        if entitySpeed < 5 and IsEntityXYDirectionRotatedMoreThan(state.entity, orderPointOfSprint, 2) then
          SetNavigationToRotateAndGetIsRotated(state.entity, orderPointOfSprint, state.wayDirection)
          HUD.DrawStatusText("Rotate ordered")
          return 500
        end

        state.entity.vehicle:SetMovementMode(1);
        SetNavigationToFastFlyAndGetIsCrossed(state.entity, orderPointOfSprint, state.wayDirection)
        HUD.DrawStatusText("Sprint ordered")
        return 500
      end

		  local curTime = _time;
      if (curTime - state.timePointOfOperation) > timeOfOperation then

        SetGunnerIgnorant(state.entity, 0)
        state.entity.vehicle:SetMovementMode(0);

        if rangeBetweenTarget < behaviorOptions.distanceAroundToLandingPoint and entitySpeed < 5.0 then
          state:InRangeToLand()
          return 100
        end

        if entitySpeed > 20 then
          local negateDirection = {}
          CopyVector(negateDirection, state.entity:GetDirectionVector(1))
          ScaleVectorInPlace(negateDirection, -0,5)
          negateDirection.z = 0
          AI.SetForcedNavigation(state.entity.id, negateDirection)
          HUD.DrawStatusText("Slowing ordered")
        else
          local orderPoint = GetPositionWithTerrainOffset(state.target, behaviorOptions.terrainOffset)
          if rangeBetweenTarget < behaviorOptions.distanceAroundToLandingPointToStopGoUp then
            orderPoint.z = state.entity:GetPos().z
          end
          OrderEntityGoToPositionWithSpeed(state.entity, orderPoint, 3)
          HUD.DrawStatusText("GoTo ordered")
        end

        state.timePointOfOperation = curTime
      end

    end,

    Landing = function (state)

      -- local targetPos = state.entity:GetPos();
      -- local targetDir = g_Vectors.temp_v1;
      -- targetDir.x = 0;
      -- targetDir.y = 0;
      -- targetDir.z = -10;

      -- local rayFilter = ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid
      -- local hits = Physics.RayWorldIntersection(targetPos, targetDir, 2, rayFilter, state.entity.id, nil, g_HitTable);
      -- if(hits > 0) then
      --   local firstHit = g_HitTable[1];
      --   if(firstHit.normal.z < 3) then
      --     state:Landed()
      --     return 3000
      --   end
      -- end

      SetGunnerIgnorant(state.entity, 1)
      local myPos = state.entity:GetPos()

      local distance = System.GetTerrainElevation(myPos);
      distance = myPos.z - distance;
      -- HUD.DrawStatusText("Distance to terrain = "..tostring(distance))
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
        for i = count(toExit), 1, -1 do
            local member = toExit[i]
            StartExitByChainAndGoToRandomPointAsync(member, i, previous)
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

  onCompleteAction = function(state)
    if (state.entity:IsDead()) then
      KillAllPassengersInVehicle(state.entity)

      if not state:is("Finished") then
		    HUD.DisplayBigOverlayFlashMessage("Reinforcements ship was destroyed, before reaching landing point", 2, 400, 375, { x=0.96, y=0.63, z=0 });
      end
    end
  end
}

function CreateAndRunMachineLandingManager(entity, target, afterLandMachineAction)
  local fsm = CreateStateManagerBasedOnPreset(behaviorSetup, entity)
  fsm.target = target

  fsm.finishAction = afterLandMachineAction

	HUD.AddEntityToRadar(entity.id);

  RunStateManagerAsync(fsm)

  return fsm
end
