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
		ply:EmitSound("paranatural/dash/whoosh" .. math.random(1, 3) .. ".wav", 75, 100, 1, CHAN_STATIC)
		timer.Simple(0.2, function()
			ply:SetFriction(friction)
			timer.Simple(0.3, function()
				ply.paranatural_dashing = false
			end)
		end)
	end
end)