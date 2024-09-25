local function shield(ply)
	ply.paranatural_sh_activewep = ply:GetActiveWeapon():GetClass()
	ply:Give("paranatural_telekinetic")
	ply:SelectWeapon("paranatural_telekinetic")
	ply.paranatural_blocking_ability = "shield"
	ply.paranatural_sh_shielded = true
	local positions = {
		Vector(90, 0, 0),
		Vector(90, 50, 15),
		Vector(90, -50, 15),
		Vector(90, 0, -40),
		Vector(90, 50, -40),
		Vector(90, -50, -40)
	}
	local angles = {
		Angle(0, 90, 90),
		Angle(0, 45, 90),
		Angle(0, -45, 90),
		Angle(0, 90+180, 90),
		Angle(0, 45, 90),
		Angle(0, -45, 90)
	}
	local models = {
		"models/props_debris/concrete_chunk02b.mdl",
		"models/props_debris/concrete_chunk01a.mdl",
		"models/props_debris/concrete_chunk07a.mdl",
		"models/props_debris/concrete_chunk06c.mdl",
		"models/props_debris/concrete_chunk01c.mdl",
		"models/props_debris/concrete_chunk02b.mdl"
	}
	ply.paranatural_sh_shield = {}
	ply.paranatural_sh_shield_elist = {}
	ply:EmitSound("paranatural/shield/raise.wav", 75, 100, 1, CHAN_STATIC)
	--ply:EmitSound("paranatural/shield/hum.wav", 75, 100, 0.75, CHAN_STATIC)
	hook.Add("EntityEmitSound", "paranatural_shield_sound_"..ply:GetName(), function(data)
		data.DSP = 16
		data.Pitch = 75
		return true
	end)

	local material_lookup = {
		[MAT_ANTLION]="paranatural/shield_mats/shell.vmt",
		[MAT_BLOODYFLESH]="paranatural/shield_mats/flesh.vmt",
		[MAT_CONCRETE]="paranatural/shield_mats/concrete.vmt",
		[MAT_DIRT]="paranatural/shield_mats/dirt.vmt",
		[MAT_EGGSHELL]="paranatural/shield_mats/shell.vmt",
		[MAT_FLESH]="paranatural/shield_mats/flesh.vmt",
		[MAT_GRATE]="paranatural/shield_mats/grate.vmt",
		[MAT_ALIENFLESH]="paranatural/shield_mats/shell.vmt",
		[MAT_CLIP]="paranatural/shield_mats/nodraw.vmt",
		[MAT_SNOW]="paranatural/shield_mats/snow.vmt",
		[MAT_PLASTIC]="paranatural/shield_mats/plastic.vmt",
		[MAT_METAL]="paranatural/shield_mats/metal.vmt",
		[MAT_SAND]="paranatural/shield_mats/sand.vmt",
		[MAT_FOLIAGE]="paranatural/shield_mats/grass.vmt",
		[MAT_COMPUTER]="paranatural/shield_mats/metal.vmt",
		[MAT_SLOSH]="paranatural/shield_mats/shell.vmt",
		[MAT_TILE]="paranatural/shield_mats/plastic.vmt",
		[MAT_GRASS]="paranatural/shield_mats/grass.vmt",
		[MAT_VENT]="paranatural/shield_mats/grate.vmt",
		[MAT_WOOD]="paranatural/shield_mats/wood.vmt",
		[MAT_DEFAULT]="paranatural/shield_mats/nodraw.vmt",
		[MAT_GLASS]="paranatural/shield_mats/glass.vmt",
		[MAT_WARPSHIELD]="paranatural/shield_mats/shell.vmt",
	}

	for n,position in pairs(positions) do
		ply.paranatural_sh_shield[n] = ents.Create("prop_physics")
		local e = ply.paranatural_sh_shield[n]
		ply.paranatural_sh_shield_elist[e] = true
		--e:SetPos(ply:EyePos() + 
		--	ply:EyeAngles():Forward() * position.x + 
		--	ply:EyeAngles():Right() * position.y + 
		--	ply:EyeAngles():Up() * position.z
		--)
		local spos = ply:GetPos() + ply:GetAngles():Up() * 100 + math.random(-100, 100) * ply:GetAngles():Right()
		local safety = 0
		while not util.IsInWorld(spos) and safety < 5 do
			safety = safety + 1
			spos = ply:GetPos() + ply:GetAngles():Up() * 100 + math.random(-100, 100) * ply:GetAngles():Right()
		end
		local trace = util.TraceLine({start=spos, endpos=spos+Vector(0, 0, -32767), mask=MASK_NPCWORLDSTATIC})
		spos = trace.HitPos
		e:SetPos(spos)
		e:SetModel(models[n])
		e:SetMaterial(material_lookup[trace.MatType])
		e:Spawn()
		e.pos = position
		e.ang = angles[n]
		e.owner = ply
		e:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		--e:SetAngles(ply:EyeAngles() + e.ang)
		e:GetPhysicsObject():SetAngleDragCoefficient(20)
		local hname = "paranatural_shield_nocollide_"..e:EntIndex()
		e:SetCustomCollisionCheck(true)
		hook.Add("ShouldCollide", hname, function(ent1, ent2)
			if not IsValid(e) then return hook.Remove("ShouldCollide", hname) end
			if ent1 == e then
				if ent2 == e.owner then return false end
				if ply.paranatural_sh_shield_elist[ent2] then return false end
				return true
			end
			if ent2 == e then
				if ent1 == e.owner then return false end
				if ply.paranatural_sh_shield_elist[ent1] then return false end
				return true
			end
		end)
	end
end
local function unshield(ply)
	ply.paranatural_blocking_ability = nil
	ply:SelectWeapon(ply.paranatural_sh_activewep)
	ply:StripWeapon("paranatural_telekinetic")
	ply.paranatural_sh_shielded = false
	ply:StopSound("paranatural/shield/hum.wav")
	hook.Remove("EntityEmitSound", "paranatural_shield_sound_"..ply:GetName())
	for k,v in pairs(ply.paranatural_sh_shield) do
		timer.Simple(2, function() v:Remove() end)
		v:SetRenderMode(RENDERMODE_TRANSCOLOR)
		local c = v:GetColor()
		c.a = 255
		v:SetColor(c)
		for i=0,255,1 do
			timer.Simple(2.5 / i, function()
				if not IsValid(v) then return end
				local c = v:GetColor()
				c.a = i
				v:SetColor(c)
			end)
		end
		v:GetPhysicsObject():SetVelocity((ply:EyeAngles():Forward() + VectorRand()) * 100)
	end
	ply.paranatural_sh_shield = nil
end

hook.Add("Think", "paranatural_shield", function()
	for _,ply in player.Iterator() do
		if ply.paranatural_blocking_ability and ply.paranatural_blocking_ability ~= "shield" then ply.paranatural_sh_control = false return end
		if not _G.paranatural.dash_allowed:GetBool() and not ply:IsAdmin() then
			if ply.paranatural_sh_shield then
				unshield(ply)
			end
			continue
		end

		if ply.paranatural_sh_shield then
			if not ply:Alive() then
				return unshield(ply)
			end
			for _,ent in pairs(ply.paranatural_sh_shield) do
				--ent:SetPos(ply:EyePos() + 
				--	(ply:EyeAngles():Forward() * ent.pos.x + 
				--	 ply:EyeAngles():Right() * ent.pos.y + 
				--	 ply:EyeAngles():Up() * ent.pos.z)
				--)
				local target = ply:EyePos() + 
					(ply:EyeAngles():Forward() * ent.pos.x + 
					 ply:EyeAngles():Right() * ent.pos.y + 
					 ply:EyeAngles():Up() * ent.pos.z)
				local vel = (target - ent:GetPos())
				
				local dist = (vel:Distance(Vector()) / 25) * 20
				if ent:GetPos():Distance(ply:GetPos() + ply:OBBCenter()) < 150 then
					dist = dist * 5
				end

				ent:GetPhysicsObject():SetVelocity(vel * math.log(dist * dist))
				local a = ply:EyeAngles() + ent.ang
				--a.pitch = 0
				a:Normalize()
				local da = (a - ent:GetAngles())
				da:Normalize()
				--print(ent:GetPhysicsObject():CalculateForceOffset(Vector(1), ent:GetPos()))
				ent:GetPhysicsObject():SetAngleVelocity(Vector(da.roll, da.pitch, da.yaw) * 2)
				--ent:SetAngles(ent:GetAngles() * 0.5 + a * 0.4)
			end
		end

		if not ply.paranatural_sh_control then return end
		ply.paranatural_sh_control = false
		if ply.paranatural_sh_shielded then
			unshield(ply)
		else
			shield(ply)
		end
	end
end)