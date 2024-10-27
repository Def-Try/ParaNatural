local allowed 

if SERVER then
	allowed = CreateConVar("paranatural_levitation_allowed", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED)
end

hook.Add("GetFallDamage", "paranatural_levitation", function(ply, speed)
	if not ply:GetNWBool("paranatural_forcing") then return end
	ply:SetNWBool("paranatural_forcing", false)
	local ents_ = ents.FindInSphere(ply:GetPos(), 512)
	for _,ent in pairs(ents_) do
		if not IsValid(ent) then return end
		if ent == ply then continue end
		if IsValid(ent:GetPhysicsObject()) then
			for i=0,ent:GetPhysicsObjectCount()-1,1 do
				local dir = ent:GetPhysicsObjectNum(i):GetPos() - ply:GetPos()
				local dist = dir:Distance(Vector())
				dir:Normalize()
				ent:GetPhysicsObjectNum(i):AddVelocity(dir * (512 - dist) * 2)
			end
		end
		if not ent.TakeDamageInfo and not ent.TakePhysicsDamage then continue end
		local damageInfo = DamageInfo()
		damageInfo:SetDamage(speed / 8)
		damageInfo:SetDamageType(DMG_CRUSH)
		damageInfo:SetAttacker(ply)
		damageInfo:SetInflictor(ply)
		damageInfo:SetDamageForce(Vector(0, 0, speed * -100) + (ply:GetVelocity()))
			
		if ent.TakeDamageInfo then ent:TakeDamageInfo(damageInfo) end
		if ent.TakePhysicsDamage then ent:TakePhysicsDamage(damageInfo) end
	end
	ply:EmitSound("NPC_CombineBall.Explosion")
	util.Decal("Scorch", ply:GetPos()+Vector(0, 0, 1), Vector(0, 0, -1000), ents_)
	effects.BeamRingPoint(ply:GetPos(), 0.5, 12, 512, 64, 0, Color(255,255,225,64), {
		speed=0,
		spread=0,
		delay=0,
		framerate=2,
		material="sprites/lgtning.vmt"
	})
	return 0
end)

local function unlevitate(ply)
	if not IsFirstTimePredicted() then return end
	ply.paranatural_lv_reset = true
	ply.paranatural_lv_waslevitating = true
	ply:SetMoveType(MOVETYPE_WALK)
	ply:SetNWBool("paranatural_levitating", false)
	ply:StopSound("paranatural/levitation/loop.wav")
	ply:StopSound("paranatural/levitation/lower.wav")
end
local function levitate(ply)
	if not IsFirstTimePredicted() then return end
	ply.paranatural_lv_reset = false
	ply.paranatural_lv_waslevitating = false
	ply:SetMoveType(MOVETYPE_FLY)
	ply:SetNWBool("paranatural_levitating", true)
	ply:EmitSound("paranatural/levitation/loop.wav", 75, 100, 1, CHAN_STATIC)
end

hook.Add("CalcMainActivity", "paranatural_calcactivity_levitation", function(ply, vel)
	if ply:GetNWBool("paranatural_levitating") or ply:GetNWBool("paranatural_slowfall") then
		return ACT_HL2MP_SWIM, -1
	end
end)

hook.Add("SetupMove", "paranatural_levitation", function(ply, mv)
	if ply:IsOnGround() then
		ply:StopSound("paranatural/levitation/loop.wav")
	end
	if ply:IsOnGround() and ply:GetNWBool("paranatural_forcing") then
		ply:SetNWBool("paranatural_forcing", false)
	end
	if ply:GetNWBool("paranatural_forcing") then return end
	if ply:IsOnGround() and ply:GetNWBool("paranatural_slowfall") then
		ply:SetNWBool("paranatural_slowfall", false)
	end
	if ply:IsOnGround() and (ply.paranatural_lv_waslevitating or not ply.paranatural_lv_reset) then
		ply:SetMoveType(MOVETYPE_WALK)
		ply:SetNWBool("paranatural_slowfall", false)
		unlevitate(ply)
		ply.paranatural_lv_waslevitating = false
		ply.paranatural_lv_reset = true
	end
	if CLIENT then
		--print(ply:GetNWBool("paranatural_levitating"))
		if not ply:GetNWBool("paranatural_levitating") then
			if ply.paranatural_lv_reset then return end
			return unlevitate(ply)
		end
		if ply:GetNWBool("paranatural_levitating") and ply.paranatural_lv_reset then
			levitate(ply)
		end
	else
		if ply:GetInfoNum("paranatural_levitation_enable", 1) ~= 1 or not allowed:GetBool() and not ply:IsAdmin() then
			if ply.paranatural_lv_reset then return end
			return unlevitate(ply)
		end
	end

	if not ply.paranatural_lv_reset and ply:IsOnGround() then
		return unlevitate(ply)
	end

	if mv:KeyPressed(IN_DUCK) and ply:GetNWBool("paranatural_levitating") then
		ply:SetNWBool("paranatural_forcing", true)

		local dir = ply:GetAimVector()
		if dir:Dot(vector_up) > -0.30 then
			dir = -dir
		end
		unlevitate(ply)
		mv:SetVelocity(dir * 1000)
		return
	end

	if mv:KeyPressed(IN_JUMP) then
		if mv:GetVelocity().z < -25 then
			ply.paranatural_lv_waslevitating = true
		end
		if ply:IsOnGround() then return end
		if ply.paranatural_lv_waslevitating then
			if ply:GetMoveType() == MOVETYPE_WALK and ply.paranatural_lv_reset then
				if IsFirstTimePredicted() then
					ply.paranatural_lv_reset = false
				end
				ply:SetNWBool("paranatural_slowfall", true)
				ply:EmitSound("paranatural/levitation/lower.wav", 75, 100, 1, CHAN_STATIC)
			elseif ply:GetNWBool("paranatural_slowfall") then
				if IsFirstTimePredicted() then
					ply.paranatural_lv_reset = true
				end
				ply:SetNWBool("paranatural_slowfall", false)
				ply:StopSound("paranatural/levitation/lower.wav")
			end
			return
		end
		if not ply.paranatural_lv_reset then
			return unlevitate(ply)
		end
		return levitate(ply)
	end
	if ply:GetNWBool("paranatural_slowfall") then
		local vel = mv:GetVelocity()
		vel.z = math.Approach(vel.z, math.max(-250, vel.z+5), 25)
		mv:SetVelocity(vel)
		return
	end
	if not ply.paranatural_lv_reset then
		local vel = mv:GetVelocity()
		local fwd, sde = mv:GetAngles():Forward(), mv:GetAngles():Right()
		local mul = 1
		local mov = Vector()
		if mv:KeyDown(IN_JUMP) then
			mov.z = 250
		else
			mov.z = 0
		end
		if mv:KeyDown(IN_SPEED) then mul = 2 end
		if mv:KeyDown(IN_FORWARD) then
			mov.x = mov.x + fwd.x * 250 * mul
			mov.y = mov.y + fwd.y * 250 * mul
			mov.z = mov.z + fwd.z * 250 * mul
		end
		if mv:KeyDown(IN_BACK) then
			mov.x = mov.x + fwd.x * 250 * -mul
			mov.y = mov.y + fwd.y * 250 * -mul
			mov.z = mov.z + fwd.z * 250 * -mul
		end
		if mv:KeyDown(IN_MOVELEFT) then
			mov.x = mov.x + sde.x * 250 * -mul
			mov.y = mov.y + sde.y * 250 * -mul
			mov.z = mov.z + sde.z * 250 * -mul
		end
		if mv:KeyDown(IN_MOVERIGHT) then
			mov.x = mov.x + sde.x * 250 * mul
			mov.y = mov.y + sde.y * 250 * mul
			mov.z = mov.z + sde.z * 250 * mul
		end

		vel.x = math.Approach(vel.x, mov.x, 5)
		vel.y = math.Approach(vel.y, mov.y, 5)
		vel.z = math.Approach(vel.z, mov.z, 5)
		mv:SetVelocity(vel)
	end
end)