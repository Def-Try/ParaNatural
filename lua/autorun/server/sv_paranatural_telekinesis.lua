local function grab(ply)
	local ent = ply:GetEyeTrace().Entity
	if not IsValid(ent:GetPhysicsObject()) or ent == game.GetWorld() then return end
	if ent:IsNPC() or ent:IsPlayer() then
		if ent:Health() / ent:GetMaxHealth() < 0.3 then
			ent:TakeDamage(ent:Health() + 1, ply, ply)
		else
			return
		end
		ent = ply:GetEyeTrace().Entity -- should be killed entity's ragdoll
	end
	local mins, maxs = ent:GetModelBounds()
	local size = maxs - mins
	size = math.max(size[1], size[2], size[3])
	if size > 96 then return end
	ply.paranatural_tk_activewep = ply:GetActiveWeapon():GetClass()
	ply:Give("paranatural_telekinetic")
	ply:SelectWeapon("paranatural_telekinetic")
	ply.paranatural_blocking_ability = "telekinesis"
	ply.paranatural_tk_grabbed = ent
	ply.paranatural_tk_grabbed.paranatural_tk_gravityenable = {}
	for i=0,ply.paranatural_tk_grabbed:GetPhysicsObjectCount()-1,1 do
		ply.paranatural_tk_grabbed.paranatural_tk_gravityenable[i] =
			ply.paranatural_tk_grabbed:GetPhysicsObjectNum(i):IsGravityEnabled()
		ply.paranatural_tk_grabbed:GetPhysicsObjectNum(i):EnableGravity(false)
	end
	ply.paranatural_tk_grabbed.paranatural_tk_collidegroup = ply.paranatural_tk_grabbed:GetCollisionGroup()
	ply.paranatural_tk_grabbed:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
end
local function ungrab(ply)
	ply.paranatural_blocking_ability = nil
	if ply:GetActiveWeapon():GetClass() == "paranatural_telekinetic" then
		ply:SelectWeapon(ply.paranatural_tk_activewep)
	end
	ply:StripWeapon("paranatural_telekinetic")
	if not IsValid(ply.paranatural_tk_grabbed) then
		ply.paranatural_tk_grabbed = nil
		return
	end
	if not IsValid(ply.paranatural_tk_grabbed:GetPhysicsObject()) then
		ply.paranatural_tk_grabbed = nil
		return
	end
	ply.paranatural_tk_grabbed.paranatural_tk_grabtime = nil
	for i=0,ply.paranatural_tk_grabbed:GetPhysicsObjectCount()-1,1 do
		ply.paranatural_tk_grabbed:GetPhysicsObjectNum(i):EnableGravity(
			ply.paranatural_tk_grabbed.paranatural_tk_gravityenable[i]
		)
	end
	ply.paranatural_tk_grabbed:SetCollisionGroup(ply.paranatural_tk_grabbed.paranatural_tk_collidegroup)
	ply.paranatural_tk_grabbed = nil
end

hook.Add("Think", "paranatural_telekinesis", function()
	for _,ply in player.Iterator() do
		if ply.paranatural_blocking_ability and ply.paranatural_blocking_ability ~= "telekinesis" then ply.paranatural_tk_control = false continue end
		if not _G.paranatural.telekinesis_allowed:GetBool() and not ply:IsAdmin() then
			if IsValid(ply.paranatural_tk_grabbed) then
				ungrab(ply)
			end
			continue
		end
		if IsValid(ply.paranatural_tk_grabbed) then
			if not ply:Alive() then
				return ungrab(ply)
			end
			if not ply.paranatural_tk_grabbed.paranatural_tk_grabtime then
				ply.paranatural_tk_grabbed.paranatural_tk_grabtime = CurTime()
				ply.paranatural_tk_grabbed.paranatural_tk_grabz = ply.paranatural_tk_grabbed:GetPos().z
				for i=0,ply.paranatural_tk_grabbed:GetPhysicsObjectCount()-1,1 do
					ply.paranatural_tk_grabbed:GetPhysicsObjectNum(i):SetAngleVelocity(VectorRand() * 180)
				end
			end
			if CurTime() - ply.paranatural_tk_grabbed.paranatural_tk_grabtime < 0.743 then
				if ply.paranatural_tk_grabbed:GetPos().z - ply.paranatural_tk_grabbed.paranatural_tk_grabz < 50 then
					for i=0,ply.paranatural_tk_grabbed:GetPhysicsObjectCount()-1,1 do
						ply.paranatural_tk_grabbed:GetPhysicsObjectNum(i):SetVelocity(
							ply.paranatural_tk_grabbed:GetPhysicsObjectNum(i):GetVelocity() + Vector(0, 0, 25)
						)
					end
				else
					for i=0,ply.paranatural_tk_grabbed:GetPhysicsObjectCount()-1,1 do
						ply.paranatural_tk_grabbed:GetPhysicsObjectNum(i):SetVelocity(
							ply.paranatural_tk_grabbed:GetPhysicsObjectNum(i):GetVelocity()*0.9
						)
					end
				end
				return
			end
			local ply_hold_pos = (ply:GetPos() + ply:OBBCenter())
			ply_hold_pos = ply_hold_pos + ply:EyeAngles():Forward() * 75
			ply_hold_pos = ply_hold_pos + ply:EyeAngles():Up() * 50
			ply_hold_pos = ply_hold_pos + ply:EyeAngles():Right() * 25
			local vel = ply_hold_pos - (ply.paranatural_tk_grabbed:GetPos() + ply.paranatural_tk_grabbed:OBBCenter())
			local dist = (vel:Distance(Vector()) / 25)
			if ply.paranatural_tk_grabbed:GetPos():Distance(ply:GetPos() + ply:OBBCenter()) < 75 then
				dist = dist * 100
			end

			local a = ply:EyeAngles()
			a:Normalize()

			for i=0,ply.paranatural_tk_grabbed:GetPhysicsObjectCount()-1,1 do
				ply.paranatural_tk_grabbed:GetPhysicsObjectNum(i):SetVelocity(
					ply.paranatural_tk_grabbed:GetPhysicsObjectNum(i):GetVelocity() * 0.5 +
					vel * math.log(dist * dist * 10) * 0.5
				)
				if i ~= 0 then
					local da = (a - ply.paranatural_tk_grabbed:GetPhysicsObjectNum(i):GetAngles())
					da:Normalize()
					ply.paranatural_tk_grabbed:GetPhysicsObjectNum(i):SetAngleVelocity(Vector(da.roll, da.pitch, da.yaw) * 10)
				end
			end

			if ply:KeyDown(IN_ATTACK) and ply:GetActiveWeapon():GetClass() == "paranatural_telekinetic" then
				local ent = ply.paranatural_tk_grabbed
				ungrab(ply)
				local trace = util.GetPlayerTrace(ply, ply:GetAimVector() * (4096 * 8))
				trace.filter = {trace.filter, ent}
				local yeet = util.TraceLine(trace).HitPos - ply_hold_pos
				--ent:GetPhysicsObject():SetVelocity(yeet * 32767)
				
				for i=0,ent:GetPhysicsObjectCount()-1,1 do
					ent:GetPhysicsObjectNum(i):SetVelocity(yeet * 32767)
					ent:GetPhysicsObjectNum(i):AddGameFlag(FVPHYSICS_HEAVY_OBJECT)
					ent:GetPhysicsObjectNum(i):AddGameFlag(FVPHYSICS_WAS_THROWN)
					timer.Simple(5, function()
						if not IsValid(ent) or not IsValid(ent:GetPhysicsObjectNum(i)) then return end
						ent:GetPhysicsObjectNum(i):ClearGameFlag(FVPHYSICS_HEAVY_OBJECT)
					end)
				end
				ply:EmitSound("paranatural/telekinesis/throw.mp3", 75, 100, 1, CHAN_STATIC)
			end
		end
		if not IsValid(ply.paranatural_tk_grabbed) and ply.paranatural_tk_grabbed ~= nil then
			ungrab(ply)
		end

		if not ply.paranatural_tk_control then return end
		ply.paranatural_tk_control = false
		if not ply.paranatural_tk_grabbed then
			grab(ply)
			if IsValid(ply.paranatural_tk_grabbed) then
				ply:EmitSound("paranatural/telekinesis/grab.wav", 75, 100, 1, CHAN_STATIC)
			end
		else
			ungrab(ply)
			ply:EmitSound("paranatural/telekinesis/ungrab.mp3", 75, 100, 1, CHAN_STATIC)
		end
	end
end)