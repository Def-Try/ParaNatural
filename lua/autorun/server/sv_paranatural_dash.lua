hook.Add("PlayerShouldTakeDamage", "paranatural_dash", function(ply, attacker)
	if not ply.paranatural_dashing then return end
	if ply == attacker then return false end
	attacker:TakeDamage(100, ply, ply)
	if not attacker:IsNPC() and not attacker:IsPlayer() then
		return false
	end
end)

hook.Add("ShouldCollide", "paranatural_dash", function(ent1, ent2)
	if checking_SHOULDCOLLIDE then return end
	local ply, ent = nil, nil
	if ent1.paranatural_dashing then ply, ent = ent1, ent2 end
	if ent2.paranatural_dashing then ply, ent = ent2, ent1 end
	if not IsValid(ply) then return end
	local _1, _2, _3 = util.IntersectRayWithOBB(ply:GetShootPos(), ply:GetVelocity():GetNormal() * 500, ent:GetPos() + ent:OBBCenter(), ent:GetAngles(), ent:OBBMins(), ent:OBBMaxs())
	if _1 == nil and _2 == nil and _3 == nil then return end
	ent:TakeDamage(100, ply, ply)
end)

hook.Add("Think", "paranatural_dash", function()
	for _,ply in player.Iterator() do
		if not ply.paranatural_ds_control then return end
		if ply.paranatural_dashing then return end
		ply.paranatural_ds_control = false
		local ang = ply:EyeAngles()
		ang.pitch = 0
		ply:SetVelocity(ang:Forward() * 1000)
		local friction = ply:GetFriction()
		ply:SetFriction(0)
		ply:SetFOV(ply:GetFOV()+5, 0.1)
		timer.Simple(0.1, function()
			ply:SetFOV(0, 0.2)
		end)
		ply.paranatural_dashing = true
		local wasccc = ply:GetCustomCollisionCheck()
		ply:SetCustomCollisionCheck(true)
		ply:EmitSound("paranatural/dash/whoosh" .. math.random(1, 3) .. ".wav", 75, 100, 1, CHAN_STATIC)
		timer.Simple(0.2, function()
			ply:SetFriction(friction)
			timer.Simple(0.3, function()
				ply:SetCustomCollisionCheck(wasccc)
				ply.paranatural_dashing = false
			end)
		end)
	end
end)