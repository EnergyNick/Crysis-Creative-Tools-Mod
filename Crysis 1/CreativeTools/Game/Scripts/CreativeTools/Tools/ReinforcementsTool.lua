Script.ReloadScript("SCRIPTS/CreativeTools/Tools/ToolsCore.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/Utils/TableManagementUtils.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/LIST_ReinforcementsTool.lua");

local toolFieldName = 'reinforcementsTool'

local ToolActions = {
	["attack1"] = function (self)
		local currentPreset = GetCurrentElementOrReset(self)
		if not currentPreset then
			HUD.DisplayBigOverlayFlashMessage("Invalid spawn preset, not found any entities to spawn", 4, 400, 275, { x=1, y=0, z=0});
			return
		end

		local hit = self:PlayerMuzzleTrace(currentPreset)

		if (not hit) then
			HUD.HitIndicator();
			return;
		end

		local entity = self:SpawnEntityWithPositionImprovements(hit.position, currentPreset)

		if (entity) then
			local newEntitiesGroup = {
				[1] = entity:GetName()
			}

			ApplyEntityCustomizations(entity, currentPreset)
			self:EntityAdditionalActions(entity, hit.position, currentPreset, newEntitiesGroup)

			table.insert(self.spawnedEntityNamesPool, newEntitiesGroup)

			HUD.DrawStatusText("Spawned ["..currentPreset.name.."]");
		else
			HUD.DisplayBigOverlayFlashMessage("Error: entity not spawned", 4, 400, 275, { x=1, y=0, z=0});
		end
	end,

	["reload"] = function (self)
		IncrementCategoryIndexCycled(self)
		local current = GetCurrentCategory(self)

		if current then
			HUD.DisplayBigOverlayFlashMessage("Switch category to ["..current.name.."]", 2, 400, 375, { x=0.3, y=1, z=0.3 });
		else
			ResetCategoryAndIndex(self)
		end
	end,

	["zoom"] = function (self)

		IncrementElementIndexCycled(self)

		local current = GetCurrentElement(self)

		if current then
			HUD.DisplayBigOverlayFlashMessage("Switch entity to ["..current.name.."]", 2, 400, 375, { x=0.5, y=0.8, z=0.9});
		else
			ResetCategoryAndIndex(self)
		end
	end,

	["special"] = function (self)
		local element = GetCurrentElementOrReset(self)
		if not element then
			HUD.DisplayBigOverlayFlashMessage("Invalid spawn preset, not found any entities to spawn", 4, 400, 275, { x=1, y=0, z=0});
			return
		end

		local categoryName = GetCurrentCategory(self).name
		local elementName = element.name
		HUD.DisplayBigOverlayFlashMessage("Selected category ["..categoryName.."], element ["..elementName.."]", 2, 400, 375, { x=1, y=1, z=1 });
	end,

	["firemode"] = function (self)
		local lastIndex = count(self.spawnedEntityNamesPool)

		if (lastIndex == 0) then
			HUD.HitIndicator();
			return;
		end

		local lastEntityGroup = self.spawnedEntityNamesPool[lastIndex]
		table.remove(self.spawnedEntityNamesPool, lastIndex)
		for i, name in pairs(lastEntityGroup) do
			local toDelete = System.GetEntityByName(name);
			if toDelete and toDelete.id then
				DestroyEntity(toDelete)
			end
		end

		local countOfDeleted = count(lastEntityGroup)
		if countOfDeleted == 1 then
			HUD.DrawStatusText("Removed entity");
		elseif countOfDeleted > 1 then
			HUD.DrawStatusText("Removed group with "..tostring(countOfDeleted).." entities");
		end
	end,

	["hud_openchat"] = function (self)
		local prevValue = self.player.followingDisabled
		self.player.followingDisabled = prevValue == nil or prevValue == false
		local actionName = self.player.followingDisabled and "Disabled" or "Enabled"
		HUD.DisplayBigOverlayFlashMessage(""..actionName.." following friendly entities", 2, 400, 375, { x=1, y=1, z=1 });
	end
}

-- ToolActions['nextitem'] = ToolActions['previtem']

-- 	-- "voice_chat_talk"
-- 	-- "lights"
-- 	-- "hud_openchat"
-- 	-- "hud_openteamchat"
-- 	-- "nextitem"
-- 	-- "previtem"

---------------------------------------------------------------------------------------------------------
-- Player extensions

function Player:IsUsingReinforcementsToolNow()
	local item = self.inventory:GetCurrentItem();
	return item and item.class == "ReinforcementsTool"
end

function Player:GetReinforcementsTool()
	return self[toolFieldName]
end

function Player:GetOrInitReinforcementsTool()
	if not self[toolFieldName] then
		local tool = CreateUserTool(toolFieldName, ReinforcementSpawnList, ToolActions, self)
		self[toolFieldName] = tool
	end
	return self[toolFieldName]
end

