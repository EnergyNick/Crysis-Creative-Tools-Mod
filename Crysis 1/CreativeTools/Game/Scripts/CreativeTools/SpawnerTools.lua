-- Script.ReloadScript("SCRIPTS/HUD/Hud.lua");
-- Script.ReloadScript("SCRIPTS/CreativeTools/CustomBehaviors/BehaviorsCatalog.lua");
-- Script.ReloadScript("SCRIPTS/CreativeTools/LIST_TO_SPAWN.lua");


-- Properties = {
-- 	minDistance = 3,
-- 	maxDistance = 25,
-- 	currentElementIndex = 1,
-- 	currentCategoryIndex = 1,
-- 	totalCategories = count(EntitySpawnList),
-- 	spawnedEntityPool = {},
-- 	creationIndexSequence = 0
-- }

-- local function getElementInCategory(index)
-- 	return EntitySpawnList[Properties.currentCategoryIndex].categoryElements[index]
-- end

-- local function getCurrentCategory()
-- 	return EntitySpawnList[Properties.currentCategoryIndex]
-- end

-- local function getCurrentElement()
-- 	return EntitySpawnList[Properties.currentCategoryIndex].categoryElements[Properties.currentElementIndex]
-- end

-- local function incrementElementIndexCycled()
-- 	local newIndex = Properties.currentElementIndex + 1
-- 	local currentCategoryCount = count(EntitySpawnList[Properties.currentCategoryIndex].categoryElements)
-- 	if (newIndex > currentCategoryCount) then
-- 		newIndex = 1
-- 	end
-- 	Properties.currentElementIndex = newIndex

-- 	return newIndex
-- end

-- local function incrementCategoryIndexCycled()
-- 	local newIndex = Properties.currentCategoryIndex + 1
-- 	if (newIndex > Properties.totalCategories) then
-- 		newIndex = 1
-- 	end
-- 	Properties.currentElementIndex = 1
-- 	Properties.currentCategoryIndex = newIndex

-- 	return newIndex
-- end

-- local function tryFindElementAndSetByName(elementName)
-- 	for catInd, category in pairs(EntitySpawnList) do
-- 		for i, value in pairs(category.categoryElements) do

-- 			if value.name == elementName then
-- 				Properties.currentElementIndex = i
-- 				Properties.currentCategoryIndex = catInd
-- 				return true
-- 			end
-- 		end
-- 	end

-- 	return false
-- end

-- local function getNewIndexForSpawnedEntity()
-- 	local res = Properties.creationIndexSequence
-- 	Properties.creationIndexSequence = res + 1
-- 	return res
-- end

-- function Player:EntityAdditionalActions(entity, spawnInfo, hitPosition, newEntitiesGroup)

-- 	if (spawnInfo.name == "vtol") then
-- 		entity.vehicle:SetAmmoCount("a2ahomingmissile", 12);
-- 	end

-- 	local spawnedCrew = {}
-- 	if spawnInfo.crew then
-- 		for i, currentItem in pairs(spawnInfo.crew) do
-- 			local position = entity:GetPos();
-- 			local elevation = System.GetTerrainElevation(position);
-- 			position.x = position.x + 5 * i
-- 			position.z = elevation - 5

-- 			local name = currentItem.name.." ["..getNewIndexForSpawnedEntity().."]"
-- 			local params = {
-- 				class = currentItem.class,
-- 				archetype = currentItem.archetype,
-- 				position = position,
-- 				orientation = entity:GetDirectionVector(1),
-- 				name = name,
-- 				scale = self:GetScale(),
-- 				properties = currentItem.properties,
-- 			}
-- 			local subEntity = System.SpawnEntity(params)

-- 			if(subEntity) then
-- 				EnterVehicle(subEntity, entity, i, true)

-- 				table.insert(spawnedCrew, subEntity)
-- 				table.insert(newEntitiesGroup, subEntity:GetName())
-- 			end
-- 		end
-- 	end

-- 	if (spawnInfo.behavior) then
-- 		RunBehaviorByName(spawnInfo.behavior, entity, self, hitPosition, spawnedCrew)
-- 	end
-- end

-- function Player:MuzzleTrace(currentItemPreset)
-- 	local rayfilter = ent_all;
-- 	local rayLimit = currentItemPreset.maxDistanceOverride or Properties.maxDistance;

-- 	local direction = g_Vectors.temp_v1;
-- 	local cameraDirection = System.GetViewCameraDir()
-- 	CopyVector(direction, cameraDirection);
-- 	ScaleVectorInPlace(direction, rayLimit);

-- 	local position = g_Vectors.temp_v2;
-- 	self.actor:GetHeadPos(position);

-- 	local hits = Physics.RayWorldIntersection(position,direction,2,rayfilter,self.id,nil,g_HitTable);

-- 	local minDistanceToSpawn = currentItemPreset.minDistanceOverride or Properties.minDistance
-- 	if (hits == 0 or g_HitTable[1].dist < minDistanceToSpawn) then
-- 		return nil;
-- 	end

-- 	local data = {
-- 		position = g_HitTable[1].pos,
-- 		entity = g_HitTable[1].entity,
-- 		distance = g_HitTable[1].dist
-- 	}
-- 	return data;
-- end

-- function SpawnEntity(spawnPoint, currentItemPreset, orientation)
-- 	local params = {
-- 		class = currentItemPreset.class,
-- 		archetype = currentItemPreset.archetype,
-- 		position = spawnPoint,
-- 		orientation = orientation,
-- 		name = currentItemPreset.name.." ["..getNewIndexForSpawnedEntity().."]",
-- 		scale = g_Vectors.v111,
-- 		-- properties = spawnParam,
-- 		-- propertiesInstance = self.PropertiesInstance,
-- 	}
-- 	return System.SpawnEntity(params)
-- end

-- function Player:SpawnEntityFromPreset(positionToSpawn, currentItemPreset)
-- 	local cameraDirection = System.GetViewCameraDir()
-- 	-- CopyVector(cameraDirection, System.GetViewCameraDir())

-- 	if (currentItemPreset.spawnDistanceAbovePlayer) then
-- 		cameraDirection.x = -cameraDirection.x
-- 		cameraDirection.y = -cameraDirection.y
-- 		positionToSpawn = GetPositionWithTerrainOffset(self:GetPos(), cameraDirection, currentItemPreset.spawnDistanceAbovePlayer, currentItemPreset.zOffset)
-- 	else
-- 		positionToSpawn.z = positionToSpawn.z + currentItemPreset.zOffset
-- 	end

-- 	-- Hack for AI initialization. Problem: AI activating only in range 100 (either vehicle ai is dummy)
-- 	local spawnParamUpdate = g_Vectors.temp_v3
-- 	if (currentItemPreset.spawnDistanceAbovePlayer and currentItemPreset.spawnDistanceAbovePlayer > 100) then
-- 		-- HUD.DrawStatusText("Position before: "..vecToString(positionToSpawn))
-- 		CopyVector(spawnParamUpdate, positionToSpawn)
-- 		CopyVector(positionToSpawn, GetPositionWithTerrainOffset(self:GetPos(), cameraDirection, 50, currentItemPreset.zOffset))
-- 	end

-- 	-- HUD.DrawStatusText("Position: "..vecToString(positionToSpawn))

-- 	-- local spawnParam = currentItemPreset.properties
-- 	local params = {
-- 		class = currentItemPreset.class,
-- 		archetype = currentItemPreset.archetype,
-- 		position = positionToSpawn,
-- 		orientation = self:GetDirectionVector(1),
-- 		name = currentItemPreset.name.." ["..getNewIndexForSpawnedEntity().."]",
-- 		scale = g_Vectors.v111
-- 		-- properties = spawnParam,
-- 		-- propertiesInstance = self.PropertiesInstance,
-- 	}
-- 	local entity = System.SpawnEntity(params)

-- 	-- Hack for AI initialization. Problem: AI activating only in range 100 (either vehicle ai is dummy)
-- 	if (currentItemPreset.spawnDistanceAbovePlayer and currentItemPreset.spawnDistanceAbovePlayer >= 100) then
-- 		Script.SetTimer(150, function (ent) ent:SetPos(spawnParamUpdate) end, entity)
-- 	end

-- 	return entity
-- end

-- function Player:CanUseSpawnerTool()
-- 	local wep = self.inventory:GetCurrentItem();
-- 	return wep and (wep.class == "DebugGun" or wep.class == "SpawnGun")
-- end

-- function Player:SpawnerToolAction(action, isPressed)

-- 	local wep = self.inventory:GetCurrentItem();
-- 	if isPressed and wep and (wep.class == "LockpickKit") then
-- 		HUD.SetProgressBar(true, random(1, 100), "Calling reinforcements...");
-- 	end

-- 	-- if wep and (wep.class == "RadarKit") then
-- 	-- 	HUD.SetProgressBar(true, random(1, 100), "@ui_work_scan");
-- 	-- end

-- 	-- if wep and (wep.class == "RepairKit") then
-- 	-- 	HUD.SetProgressBar(true, random(1, 100), "@ui_work_repair");
-- 	-- end

-- 	if (not self:CanUseSpawnerTool() or not isPressed) then
-- 		return
-- 	end

-- 	-- "voice_chat_talk"
-- 	-- "lights"
-- 	-- "hud_openchat"
-- 	-- "hud_openteamchat"
-- 	-- "nextitem"
-- 	-- "previtem"

--     if (action == "attack1" and isPressed) then

-- 		local currentItem = getCurrentElement();

-- 		local hit = self:MuzzleTrace(currentItem)

-- 		if (not hit) then
-- 			HUD.HitIndicator();
-- 			return;
-- 		end

-- 		local entity = self:SpawnEntityFromPreset(hit.position, currentItem)

-- 		-- misc.signal_flare.on_ground
-- 		-- explosions.flare.a

-- 		-- TODO: See SETUP_REINF in Cover2CallReinforcements
-- 		-- DO_FLARE	= function (self, entity)
-- 		-- 	-- Use hard coded values since the bone position cannot be trusted when the
-- 		-- 	-- character is not rendered.
-- 		-- 	local pos = entity:GetPos();
-- 		-- 	pos.z = pos.z + 1.9;
-- 		-- 	local dir = entity:GetDirectionVector(1);
-- 		-- 	dir.x = dir.x * 0.2;
-- 		-- 	dir.y = dir.y * 0.2;
-- 		-- 	dir.z = dir.z * 0.2;
-- 		-- 	dir.z = 0.99;
-- 		-- 	Particle.SpawnEffect("explosions.flare.a", pos, dir, 1.0);
-- 		-- end,
-- 		if (entity) then
-- 			local newEntitiesGroup = {
-- 				[1] = entity:GetName()
-- 			}
-- 			self:EntityAdditionalActions(entity, currentItem, hit.position, newEntitiesGroup)

-- 			table.insert(Properties.spawnedEntityPool, newEntitiesGroup)

-- 			HUD.DrawStatusText("Spawned ["..currentItem.name.."]");
-- 		else
-- 			-- If you see that error enter to console "log_verbosity 3" to see error message
-- 			HUD.DisplayBigOverlayFlashMessage("Error: entity not spawned", 4, 400, 275, { x=1, y=0, z=0});
-- 		end
-- 	end

-- 	if (action == "reload" and isPressed) then

-- 		local newIndex = incrementCategoryIndexCycled()

-- 		local newCategoryName = EntitySpawnList[newIndex].name

-- 		HUD.DisplayBigOverlayFlashMessage("Switch category to ["..newCategoryName.."]", 2, 400, 375, { x=0.3, y=1, z=0.3 });
-- 	end

-- 	if (action == "zoom" and isPressed) then

-- 		local newIndex = incrementElementIndexCycled()

-- 		local newElementName = getElementInCategory(newIndex).name

-- 		HUD.DisplayBigOverlayFlashMessage("Switch entity to ["..newElementName.."]", 2, 400, 375, { x=0.5, y=0.8, z=0.9});
-- 	end

-- 	if (action == "hud_openchat" and isPressed) then

-- 		local type = System.GetCVar("v_debugVehicle");

-- 		if (not type or string.len(type) == 0) then
-- 			HUD.DrawStatusText("Not set entity name to CVar 'v_debugVehicle' for search, skip");
-- 			return;
-- 		end

-- 		if (tryFindElementAndSetByName(type)) then
-- 			HUD.DisplayBigOverlayFlashMessage("Selected entity from CVar = "..type, 2, { x=1, y=1, z=1});
-- 		else
-- 			-- When entered not existing entity name
-- 			HUD.DrawStatusText("Error: Can't find element be name ["..type.."]");
-- 		end
-- 	end

-- 	if (action == "special" and isPressed) then

-- 		System.AddCCommand("creativetools", "HUD.DrawStatusText(%1)", "Give items")
-- 		System.AddCCommand("creativetools2", "System.ExecuteCommand(\"i_giveitem SpawnTool\")", "Give items")

-- 		local categoryName = getCurrentCategory().name
-- 		local elementName = getCurrentElement().name
-- 		HUD.DisplayBigOverlayFlashMessage("Selected category ["..categoryName.."], element ["..elementName.."]", 2, 400, 375, { x=1, y=1, z=1 });
-- 	end

-- 	if (action == "firemode" and isPressed) then

-- 		local lastIndex = count(Properties.spawnedEntityPool)

-- 		if (lastIndex == 0) then
-- 			HUD.HitIndicator();
-- 			return;
-- 		end

-- 		local lastEntityGroup = Properties.spawnedEntityPool[lastIndex]
-- 		table.remove(Properties.spawnedEntityPool, lastIndex)
-- 		for i, name in pairs(lastEntityGroup) do
-- 			local toDelete = System.GetEntityByName(name);
-- 			if toDelete and toDelete.id then
-- 				System.RemoveEntity(toDelete.id);
-- 			end
-- 		end

-- 		local countOfDeleted = #lastEntityGroup
-- 		if countOfDeleted == 1 then
-- 			HUD.DrawStatusText("Removed entity");
-- 		elseif countOfDeleted > 1 then
-- 			HUD.DrawStatusText("Removed group with "..#lastEntityGroup.." entities");
-- 		end
-- 	end
-- end
