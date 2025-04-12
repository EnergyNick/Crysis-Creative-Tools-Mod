Script.ReloadScript("Scripts/CreativeTools/Utils/AllHelpers.lua");

local function randomWalk(entity)
    entity:SelectPipe(0,"patrol_random_walk");
end

-- TODO: Rework and make behavior type get from specific file
local fightingHumanType = 'human_fighting'

function InvokeGlobalActions(player, action, activation)
    if activation ~= "press" then
        return
    end

    -- Feature of exit all reinforcements NPC with behavior from vehicle
    if action == "v_horn" then
        if player:IsOnVehicle() then
            local vehicleId = player.actor:GetLinkedVehicleId()
            local vehicle = System.GetEntity(vehicleId)
            if not vehicle then
                return
            end

            local passengers = GetReinforcementsPassengerEntitiesFromVehicle(vehicle)
            if vehicle.class == "US_vtol" or vehicle.class == "US_apc" then
                local previous = nil
                for i = count(passengers), 1, -1 do
                    local passenger = passengers[i]
                    if not passenger.actor:IsPlayer() and passenger.behaviorType == fightingHumanType then
                      passenger:DrawWeaponNow();
                      StartExitByChainAndGoToRandomPointAsync(passenger, i, previous, randomWalk)
                      previous = passenger
                    end
                end
            else
                for _, passenger in pairs(passengers) do
                    if not passenger.actor:IsPlayer() and passenger.behaviorType == fightingHumanType then
                        ExitVehicle(passenger)
                    end
                end
            end
        end
    end
end