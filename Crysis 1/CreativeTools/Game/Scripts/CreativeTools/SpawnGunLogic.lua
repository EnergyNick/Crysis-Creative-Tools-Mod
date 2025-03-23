Script.ReloadScript("SCRIPTS/HUD/Hud.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/BehaviorsCatalog.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/EntityPresetTemplates.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/TableManagementUtils.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/LIST_SpawnTool.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/LIST_ReinforcementsTool.lua");


local GlobalProperties = {
	minDistance = 3,
	maxDistance = 25,

	defaultOffsetZ = 0.5,

	spawnToolActionList = {
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
					System.RemoveEntity(toDelete.id);
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

			local type = System.GetCVar("v_debugVehicle");

			if (not type or string.len(type) == 0) then
				HUD.DrawStatusText("Not set entity name to CVar 'v_debugVehicle' for search, skip");
				return;
			end

			if (TryFindElementAndSetByName(self, type)) then
				HUD.DisplayBigOverlayFlashMessage("Selected entity from CVar = "..type, 2, { x=1, y=1, z=1});
			else
				-- When entered not existing entity name
				HUD.DrawStatusText("Error: Can't find element be name ["..type.."]");
			end
		end
	},

	reinforcementsToolActionList = {
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

		["firemode"] = function (self)
			spawnToolActionList
		end,
	}
}

UserTool = {
	spawnedEntityNamesPool = {},
	creationIndexSequence = 0,

	-- Use for table management logic
	table = {},
	currentElementIndex = 1,
	currentCategoryIndex = 1,
}



function ApplyEntityCustomizations(entity, spawnInfo)
	if (spawnInfo.class == "US_vtol") then
		entity.vehicle:SetAmmoCount("a2ahomingmissile", 12);
	end

	CheckWeaponAttachments(entity)

	-- if spawnInfo then
	-- 	ItemSystem.GiveItem("MOAR",entity.id);
	-- 	ItemSystem.SetActorItemByName(entity.id,"LightMOAC",false);
	-- end
end

function UserTool:EntityAdditionalActions(entity, hitPosition, spawnInfo, newEntitiesGroup)
	if spawnInfo.weaponAttachments then
		for i, item in pairs(spawnInfo.weaponAttachments) do
			if (item.weapon and item.attachment) then
				AddWeaponAttachment(entity, item.weapon, item.attachment)
			else
				HUD.DisplayBigOverlayFlashMessage("Error: invalid config for weapon attachment", 4, 400, 275, { x=1, y=0, z=0});
			end
		end
	end

	if spawnInfo.playerAsCrewSeatIndex then
		EnterVehicle(self.player, entity, spawnInfo.playerAsCrewSeatIndex, true)
	end

	local spawnedCrew = {}
	if spawnInfo.crew then
		for i, currentItem in pairs(spawnInfo.crew) do
			local position = entity:GetPos();
			position.x = position.x + 5 * i

			-- Spawn under terrain, used for player doesn't see teleportation to vehicle
			local elevation = System.GetTerrainElevation(position);
			position.z = elevation - 5

			local subEntity = self:SpawnEntity(position, currentItem, entity:GetDirectionVector(1))

			if(subEntity) then
				ApplyEntityCustomizations(subEntity, currentItem)
				EnterVehicle(subEntity, entity, i, true)

				table.insert(spawnedCrew, subEntity)
				table.insert(newEntitiesGroup, subEntity:GetName())
			end
		end
	end

	if (spawnInfo.behavior) then
		RunBehaviorByName(spawnInfo.behavior, entity, self.player, hitPosition, spawnedCrew)
	end
end

function UserTool:PlayerMuzzleTrace(currentItemPreset)
	local rayFilter = ent_all;
	local rayLimit = currentItemPreset.maxDistanceOverride or GlobalProperties.maxDistance;

	local direction = g_Vectors.temp_v1;
	local cameraDirection = System.GetViewCameraDir()
	CopyVector(direction, cameraDirection);
	ScaleVectorInPlace(direction, rayLimit);

	local position = g_Vectors.temp_v2;
	self.player.actor:GetHeadPos(position);

	local hits = Physics.RayWorldIntersection(position,direction,2,rayFilter,self.player.id,nil,g_HitTable);

	local minDistanceToSpawn = currentItemPreset.minDistanceOverride or GlobalProperties.minDistance
	if (hits == 0 or g_HitTable[1].dist < minDistanceToSpawn) then
		return nil;
	end

	local data = {
		position = g_HitTable[1].pos,
		entity = g_HitTable[1].entity,
		distance = g_HitTable[1].dist
	}
	return data;
end

function UserTool:getNewIndexForSpawnedEntity()
	local res = self.creationIndexSequence
	self.creationIndexSequence = res + 1
	return res
end

function UserTool:SpawnEntity(spawnPoint, currentItemPreset, orientation)
	local name = currentItemPreset.class..(currentItemPreset.archetype or "").." ["..self:getNewIndexForSpawnedEntity().."]"
	local params = {
		class = currentItemPreset.class,
		archetype = currentItemPreset.archetype,
		position = spawnPoint,
		orientation = orientation,
		name = name,
		scale = g_Vectors.v111,
		properties = currentItemPreset.entity_properties,
	}
	return System.SpawnEntity(params)
end

function UserTool:SpawnEntityWithPositionImprovements(positionToSpawn, currentItemPreset)
	local cameraDirection = System.GetViewCameraDir()

	local zOffset = currentItemPreset.zOffset or GlobalProperties.defaultOffsetZ
	if (currentItemPreset.spawnDistanceAbovePlayer) then
		cameraDirection.x = -cameraDirection.x
		cameraDirection.y = -cameraDirection.y
		positionToSpawn = GetFarthestValidPositionOnDistanceWithTerrainOffset(self.player, cameraDirection, currentItemPreset.spawnDistanceAbovePlayer, zOffset)
	else
		positionToSpawn.z = positionToSpawn.z + zOffset
	end

	if not positionToSpawn then
		return nil
	end

	local playerPos = self.player:GetPos()
	local distanceBetweenSpawnPoints = GetLengthBetweenPositions(playerPos, positionToSpawn)
	local afterSpawnUpdatePos = g_Vectors.temp_v3
	-- Hack for AI initialization. Problem: AI activating only in range 100 (either vehicle ai is dummy)
	if (distanceBetweenSpawnPoints > 100) then
		CopyVector(afterSpawnUpdatePos, positionToSpawn)
		CopyVector(positionToSpawn, GetPositionOnDistanceWithTerrainOffset(playerPos, cameraDirection, 50, zOffset))
	end

	local entity = self:SpawnEntity(positionToSpawn, currentItemPreset, self.player:GetDirectionVector(1))

	-- Hack for AI initialization. Problem: AI activating only in range 100 (either vehicle ai is dummy)
	if (distanceBetweenSpawnPoints > 100) then
		Script.SetTimer(150, function (ent) ent:SetPos(afterSpawnUpdatePos) end, entity)
	end

	return entity
end

function UserTool:OnAction(action)
	local onAction = self.actions[action]
	if (onAction) then
		onAction(self)
	end
end

function UserTool:OnSave(save)
	save.spawnTool = {
		creationIndexSequence = self.creationIndexSequence,
		currentCategoryIndex = self.currentCategoryIndex,
		currentElementIndex = self.currentElementIndex,
		spawnedEntityNamesPool = self.spawnedEntityNamesPool
	}
end

function UserTool:OnLoad(saved)
	local fromSave = saved.spawnTool

	if fromSave then
		self.creationIndexSequence = fromSave.creationIndexSequence
		self.currentCategoryIndex = fromSave.currentCategoryIndex
		self.currentElementIndex = fromSave.currentElementIndex
		self.spawnedEntityNamesPool = {}

		for i, value in pairs(fromSave.spawnedEntityNamesPool) do
			local obj = System.GetEntityByName(value)
			if obj then
				table.insert(self.spawnedEntityNamesPool, value)
			end
		end

		HUD.DrawStatusText("Save loaded")
	end
end

---------------------------------------------------------------------------------------------------------
-- Player extensions

local function getEntitiesPresets(spawnList)
	local presetsCopy = CopyTableWithMetadata(spawnList, nil)
	for _, category in pairs(presetsCopy) do
		for i, preset in pairs(category.categoryElements) do
			TryFindAndApplyTemplateToPreset(preset, EntityPresetTemplates)
			if preset.crew then
				for _, crewPreset in pairs(preset.crew) do
					TryFindAndApplyTemplateToPreset(crewPreset, EntityPresetTemplates)
				end
			end
		end
	end

	return presetsCopy
end

local function createTool(player, spawnList, actionList)
	local obj = CopyTableWithMetadata(UserTool, nil)
	obj.table = getEntitiesPresets(spawnList)
	obj.player = player
	obj.actions = actionList
	return obj
end

function Player:IsUsingSpawnToolNow()
	local item = self.inventory:GetCurrentItem();
	-- "DebugGun" use for backward compatibility or player preferences 
	return item and (item.class == "DebugGun" or item.class == "SpawnTool")
end

function Player:GetOrInitSpawnTool()
	if not self.spawnTool then
		local tool = createTool(self, EntitySpawnList, GlobalProperties.spawnToolActionList)
		self.spawnTool = tool
	end
	return self.spawnTool
end

function Player:IsUsingReinforcementsToolNow()
	local item = self.inventory:GetCurrentItem();
	return item and item.class == "ReinforcementsTool"
end

function Player:GetOrInitReinforcementsTool()
	if not self.reinforcementsTool then
		local tool = createTool(self, ReinforcementSpawnList, GlobalProperties.reinforcementsToolActionList)
		self.reinforcementsTool = tool
	end
	return self.reinforcementsTool
end

function InvokeCreativeToolsCommand()
	System.ExecuteCommand("i_giveitem SpawnTool")
	System.ExecuteCommand("i_giveitem ReinforcementsTool")
end

System.AddCCommand("creative_tools", "InvokeCreativeToolsCommand()", "Give items")
System.AddCCommand("extend_power", "InvokeCreativeToolsCommand()", "Give items")
