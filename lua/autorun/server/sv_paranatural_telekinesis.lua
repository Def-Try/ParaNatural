local function grab(ply)
	local ent = ply:GetEyeTrace().Entity
	if not IsValid(ent:GetPhysicsObject()) or ent == game.GetWorld() then return end
	if ent:IsNPC() or ent:IsPlayer() then
		if ent:Health() / ent:GetMaxHealth() < 0.2 then
			ent:TakeDamage(ent:Health() + 1, ply, ply)
		else
			return
		end
		ent = ply:GetEyeTrace().Entity -- should be killed entity's ragdoll
	end
	ply.paranatural_tk_activewep = ply:GetActiveWeapon():GetClass()
	ply:Give("paranatural_telekinetic")
	ply:SelectWeapon("paranatural_telekinetic")
	ply.paranatural_blocking_ability = "telekinesis"
	ply.paranatural_tk_grabbed = ent
	ply.paranatural_tk_grabbed.paranatural_tk_gravityenable = ply.paranatural_tk_grabbed:GetPhysicsObject():IsGravityEnabled()
	ply.paranatural_tk_grabbed.paranatural_tk_collidegroup = ply.paranatural_tk_grabbed:GetCollisionGroup()
	ply.paranatural_tk_grabbed:GetPhysicsObject():EnableGravity(false)
	ply.paranatural_tk_grabbed:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
end
local function ungrab(ply)
	ply.paranatural_blocking_ability = nil
	ply:SelectWeapon(ply.paranatural_tk_activewep)
	ply:StripWeapon("paranatural_telekinetic")
	if not IsValid(ply.paranatural_tk_grabbed) then
		ply.paranatural_tk_grabbed = nil
		return
	end
	if not IsValid(ply.paranatural_tk_grabbed:GetPhysicsObject()) then
		ply.paranatural_tk_grabbed = nil
		return
	end
	ply.paranatural_tk_grabbed:GetPhysicsObject():EnableGravity(ply.paranatural_tk_grabbed.paranatural_tk_gravityenable)
	ply.paranatural_tk_grabbed:SetCollisionGroup(ply.paranatural_tk_grabbed.paranatural_tk_collidegroup)
	ply.paranatural_tk_grabbed = nil
end

hook.Add("Think", "paranatural_telekinesis", function()
	for _,ply in player.Iterator() do
		if ply.paranatural_blocking_ability and ply.paranatural_blocking_ability ~= "telekinesis" then ply.paranatural_tk_control = false return end
		if IsValid(ply.paranatural_tk_grabbed) then
			local ply_hold_pos = (ply:GetPos() + ply:OBBCenter())
			ply_hold_pos = ply_hold_pos + ply:EyeAngles():Forward() * 75
			ply_hold_pos = ply_hold_pos + ply:EyeAngles():Up() * 50
			ply_hold_pos = ply_hold_pos + ply:EyeAngles():Right() * 25
			local vel = ply_hold_pos - (ply.paranatural_tk_grabbed:GetPos() + ply.paranatural_tk_grabbed:OBBCenter())
			local dist = (vel:Distance(Vector()) / 25)
			if ply.paranatural_tk_grabbed:GetPos():Distance(ply:GetPos() + ply:OBBCenter()) < 150 then
				dist = dist * 100
			end

			local a = ply:EyeAngles()
			a:Normalize()

			for i=0,ply.paranatural_tk_grabbed:GetPhysicsObjectCount()-1,1 do
				ply.paranatural_tk_grabbed:GetPhysicsObjectNum(i):SetVelocity(
					ply.paranatural_tk_grabbed:GetPhysicsObjectNum(i):GetVelocity() * 0.5 +
					vel * math.log(dist * dist) * 0.5
				)
				if i ~= 0 then
					local da = (a - ply.paranatural_tk_grabbed:GetPhysicsObjectNum(i):GetAngles())
					da:Normalize()
					ply.paranatural_tk_grabbed:GetPhysicsObjectNum(i):SetAngleVelocity(Vector(da.roll, da.pitch, da.yaw) * 10)
				end
			end

			if ply:KeyDown(IN_ATTACK) then
				local ent = ply.paranatural_tk_grabbed
				ungrab(ply)
				local trace = util.GetPlayerTrace(ply, ply:GetAimVector() * (4096 * 8))
				trace.filter = {trace.filter, ent}
				local yeet = util.TraceLine(trace).HitPos - ply_hold_pos
				--ent:GetPhysicsObject():SetVelocity(yeet * 32767)
				
				for i=0,ent:GetPhysicsObjectCount()-1,1 do
					ent:GetPhysicsObjectNum(i):SetVelocity(yeet * 32767)
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
				ply:EmitSound("paranatural/telekinesis/grab.mp3", 75, 100, 1, CHAN_STATIC)
			end
		else
			ungrab(ply)
			ply:EmitSound("paranatural/telekinesis/ungrab.mp3", 75, 100, 1, CHAN_STATIC)
		end
	end
end)