AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

include("spawn/spawn.lua")
function GM:TouchedStageTrigger(stage)
    print("we gucci stage "..stage)
    local position_ents = ents.FindByName("ac_enemyspawnpos_"..stage)
    for _, posent in pairs(position_ents) do
        local pos = posent:GetPos()
        GAMEMODE:SpawnRandomEnemy(pos)
    end
end
