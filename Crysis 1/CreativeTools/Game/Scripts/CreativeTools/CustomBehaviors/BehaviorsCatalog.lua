Script.ReloadScript("SCRIPTS/HUD/Hud.lua");
Script.ReloadScript("Scripts/CreativeTools/Utils/AllHelpers.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/Implementations/HumanFollowerBehavior.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/Implementations/MachineFollowerBehavior.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/Implementations/MachineLandingBehavior.lua");

BehaviorsCatalog = {
    ["human_following"] = function(entity, spawnPosition, player, spawnedCrew)
        local manager = CreateAndRunHumanFollowerManager(entity, player)
        SafeInsertBehavior(player, manager)
    end,
    ["vehicle_following"] = function(entity, spawnPosition, player, spawnedCrew)
        if (IsFlyingVehicles(entity)) then
            DisablePhysicsAndLaterEnabledWithUpPush(entity, 2000)
        end

        local manager = CreateAndRunMachineFollowerManager(entity, player)
        SafeInsertBehavior(player, manager)
    end,
    ["vehicle_landing_after_following"] = function(entity, spawnPosition, player, spawnedCrew)
        local actionForVehicle = function(eventEntity)
            TakeoffAirVehicle(eventEntity, 40)

            local machineManager = CreateAndRunMachineFollowerManager(eventEntity, player)
            SafeInsertBehavior(player, machineManager)
            SetGunnerIgnorant(eventEntity, 0)

            for i, crewEntity in pairs(spawnedCrew) do
                -- Skip driver and gunner
                if i > 2 then
                    local manager = CreateAndRunHumanFollowerManager(crewEntity, player)
                    SafeInsertBehavior(player, manager)
                end
            end
        end

        DisablePhysicsAndLaterEnabledWithUpPush(entity, 2000)
        local manager = CreateAndRunMachineLandingManager(entity, spawnPosition, actionForVehicle)
        SafeInsertBehavior(player, manager)
    end,
}

function RunBehaviorByName(behaviorName, entity, player, spawnPosition, spawnedCrew)
    local runner = BehaviorsCatalog[behaviorName]
    if (runner) then
        runner(entity, spawnPosition, player, spawnedCrew)
        return true
    else
        HUD.DisplayBigOverlayFlashMessage("Error: invalid behavior name '" .. behaviorName .. "' for entity", 4, 400, 275,
            { x = 1, y = 0, z = 0 });
        return false
    end
end

function SafeInsertBehavior(player, behavior)
    if not player.customBehaviors then
        player.customBehaviors = {}
    end

    table.insert(player.customBehaviors, behavior)
end