Script.ReloadScript("SCRIPTS/HUD/Hud.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/BehaviorsCatalog.lua");
Script.ReloadScript("SCRIPTS/CreativeTools/LIST_TO_SPAWN.lua");


DebugGunProperties = {
	minDistance = 3,
	maxDistance = 25,
	currentElementIndex = 1,
	currentCategoryIndex = 1,
	totalCategories = count(EntitySpawnList),
	spawnedEntityPool = {},
	creationIndexSequence = 0
}

local function getElementInCategory(index)
	return EntitySpawnList[DebugGunProperties.currentCategoryIndex].categoryElements[index]
end

local function getCurrentCategory()
	return EntitySpawnList[DebugGunProperties.currentCategoryIndex]
end

local function getCurrentElement()
	return EntitySpawnList[DebugGunProperties.currentCategoryIndex].categoryElements[DebugGunProperties.currentElementIndex]
end

local function incrementElementIndexCycled()
	local newIndex = DebugGunProperties.currentElementIndex + 1
	local currentCategoryCount = count(EntitySpawnList[DebugGunProperties.currentCategoryIndex].categoryElements)
	if (newIndex > currentCategoryCount) then
		newIndex = 1
	end
	DebugGunProperties.currentElementIndex = newIndex

	return newIndex
end

local function incrementCategoryIndexCycled()
	local newIndex = DebugGunProperties.currentCategoryIndex + 1
	if (newIndex > DebugGunProperties.totalCategories) then
		newIndex = 1
	end
	DebugGunProperties.currentElementIndex = 1
	DebugGunProperties.currentCategoryIndex = newIndex

	return newIndex
end

local function tryFindElementAndSetByName(elementName)
	for catInd, category in pairs(EntitySpawnList) do
		for i, value in pairs(category.categoryElements) do

			if value.name == elementName then
				DebugGunProperties.currentElementIndex = i
				DebugGunProperties.currentCategoryIndex = catInd
				return true
			end
		end
	end

	return false
end

local function getNewIndexForSpawnedEntity()
	local res = DebugGunProperties.creationIndexSequence
	DebugGunProperties.creationIndexSequence = res + 1
	return res
end

function Player:EntityAdditionalActions(entity, spawnInfo, hitPosition, newEntitiesGroup)

	if (spawnInfo.name == "vtol") then
		entity.vehicle:SetAmmoCount("a2ahomingmissile", 12);
	end

	local spawnedCrew = {}
	if spawnInfo.crew then
		for i, currentItem in pairs(spawnInfo.crew) do
			local position = entity:GetPos();
			local elevation = System.GetTerrainElevation(position);
			position.x = position.x + 5 * i
			position.z = elevation - 5

			local name = currentItem.name.." ["..getNewIndexForSpawnedEntity().."]"
			local params = {
				class = currentItem.class,
				archetype = currentItem.archetype,
				position = position,
				orientation = entity:GetDirectionVector(1),
				name = name,
				scale = self:GetScale(),
				properties = currentItem.properties,
			}
			local subEntity = System.SpawnEntity(params)

			if(subEntity) then
				EnterVehicle(subEntity, entity, i, true)

				table.insert(spawnedCrew, subEntity)
				table.insert(newEntitiesGroup, subEntity)
			end
		end
	end

	if (spawnInfo.behavior) then
		RunBehaviorByName(spawnInfo.behavior, entity, self, hitPosition, spawnedCrew)
	end
end

function Player:MuzzleTrace(currentItemPreset)
	local rayfilter = ent_all;
	local rayLimit = currentItemPreset.maxDistanceOverride or DebugGunProperties.maxDistance;

	local direction = g_Vectors.temp_v1;
	local cameraDirection = System.GetViewCameraDir()
	CopyVector(direction, cameraDirection);
	ScaleVectorInPlace(direction, rayLimit);

	local position = g_Vectors.temp_v2;
	self.actor:GetHeadPos(position);

	local hits = Physics.RayWorldIntersection(position,direction,2,rayfilter,self.id,nil,g_HitTable);

	local minDistanceToSpawn = currentItemPreset.minDistanceOverride or DebugGunProperties.minDistance
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

function Player:SpawnEntity(positionToSpawn, currentItemPreset)
	local cameraDirection = System.GetViewCameraDir()

	if (currentItemPreset.spawnDistanceAbovePlayer) then
		cameraDirection.x = -cameraDirection.x
		cameraDirection.y = -cameraDirection.y
		positionToSpawn = GetPositionWithTerrainOffset(self:GetPos(), cameraDirection, currentItemPreset.spawnDistanceAbovePlayer, currentItemPreset.zOffset)
	else
		positionToSpawn.z = positionToSpawn.z + currentItemPreset.zOffset
	end

	-- Hack for AI initialization. Problem: AI activating only in range 100 (either vehicle ai is dummy)
	local spawnParamUpdate = g_Vectors.temp_v3
	if (currentItemPreset.spawnDistanceAbovePlayer and currentItemPreset.spawnDistanceAbovePlayer > 100) then
		CopyVector(spawnParamUpdate, positionToSpawn)
		CopyVector(positionToSpawn, GetPositionWithTerrainOffset(self:GetPos(), cameraDirection, 50, currentItemPreset.zOffset))
	end


	local spawnParam = currentItemPreset.properties
	local params = {
		class = currentItemPreset.class,
		archetype = currentItemPreset.archetype,
		position = positionToSpawn,
		orientation = self:GetDirectionVector(1),
		name = currentItemPreset.name.." ["..getNewIndexForSpawnedEntity().."]",
		scale = self:GetScale(),
		properties = spawnParam,
		-- propertiesInstance = self.PropertiesInstance,
	}
	local entity = System.SpawnEntity(params)

	-- Hack for AI initialization. Problem: AI activating only in range 100 (either vehicle ai is dummy)
	if (currentItemPreset.spawnDistanceAbovePlayer and currentItemPreset.spawnDistanceAbovePlayer >= 100) then
		Script.SetTimer(150, function (ent) ent:SetPos(spawnParamUpdate) end, entity)
	end

	return entity
end

function Player:CanUseSpawnerTool()
	local wep = self.inventory:GetCurrentItem();
	return wep and (wep.class == "DebugGun" or wep.class == "SpawnGun")
end

function Player:SpawnerToolAction(action, isPressed, isHold)

	if (not self:CanUseSpawnerTool() or not isPressed) then
		return
	end

    if (action == "attack1" and isPressed) then

		local currentItem = getCurrentElement();

		local hit = self:MuzzleTrace(currentItem)

		if (not hit) then
			HUD.HitIndicator();
			return;
		end

		local entity = self:SpawnEntity(hit.position, currentItem)

		if (entity) then
			local newEntitiesGroup = {
				["0"] = entity
			}
			self:EntityAdditionalActions(entity, currentItem, hit.position, newEntitiesGroup)

			table.insert(DebugGunProperties.spawnedEntityPool, newEntitiesGroup)

			HUD.DrawStatusText("Spawned ["..currentItem.name.."]");
		else
			-- If you see that error enter to console "log_verbosity 3" to see error message
			HUD.DisplayBigOverlayFlashMessage("Error: entity not spawned", 4, 400, 275, { x=1, y=0, z=0});
		end
	end

	if (action == "reload" and isPressed) then

		local newIndex = incrementCategoryIndexCycled()

		local newCategoryName = EntitySpawnList[newIndex].name

		HUD.DisplayBigOverlayFlashMessage("Switch category to ["..newCategoryName.."]", 2, 400, 375, { x=0.3, y=1, z=0.3 });
	end

	if (action == "zoom" and isPressed) then

		local newIndex = incrementElementIndexCycled()

		local newElementName = getElementInCategory(newIndex).name

		HUD.DisplayBigOverlayFlashMessage("Switch entity to ["..newElementName.."]", 2, 400, 375, { x=0.5, y=0.8, z=0.9});
	end

	if (action == "hud_openchat" and isPressed) then

		local type = System.GetCVar("v_debugVehicle");

		if (not type or string.len(type) == 0) then
			HUD.DrawStatusText("Not set entity name to CVar 'v_debugVehicle' for search, skip");
			return;
		end

		if (tryFindElementAndSetByName(type)) then
			HUD.DisplayBigOverlayFlashMessage("Selected entity from CVar = "..type, 2, { x=1, y=1, z=1});
		else
			-- When entered not existing entity name
			HUD.DrawStatusText("Error: Can't find element be name ["..type.."]");
		end
	end

	if (action == "special" and isPressed) then
		local categoryName = getCurrentCategory().name
		local elementName = getCurrentElement().name
		HUD.DisplayBigOverlayFlashMessage("Selected category ["..categoryName.."], element ["..elementName.."]", 2, 400, 375, { x=1, y=1, z=1 });
	end

	if (action == "firemode" and isPressed) then

		local lastIndex = count(DebugGunProperties.spawnedEntityPool)

		if (lastIndex == 0) then
			HUD.HitIndicator();
			return;
		end

		local lastEntityGroup = DebugGunProperties.spawnedEntityPool[lastIndex]
		table.remove(DebugGunProperties.spawnedEntityPool, lastIndex)
		for key, value in pairs(lastEntityGroup) do
			System.RemoveEntity(value.id);
		end

		HUD.DrawStatusText("Removed ["..lastEntityGroup:GetName().."]");
	end
end
