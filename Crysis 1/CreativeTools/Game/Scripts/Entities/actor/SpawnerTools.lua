Script.ReloadScript("SCRIPTS/SpawnEntityList.lua");
Script.ReloadScript("SCRIPTS/HUD/Hud.lua");


DebugGunProperties = {
	minDistance = 3,
	maxDistance = 25,
	currentElementIndex = 1,
	currentCategoryIndex = 1,
	totalCategories = count(DebugGunSpawnList),
	spawnedEntityPool = {},
	creationIndexSequence = 0
}

local function getElementInCategory(index)
	return DebugGunSpawnList[DebugGunProperties.currentCategoryIndex].categoryElements[index]
end

local function getCurrentCategory()
	return DebugGunSpawnList[DebugGunProperties.currentCategoryIndex]
end

local function getCurrentElement()
	return DebugGunSpawnList[DebugGunProperties.currentCategoryIndex].categoryElements[DebugGunProperties.currentElementIndex]
end

local function incrementElementIndexCycled()
	local newIndex = DebugGunProperties.currentElementIndex + 1
	local currentCategoryCount = count(DebugGunSpawnList[DebugGunProperties.currentCategoryIndex].categoryElements)
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
	for catInd, category in pairs(DebugGunSpawnList) do
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


function Player:EntityAdditionalActions(entity, spawnInfo, newEntitiesGroup)

	if (spawnInfo.name == "vtol") then
		entity.vehicle:SetAmmoCount("a2ahomingmissile", 12);
	end

	if spawnInfo.crew then
		for i, currentItem in pairs(spawnInfo.crew) do
			local position = entity:GetPos();
			position.x = position.x + 5

			local name = currentItem.name.." ["..getNewIndexForSpawnedEntity().."]"
			local params = {
				class = currentItem.class,
				archetype = currentItem.archetype,
				position = position,
				orientation = entity:GetDirectionVector(1),
				name = name,
				scale = self:GetScale(),
				properties = currentItem.properties,
				-- propertiesInstance = self.PropertiesInstance,
			}
			local subEntity = System.SpawnEntity(params)

			if(subEntity) then
				EnterVehicle(subEntity, entity, i, true)
				table.insert(newEntitiesGroup, subEntity)
			end
		end
	end
end

function Player:SpawnerToolAction(action, isPressed, isHold)

	local wep = self.inventory:GetCurrentItem();
	if (not wep or wep.class ~= "DebugGun") then
		return
	end

    if (action == "attack1" and isPressed) then

		local currentItem = getCurrentElement();

		local rayfilter = ent_all;
		local rayLimit = currentItem.maxDistanceOverride or DebugGunProperties.maxDistance;

		local direction = g_Vectors.temp_v1;
		CopyVector(direction, System.GetViewCameraDir());
		ScaleVectorInPlace(direction, rayLimit);

		local position = g_Vectors.temp_v2;
		self.actor:GetHeadPos(position);

		local hits = Physics.RayWorldIntersection(position,direction,2,rayfilter,self.id,nil,g_HitTable);

		local minDistanceToSpawn = currentItem.minDistanceOverride or DebugGunProperties.minDistance
		if (hits == 0 or g_HitTable[1].dist < minDistanceToSpawn) then
			HUD.HitIndicator();
			return;
		end

		local pos = g_HitTable[1].pos
		pos.z = pos.z + currentItem.zOffset

		local spawnParam = currentItem.properties
		local params = {
			class = currentItem.class,
			archetype = currentItem.archetype,
			position = pos,
			orientation = self:GetDirectionVector(1),
			name = currentItem.name.." ["..getNewIndexForSpawnedEntity().."]",
			scale = self:GetScale(),
			properties = spawnParam,
			-- propertiesInstance = self.PropertiesInstance,
		}
		local entity = System.SpawnEntity(params)

		if (entity) then
			local newEntitiesGroup = {
				["0"] = entity
			}
			self:EntityAdditionalActions(entity, currentItem, newEntitiesGroup)

			table.insert(DebugGunProperties.spawnedEntityPool, newEntitiesGroup)

			HUD.DrawStatusText("Spawned ["..currentItem.name.."]");
		else
			-- If you see that error enter to console "log_verbosity 3" to see error message
			HUD.DisplayBigOverlayFlashMessage("Error: entity not spawned", 4, 400, 275, { x=1, y=0, z=0});
		end
	end

	if (action == "reload" and isPressed) then

		local newIndex = incrementCategoryIndexCycled()

		local newCategoryName = DebugGunSpawnList[newIndex].name

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
