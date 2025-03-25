Script.ReloadScript("SCRIPTS/HUD/Hud.lua");
Script.ReloadScript("Scripts/CreativeTools/Utils/AllHelpers.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/Implementations/HumanFollowerBehavior.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/Implementations/MachineFollowerBehavior.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/Implementations/MachineLandingBehavior.lua");


function RunBehaviorByName(behaviorName, entity, player)
    local behavior = BehaviorsCatalog[behaviorName]
    if (behavior) then
        behavior.Spawn(entity, player)
        return true
    else
        HUD.DisplayBigOverlayFlashMessage("Error: invalid behavior name '" .. behaviorName .. "' for entity",
            4, 400, 275,
            { x = 1, y = 0, z = 0 });
        return false
    end
end


function SaveCustomBehaviorManagers(player, save)
    if not player.customBehaviorManagers then
        return
    end

    local behaviorSaves = {}
    for key, behavior in pairs(player.customBehaviorManagers) do
        if behavior then
            local data = behavior:GetSave()
            if data then
                table.insert(behaviorSaves, data)
            end
        end
    end

    save.customBehaviorManagers = behaviorSaves
end


local function loadBehaviorByName(behaviorSave, player)
    local behaviorName = behaviorSave.type
    if not behaviorName then
        return false
    end

    local behavior = BehaviorsCatalog[behaviorName]
    if (behavior) then
        behavior.Load(behaviorSave, player)
        return true
    else
        HUD.DisplayBigOverlayFlashMessage("Error on save load: invalid behavior name '" .. behaviorName .. "'",
            4, 400, 275,
            { x = 1, y = 0, z = 0 });
        return false
    end
end

function LoadCustomBehaviorManagers(player, saved)
    if not saved.customBehaviorManagers then
        return
    end

    local behaviors = {}
    for key, behaviorSave in pairs(saved.customBehaviorManagers) do
        local data = loadBehaviorByName(behaviorSave, player)
        if data then
            table.insert(behaviors, data)
        end
    end

    player.customBehaviorManagers = behaviors
end


local function safeInsertManager(player, behavior)
    if not behavior then
        return
    end

    if not player.customBehaviorManagers then
        player.customBehaviorManagers = {}
    end

    table.insert(player.customBehaviorManagers, behavior)
end


BehaviorsCatalog = {}


-----------------------------------------------------------------------------------------
--- Follow human 

local followHumanType = 'human_following'

BehaviorsCatalog[followHumanType] = {
    Spawn = function(entity, player)
        local manager = CreateAndRunHumanFollowerManager(followHumanType, entity, player)
        safeInsertManager(player, manager)
    end,
    Load = function(behaviorSave, player)
        local manager = LoadAndRunHumanFollowerManager(followHumanType, behaviorSave)
        safeInsertManager(player, manager)
    end
}

-----------------------------------------------------------------------------------------
--- Follow machine 

local followMachineType = 'vehicle_following'

BehaviorsCatalog[followMachineType] = {
    Spawn = function(entity, player)
        local manager = CreateAndRunMachineFollowerManager(followMachineType, entity, player)
        safeInsertManager(player, manager)
    end,
    Load = function(behaviorSave, player)
        local manager = LoadAndRunMachineFollowerManager(followMachineType, behaviorSave)
        safeInsertManager(player, manager)
    end
}


-----------------------------------------------------------------------------------------
--- Landing aircraft with troopers after with following 

local followLandType = 'vehicle_landing_after_following'

local function getActionForVehicleToFollow(player)
    local actionForVehicle = function(eventEntity)
        TakeoffAirVehicle(eventEntity, 40)

        local machineManager = CreateAndRunMachineFollowerManager(followMachineType, eventEntity, player)
        safeInsertManager(player, machineManager)
        SetGunnerIgnorant(eventEntity, 0)

        for i, crewName in pairs(eventEntity.spawnedCrewNames) do
            -- Skip driver and gunner
            if i > 2 then
                local crewEntity = System.GetEntityByName(crewName)
                if crewEntity then
                    local manager = CreateAndRunHumanFollowerManager(followHumanType, crewEntity, player)
                    safeInsertManager(player, manager)
                end
            end
        end
    end

    return actionForVehicle
end

BehaviorsCatalog[followLandType] = {
    Spawn = function(entity, player)
        local manager = CreateAndRunMachineLandingManager(followLandType, entity, entity.spawnInfo.hitPoint, getActionForVehicleToFollow(player))
        safeInsertManager(player, manager)
    end,

    Load = function (behaviorSave, player)
        local manager = LoadAndRunMachineLandingManager(followLandType, behaviorSave, getActionForVehicleToFollow(player))
        safeInsertManager(player, manager)
    end
}