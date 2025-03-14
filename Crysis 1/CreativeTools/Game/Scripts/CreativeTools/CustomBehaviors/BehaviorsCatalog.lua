Script.ReloadScript("SCRIPTS/HUD/Hud.lua");
Script.ReloadScript("Scripts/CreativeTools/EntityHelpers.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/Implementations/HumanFollowerBehavior.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/Implementations/MachineFollowerBehavior.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/Implementations/MachineLandingBehavior.lua");

BehaviorsCatalog = {
    ["human_following"] = function(entity, spawnPosition, player, spawnedCrew)
        CreateAndRunHumanFollowerManager(entity, player)
    end,
    ["vehicle_following"] = function(entity, spawnPosition, player, spawnedCrew)
        if (IsFlyingVehicles(entity)) then
            DisablePhysicsAntLaterEnabledWithUpPush(entity, 2000)
        end

        CreateAndRunMachineFollowerManager(entity, player)
    end,
    ["vehicle_landing_after_following"] = function(entity, spawnPosition, player, spawnedCrew)
        local actionForVehicle = function(eventEntity)
            TakeoffAirVehicle(eventEntity)

            CreateAndRunMachineFollowerManager(eventEntity, player)

            for i, crewEntity in pairs(spawnedCrew) do
                CreateAndRunHumanFollowerManager(crewEntity, player)
            end
        end

        DisablePhysicsAntLaterEnabledWithUpPush(entity, 2000)
        CreateAndRunMachineLandingManager(entity, spawnPosition, actionForVehicle)
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
