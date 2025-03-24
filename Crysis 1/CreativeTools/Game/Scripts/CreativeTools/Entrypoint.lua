Script.ReloadScript("Scripts/CreativeTools/Tools/SpawnTool.lua");
Script.ReloadScript("Scripts/CreativeTools/Tools/ReinforcementsTool.lua");


function Player:OnActionCreativeTools(action)
    if self:IsUsingSpawnToolNow() then
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

    local spawnTool = self:GetOrInitSpawnTool()
    if spawnTool then
        spawnTool:OnLoad(saved)
    end

    local reinforcementTool = self:GetOrInitReinforcementsTool()
    if reinforcementTool then
        reinforcementTool:OnLoad(saved)
    end

    LoadCustomBehaviorManagers(self, saved)
end

function InvokeCreativeToolsCommand()
	System.ExecuteCommand("i_giveitem SpawnTool")
	System.ExecuteCommand("i_giveitem ReinforcementsTool")
end

System.AddCCommand("creative_tools", "InvokeCreativeToolsCommand()", "Give items")
System.AddCCommand("extend_power", "InvokeCreativeToolsCommand()", "Give items")