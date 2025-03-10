Script.ReloadScript("SCRIPTS/HUD/Hud.lua");

BehaviorsCatalog = {
	["human_following"] = function (entity, player)
		
	end,
	["vehicle_following"] = function (entity, player)
		
	end,
	["vehicle_landing_after_following"] = function (entity, player)
		
	end,
}

function RunBehaviorByName(behaviorName, entity, playerEntity)
    local runner = BehaviorsCatalog[behaviorName]
    if (runner) then
        runner(entity, playerEntity)
        return true
    else
        HUD.DisplayBigOverlayFlashMessage("Error: invalid behavior name '"..behaviorName.."' for entity", 4, 400, 275, { x=1, y=0, z=0});
        return false
    end
end