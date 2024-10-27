GM.Name = "Astral Challange"
GM.Author = "googer_"
GM.Email = "N/A"
GM.Website = "N/A"

include("player_class/parautilitarian.lua")

function GM:Initialize()
    _G.PARANATURAL_WE_GUCCI = true -- lol
end

function GM:PlayerSpawn(ply, transition)
    player_manager.SetPlayerClass(ply, "parautilitarian")
    
	player_manager.OnPlayerSpawn(ply, transition)
	player_manager.RunClass(ply, "Spawn")

    if not transition then hook.Call("PlayerLoadout", GAMEMODE, ply) end

    hook.Call("PlayerSetModel", GAMEMODE, ply)

    ply:SetupHands()
end