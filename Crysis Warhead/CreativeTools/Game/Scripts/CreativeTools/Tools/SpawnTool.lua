Script.ReloadScript("SCRIPTS/CreativeTools/Tools/ToolsCore.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/Utils/TableManagementUtils.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/LIST_SpawnTool.lua");

local toolFieldName = 'spawnTool'

local ToolActions = {
	["attack1"] = function (self) self:SpawnCurrentSelectedPresetEntity() end,

	["firemode"] = function (self) self:RemoveLastSpawnedEntityGroup() end,

	["hud_openteamchat"] = function (self)
		local prevValue = self.player.followingDisabled
		self.player.followingDisabled = prevValue == nil or prevValue == false
		local actionName = self.player.followingDisabled and "disabled" or "enabled"
		local message = string.format("Globally %s following player for friendly entities, spawned as 'follower'", actionName);
		HUD.DisplayBigOverlayFlashMessage(message, 3, 400, 375, { x=1, y=1, z=1 });
	end,

	["zoom"] = function (self) self:ChangeToNextElementInPreset() end,

	["reload"] = function (self) self:ChangeToNextCategoryInPreset() end,

	["special"] = function (self) self:ChangeToNextGroupInPreset() end,

	["use"] = function (self) self:ShowSelectedItem(true) end,

	["nextitem"] = function (self) self:ShowSelectedItem(false) end,

	["previtem"] = function (self) self:ShowSelectedItem(false) end,
}

---------------------------------------------------------------------------------------------------------
-- Player extensions

function Player:IsUsingSpawnToolNow()
	local item = self.inventory:GetCurrentItem();
	-- "DebugGun" use for backward compatibility or player preferences 
	return item and (item.class == "DebugGun" or item.class == "SpawnTool")
end

function Player:GetSpawnTool()
	return self[toolFieldName]
end

function Player:GetOrInitSpawnTool()
	if not self[toolFieldName] then
		local tool = CreateUserTool(toolFieldName, ToolActions, nil, self, EntitySpawnList)
		self[toolFieldName] = tool
	end
	return self[toolFieldName]
end
