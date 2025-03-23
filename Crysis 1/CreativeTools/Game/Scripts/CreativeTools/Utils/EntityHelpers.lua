Script.ReloadScript("Scripts/CreativeTools/Utils/MathHelpers.lua");

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
	-- AI.SetSpeed(entity.id, 3)
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
