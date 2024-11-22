local allowed 

if CLIENT then
	CreateClientConVar("paranatural_telekinesis_key", "30", true, true) -- default key: T
end
if SERVER then
	allowed = CreateConVar("paranatural_telekinesis_allowed", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED)
end

hook.Add("EntityRemoved", "paranatural_telekinesis", function(ent)
	if CLIENT then return end
	ent:StopSound("paranatural/telekinesis/loop.wav")
end)

local function no(ply)
	return ply:EmitSound("paranatural/telekinesis/drop.wav", 75, 100, 1, CHAN_STATIC)
end

local allowed_npcs = {
	["npc_manhack"] = true,
	["npc_turret_floor"] = true,
	["npc_sscanner"] = true,
	["npc_cscanner"] = true,
	["npc_clawscanner"] = true,
	["npc_rollermine"] = true
}

local function grab(ply, ent)
	local ok = false
	if allowed_npcs[ent:GetClass()] then ok = true end
	if not ok and (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) then
		if ent:Health() / ent:GetMaxHealth() < 0.5 then
			ok = true
			local pos = ent:GetPos()
			local ents1 = table.Flip(ents.FindInSphere(pos, 50))
			local dmg = DamageInfo()
				dmg:SetDamage(ent:Health() + 1)
				dmg:SetAttacker(ply)
				dmg:SetInflictor(ply)
				dmg:SetDamageType(DMG_PHYSGUN)
			ent:TakeDamageInfo(dmg)
			for _,ent2 in pairs(ents.FindInSphere(pos, 50)) do
				if ents1[ent2] then continue end
				if ent2:GetClass() == "prop_ragdoll" then ent = ent2 break end
			end
		end
	end
	if not ok and hook.Run("PhysgunPickup", ply, ent) then ok = true end
	if not ok and IsValid(ent:GetPhysicsObject()) and ent:GetPhysicsObject():IsMotionEnabled() then ok = true end
	if not ok then
		local mins, maxs = ent:GetModelBounds()
		local size = math.max(maxs.x - mins.x, maxs.y - mins.y, maxs.z - mins.z) * 0.5
		if size < 300 then ok = true end
	end

	if not ok then return no(ply) end

	local entities = ply.paranatural_tk_entities

	ent:SetOwner(ply)
	ent:EmitSound("paranatural/telekinesis/loop.wav")
	ply:EmitSound("paranatural/telekinesis/grab.wav", 75, 100, 1, CHAN_STATIC)
	entities[#entities+1] = ent
	ent.paranatural_tk_grabbed = CurTime()
	ent.paranatural_tk_toofar = nil
	ent.paranatural_tk_hadgravity = ent:GetPhysicsObject():IsGravityEnabled()
	for n=0,ent:GetPhysicsObjectCount()-1 do
		local phys = ent:GetPhysicsObjectNum(n)
		phys:EnableGravity(false)
		phys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
		phys:SetAngleVelocity(VectorRand(-180, 180))
	end
end

local function release(ply, ent)
	ent = ent or ply.paranatural_tk_entities[#ply.paranatural_tk_entities]
	for k,v in pairs(ply.paranatural_tk_entities) do
		if v ~= ent then continue end
		ply.paranatural_tk_entities[k] = nil
		break
	end
	
	if not IsValid(ent) then return end
	if not IsValid(ent:GetPhysicsObject()) then return end

	for n=0,ent:GetPhysicsObjectCount()-1 do
		local phys = ent:GetPhysicsObjectNum(n)
		phys:EnableGravity(ent.paranatural_tk_hadgravity)
		phys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
	end
	ent:SetOwner(NULL)
	ent:StopSound("paranatural/telekinesis/loop.wav")
	ent.paranatural_tk_toofar = nil
	ent.paranatural_tk_grabbed = nil
	ent.paranatural_tk_hadgravity = nil
end

local function collapse_table(t)
	local new_table = {}
	local index = 1
	for k, v in pairs(t) do
		new_table[index] = v
		index = index + 1
	end
	return new_table
end

hook.Add("PlayerButtonDown", "paranatural_telekinesis", function(ply, button)
	if CLIENT then return end
	if not IsFirstTimePredicted() then return end
	if ply:GetNWBool("paranatural_shielded") then return end
	if not allowed:GetBool() and not ply:IsAdmin() then return end
	if button == ply:GetInfoNum("paranatural_telekinesis_key", 30) then
		ply.paranatural_tk_entities = collapse_table(ply.paranatural_tk_entities or {})
		local entities = ply.paranatural_tk_entities
		
		ply:LagCompensation(true)
		local ent = ply:GetEyeTrace().Entity
		ply:LagCompensation(false)
		if not IsValid(ent) then
			if #entities <= 0 then return no(ply) end
			if #entities == 1 then
				if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "paranatural_telekinetic" then
					ply:SelectWeapon(ply.paranatural_wasactiveweapon)
					ply.paranatural_wasactiveweapon = nil
				end
				ply:StripWeapon("paranatural_telekinetic")
			end
			ply:EmitSound("paranatural/telekinesis/ungrab.mp3", 75, 100, 1, CHAN_STATIC)
			return release(ply)
		end
		if #entities >= 3 then return no(ply) end
		if ent.paranatural_tk_grabbed then return no(ply) end
		if not IsValid(ply:GetWeapon("paranatural_telekinetic")) then
			ply:Give("paranatural_telekinetic")
			ply.paranatural_wasactiveweapon = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() or ""
			ply:SelectWeapon("paranatural_telekinetic")
		end
		return grab(ply, ent)
	end

	if button == 107 then -- throwing
		if not IsValid(ply:GetActiveWeapon()) then return end
		if ply:GetActiveWeapon():GetClass() ~= "paranatural_telekinetic" then return end
		ply.paranatural_tk_entities = collapse_table(ply.paranatural_tk_entities or {})
		local entities = ply.paranatural_tk_entities
		if #entities <= 0 then return no(ply) end
		for _, ent in pairs(entities) do
			if not IsValid(ent) then continue end
			ent:SetOwner(NULL)
			timer.Simple(0.1*(_ - 1), function()
				ent:SetNWFloat("paranatural_tk_grabbed", -1)
				local d = (ply:GetEyeTrace().HitPos - ent:GetPos()):GetNormalized()
				for n=0,ent:GetPhysicsObjectCount()-1 do
					local phys = ent:GetPhysicsObjectNum(n)
					phys:SetVelocity(d * 32767 * 16 + ply:GetVelocity())
				end
				release(ply, ent)
				ent:SetPhysicsAttacker(ply, 10)
				ent:SetSaveValue("m_bFirstCollisionAfterLaunch", true)
				ply:EmitSound("paranatural/telekinesis/throw.mp3", 75, 100, 1, CHAN_STATIC)
				ent:StopSound("paranatural/telekinesis/loop.wav")
			end)
		end
		timer.Simple(0.3, function()
			if not IsValid(ply) then return end
			if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "paranatural_telekinetic" then
				ply:SelectWeapon(ply.paranatural_wasactiveweapon)
				ply.paranatural_wasactiveweapon = nil
			end
			ply:StripWeapon("paranatural_telekinetic")
		end)
	end
end)
hook.Add("Think", "paranatural_telekinesis", function()
	if CLIENT then return end
	for _,ply in pairs(player.GetAll()) do
		if ply:GetNWBool("paranatural_shielded") then continue end
		ply.paranatural_tk_entities = ply.paranatural_tk_entities or {}
		local entities = ply.paranatural_tk_entities
		if #entities <= 0 then continue end
		if ply:Alive() then continue end
		for k,ent in pairs(entities) do
			if not IsValid(ent) then continue end
			release(ply, ent)
			ply:SetNWEntity("paranatural_tk_entity_"..k, nil)
		end
	end
end)
hook.Add("SetupMove", "paranatural_telekinesis", function(ply, mv)
	if CLIENT then return end
	if not IsFirstTimePredicted() then return end
	if not allowed:GetBool() and not ply:IsAdmin() then 
		return release(ply)
	end
	ply.paranatural_tk_entities = ply.paranatural_tk_entities or {}
	local entities = {}
	for k,v in pairs(ply.paranatural_tk_entities) do
		if not IsValid(v) then
			ply.paranatural_tk_entities[k] = nil
			continue
		end
		entities[#entities+1] = v
	end
	local offsets = {}
	if #entities == 1 then offsets = {Vector(2, 2, 0)} end
	if #entities == 2 then offsets = {Vector(1, 2, 0), Vector(3, 2, 0)} end
	if #entities == 3 then offsets = {Vector(1, 2, -1), Vector(3, 2, -1), Vector(2, 2, 1)} end

	if #entities == 0 then
		if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "paranatural_telekinetic" then
			ply:SelectWeapon(ply.paranatural_wasactiveweapon)
			ply.paranatural_wasactiveweapon = nil
		end
		ply:StripWeapon("paranatural_telekinetic")
		return
	end

	for _, ent in pairs(entities) do
		if not IsValid(ent) then continue end
		if ent:GetInternalVariable("m_flDetonateTime") then
			ent:SetSaveValue("m_flDetonateTime", 1)
		end
		if CurTime() - ent.paranatural_tk_grabbed < 0.743 then
			local vel = Vector(0, 0, 200) * (0.743 - (CurTime() - ent.paranatural_tk_grabbed ))
			for n=0,ent:GetPhysicsObjectCount()-1 do
				local phys = ent:GetPhysicsObjectNum(n)
				phys:SetVelocity(ply:GetVelocity() * 0.5 + phys:GetVelocity() * 0.5 + vel * 0.5)
			end
			continue
		end
		local phys = ent:GetPhysicsObject()
		if not IsValid(phys) then continue end
		local ang = ply:EyeAngles()
		local hold = ply:EyePos()
		local size = 0
		do
			local mins, maxs = ent:GetModelBounds()
			size = math.max(maxs.x - mins.x, maxs.y - mins.y, maxs.z - mins.z) * 0.5
		end
		hold = hold + offsets[_].x * ang:Right() * (size + 10)
					+ offsets[_].y * ang:Forward() * (size + 10)
					+ offsets[_].z * ang:Up() * size

		if ent:GetPos():Distance(hold) > size * 4 then
			ent.paranatural_tk_toofar = ent.paranatural_tk_toofar or CurTime()
			if CurTime() - ent.paranatural_tk_toofar > 5 then
				if #entities == 1 then
					if ply:GetActiveWeapon():GetClass() == "paranatural_telekinetic" then
						ply:SelectWeapon(ply.paranatural_wasactiveweapon)
						ply.paranatural_wasactiveweapon = nil
					end
					ply:StripWeapon("paranatural_telekinetic")
				end
				release(ply, ent)
				ply:EmitSound("paranatural/telekinesis/drop.wav", 75, 100, 1, CHAN_STATIC)
				return
			end
		else
			ent.paranatural_tk_toofar = nil
		end

		local vel = (hold - phys:GetPos()) / 5

		local dang = (ply:EyeAngles() - phys:GetAngles())
		dang:Normalize()
		dang = Vector(dang.roll, dang.pitch, dang.yaw) * 10
		--phys:SetAngleVelocity(dang)
		local dist = (vel:Distance(Vector()))
		for n=0,ent:GetPhysicsObjectCount()-1 do
			local phys = ent:GetPhysicsObjectNum(n)
			phys:SetVelocity(ply:GetVelocity() * 0.5 + phys:GetVelocity() * 0.5 + vel * math.max(1, math.log((1 - dist) * (1 - dist) * 10)))
		end
	end
end)

do return end

hook.Add("PlayerButtonDown", "paranatural_telekinesis", function(ply, button)
	if ply:GetNWBool("paranatural_shielded") then return end
	if CLIENT then return end
	if not allowed:GetBool() and not ply:IsAdmin() then return end
	if not IsFirstTimePredicted() then return end
	if button == ply:GetInfoNum("paranatural_telekinesis_key", 30) then
		local idx = 1
		local entities = {
			ply:GetNWEntity("paranatural_tk_entity_1"),
			ply:GetNWEntity("paranatural_tk_entity_2"),
			ply:GetNWEntity("paranatural_tk_entity_3")
		}
		ply:LagCompensation(true)
		local ent = ply:GetEyeTrace().Entity
		ply:LagCompensation(false)
		if ent:GetNWFloat("paranatural_tk_grabbed", -1) > 0 then return end
		local allowed_npcs = {
			["npc_manhack"] = true,
			["npc_turret_floor"] = true,
			["npc_sscanner"] = true,
			["npc_cscanner"] = true,
			["npc_clawscanner"] = true,
			["npc_rollermine"] = true
		}
		local ignore_physgunhook = false
		if not allowed_npcs[ent:GetClass()] and (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) then
			if ent:Health() / ent:GetMaxHealth() > 0.5 then return ply:EmitSound("paranatural/telekinesis/drop.wav", 75, 100, 1, CHAN_STATIC) end
			local pos = ent:GetPos()
			local ents1 = table.Flip(ents.FindInSphere(pos, 50))
			local dmg = DamageInfo()
				dmg:SetDamage(ent:Health() + 1)
				dmg:SetAttacker(ply)
				dmg:SetInflictor(ply)
				dmg:SetDamageType(DMG_PHYSGUN)
			ent:TakeDamageInfo(dmg)
			for _,ent2 in pairs(ents.FindInSphere(pos, 50)) do
				if ents1[ent2] then continue end
				if ent2:GetClass() == "prop_ragdoll" then
					ent = ent2
					ignore_physgunhook = true -- sometimes it doesn't update properly? we'll ignore physgunpickup for this tick.
					break
				end
			end
		end
		local size
		do
			local mins, maxs = ent:GetModelBounds()
			size = math.max(maxs.x - mins.x, maxs.y - mins.y, maxs.z - mins.z) * 0.5
		end
		if IsValid(entities[1]) then idx = idx + 1 end
		if IsValid(entities[2]) then idx = idx + 1 end
		if IsValid(entities[3]) then idx = idx + 1 end
		local disallow = ent:GetNWFloat("paranatural_tk_grabbed", -1) > 0 or
			not IsValid(ent:GetPhysicsObject()) or not ent:GetPhysicsObject():IsMotionEnabled() or
			not (ignore_physgunhook or hook.Run("PhysgunPickup", ply, ent)) or size > 380
		if not IsValid(ent) or ent:EntIndex() == 0 or (idx > 1 and disallow) then
			idx = idx - 1
			ent = ply:GetNWEntity("paranatural_tk_entity_"..idx)
			if not IsValid(ent) then return end
			if idx == 1 then
				if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "paranatural_telekinetic" then
					ply:SelectWeapon(ply.paranatural_wasactiveweapon)
					ply.paranatural_wasactiveweapon = nil
				end
				ply:StripWeapon("paranatural_telekinetic")
			end
			ply:SetNWEntity("paranatural_tk_entity_"..idx, nil)
			release(ply, ent)
			ply:EmitSound("paranatural/telekinesis/ungrab.mp3", 75, 100, 1, CHAN_STATIC)
			return
		elseif idx > 3 then
			return
		end
		if disallow then
			ply:EmitSound("paranatural/telekinesis/drop.wav", 75, 100, 1, CHAN_STATIC)
			return
		end
		if not IsValid(ply:GetWeapon("paranatural_telekinetic")) then
			ply:Give("paranatural_telekinetic")
			ply.paranatural_wasactiveweapon = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() or ""
			ply:SelectWeapon("paranatural_telekinetic")
		end
		ent:SetOwner(ply)
		ent:EmitSound("paranatural/telekinesis/loop.wav")
		ply:EmitSound("paranatural/telekinesis/grab.wav", 75, 100, 1, CHAN_STATIC)
		ply:SetNWEntity("paranatural_tk_entity_"..idx, ent)
		ent:SetNWFloat("paranatural_tk_grabbed", CurTime())
		ent.paranatural_tk_hadgravity = ent:GetPhysicsObject():IsGravityEnabled()
		for n=0,ent:GetPhysicsObjectCount()-1 do
			local phys = ent:GetPhysicsObjectNum(n)
			phys:EnableGravity(false)
			phys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
			phys:SetAngleVelocity(VectorRand(-180, 180))
		end
		return
	end
	if button == 107 then -- throwing
		local entities = {
			ply:GetNWEntity("paranatural_tk_entity_1"),
			ply:GetNWEntity("paranatural_tk_entity_2"),
			ply:GetNWEntity("paranatural_tk_entity_3")
		}
		for i=1,3 do ply:SetNWEntity("paranatural_tk_entity_"..i, nil) end
		for _, ent in pairs(entities) do
			if not IsValid(ent) then continue end
			ent:SetOwner(NULL)
			timer.Simple(0.1*(_ - 1), function()
				ent:SetNWFloat("paranatural_tk_grabbed", -1)
				local d = (ply:GetEyeTrace().HitPos - ent:GetPos()):GetNormalized()
				for n=0,ent:GetPhysicsObjectCount()-1 do
					local phys = ent:GetPhysicsObjectNum(n)
					phys:SetVelocity(d * 32767 * 16 + ply:GetVelocity())
					phys:EnableGravity(ent.paranatural_tk_hadgravity)
					phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
					phys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
				end
				ent:SetPhysicsAttacker(ply, 10)
				ent:SetSaveValue("m_bFirstCollisionAfterLaunch", true)
				ply:EmitSound("paranatural/telekinesis/throw.mp3", 75, 100, 1, CHAN_STATIC)
				ent:StopSound("paranatural/telekinesis/loop.wav")
			end)
		end
		timer.Simple(0.3, function()
			if not IsValid(ply) then return end
			if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "paranatural_telekinetic" then
				ply:SelectWeapon(ply.paranatural_wasactiveweapon)
				ply.paranatural_wasactiveweapon = nil
			end
			ply:StripWeapon("paranatural_telekinetic")
		end)
	end
end)