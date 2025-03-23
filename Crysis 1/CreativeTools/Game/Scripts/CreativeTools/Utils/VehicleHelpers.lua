Script.ReloadScript("Scripts/CreativeTools/Utils/MathHelpers.lua");

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
				-- member.actor:SetHealth(0);
				-- member:HealthChanged();
			end
		end
	end
end

function DisablePhysicsAndLaterEnabledWithUpPush(vehicle, delay)
	vehicle:EnablePhysics(false);
	--  void SetMovementTarget(const Vec3 &position,const Vec3 &looktarget,const Vec3 &up,float speed) {};
	-- entity.actor:SetMovementTarget( alignPos, alignLookAt,{x=0,y=0,z=0},1 );
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
	-- g_SignalData.iValue = -1244 		-- random pipe id
	-- g_SignalData.iValue2 = 1 		--fast flag (?)
	-- AI.Signal(SIGNALFILTER_SENDER,0,"ACT_EXITVEHICLE",entity.id,g_SignalData);
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