Script.ReloadScript( "SCRIPTS/SpawnEntityList.lua");

DebugGunProperties = {
	minDistance = 3,
	currentIndex = 1,
	totalSpawnable = count(DebugGunSpawnList),
	spawnedEntityPool = {}
}


-- Customization of entity
function CustomizeSpawned(entity, spawnInfo)

	if (entity and spawnInfo.name == "vtol") then
		entity.vehicle:SetAmmoCount("a2ahomingmissile", 12);
	end
end

function Player:SpawnerToolAction(action, isPressed)

    if (action == "attack1" and isPressed) then

		local wep = self.inventory:GetCurrentItem();
		if (wep and wep.class == "DebugGun") then

			local currentItem = DebugGunSpawnList[DebugGunProperties.currentIndex];

			local rayfilter = ent_all;
			local rayLimit = 25;

			local direction = g_Vectors.temp_v1;
			local position = g_Vectors.temp_v2;
			self.actor:GetHeadPos(position);
			CopyVector(direction, System.GetViewCameraDir());
			ScaleVectorInPlace(direction, rayLimit);

			local hits = Physics.RayWorldIntersection(position,direction,2,rayfilter,self.id,nil,g_HitTable);
		
			if (hits == 0) then
				return;
			end

			if (g_HitTable[1].dist < DebugGunProperties.minDistance) then
				return;
			end

			local pos = g_HitTable[1].pos
			pos.z = pos.z + currentItem.zOffset

			local params = {
				class = currentItem.class,
				archetype = currentItem.archetype,
				position = pos,
				orientation = self:GetDirectionVector(1),
				name = "SpawnedEntity_"..currentItem.name,
				scale = self:GetScale(),
				-- properties = self.Properties,
				-- propertiesInstance = self.PropertiesInstance,
			}
			local entity = System.SpawnEntity(params)

			if (entity) then
				CustomizeSpawned(entity, currentItem)

				table.insert(DebugGunProperties.spawnedEntityPool, entity)
			end
		end
	end

	if (action == "reload" and isPressed) then

		local wep = self.inventory:GetCurrentItem();
		if (wep and wep.class == "DebugGun") then

			local type = System.GetCVar("v_debugVehicle");

			if (not type or string.len(type) == 0) then
				return;
			end

			for i, value in pairs(DebugGunSpawnList) do
				if value.name == type then
					DebugGunProperties.currentIndex = i
					return
				end
			end
		end
	end


	if (action == "zoom" and isPressed) then

		local wep = self.inventory:GetCurrentItem();
		if (wep and wep.class == "DebugGun") then

			local newIndex = DebugGunProperties.currentIndex + 1
			if (newIndex > DebugGunProperties.totalSpawnable) then
				newIndex = 1
			end
			DebugGunProperties.currentIndex = newIndex

			System.SetCVar("v_debugVehicle", DebugGunSpawnList[newIndex].name)
		end
	end

	if (action == "firemode" and isPressed) then
		local lastIndex = count(DebugGunProperties.spawnedEntityPool)

		if (lastIndex == 0) then
			return;
		end

		local lastEntity = DebugGunProperties.spawnedEntityPool[lastIndex]
		table.remove(DebugGunProperties.spawnedEntityPool, lastIndex)
		System.RemoveEntity(lastEntity.id);
	end
end
