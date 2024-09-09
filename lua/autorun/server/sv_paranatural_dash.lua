hook.Add("Think", "paranatural_dash", function()
	for _,ply in player.Iterator() do
		if not ply.paranatural_ds_control then return end
		ply.paranatural_ds_control = false
		local ang = ply:EyeAngles()
		ang.pitch = 0
		ply:SetVelocity(((ply:IsOnGround() and 1 or 0) * ang:Up() * 250) + ang:Forward() * 1000)
		ply:EmitSound("weapons/fx/nearmiss/bulletltor0" .. math.random(3, 9) .. ".wav", 75, 100, 1, CHAN_STATIC)
	end
end)