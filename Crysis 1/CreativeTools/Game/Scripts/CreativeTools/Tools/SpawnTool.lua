Script.ReloadScript("SCRIPTS/CreativeTools/Tools/ToolsCore.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/Utils/TableManagementUtils.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/LIST_SpawnTool.lua");

local toolFieldName = 'spawnTool'

local ToolActions = {
	["attack1"] = function (self) self:SpawnCurrentSelectedPresetEntity() end,

	["firemode"] = function (self) self:RemoveLastSpawnedEntityGroup() end,

	["zoom"] = function (self) self:ChangeToNextElementInPreset() end,

	["reload"] = function (self) self:ChangeToNextCategoryInPreset() end,

	["special"] = function (self) self:ChangeToNextGroupInPreset() end,

	["use"] = function (self) 
			self:ShowSelectedItem(true) 
			local dir = self.player:GetDirectionVector(1)
			dump(dir)
			local vRotateDir = SubVectorsNormalizedOnXY(self.player:GetPos(), g_Vectors.v000)
			dump(vRotateDir)
			local scalarBetweenDirections = dotproduct3d(vRotateDir, dir)
			Log("State: dot = %s", scalarBetweenDirections)
			-- local res = IsEntityXYDirectionRotatedMoreThan(self.player, g_Vectors.v000, 4)
			-- Log("Res is "..tostring(res))
		end,

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
