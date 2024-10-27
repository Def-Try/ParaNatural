function GM:SpawnEnemy_Zombie(pos)
    local npc = ents.Create("npc_zombie")
    npc:SetPos(pos)
    npc:SetAngles(Angle(0, math.random(-180, 180), 0))
    npc:Spawn()
    npc:SetColor(Color(26, 31, 48))
end