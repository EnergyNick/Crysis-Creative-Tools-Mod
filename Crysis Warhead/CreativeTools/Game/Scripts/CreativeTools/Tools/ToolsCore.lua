Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/BehaviorsCatalog.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/Utils/TableManagementUtils.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/EntityPresetTemplates.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/Utils/AllHelpers.lua");


local GlobalProperties = {
	minDistance = 3,
	maxDistance = 150,

	defaultOffsetZ = 0.5,
}

UserTool = {
	toolName = "Default",

	settings = {},
	spawnedEntityNamesPool = {},
	creationIndexSequence = 0,

	-- Use for table management logic
	groups = {},
	currentGroupIndex = 1,
	currentElementIndex = 1,
	currentCategoryIndex = 1,
}


---------------------------------------------------------------------------------------------------------
-- Internal functions


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

---------------------------------------------------------------------------------------------------------
-- Internal spawn functions

function ApplyEntityCustomizations(entity, spawnInfo, player)

	if spawnInfo.enablePhysics then
		PhysicalizeEntity(entity)
		Log("Physics "..(spawnInfo.enablePhysics and "enabled" or "disabled"))
	end

	if (spawnInfo.class == "US_vtol") then
		entity.vehicle:SetAmmoCount("a2ahomingmissile", 12);
	end

	if spawnInfo.weaponAttachments then
		for i, item in pairs(spawnInfo.weaponAttachments) do
			if (item.weapon and item.attachment) then
				AddWeaponAttachment(entity, item.weapon, item.attachment)
			else
				HUD.DisplayBigOverlayFlashMessage("Error: invalid config for weapon attachment", 4, 400, 275, { x=1, y=0, z=0});
			end
		end
	end

	CheckWeaponAttachments(entity)

	if (spawnInfo.behavior) then
		RunBehaviorByName(spawnInfo.behavior, entity, player)
	end

	-- if spawnInfo then
	-- 	ItemSystem.GiveItem("MOAR",entity.id);
	-- 	ItemSystem.SetActorItemByName(entity.id,"LightMOAC",false);
	-- end
end

function UserTool:EntityAdditionalSpawn(entity, spawnInfo)
	if spawnInfo.playerAsCrewSeatIndex then
		EnterVehicle(self.player, entity, spawnInfo.playerAsCrewSeatIndex, true)
	end

	if spawnInfo.crew then
		local crewNames = {}
		local takenSeats = {}
		if spawnInfo.playerAsCrewSeatIndex then
			takenSeats[spawnInfo.playerAsCrewSeatIndex] = true
		end

		if spawnInfo.reservedSeatIndexes then
			for _, value in pairs(spawnInfo.reservedSeatIndexes) do
				takenSeats[value] = true
			end
		end

		for i, currentItem in pairs(spawnInfo.crew) do
			local position = entity:GetPos();
			position.x = position.x + 5 * i

			-- Spawn under terrain, used for player doesn't see teleportation to vehicle
			local elevation = System.GetTerrainElevation(position);
			position.z = elevation - 5

			local subEntity = self:SpawnEntity(position, currentItem, entity:GetDirectionVector(1))

			if(subEntity) then
				local seatIndex = GetFirstEmptyIndexFromOne(takenSeats)
				takenSeats[seatIndex] = true
				EnterVehicle(subEntity, entity, seatIndex, true)

				ApplyEntityCustomizations(subEntity, currentItem, self.player)

				local entityName = subEntity:GetName()
				table.insert(crewNames, entityName)
				table.insert(self.spawnedEntityNamesPool, entityName)
			end
		end

		entity.spawnedCrewNames = crewNames
	end
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

function UserTool:SpawnEntityWithPositionImprovements(hitPoint, currentItemPreset)
	local cameraDirection = System.GetViewCameraDir()

	local positionToSpawn
	local zOffset = currentItemPreset.zOffset or GlobalProperties.defaultOffsetZ
	if (currentItemPreset.spawnDistanceAbovePlayer) then
		cameraDirection.x = -cameraDirection.x
		cameraDirection.y = -cameraDirection.y

		local distanceAbovePlayer = currentItemPreset.spawnDistanceAbovePlayer
		if (self.settings.useShortPath == true) then
			distanceAbovePlayer = distanceAbovePlayer / 2
		end
		positionToSpawn = GetFarthestValidPositionOnDistanceWithTerrainOffset(self.player, cameraDirection, distanceAbovePlayer, zOffset)
	else
		positionToSpawn = {}
		CopyVector(positionToSpawn, hitPoint)
		positionToSpawn.z = positionToSpawn.z + zOffset
	end

	if not positionToSpawn then
		Log("Can't found position to spawn")
		return nil
	end

	-- Hack for AI initialization. Problem: AI activating only in range 100 (either vehicle ai is dummy)
	local playerPos = self.player:GetPos()
	local distanceBetweenSpawnPoints = GetLengthBetweenPositions(playerPos, positionToSpawn)
	local tempPositionToSpawn = g_Vectors.temp_v3
	local isNeedToUseAIHack = distanceBetweenSpawnPoints > 100
	if isNeedToUseAIHack then
		CopyVector(tempPositionToSpawn, GetPositionOnDistanceWithTerrainOffset(playerPos, cameraDirection, 50, zOffset))
	else
		CopyVector(tempPositionToSpawn, positionToSpawn)
	end

	local entity = self:SpawnEntity(tempPositionToSpawn, currentItemPreset, self.player:GetDirectionVector(1))
	dump(entity)
	if entity then
		-- Hack for AI initialization. Problem: AI activating only in range 100 (either vehicle ai is dummy)
		if isNeedToUseAIHack then
			Script.SetTimer(150, function (ent) ent:SetPos(positionToSpawn) end, entity)
		end

		entity.spawnInfo =
		{
			hitPoint = hitPoint,
			point = positionToSpawn
		}
	end


	return entity
end

---------------------------------------------------------------------------------------------------------
-- Pre-defined actions with HUD integration

function UserTool:SpawnCurrentSelectedPresetEntity()
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
		self:EntityAdditionalSpawn(entity, currentPreset)

		ApplyEntityCustomizations(entity, currentPreset, self.player)

		table.insert(self.spawnedEntityNamesPool, entity:GetName())

		HUD.DrawStatusText("Spawned ["..currentPreset.name.."]");
	else
		HUD.DisplayBigOverlayFlashMessage("Error: entity not spawned", 4, 400, 275, { x=1, y=0, z=0});
	end
end

local function popLastExistingEntity(entitiesNames)
	local lastIndex = count(entitiesNames)
	if (lastIndex == 0) then
		return nil
	end

	for i = lastIndex, 1, -1 do
		local entityName = entitiesNames[i]
		local entity = System.GetEntityByName(entityName)
		table.remove(entitiesNames, i)
		if entity then
			return entity
		end
	end
end

function UserTool:RemoveLastSpawnedEntityGroup()
	local entity = popLastExistingEntity(self.spawnedEntityNamesPool, count(self.spawnedEntityNamesPool))

	if (not entity) then
		HUD.HitIndicator();
		return;
	end

	local isVehicle = entity.vehicle ~= nil
	DestroyEntity(entity)

	if isVehicle then
		HUD.DrawStatusText("Removed vehicle with crew");
	else
		HUD.DrawStatusText("Removed entity");
	end
end

-- Preset functions
function UserTool:ShowSelectedItem(showIfPresetIsInvalid)
	local element = GetCurrentElementOrReset(self)
	if not element then
		if showIfPresetIsInvalid then
			HUD.DisplayBigOverlayFlashMessage("Invalid spawn preset, not found any entities to spawn", 4, 400, 275, { x=1, y=0, z=0});
		end
		return
	end

	local groupName = GetCurrentGroup(self).name
	local categoryName = GetCurrentCategory(self).name
	local elementName = element.name
	local message = string.format("Group %q, category %q, element %q", groupName, categoryName, elementName)
	HUD.DisplayBigOverlayFlashMessage(message, 2, 400, 375, { x=1, y=1, z=1 });
end


function UserTool:ChangeToNextElementInPreset()
	IncrementElementIndexCycled(self)
	local current = GetCurrentElement(self)

	if current then
		HUD.DisplayBigOverlayFlashMessage("Switch entity to ["..current.name.."]", 2, 400, 375, { x=0.5, y=0.8, z=0.9});
	else
		LogWarning("Empty elements")
		ResetCategoryAndIndex(self)
	end
end

function UserTool:ChangeToNextCategoryInPreset()
	IncrementCategoryIndexCycled(self)
	local current = GetCurrentCategory(self)

	if current then
		HUD.DisplayBigOverlayFlashMessage("Switch category to ["..current.name.."]", 2, 400, 375, { x=0.3, y=1, z=0.3 });
	else
		LogWarning("Empty categories")
		ResetCategoryAndIndex(self)
	end
end

function UserTool:ChangeToNextGroupInPreset()
	SwitchToNextGroupCycled(self)
	local current = GetCurrentGroup(self)

	if current then
		HUD.DisplayBigOverlayFlashMessage("Switch group to ["..current.name.."]", 2, 400, 375, { x=0, y=0.69, z=1 });
	else
		LogWarning("Empty groups")
		ResetCategoryAndIndex(self)
	end
end

---------------------------------------------------------------------------------------------------------
-- Interface actions

function UserTool:OnAction(action, activation)
	local onAction = self.actions[action]
	local onActionWithActivation = self.actionsWithActivation[action]
	if (activation == "press" and onAction) then
		onAction(self)
	elseif onActionWithActivation then
		onActionWithActivation(self, activation)
	end
end

function UserTool:OnSave(save)

	local entityInfos = {}
	for i, name in pairs(self.spawnedEntityNamesPool) do
		local obj = System.GetEntityByName(name)
		if obj then
			local entitySave = {}
			if obj.spawnInfo then
				entitySave.spawnInfo = obj.spawnInfo
			end

			if obj.spawnedCrewNames then
				local res = {}
				for _, crewName in pairs(obj.spawnedCrewNames) do
					table.insert(res, crewName)
				end
				entitySave.crewNames = res
			end

			entityInfos[name] = entitySave
		end
	end

	save[self.toolName] =
	{
		creationIndexSequence = self.creationIndexSequence,
		currentCategoryIndex = self.currentCategoryIndex,
		currentElementIndex = self.currentElementIndex,
		settings = self.settings,
		spawnedEntityNamesPool = self.spawnedEntityNamesPool,
		spawnedEntityAdditionalInfos = entityInfos
	}
end

function UserTool:OnLoad(saved)
	local fromSave = saved[self.toolName]

	if fromSave then
		self.creationIndexSequence = fromSave.creationIndexSequence
		self.currentCategoryIndex = fromSave.currentCategoryIndex
		self.currentElementIndex = fromSave.currentElementIndex
		self.settings = fromSave.settings or {}
		self.spawnedEntityNamesPool = {}

		for _, name in pairs(fromSave.spawnedEntityNamesPool) do
			local obj = System.GetEntityByName(name)
			if obj then
				table.insert(self.spawnedEntityNamesPool, name)

				if fromSave.spawnedEntityAdditionalInfos and fromSave.spawnedEntityAdditionalInfos[name] then
					local infos = fromSave.spawnedEntityAdditionalInfos[name]

					if infos.spawnInfo then
						obj.spawnInfo = infos.spawnInfo
					end

					if infos.crewNames then
						local res = {}
						for j, crewName in pairs(infos.crewNames) do
							table.insert(res, crewName)
						end
						obj.spawnedCrewNames = res
					end
				end
			end
		end

		System.Log("Save loaded successfully")
	else
        System.Log("["..self.toolName.."]: Can't find save slot, skipped")
	end
end

---------------------------------------------------------------------------------------------------------
-- Player extensions

local function getEntitiesPresets(spawnList)
	local presetsCopy = CopyTableWithMetadata(spawnList, nil)
	for _, group in ipairs(presetsCopy) do
		for _, category in ipairs(group) do
			for _, preset in ipairs(category) do
				TryFindAndApplyTemplateToPreset(preset, EntityPresetTemplates)
				if preset.crew then
					for _, crewPreset in pairs(preset.crew) do
						TryFindAndApplyTemplateToPreset(crewPreset, EntityPresetTemplates)
					end
				end
			end
		end
	end

	return presetsCopy
end

function CreateUserTool(toolName, actionList, actionWithActivationList, player, spawnList)
	local tool = CopyTableWithMetadata(UserTool, nil)
	tool.toolName = toolName
	tool.player = player
	tool.actions = actionList or {}
	tool.actionsWithActivation = actionWithActivationList or {}
	tool.groups = getEntitiesPresets(spawnList)
	return tool
end
