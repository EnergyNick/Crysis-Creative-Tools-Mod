Script.ReloadScript("SCRIPTS/HUD/Hud.lua");
Script.ReloadScript("Scripts/CreativeTools/Utils/AllHelpers.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/Implementations/HumanFollowerBehavior.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/Implementations/MachineFollowerBehavior.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/Implementations/MachineLandingBehavior.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/Implementations/AircraftGoAwayBehavior.lua");


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
    for _, behavior in pairs(player.customBehaviorManagers) do
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
--- Go away behavior aircraft

local aircraftGoAwayType = 'aircraft_go_away'

BehaviorsCatalog[aircraftGoAwayType] = {
    Spawn = function(entity, player)
        local awayPosition = entity.goAwayPosition or entity.spawnInfo.point
        local manager = CreateAndRunAircraftGoAwayManager(aircraftGoAwayType, entity, awayPosition)
        safeInsertManager(player, manager)
    end,
    Load = function(behaviorSave, player)
        local manager = LoadAndRunAircraftGoAwayManager(aircraftGoAwayType, behaviorSave)
        safeInsertManager(player, manager)
    end
}


-----------------------------------------------------------------------------------------
--- Landing aircraft with troopers

local function getActionForVehicleToFollow(player)
    local actionForVehicle = function(eventEntity)
        TakeoffAirVehicle(eventEntity, 40)

        local machineManager = CreateAndRunMachineFollowerManager(followMachineType, eventEntity, player)
        safeInsertManager(player, machineManager)
        SetGunnerIgnorant(eventEntity, 0)
    end

    return actionForVehicle
end

local function getActionForVehicleToGoAway(player)
    local actionForVehicle = function(eventEntity)
        local machineManager = CreateAndRunAircraftGoAwayManager(aircraftGoAwayType, eventEntity, eventEntity.spawnInfo.point)
        safeInsertManager(player, machineManager)
    end

    return actionForVehicle
end

local function getActionForReinforcement(player)
    local function actionForHuman(entity)
        local manager = CreateAndRunHumanFollowerManager(followHumanType, entity, player)
        safeInsertManager(player, manager)
    end

    return actionForHuman
end


local aircraftLandTypeForFollow = 'aircraft_landing_with_reinforcements_after_follow'

BehaviorsCatalog[aircraftLandTypeForFollow] = {
    Spawn = function(entity, player)
        local vehicleAction = getActionForVehicleToFollow(player)
        local humanAction = getActionForReinforcement(player)
        local manager = CreateAndRunMachineLandingManager(aircraftLandTypeForFollow, entity, entity.spawnInfo.hitPoint, vehicleAction, humanAction)
        safeInsertManager(player, manager)
    end,

    Load = function (behaviorSave, player)
        local vehicleAction = getActionForVehicleToFollow(player)
        local humanAction = getActionForReinforcement(player)
        local manager = LoadAndRunMachineLandingManager(aircraftLandTypeForFollow, behaviorSave, vehicleAction, humanAction)
        safeInsertManager(player, manager)
    end
}

local aircraftLandTypeAndGoAway = 'aircraft_landing_with_reinforcements_after_go_away'

BehaviorsCatalog[aircraftLandTypeAndGoAway] = {
    Spawn = function(entity, player)
        local vehicleAction = getActionForVehicleToGoAway(player)
        local humanAction = getActionForReinforcement(player)
        local manager = CreateAndRunMachineLandingManager(aircraftLandTypeAndGoAway, entity, entity.spawnInfo.hitPoint, vehicleAction, humanAction)
        safeInsertManager(player, manager)
    end,

    Load = function (behaviorSave, player)
        local vehicleAction = getActionForVehicleToGoAway(player)
        local humanAction = getActionForReinforcement(player)
        local manager = LoadAndRunMachineLandingManager(aircraftLandTypeAndGoAway, behaviorSave, vehicleAction, humanAction)
        safeInsertManager(player, manager)
    end
}