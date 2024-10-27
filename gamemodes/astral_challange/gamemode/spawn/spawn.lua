include("enemies.lua")

local SpawnFunctions = {GM.SpawnEnemy_Zombie}

function GM:SpawnRandomEnemy(pos)
    return SpawnFunctions[math.random(1, #SpawnFunctions - 1)](GAMEMODE, pos)
end