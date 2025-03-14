Script.ReloadScript("Scripts/Utils/Math.lua");

function VectorToString(vector)
	return "x="..tostring(vector.x).." y="..tostring(vector.y).." z="..tostring(vector.z)
end

---------------------------------------------------------------------------------------------------------
-- Math functions

function GetLengthBetweenPositions(first, second)
	local diff = g_Vectors.temp_v1;
	CopyVector( diff, first );
	SubVectors( diff, diff, second);
	return LengthVector( diff );
end

function GetLengthBetweenPositionsOnXY(first, second)
	local diff = g_Vectors.temp_v1;
	CopyVector( diff, first );
	SubVectors( diff, diff, second);
	diff.z = 0
	return LengthVector( diff );
end

function GetLengthBetweenEntities(startEntity, endEntity)
	return GetLengthBetweenPositions(startEntity:GetPos(), endEntity:GetPos());
end

function GetPointNearTargetPosition(sourcePosition, targetPosition, distanceNearTarget)
	local direction = g_Vectors.temp_v1;
	local result = {};

	SubVectors(direction, targetPosition, sourcePosition)
	local length = LengthVector(direction)

	NormalizeVector(direction)
	ScaleVectorInPlace(direction, math.max(length - distanceNearTarget, distanceNearTarget));

	FastSumVectors(result, sourcePosition, direction)
	return result;
end

function GetPositionWithTerrainOffset(sourcePosition, direction, distance, zOffset)
	local dirVectorScaled = g_Vectors.temp_v1
	CopyVector(dirVectorScaled, direction)
	ScaleVectorInPlace(dirVectorScaled, distance);

	local result = {};
	FastSumVectors(result, sourcePosition, dirVectorScaled)
	InPlaceVectorApplyTerrainOffset(result, zOffset)
	return result;
end

function InPlaceVectorApplyTerrainOffset(position, zOffset)
	position.z = System.GetTerrainElevation(position) + zOffset
end

function TargetObstacleCheck(entity, targetPoint)

	local vSrc ={};
	local vDst ={};
	local vTmp ={};

	CopyVector( vSrc, entity:GetPos() );
	CopyVector( vDst, targetPoint );

	SubVectors( vTmp, vDst, vSrc );
	vTmp.z =0;

	if ( LengthVector(vTmp) > 120.0 ) then
		return true;
	end

	if ( vSrc.z - vDst.z < 5.0 ) then
		return true;
	end

	local entities = System.GetPhysicalEntitiesInBox( vDst , 10.0 );

	if (entities) then

		for i,targetEntity in ipairs(entities) do
			local objEntity = targetEntity;
			if (objEntity.id ~= entity.id ) then
				local bbmin,bbmax = objEntity:GetLocalBBox();
				if ( DistanceVectors( bbmin , bbmax ) >  3.0 or objEntity:GetMass() > 300.0 ) then
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
	for i,seat in pairs(vehicle.Seats) do
		if (seat.seat:GetWeaponCount() > 0 and not seat.isDriver) then
			if (seat.enterHelper and seat:IsFree()) then
				return i;
			end
		end
	end

	for i,seat in pairs(vehicle.Seats) do

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

	for i,seat in pairs(vehicle.Seats) do
		if(seat.passengerId) then
			local member = System.GetEntity( seat.passengerId );
			if( member ~= nil ) then
				if (seat.isDriver) then
					-- when a passenger is the driver.
				elseif ( seat.seat:GetWeaponCount() > 0) then
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
	for i,seat in pairs(vehicle.Seats) do
		if(seat.passengerId) then
			local member = System.GetEntity(seat.passengerId);
			if( member ~= nil ) then
				member.actor:SetHealth(0);
				member:HealthChanged();
			end
		end
	end
end

function GetFirstPassengerEntityFromVehicle(vehicle)
	for i,seat in pairs(vehicle.Seats) do
		if(seat.passengerId) then
			local member = System.GetEntity( seat.passengerId );
			if( member ~= nil ) then
				if (seat.isDriver) then
					-- when a passenger is the driver.
				elseif ( seat.seat:GetWeaponCount() > 0) then
					-- when a passenger is the gunner.
				else
					-- this guy should be a reinforcement.
					if (not member:IsDead()) then
						return member
					end
				end
			end
		end
	end

	return nil
end

function DisablePhysicsAntLaterEnabledWithUpPush(vehicle, delay)
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

function TakeoffAirVehicle(vehicle)
	vehicle.vehicle:DisableEngine(0);

	local direction = g_Vectors.temp_v1;
	direction.z = 15

	vehicle.vehicle:CloseAutomaticDoors();
	AI.SetForcedNavigation(vehicle.id, direction);

	Script.SetTimer(6000, function(ent)
		AI.SetForcedNavigation(ent.id, g_Vectors.v000)
	end, vehicle)
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
function OrderEntitySpeedOfAction(entity, oneOfSpeeds)
	g_SignalData.iValue = oneOfSpeeds;
	AI.Signal(SIGNALFILTER_SENDER, 1, "ACT_SPEED", entity.id, g_SignalData);
end

---@param seatIndex integer
---@param isFastIntFlag boolean
function EnterVehicle(entity, vehicle, seatIndex, isFastIntFlag)
	g_SignalData.fValue = seatIndex	--seatId, indexing starts from 1
	g_SignalData.id = vehicle.id 	--vehicleId
	g_SignalData.iValue2 = isFastIntFlag and 1 or 0 		--fast flag
	AI.Signal(SIGNALFILTER_SENDER,0,"ACT_ENTERVEHICLE",entity.id,g_SignalData);
end

function ExitVehicle(entity)
    AI.Signal(SIGNALFILTER_SENDER, 1, "EXIT_VEHICLE_STAND", entity.id)
end
