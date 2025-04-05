Script.ReloadScript("SCRIPTS/CreativeTools/Tools/ToolsCore.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/Utils/TableManagementUtils.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/LIST_ReinforcementsTool.lua");

local toolFieldName = 'reinforcementsTool'

local ToolActionsWithActivations = {
	["attack1"] = function (self, activation)
		if activation == "release" and self.spawnProgressBarCancel then
			self.spawnProgressBarCancel()
			return
		end

		local onFinishFunc = function ()
			self:SpawnCurrentSelectedPresetEntity()
		end
		self.spawnProgressBarCancel = StarProgressBar("Reinforcements calling", onFinishFunc, 110)
	end,
}

local ToolActions = {

	["firemode"] = function (self) self:RemoveLastSpawnedEntityGroup() end,

	["hud_openchat"] = function (self)
		local prevValue = self.player.followingDisabled
		self.player.followingDisabled = prevValue == nil or prevValue == false
		local actionName = self.player.followingDisabled and "disabled" or "enabled"
		local message = string.format("Globally %s following player for friendly entities, spawned as follower", actionName);
		HUD.DisplayBigOverlayFlashMessage(message, 3, 400, 375, { x=1, y=1, z=1 });
	end,

	["hud_openteamchat"] = function (self)
		local prevValue = self.player.followingDisabled
		self.player.followingDisabled = prevValue == nil or prevValue == false
		local actionName = self.player.followingDisabled and "disabled" or "enabled"
		local message = string.format("Globally %s following player for friendly entities, spawned as follower", actionName);
		HUD.DisplayBigOverlayFlashMessage(message, 3, 400, 375, { x=1, y=1, z=1 });
	end,

	["zoom"] = function (self) self:ChangeToNextElementInPreset() end,

	["reload"] = function (self) self:ChangeToNextCategoryInPreset() end,

	["special"] = function (self) self:ChangeToNextGroupInPreset() end,

	["use"] = function (self) self:ShowSelectedItem(true) end,

	["nextitem"] = function (self) self:ShowSelectedItem(false) end,

	["previtem"] = function (self) self:ShowSelectedItem(false) end,
}

-- ToolActions['nextitem'] = ToolActions['previtem']

-- 	-- "voice_chat_talk"
-- 	-- "lights"
-- 	-- "hud_openchat"
-- 	-- "hud_openteamchat"

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
		local tool = CreateUserTool(toolFieldName, ToolActions, ToolActionsWithActivations, self, ReinforcementSpawnList)
		self[toolFieldName] = tool
	end
	return self[toolFieldName]
end

