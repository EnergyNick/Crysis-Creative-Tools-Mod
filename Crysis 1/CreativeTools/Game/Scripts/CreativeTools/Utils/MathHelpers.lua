Script.ReloadScript("Scripts/Utils/Math.lua");

function VectorToString(vector)
	return "x="..tostring(vector.x).." y="..tostring(vector.y).." z="..tostring(vector.z)
end

function GetFirstEmptyIndexFromOne(array)
	local index = 1
	for key, _ in pairs(array) do
		if key - index >= 1 then
			return index
		end
		index = index + 1
	end
	return index
end

function GetLengthBetweenPositions(first, second)
	local diff = {};
	CopyVector( diff, first );
	SubVectors( diff, diff, second);
	return LengthVector( diff );
end

function GetLengthBetweenPositionsOnXY(first, second)
	local diff = {};
	CopyVector( diff, first );
	SubVectors( diff, diff, second);
	diff.z = 0
	return LengthVector( diff );
end

function GetLengthBetweenEntities(startEntity, endEntity)
	return GetLengthBetweenPositions(startEntity:GetPos(), endEntity:GetPos());
end

function SubVectorsNormalized(first, second)
	local result = {};
	SubVectors(result, first, second);
	NormalizeVector(result)
	return result;
end

function SubVectorsNormalizedOnXY(first, second)
	local result = {};
	SubVectors(result, first, second);
	result.z = 0
	NormalizeVector(result)
	return result;
end

function GetPointNearTargetPosition(sourcePosition, targetPosition, distanceNearTarget)
	local direction = {};
	local result = {};

	SubVectors(direction, targetPosition, sourcePosition)
	local length = LengthVector(direction)

	NormalizeVector(direction)
	ScaleVectorInPlace(direction, math.max(length - distanceNearTarget, distanceNearTarget));

	FastSumVectors(result, sourcePosition, direction)
	return result;
end

function GetFarthestValidPositionOnDistanceWithTerrainOffset(sourceEntity, direction, distance, zOffset, voidRadiusToStart)
	local sourceWithZOffset = {}
	CopyVector(sourceWithZOffset, sourceEntity:GetPos())
	InPlaceVectorApplyTerrainOffset(sourceWithZOffset, zOffset)

	local iterationStep = distance * 0.1
	local currentDistance = distance
	local vPeak = {}
	while currentDistance > 30 do
		local positionToSpawn = GetPositionOnDistanceWithTerrainOffset(sourceEntity:GetPos(), direction, currentDistance, zOffset)

		CopyVector(vPeak, AI.IsFlightSpaceVoidByRadius(positionToSpawn, direction, voidRadiusToStart or 15));
		Log("Current space vector is %s", VectorToString(vPeak))
		if (LengthVector(vPeak) < 0.001 or positionToSpawn.z - vPeak.z > 5) then
			return positionToSpawn
		 end

		currentDistance = currentDistance - iterationStep
	end

	return nil
end

function GetPositionOnDistanceWithTerrainOffset(sourcePosition, direction, distance, zOffset)
	local dirVectorScaled = {}
	CopyVector(dirVectorScaled, direction)
	ScaleVectorInPlace(dirVectorScaled, distance);

	local result = {};
	FastSumVectors(result, sourcePosition, dirVectorScaled)
	InPlaceVectorApplyTerrainOffset(result, zOffset)
	return result;
end

function GetPositionWithTerrainOffset(sourcePosition, zOffset)
	local result = {};
	CopyVector(result, sourcePosition)
	InPlaceVectorApplyTerrainOffset(result, zOffset)
	return result;
end

function InPlaceVectorApplyTerrainOffset(position, zOffset)
	-- math.max used for fix, when elevation in 0 coordinates
	position.z = math.max(System.GetTerrainElevation(position) + zOffset, position.z)
end

function IsEntityRotatedXYToTargetMoreThan(entity, targetPosition, angleInDegree)
	local vEntityDir = {}
	CopyVector(vEntityDir, entity:GetDirectionVector(1));
	vEntityDir.z = 0;
	NormalizeVector(vEntityDir);

	local directionToTarget = SubVectorsNormalizedOnXY(targetPosition, entity:GetPos())
	-- NormalizeVector(directionToTarget)

	local prod1 = dotproduct3d(vEntityDir, directionToTarget)
	local ang2 = math.cos(3.1416 * (angleInDegree * 1.0) / 180.0)
	-- Log("Tar: %f <= %f", prod1, ang2)
	return prod1 <= ang2
end

function IsEntityXYDirectionRotatedMoreThan(entity, targetDirection, angleInDegree)
	local vEntityDir = {}
	CopyVector(vEntityDir, entity:GetDirectionVector(1));
	vEntityDir.z = 0;
	NormalizeVector(vEntityDir);

	local prod1 = dotproduct3d(vEntityDir, targetDirection)
	local ang2 = math.cos(3.1416 * (angleInDegree * 1.0) / 180.0)
	-- Log("Rot: %f <= %f", prod1, ang2)
	return prod1 <= ang2
end