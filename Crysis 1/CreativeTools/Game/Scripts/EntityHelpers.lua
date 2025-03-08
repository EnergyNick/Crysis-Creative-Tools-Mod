Script.ReloadScript("Scripts/Utils/Math.lua");


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

function GetLengthBetweenEntities(startEntity, endEntity)
	local diff = g_Vectors.temp_v1;
	CopyVector( diff, endEntity:GetPos() );
	SubVectors( diff, diff, startEntity:GetPos());
	return LengthVector( diff );
end

function CoordinateToFollow(source, follower, distance)
	local diff = g_Vectors.temp_v1;
	local result = g_Vectors.temp_v3;

	CopyVector(diff, follower:GetPos());
	SubVectors(diff, diff, source:GetPos());
	local len = LengthVector( diff );

	ScaleVectorInPlace(diff, math.min(distance/len, 1));
	FastSumVectors(result, source:GetPos(), diff);
	return result;
end

function OrderEntityGoToPosition(entity, positionVector)
	local followerPos = entity:GetPos()
	CopyVector(g_SignalData.point, positionVector);
	g_SignalData.point.z = followerPos.z

	g_SignalData.iValue = 1;
	AI.Signal(SIGNALFILTER_SENDER, 1, "ACT_GOTO", entity.id, g_SignalData);
end

-- from sprint to slowest (from 3 to -2)
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
	g_SignalData.iValue = -1244 		-- random pipe id
	g_SignalData.iValue2 = 1 		--fast flag (?)
	AI.Signal(SIGNALFILTER_SENDER,0,"ACT_EXITVEHICLE",entity.id,g_SignalData);
end
