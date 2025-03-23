Script.ReloadScript("Scripts/CreativeTools/MathHelpers.lua");

---------------------------------------------------------------------------------------------------------
-- Math functions

function TargetObstacleCheck(entity, targetPoint)

	local vSrc = {};
	local vDst = {};
	local vTmp = {};

	CopyVector(vSrc, entity:GetPos());
	CopyVector(vDst, targetPoint);

	SubVectors(vTmp, vDst, vSrc);
	vTmp.z = 0;

	if (LengthVector(vTmp) > 120.0) then
		return true;
	end

	if (vSrc.z - vDst.z < 5.0) then
		return true;
	end

	local entities = System.GetPhysicalEntitiesInBox(vDst, 10.0);

	if (entities) then

		for i, targetEntity in ipairs(entities) do
			local objEntity = targetEntity;
			if (objEntity.id ~= entity.id) then
				local bbmin, bbmax = objEntity:GetLocalBBox();
				if (DistanceVectors(bbmin, bbmax) > 3.0 or objEntity:GetMass() > 300.0) then
					return false;
				end
			end
		end

	end

	return true;
end


---------------------------------------------------------------------------------------------------------
-- Vehicle helpers

function IsFlyingVehicles(entity)
	return entity.class == "US_vtol" or entity.class == "Asian_helicopter"
end

function RequestMorePriorityOrClosestSeatExcludeDriver(vehicle, userId)

	local previousOrReservedSeatId = vehicle:GetSeatId(userId)
	if previousOrReservedSeatId then
		return previousOrReservedSeatId
	end

	local pos = System.GetEntity(userId):GetWorldPos();

	local minDistanceSq = 100000;

	-- search for gunner seats
	for i, seat in pairs(vehicle.Seats) do
		if (seat.seat:GetWeaponCount() > 0 and not seat.isDriver) then
			if (seat.enterHelper and seat:IsFree()) then
				return i;
			end
		end
	end

	for i, seat in pairs(vehicle.Seats) do

		if (seat.enterHelper and seat:IsFree() and not seat.isDriver) then

			local enterPos;
			if (vehicle.vehicle:HasHelper(seat.enterHelper)) then
				enterPos = vehicle.vehicle:GetHelperWorldPos(seat.enterHelper);
			else
				enterPos = vehicle:GetHelperPos(seat.enterHelper, HELPER_WORLD);
			end

			local distanceSq = DistanceSqVectors(pos, enterPos);
			if (distanceSq <= minDistanceSq) then
				minDistanceSq = distanceSq;
				return i;
			end
		end
	end

	return nil;
end

function GetReinforcementsPassengerEntitiesFromVehicle(vehicle)
	local passengers = {}

	for i, seat in pairs(vehicle.Seats) do
		if (seat.passengerId) then
			local member = System.GetEntity(seat.passengerId);
			if (member ~= nil) then
				if (seat.isDriver) then
					-- when a passenger is the driver.
				elseif (seat.seat:GetWeaponCount() > 0) then
					-- when a passenger is the gunner.
				else
					-- this guy should be a reinforcement.
					if (not member:IsDead()) then
						table.insert(passengers, member)
					end
				end
			end
		end
	end

	return passengers
end

function KillAllPassengersInVehicle(vehicle)
	for i, seat in pairs(vehicle.Seats) do
		if (seat.passengerId) then
			local member = System.GetEntity(seat.passengerId);
			if (member ~= nil) then
				member:Kill(true, NULL_ENTITY, NULL_ENTITY);
			end
		end
	end
end

function DisablePhysicsAndLaterEnabledWithUpPush(vehicle, delay)
	vehicle:EnablePhysics(false);
	Script.SetTimer(delay, function(ent)
		ent:EnablePhysics(true)
		local vIpos = {};
		CopyVector(vIpos, ent:GetCenterOfMassPos());
		vIpos.z = vIpos.z - 1
		local vIdir = { x = 0.0, y = 0.0, z = 3.0 };
		ent:AddImpulse(-1, vIpos, vIdir, ent:GetMass() * 5.0);
	end, vehicle)
end

local function toFlyIteration(data)
	local entityPos = data.vehicle:GetPos()
	local distance = entityPos.z - System.GetTerrainElevation(entityPos)

	if distance < data.takeoffRange then
		local direction = SubVectorsNormalizedOnXY(data.finalPos, entityPos)
		direction.z = 13

		AI.SetForcedNavigation(data.vehicle.id, direction)
		Script.SetTimer(500, toFlyIteration, data)
		HUD.DrawStatusText("Order fly up")
	else
		local direction = {}
		ZeroVector(direction)
		if data.vehicle:GetSpeed() > 5 then
			CopyVector(direction, data.vehicle:GetDirectionVector(2))
			ScaleVectorInPlace(direction, -0.25)
			Script.SetTimer(500, toFlyIteration, data)
			HUD.DrawStatusText("Order slow down")
		else
			HUD.DrawStatusText("Order stop")
		end
		AI.SetForcedNavigation(data.vehicle.id, direction)
	end
end

function TakeoffAirVehicle(vehicle, takeoffRange, afterTakeOff)
	vehicle.vehicle:DisableEngine(0);
	vehicle.vehicle:CloseAutomaticDoors();

	local targetToFly = GetPositionWithTerrainOffset(vehicle:GetPos(), takeoffRange)
	local data = {
		vehicle = vehicle,
		takeoffRange = takeoffRange,
		finalPos = targetToFly,
		afterTakeOff = afterTakeOff
	}
	Script.SetTimer(1000, toFlyIteration, data)
end

---@return boolean Result Is currently rotated successfully
function SetNavigationToRotateAndGetIsRotated(entity, targetPosition, currentToTargetDirection)
	local vRotateDir = SubVectorsNormalizedOnXY(targetPosition, entity:GetPos())
	FastScaleVector(vRotateDir, vRotateDir, 3.0);

	CopyVector(currentToTargetDirection, vRotateDir);
	NormalizeVector(currentToTargetDirection);
	local isRotatedSuccessfully = IsEntityXYDirectionRotatedMoreThan(entity, currentToTargetDirection, 2)

	AI.SetForcedNavigation(entity.id, isRotatedSuccessfully and vRotateDir or g_Vectors.v000);
	return isRotatedSuccessfully
end

---@return boolean Result Is currently crossed target point
function SetNavigationToFastFlyAndGetIsCrossed(entity, positionVector, currentToTargetDirection, minimalZOffset)

	local vRotateDir = SubVectorsNormalizedOnXY(positionVector, entity:GetPos())
	local scalarBetweenDirections = dotproduct3d(vRotateDir, currentToTargetDirection)
	local isCrossedSuccessfully = scalarBetweenDirections < 0

	local navigationDirection = g_Vectors.v000
	if not isCrossedSuccessfully then
		navigationDirection = g_Vectors.temp_v1;
		FastScaleVector(navigationDirection, currentToTargetDirection, 65.0);

		local entityPos = entity:GetPos()
		if entityPos.z < positionVector.z then
			navigationDirection.z = 3.0
		else
			if minimalZOffset then
				local distance = entityPos.z - System.GetTerrainElevation(entityPos)
				if distance < minimalZOffset then
					navigationDirection.z = 3.0
				end
			end
		end
	end

	HUD.DrawStatusText("Nav: " .. VectorToString(navigationDirection))
	AI.SetForcedNavigation(entity.id, navigationDirection);
	return isCrossedSuccessfully;
end

local function ExitByChainAndGoToRandomPoint(data)

	if not data.isExited then
		if (not data.previousPassenger or not data.previousPassenger:IsOnVehicle()) then
			ExitVehicle(data.entity)
			data.isExited = true

			-- Use for equip weapon and searching behavior
			data.entity:MakeAlerted()
		end

		Script.SetTimer(1500, ExitByChainAndGoToRandomPoint, data)
		return
	end

	if (data.entity:IsOnVehicle()) then
		Script.SetTimer(500, ExitByChainAndGoToRandomPoint, data)
		return
	end

	local vMyFwd = g_Vectors.temp_v1;
	CopyVector(vMyFwd, data.entity:GetDirectionVector(1));
	vMyFwd.z = 0.0;
	NormalizeVector(vMyFwd);

	local deltaAngle = data.seatIndex * 25 * (3.1416 / 180.0);
	local vMyFwdRot = g_Vectors.temp_v2;
	RotateVectorAroundR(vMyFwdRot, vMyFwd, data.entity:GetDirectionVector(2), deltaAngle);

	local distanceToGo = random(3, 6)
	local resultPosition = g_Vectors.temp_v3;
	ScaleVectorInPlace(vMyFwdRot, distanceToGo);
	FastSumVectors(resultPosition, data.entity:GetPos(), vMyFwdRot);

	-- TODO: Add logic of trace to find, if entity can go to resultPosition, either make distance shorter
	OrderEntityGoToPosition(data.entity, resultPosition)
end

function StartExitByChainAndGoToRandomPointAsync(entity, seatIndex, previousPassenger, initialDelay)
	local data = {
		entity = entity,
		seatIndex = seatIndex,
		previousPassenger = previousPassenger,
		isExited = false
	}

	Script.SetTimer(initialDelay or 8000, ExitByChainAndGoToRandomPoint, data)
end

function GetNearestEnemiesEntities(entity, range, aiObjectType)
	local objects = {};
	local numObjects = AI.GetNearestEntitiesOfType(entity, aiObjectType, range, objects );

	local result = {}
	for i = 1, numObjects do
		local objEntity = System.GetEntity(objects[i].id);
		if AI.Hostile(entity.id, objEntity.id) then
			table.insert(result, objEntity)
		end
	end

	return result
end
---------------------------------------------------------------------------------------------------------
-- AI helpers

function IsEntityAttentionOnHostile(entity)
	local attentionTarget = AI.GetAttentionTargetEntity(entity.id);
	return attentionTarget and AI.Hostile(entity.id, attentionTarget.id)
end

function OrderEntityGoToPosition(entity, positionVector)
	CopyVector(g_SignalData.point, positionVector);
	g_SignalData.iValue = 1;
	AI.Signal(SIGNALFILTER_SENDER, 1, "ACT_GOTO", entity.id, g_SignalData);
end

---@param oneOfSpeeds integer From sprint speed to slowest (from 3 to -2)
function OrderEntityGoToPositionWithSpeed(entity, positionVector, oneOfSpeeds)
	-- if AI.GetTypeOf(entity.id) == AIOBJECT_VEHICLE then
	AI.SetRefPointPosition(entity.id, positionVector)

	-- oneOfSpeeds = math.max(oneOfSpeeds - 1, 0)

	g_StringTemp1 = "movement_" .. tostring(entity.id)
	AI.CreateGoalPipe(g_StringTemp1);
	-- AI.PushGoal(g_StringTemp1,"run",0,2)
	-- AI.PushGoal(g_StringTemp1,"locate",0,"refpoint");
	-- -- AI.PushGoal(g_StringTemp1,"acqtarget",1,"");
	-- AI.PushGoal(g_StringTemp1,"approach",1,5,AILASTOPRES_USE+AILASTOPRES_LOOKAT);
	-- -- AI.PushGoal(g_StringTemp1,"signal",0,10,"ACTION_DONE",SIGNALFILTER_SENDER);
	-- AI.PushGoal(g_StringTemp1,"signal",0,1,"ORD_DONE",SIGNALFILTER_SENDER);

	-- AI.PushGoal(g_StringTemp1,"ignoreall",0,1);
	AI.PushGoal(g_StringTemp1, "clear", 0, 0);
	AI.PushGoal(g_StringTemp1, "firecmd", 0, FIREMODE_OFF);
	AI.PushGoal(g_StringTemp1, "acqtarget", 1, "");

	AI.PushGoal(g_StringTemp1, "+run", 0, oneOfSpeeds, oneOfSpeeds)
	AI.PushGoal(g_StringTemp1, "+locate", 0, "refpoint");
	AI.PushGoal(g_StringTemp1, "approach", 1, 1, AILASTOPRES_USE);
	AI.PushGoal(g_StringTemp1, "signal", 0, 10, "ACTION_DONE", SIGNALFILTER_SENDER);
	-- AI.PushGoal(g_StringTemp1,"ignoreall",0,0);

	entity:SelectPipe(0, g_StringTemp1);
	-- else
	-- 	g_SignalData.iValue = oneOfSpeeds;
	-- 	AI.Signal(SIGNALFILTER_SENDER, 0, "ACT_SPEED", entity.id, g_SignalData);

	-- 	CopyVector(g_SignalData.point, positionVector);
	-- 	g_SignalData.iValue = 1;
	-- 	AI.Signal(SIGNALFILTER_SENDER, 1, "ACT_GOTO", entity.id, g_SignalData);
	-- end
end

function OrderVtolGoToPositionWithSpeed(entity, positionVector, oneOfSpeeds)
	-- CopyVector(g_SignalData.point, positionVector);
	-- g_SignalData.iValue = 143;
	-- AI.Signal(SIGNALFILTER_SENDER, 0, "TO_VTOL_FLY", entity.id, g_SignalData);
	-- AI.Signal(SIGNALFILTER_SENDER, 0, "ACT_DUMMY", entity.id, g_SignalData);

	if not entity.AI.vDirectionRsv then
		entity.AI.vDirectionRsv = { x = 0, y = 0, z = 0 }
	end

	if not entity.AI.bLock then
		entity.AI.bLock = 0
	end

	-- if ( entity.AI == nil or entity:GetSpeed() == nil ) then
	-- 	local myEntity = System.GetEntity( entity.id );
	-- 	if ( myEntity ) then
	-- 		local vZero = {x=0.0,y=0.0,z=0.0};
	-- 		AI.SetForcedNavigation( entity.id, vZero );
	-- 	end
	-- 	return true;
	-- end

	-- if ( not entity.id or not System.GetEntity( entity.id ) ) then
	-- 	local vZero = {x=0.0,y=0.0,z=0.0};
	-- 	AI.SetForcedNavigation( entity.id, vZero );
	-- 	return true;
	-- end

	-- if ( not entity:IsActive() or not AI.IsEnabled(entity.id) ) then
	-- 	local vZero = {x=0.0,y=0.0,z=0.0};
	-- 	AI.SetForcedNavigation( entity.id, vZero );
	-- 	return true;
	-- end

	--------------------------------------------------------------------------
	if (entity.AI.bLock == 0) then
		local vDir = {};
		CopyVector(vDir, entity:GetDirectionVector(1));
		vDir.z = 0;
		NormalizeVector(vDir);

		local vTmp = {};
		SubVectors(vTmp, positionVector, entity:GetPos());
		vTmp.z = 0.0;
		NormalizeVector(vTmp);
		FastScaleVector(vTmp, vTmp, 3.0);
		AI.SetForcedNavigation(entity.id, vTmp);
		HUD.DrawStatusText("Ticking on 0")

		if (entity:GetSpeed() < 5.0) then
			CopyVector(entity.AI.vDirectionRsv, vTmp);
			NormalizeVector(entity.AI.vDirectionRsv);
			if (dotproduct3d(vDir, entity.AI.vDirectionRsv) > math.cos(3.1416 * 2.0 / 180.0)) then
				HUD.DrawStatusText("Replace to 1")
				entity.AI.bLock = 1;
				entity.vehicle:SetMovementMode(1);
			end
		end
		return false;
	end

	if (entity.AI.bLock == 1) then
		local vTmp = {};
		local vMyPos = {};

		FastScaleVector(vTmp, entity.AI.vDirectionRsv, 65.0);

		CopyVector(vMyPos, entity:GetPos());
		if (vMyPos.z < positionVector.z) then
			vTmp.z = 3.0;
		end
		AI.SetForcedNavigation(entity.id, vTmp);

		local vDir = {};
		SubVectors(vDir, positionVector, entity:GetPos());
		vDir.z = 0;
		NormalizeVector(vDir);
		local product = dotproduct3d(vDir, entity.AI.vDirectionRsv)
		HUD.DrawStatusText("Ticking, scalar =  " .. tostring(product))

		if (product < 0) then
			HUD.DrawStatusText("Replace to 0")
			entity.AI.bLock = 0;
			local vZero = { x = 0.0, y = 0.0, z = 0.0 };
			AI.SetForcedNavigation(entity.id, vZero);
			entity.vehicle:SetMovementMode(0)
			return true
		end
		return false;
	end
end

---@param oneOfSpeeds integer From sprint speed to slowest (from 3 to -2)
function OrderEntitySpeedOfAction(entity, oneOfSpeeds)
	g_SignalData.iValue = oneOfSpeeds;
	AI.Signal(SIGNALFILTER_SENDER, 0, "ACT_SPEED", entity.id, g_SignalData);
end

---@param seatIndex integer
---@param isFastIntFlag boolean
function EnterVehicle(entity, vehicle, seatIndex, isFastIntFlag)
	g_SignalData.fValue = seatIndex              --seatId, indexing starts from 1
	g_SignalData.id = vehicle.id                 --vehicleId
	g_SignalData.iValue2 = isFastIntFlag and 1 or 0 --fast flag
	AI.Signal(SIGNALFILTER_SENDER, 0, "ACT_ENTERVEHICLE", entity.id, g_SignalData);
end

function ExitVehicle(entity)
	AI.Signal(SIGNALFILTER_SENDER, 1, "EXIT_VEHICLE_STAND", entity.id)
end

function SetGunnerIgnorant(vehicle, ignorantOneOrZero)
	for i, seat in pairs(vehicle.Seats) do
		if (seat.passengerId) then
			local member = System.GetEntity(seat.passengerId);
			if (member ~= nil) then
				if (not seat.isDriver and seat.seat:GetWeaponCount() > 0) then
					AI.SetIgnorant(member.id, ignorantOneOrZero);
					HUD.DrawStatusText("Ignorant set to " .. tostring(ignorantOneOrZero))
				end
			end
		end
	end
end

function ValidateWeaponAttachment(entity, weaponClass,attachmentClass)
	local itemId = entity.inventory:GetItemByClass(weaponClass);
	  if (itemId) then
		local item = System.GetEntity(itemId);
		local att = entity.inventory:GetItemByClass(attachmentClass);
		if(item and att) then
			local currWeapon = item.weapon;
			if(currWeapon and currWeapon:SupportsAccessory(attachmentClass)) then
				currWeapon:AttachAccessory(attachmentClass,false,true);	-- force detach
				currWeapon:AttachAccessory(attachmentClass,true,true);	-- force attach
			end
		end
	end
  end

function AddWeaponAttachment(entity, weaponClass, attachmentClass)
	ItemSystem.GiveItem(attachmentClass, entity.id);

	ValidateWeaponAttachment(entity, weaponClass, attachmentClass)
end

-- Strange fix of unattached scopes and other items to visual of weapon *_*
function CheckWeaponAttachments(entity)
	if not entity.SelectPrimaryWeapon then
		return
	end

	entity:SelectSecondaryWeapon();
	entity:SelectPrimaryWeapon();

	local primaryWeapon = entity.primaryWeapon
	ValidateWeaponAttachment(entity, primaryWeapon,"Silencer");
	ValidateWeaponAttachment(entity, primaryWeapon,"Reflex");
	ValidateWeaponAttachment(entity, primaryWeapon,"AssaultScope");
	ValidateWeaponAttachment(entity, primaryWeapon,"SniperScope");
	ValidateWeaponAttachment(entity, primaryWeapon,"LAMRifle");
	ValidateWeaponAttachment(entity, primaryWeapon,"LAMRifleFlashLight");
	ValidateWeaponAttachment(entity, "SOCOM","LAM");
	ValidateWeaponAttachment(entity, "SOCOM","SOCOMSilencer");
	ValidateWeaponAttachment(entity, "SOCOM","LAMFlashLight");
end
