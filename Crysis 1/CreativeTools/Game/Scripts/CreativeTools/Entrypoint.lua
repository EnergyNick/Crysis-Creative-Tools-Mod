Script.ReloadScript("Scripts/common.lua");
Script.ReloadScript("Scripts/CreativeTools/Tools/SpawnTool.lua");
Script.ReloadScript("Scripts/CreativeTools/Tools/ReinforcementsTool.lua");


function Player:OnActionCreativeTools(action)

    if self:IsUsingSpawnToolNow() then
        if action == "use" then
            local save = {}
            self:OnSaveCreativeTools(save)
            dump(save)
            self.debugSave = save
        end
        local spawnTool = self:GetOrInitSpawnTool()
        spawnTool:OnAction(action)
    elseif self:IsUsingReinforcementsToolNow() then
        local reinforcementTool = self:GetOrInitReinforcementsTool()
        reinforcementTool:OnAction(action)
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
        Log("Save load successfully")

        -- if data.player.extendPower then
            -- TODO extend power, if user request that previously
        -- end
    end, data)

end

function InvokeCreativeToolsCommand()
	System.ExecuteCommand("i_giveitem SpawnTool")
	System.ExecuteCommand("i_giveitem ReinforcementsTool")
end

function InvokeExtendPower()
    local player = System.GetEntityByName("Dude")
	System.ExecuteCommand("i_giveitem SpawnTool")
	System.ExecuteCommand("i_giveitem ReinforcementsTool")
end


System.AddCCommand("creative_tools", "InvokeCreativeToolsCommand()", "Give creative tools mods special items")
System.AddCCommand("extend_power", "InvokeExtendPower()", "Extend player powers to be more powerful, but balanced")