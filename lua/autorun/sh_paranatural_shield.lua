---@diagnostic disable: inject-field
local allowed 

if CLIENT then
	CreateClientConVar("paranatural_shield_key", "17", true, true) -- default key: G
end
allowed = CreateConVar("paranatural_shield_allowed", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED)

-- stopsound already implemented in sh_paranatural_telekinesis.lua

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

hook.Add("PlayerButtonDown", "paranatural_shield", function(ply, button)
	if IsValid(ply:GetNWEntity("paranatural_tk_entity_1")) then return end
	if CurTime() - ply:GetNWFloat("paranatural_cooldown", 0) <= 0.2 then return end
	ply:SetNWFloat("paranatural_cooldown", CurTime())
	if not allowed:GetBool() and not ply:IsAdmin() then return end
	if not IsFirstTimePredicted() then return end
	if button == 107 and ply:GetNWBool("paranatural_shielded") then -- throw
		if CLIENT then return ply:SetDSP(0) end
		local entities = {
			ply:GetNWEntity("paranatural_sh_entity_1"), ply:GetNWEntity("paranatural_sh_entity_2"),
			ply:GetNWEntity("paranatural_sh_entity_3"), ply:GetNWEntity("paranatural_sh_entity_4"),
			ply:GetNWEntity("paranatural_sh_entity_5"), ply:GetNWEntity("paranatural_sh_entity_6")
		}
		ply:EmitSound("paranatural/telekinesis/throw.mp3", 75, 100, 1, CHAN_STATIC)
		for _,ent in pairs(entities) do
			ent:GetPhysicsObject():SetVelocity(ply:EyeAngles():Forward() * 1024)
			ent:StopSound("paranatural/telekinesis/loop.wav")
			ent:SetCollisionGroup(COLLISION_GROUP_NONE)
			ent:GetPhysicsObject():ClearGameFlag(FVPHYSICS_PLAYER_HELD)
			ent:GetPhysicsObject():ClearGameFlag(FVPHYSICS_NO_IMPACT_DMG)
			timer.Simple(3, function()
				if not IsValid(ent) then return end
				ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
				local c = ent:GetColor()
				c.a = 255
				ent:SetColor(c)
				for i=0,255,1 do
					timer.Simple(2.5 / i, function()
						if not IsValid(ent) then return end
						local c = ent:GetColor()
						c.a = i
						ent:SetColor(c)
						if c.a <= 1 then
							ent:Remove()
						end
					end)
				end
				ent:GetPhysicsObject():SetVelocity(ent:GetPhysicsObject():GetVelocity() + (ply:EyeAngles():Forward() + VectorRand()) * 100)
			end)
		end
		timer.Simple(0.5, function()
			ply:StripWeapon("paranatural_telekinetic")
		end)
		if ply.paranatural_sh_activewep then
			ply:SelectWeapon(ply.paranatural_sh_activewep)
			ply.paranatural_sh_activewep = nil
		end
		ply:SetNWBool("paranatural_shielded", false)
	end
	if button ~= ply:GetInfoNum("paranatural_shield_key", 17) then return end
	if ply:GetNWBool("paranatural_shielded") then
		if CLIENT then return ply:SetDSP(0) end
		local entities = {
			ply:GetNWEntity("paranatural_sh_entity_1"), ply:GetNWEntity("paranatural_sh_entity_2"),
			ply:GetNWEntity("paranatural_sh_entity_3"), ply:GetNWEntity("paranatural_sh_entity_4"),
			ply:GetNWEntity("paranatural_sh_entity_5"), ply:GetNWEntity("paranatural_sh_entity_6")
		}
		for _, ent in pairs(entities) do
			if not IsValid(ent) then continue end
			ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
			ent:StopSound("paranatural/telekinesis/loop.wav")
			local c = ent:GetColor()
			c.a = 255
			ent:SetColor(c)
			for i=0,255,1 do
				timer.Simple(2.5 / i, function()
					if not IsValid(ent) then return end
					local c = ent:GetColor()
					c.a = i
					ent:SetColor(c)
					if c.a <= 1 then
						ent:Remove()
					end
				end)
			end
			ent:GetPhysicsObject():SetVelocity((ply:EyeAngles():Forward() + VectorRand()) * 100)
		end
		timer.Simple(0.5, function()
			ply:StripWeapon("paranatural_telekinetic")
		end)
		if ply.paranatural_sh_activewep then
			ply:SelectWeapon(ply.paranatural_sh_activewep)
			ply.paranatural_sh_activewep = nil
		end
		ply:SetNWBool("paranatural_shielded", false)
	else
		if CLIENT then return ply:SetDSP(14) end
		ply:EmitSound("paranatural/shield/raise.wav", 75, 100, 1, CHAN_STATIC)
		if IsValid(ply:GetActiveWeapon()) then
			ply.paranatural_sh_activewep = ply:GetActiveWeapon():GetClass()
		end
		ply:Give("paranatural_telekinetic")
		ply:SelectWeapon("paranatural_telekinetic")
		ply:SetNWBool("paranatural_shielded", true)
		local positions = {
			Vector(90, 0,  15), Vector(90, 50,  15), Vector(90, -50,  15),
			Vector(90, 0, -40), Vector(90, 50, -40), Vector(90, -50, -40)
		}
		local angles = {
			Angle(0, 0, 0), Angle(0, -45, 0), Angle(0, 45, 0),
			Angle(0, 0, 0), Angle(0, -45, 0), Angle(0, 45, 0)
		}
		local models = {
			"models/props_debris/concrete_chunk02b.mdl",
			"models/props_debris/concrete_chunk02b.mdl",
			"models/props_debris/concrete_chunk02b.mdl",
			"models/props_debris/concrete_chunk02b.mdl",
			"models/props_debris/concrete_chunk02b.mdl",
			"models/props_debris/concrete_chunk02b.mdl"
		}
		local entities = {}
		for n,position in pairs(positions) do
			local ent = ents.Create("prop_physics")
			entities[#entities + 1] = ent
			ply:SetNWEntity("paranatural_sh_entity_"..n, ent)
			local spos = ply:GetPos() + ply:GetAngles():Up() * 100 + math.random(-100, 100) * ply:GetAngles():Right()
			local safety = 0
			while not util.IsInWorld(spos) and safety < 5 do
				safety = safety + 1
				spos = ply:GetPos() + ply:GetAngles():Up() * 100 + math.random(-100, 100) * ply:GetAngles():Right()
			end
			local trace = util.TraceLine({start=spos, endpos=spos+Vector(0, 0, -32767), mask=MASK_NPCWORLDSTATIC})
			spos = trace.HitPos
			ent:SetPos(spos)
			ent:SetModel(models[n])
			ent:SetMaterial(material_lookup[trace.MatType])
			ent:Spawn()
			ent.pos = position
			ent.ang = angles[n]
			ent.owner = ply
			ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
			ent:GetPhysicsObject():AddGameFlag(FVPHYSICS_PLAYER_HELD)
			ent:GetPhysicsObject():AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
			ent:EmitSound("paranatural/telekinesis/loop.wav")
		end
		for _1,ent1 in pairs(entities) do
			for _2,ent2 in pairs(entities) do
				if _1 == _2 then continue end
				constraint.NoCollide(ent1, ent2, 0, 0)
			end
		end
	end
end)

hook.Add("SetupMove", "paranatural_shield", function(ply, mv)
	if CLIENT then return end
	if not ply:GetNWBool("paranatural_shielded") then return end

	local entities = {
		ply:GetNWEntity("paranatural_sh_entity_1"), ply:GetNWEntity("paranatural_sh_entity_2"),
		ply:GetNWEntity("paranatural_sh_entity_3"), ply:GetNWEntity("paranatural_sh_entity_4"),
		ply:GetNWEntity("paranatural_sh_entity_5"), ply:GetNWEntity("paranatural_sh_entity_6")
	}

	local ang = ply:EyeAngles()

	for _,ent in pairs(entities) do
		if not IsValid(ent) then continue end
		local target = ply:EyePos() + 
			(ang:Forward() * ent.pos.x + 
			 ang:Right() * ent.pos.y + 
			 ang:Up() * ent.pos.z)
		local phys = ent:GetPhysicsObject()
		local vel = (target - ent:GetPos())
		local lang = Angle(ent.ang.x, ang.y + 90 + ent.ang.y, ang.p + 90 + ent.ang.z)
		local dang = ent:WorldToLocalAngles(lang)
		--local ent_ang = ent:GetAngles()
		--local _, dang = WorldToLocal(vector_up, ent_ang, vector_up, ang)
		dang = Vector(dang.r, dang.p, dang.y) * 2
		local dist = (vel:Distance(Vector()))
		phys:SetAngleVelocity(phys:GetAngleVelocity() * 0.9 + dang * 0.5)
		phys:SetVelocity(ply:GetVelocity() * 0.5 + phys:GetVelocity() * 0.5 + vel * math.max(1, math.log((1 - dist) * (1 - dist) * 10)))

		if dist > 100 then
			ent.paranatural_toofar = ent.paranatural_toofar or CurTime()
			if CurTime() - ent.paranatural_toofar > 5 then
				ply:SetNWEntity("paranatural_sh_entity_".._, nil)
				ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
				local c = ent:GetColor()
				c.a = 255
				ent:SetColor(c)
				for i=0,255,1 do
					timer.Simple(2.5 / i, function()
						if not IsValid(ent) then return end
						local c = ent:GetColor()
						c.a = i
						ent:SetColor(c)
						if c.a <= 1 then
							ent:Remove()
						end
					end)
				end
				ent:GetPhysicsObject():SetVelocity((ply:EyeAngles():Forward() + VectorRand()) * 100)
			end
			return
		end
		ent.paranatural_toofar = nil
	end
end)