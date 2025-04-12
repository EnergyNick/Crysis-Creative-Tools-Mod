Script.ReloadScript("Scripts/common.lua");
Script.ReloadScript("Scripts/CreativeTools/Tools/SpawnTool.lua");
Script.ReloadScript("Scripts/CreativeTools/Tools/ReinforcementsTool.lua");
Script.ReloadScript("Scripts/CreativeTools/GlobalActions.lua");


function Player:OnActionCreativeTools(action, activation)

    -- if action ~= "v_rotatedir" then
    --     Log("Act: %q Mode: %q", action, activation) -- v_horn
    -- end

    if self:IsUsingSpawnToolNow() then
        -- TODO: Remove after tests
        -- if action == "use" then
        --     local save = {}
        --     self:OnSaveCreativeTools(save)
        --     dump(save)
        --     self.debugSave = save
        -- end
        local spawnTool = self:GetOrInitSpawnTool()
        spawnTool:OnAction(action, activation)

    elseif self:IsUsingReinforcementsToolNow() then
        local reinforcementTool = self:GetOrInitReinforcementsTool()
        reinforcementTool:OnAction(action, activation)
    else
        InvokeGlobalActions(self, action, activation)
    end
end

function Player:OnSaveCreativeTools(save)
    local spawnTool = self:GetSpawnTool()
    if spawnTool then
        spawnTool:OnSave(save)
    end

    local reinforcementTool = self:GetReinforcementsTool()
    if reinforcementTool then
        reinforcementTool:OnSave(save)
    end

    SaveCustomBehaviorManagers(self, save)
end


function Player:OnLoadCreativeTools(saved)
    self.debugSave = saved
    saved.enableSaveRetry = true
    local data = {
        player = self,
        saved = saved
    }

    -- Use for wait to initialize all other and run actions after all for safety and log readability purposes
    Script.SetTimer(1500, function (data)
        local spawnTool = data.player:GetOrInitSpawnTool()
        if spawnTool then
            spawnTool:OnLoad(data.saved)
        end

        local reinforcementTool = data.player:GetOrInitReinforcementsTool()
        if reinforcementTool then
            reinforcementTool:OnLoad(data.saved)
        end

        LoadCustomBehaviorManagers(data.player, data.saved)

        if data.saved.extendPowersEnable and data.saved.extendPowersEnable == 1 then
            InvokeExtendPower(1)
        end

        Log("Save load successfully")
    end, data)
end

function InvokeCreativeToolsCommand()
	System.ExecuteCommand("i_giveitem SpawnTool")
	System.ExecuteCommand("i_giveitem ReinforcementsTool")
end

function InvokeExtendPower(isActive)
    if not isActive or (isActive == 1 or isActive == 0) then
        HUD.DrawStatusText("Invalid arguments to call 'extend_power'")
        return
    end

    System.SetCVar("g_suitSpeedEnergyConsumption", 50);
    System.SetCVar("g_suitCloakEnergyDrainAdjuster", 0.4);
    System.SetCVar("g_suitArmorHealthValue", 350);
    System.SetCVar("g_suitRecoilEnergyCost", 8);
    System.SetCVar("g_playerHealthValue", 150);

    local player = System.GetEntityByName("Dude")
    player.extendPowersEnable = isActive

    HUD.DrawStatusText("[ Suit powers extended ]")
end


System.AddCCommand("creative_tools", "InvokeCreativeToolsCommand()", "Give creative tools mods special items")
System.AddCCommand("extend_power", "InvokeExtendPower(%1)", "Extend player powers to be more powerful, but balanced")