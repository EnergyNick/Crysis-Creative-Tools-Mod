Script.ReloadScript("Scripts/CreativeTools/Tools/SpawnTool.lua");
Script.ReloadScript("Scripts/CreativeTools/Tools/ReinforcementsTool.lua");


function Player:OnActionCreativeTools(action)
    if self:IsUsingSpawnToolNow() then
        local spawnGun = self:GetOrInitSpawnTool()
        spawnGun:OnAction(action)
    end
end

function InvokeCreativeToolsCommand()
	System.ExecuteCommand("i_giveitem SpawnTool")
	System.ExecuteCommand("i_giveitem ReinforcementsTool")
end

System.AddCCommand("creative_tools", "InvokeCreativeToolsCommand()", "Give items")
System.AddCCommand("extend_power", "InvokeCreativeToolsCommand()", "Give items")