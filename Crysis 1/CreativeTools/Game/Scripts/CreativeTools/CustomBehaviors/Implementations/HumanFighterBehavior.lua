Script.ReloadScript("Scripts/CreativeTools/Utils/AllHelpers.lua");
Script.ReloadScript("Scripts/CreativeTools/CustomBehaviors/StateManager.lua");


local behaviorOptions =
{
	distanceAroundToAttackPoint = 15,
  distanceAroundToFindEnemies = 30,
}

local behaviorSetup =
{
  initialState = 'Start',

  fsmTransitionEvents = {
    { name = 'Initialized',      from = 'Start',                     to = 'Normal'     },
    { name = 'InitInVehicle',    from = 'Start',                     to = 'InVehicle'  },
    { name = 'Exited',           from = 'InVehicle',                 to = 'Normal'     },
  },

  fsmCallbacks = {
  },

  fsmStateActions =
  {
    Start = function (state)
      if state.entity:IsOnVehicle() then
        state:InitInVehicle()
        return 500
      end

      state:Initialized()
      return 500
    end,

    Normal = function(state)
      -- Ignore manual state setup, if entity with attention on hostile
      if (IsEntityAttentionOnHostile(state.entity)) then
        return 4000
      end

      local randResult = random(1, 3)
      if randResult == 1 then
        Log("[%s] Select patrol walking", state.entity:GetName())
        AI.SetStance(state.entity.id, BODYPOS_STAND)
        state.entity:SelectPipe(0, "patrol_random_walk")
        return 10000
      elseif randResult == 2 then
        Log("[%s] Select random look", state.entity:GetName())
        state.entity:SelectPipe(0, "random_look_around")
        return 5000
      else
        Log("[%s] Select search enemy target", state.entity:GetName())
        local targets = GetNearestEnemiesEntities(state.entity, behaviorOptions.distanceAroundToFindEnemies, AIOBJECT_PUPPET)
        Log("[%s] Find %i targets", state.entity:GetName(), count(targets))

        if targets and count(targets) > 0 then
          local enemyChoose = random(1, count(targets))

          OrderEntitySpeedOfAction(state.entity, 3)
          local orderPoint = GetPointNearTargetPosition(state.entity:GetPos(), targets[enemyChoose]:GetPos(), behaviorOptions.distanceAroundToAttackPoint)
          OrderEntityGoToPosition(state.entity, orderPoint)
          Log("[%s] Found target, go to that", state.entity:GetName())
          return 10000
        end
        return 3000
      end
    end,

    InVehicle = function(state)
      if not state.entity:IsOnVehicle() then
        state:Exited()
        return 100
      end

      return 5000
    end,
  },

  onSaveAction = function (self, save)
    save.isHostileToPlayer = self.isHostileToPlayer
  end
}


function CreateAndRunHumanFighterManager(typeKey, entity, player)
  local fsm = CreateStateManagerBasedOnPreset(typeKey, behaviorSetup, entity)
  if not fsm then
    return nil
  end

  fsm.isHostileToPlayer = AI.Hostile(entity.id, player.id)
  if not fsm.isHostileToPlayer then
	  HUD.AddEntityToRadar(entity.id);
  end

  RunStateManagerAsync(fsm)

  return fsm
end

function LoadAndRunHumanFighterManager(typeKey, behaviorSave)
  local fsm = CreateStateManagerBasedOnPreset(typeKey, behaviorSetup, nil, behaviorSave)
  if not fsm then
    return nil
  end

  fsm.isHostileToPlayer = behaviorSave.isHostileToPlayer
  RunStateManagerAsync(fsm)

  return fsm
end