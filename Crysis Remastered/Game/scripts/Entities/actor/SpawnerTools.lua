Script.ReloadScript( "SCRIPTS/SpawnEntityList.lua");


DebugGunProperties = {
	enabled = false,
	minDistance = 3,
	currentElementIndex = 1,
	currentCategoryIndex = 1,
	totalCategories = count(DebugGunSpawnList),
	spawnedEntityPool = {}
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

-- Customization of entity
function CustomizeSpawned(entity, spawnInfo)

	if (entity and spawnInfo.name == "vtol") then
		entity.vehicle:SetAmmoCount("a2ahomingmissile", 12);
	end
end

function Player:SpawnerToolAction(action, isPressed, isHold)

	local wep = self.inventory:GetCurrentItem();
	if (not wep or wep.class ~= "Fists") then

		if (DebugGunProperties.enabled) then
			DebugGunProperties.enabled = false;

			HUD.DisplayBigOverlayFlashMessage("Disabled spawn mode", 2, { x=0.3, y=1, z=0.3 });
			return;
		end

		return
	end

	LogWarning(action.." - P:"..tostring(isPressed)..", H:"..tostring(isHold))

	if (action == "use" and isHold) then

		if (DebugGunProperties.enabled) then
			DebugGunProperties.enabled = false;

			HUD.DisplayBigOverlayFlashMessage("Disabled spawn mode", 2, { x=0.3, y=1, z=0.3 });
			return;
		end

		DebugGunProperties.enabled = true;

		HUD.DisplayBigOverlayFlashMessage("Enabled spawn mode", 2, { x=0.3, y=1, z=0.3 });
	end

	if (not DebugGunProperties.enabled) then
		return
	end

    if (action == "attack1" and isPressed) then

		local currentItem = getCurrentElement();

		local rayfilter = ent_all;
		local rayLimit = 25;

		local direction = g_Vectors.temp_v1;
		local position = g_Vectors.temp_v2;
		self.actor:GetHeadPos(position);
		CopyVector(direction, System.GetViewCameraDir());
		ScaleVectorInPlace(direction, rayLimit);

		local hits = Physics.RayWorldIntersection(position,direction,2,rayfilter,self.id,nil,g_HitTable);

		if (hits == 0 or g_HitTable[1].dist < DebugGunProperties.minDistance) then
			-- HUD.HitIndicator();
			HUD.DrawStatusText("Too close or far to spawn");
			return;
		end

		local pos = g_HitTable[1].pos
		pos.z = pos.z + currentItem.zOffset

		local params = {
			class = currentItem.class,
			archetype = currentItem.archetype,
			position = pos,
			orientation = self:GetDirectionVector(1),
			name = currentItem.name,
			scale = self:GetScale(),
			-- properties = self.Properties,
			-- propertiesInstance = self.PropertiesInstance,
		}
		local entity = System.SpawnEntity(params)

		if (entity) then
			HUD.DrawStatusText("Spawned ["..currentItem.name.."]");

			CustomizeSpawned(entity, currentItem)

			table.insert(DebugGunProperties.spawnedEntityPool, entity)
		else
			-- If you see that error enter to console "log_verbosity 3" to see error message
			HUD.DisplayBigOverlayFlashMessage("Error: entity not spawned", 2, { x=1, y=0, z=0});
		end
	end

	if (action == "reload" and isPressed) then

		local newIndex = incrementCategoryIndexCycled()

		local newCategoryName = DebugGunSpawnList[newIndex].name

		HUD.DisplayBigOverlayFlashMessage("Switch category to ["..newCategoryName.."]", 1, { x=0.3, y=1, z=0.3 });
	end


	if (action == "zoom" and isPressed) then

		local newIndex = incrementElementIndexCycled()

		local newElementName = getElementInCategory(newIndex).name

		HUD.DisplayBigOverlayFlashMessage("Switch entity to ["..newElementName.."]", 1, { x=0.5, y=0.8, z=0.9});
	end

	if (action == "hud_openchat" and isPressed) then

		local type = System.GetCVar("i_debuggun_1");

		if (not type or string.len(type) == 0) then
			-- HUD.HitIndicator();
			HUD.DrawStatusText("Not set entity name to CVar 'i_debuggun_1' for search, skip");
			return;
		end

		if (tryFindElementAndSetByName(type)) then
			HUD.DisplayBigOverlayFlashMessage("Selected entity from CVar = "..type, 0.5, { x=1, y=1, z=1});
		else
			-- When entered not existing entity name
			-- HUD.HitIndicator();
			HUD.DrawStatusText("Error: Can't find element be name ["..type.."]");
		end
	end

	if (action == "special" and isPressed) then

		local categoryName = getCurrentCategory().name
		local elementName = getCurrentElement().name
		HUD.DisplayBigOverlayFlashMessage("Selected category ["..categoryName.."], element ["..elementName.."]", 1, { x=1, y=1, z=1 });
	end

	if (action == "drop" and isPressed) then

		local lastIndex = count(DebugGunProperties.spawnedEntityPool)

		if (lastIndex == 0) then
			-- HUD.HitIndicator();
			HUD.DrawStatusText("Deletion is not possible, no objects created");
			return;
		end

		local lastEntity = DebugGunProperties.spawnedEntityPool[lastIndex]
		table.remove(DebugGunProperties.spawnedEntityPool, lastIndex)
		System.RemoveEntity(lastEntity.id);

		HUD.DrawStatusText("Removed ["..lastEntity:GetName().."]");
	end
end
