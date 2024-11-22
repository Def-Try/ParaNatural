local allowed = CreateConVar("paranatural_dash_allowed", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED)

if CLIENT then
	CreateClientConVar("paranatural_dash_key", "12", true, true) -- default key: B
end

hook.Add("PlayerShouldTakeDamage", "paranatural_dash", function(ply, attacker)
	if ply:GetNWFloat("paranatural_dashing", -1) < 0 then return end
	if ply == attacker then return false end
	attacker:TakeDamage(100, ply, ply)
	if not attacker:IsNPC() and not attacker:IsPlayer() then
		return false
	end
end)

hook.Add("ShouldCollide", "paranatural_dash", function(ent1, ent2)
	local ply, ent = nil, nil
	if ent1:GetNWFloat("paranatural_dashing", -1) > 0 then ply, ent = ent1, ent2 end
	if ent2:GetNWFloat("paranatural_dashing", -1) > 0 then ply, ent = ent2, ent1 end
	if not IsValid(ply) then return end
	if not ent.TakeDamage then return end
	local _1, _2, _3 = util.IntersectRayWithOBB(ply:GetShootPos(), ply:GetVelocity():GetNormal() * 500, ent:GetPos() + ent:OBBCenter(), ent:GetAngles(), ent:OBBMins(), ent:OBBMaxs())
	if _1 == nil and _2 == nil and _3 == nil then return end
	timer.Simple(0, function() ent:TakeDamage(100, ply, ply) end)
end)

hook.Add("CalcMainActivity", "paranatural_calcactivity_dash", function(ply, vel)
	if ply:GetNWFloat("paranatural_dashing", -1) > 0 then
		return ACT_HL2MP_SWIM, -1
	end
end)

hook.Add("PlayerButtonDown", "paranatural_dash", function(ply, button)
	if not allowed:GetBool() and not ply:IsAdmin() then return end
	if ply:GetInfoNum("paranatural_dash_enable", 1) ~= 1 then return end
	if button ~= ply:GetInfoNum("paranatural_dash_key", 12) then return end
	if not IsFirstTimePredicted() then return end
	if ply.paranatural_dashing_colset then return end
	ply:SetNWFloat("paranatural_dashing", CurTime())
	local wasccc = ply:GetCustomCollisionCheck()
	local ang = ply:EyeAngles()
	local friction = ply:GetFriction()
	ang.pitch = 0
	local dir = ang:Forward()
	local ply2 = GetPredictionPlayer()
	if IsValid(ply2) then
		local cmd = ply2:GetCurrentCommand()
		local dir2 = (cmd:GetForwardMove() * ang:Forward() + cmd:GetSideMove() * ang:Right()):GetNormalized()
		if dir2 ~= Vector() then dir = dir2 end
	end
	dir.z = 0
	ply:SetVelocity(dir * 1000)
	ply:SetFriction(0)
	ply.paranatural_dashing_fricset = friction
	ply:SetFOV(ply:GetFOV()+5, 0)
	ply.paranatural_dashing_fovset = true
	ply:SetCustomCollisionCheck(true)
	ply.paranatural_dashing_colset = wasccc

	if not ply.m_OldCollisionGroup then ply.m_OldCollisionGroup = ply:GetCollisionGroup() end
	ply:SetCollisionGroup(ply.m_OldCollisionGroup == COLLISION_GROUP_DEBRIS and COLLISION_GROUP_WORLD or COLLISION_GROUP_DEBRIS)
	ply:SetCollisionGroup(ply.m_OldCollisionGroup)
	ply.m_OldCollisionGroup = nil

	if SERVER and IsFirstTimePredicted() then
		ply:EmitSound("paranatural/dash/whoosh" .. math.random(1, 3) .. ".wav", 75, 100, 1, CHAN_STATIC)
	end
end)

hook.Add("SetupMove", "paranatural_dash", function(ply)
	if ply.paranatural_dashing_colset == nil then return end
	--if not IsFirstTimePredicted() then return end
	local time = ply:GetNWFloat("paranatural_dashing", -1)
	if ply.paranatural_dashing_fovset and CurTime() - time > 0.1 then
		ply:SetFOV(0, 0.2)
		ply.paranatural_dashing_fovset = false
	end
	if ply.paranatural_dashing_fricset and CurTime() - time > 0.2 then
		ply:SetFriction(ply.paranatural_dashing_fricset)
		ply.paranatural_dashing_fricset = false
		ply:SetNWFloat("paranatural_dashing", -1)
	end
	if ply.paranatural_dashing_colset and CurTime() - time > 0.5 then
		ply:SetCustomCollisionCheck(ply.paranatural_dashing_colset)
		if not ply.m_OldCollisionGroup then ply.m_OldCollisionGroup = ply:GetCollisionGroup() end
		ply:SetCollisionGroup(ply.m_OldCollisionGroup == COLLISION_GROUP_DEBRIS and COLLISION_GROUP_WORLD or COLLISION_GROUP_DEBRIS)
		ply:SetCollisionGroup(ply.m_OldCollisionGroup)
		ply.m_OldCollisionGroup = nil
		ply.paranatural_dashing_colset = false
	end
end)