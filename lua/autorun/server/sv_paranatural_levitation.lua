hook.Add("Think", "paranatural_levitation", function()
	for _,ply in player.Iterator() do
		if ply.paranatural_lv_zlock then
			ply:SetPos(Vector(ply:GetPos().x, ply:GetPos().y, ply.paranatural_lv_zlock))
			ply:SetVelocity(Vector(0, 0, -ply:GetVelocity().z))
		end
		--print(ply.paranatural_lv_falling)
		if ply.paranatural_lv_falling then
			local zvel = ply:GetVelocity().z
			ply:SetVelocity(Vector(0, 0, -zvel + math.max(zvel, -500)))
		end
		if ply:IsOnGround() and not ply.paranatural_lv_wasonground then
			ply.paranatural_lv_wasonground = true
			ply.paranatural_lv_holdingjump = false
			ply.paranatural_lv_reset = true
			ply.paranatural_lv_zlock = nil
			ply.paranatural_lv_falling = false
			ply.paranatural_lv_inflictedmov = {0, 0}
			ply:SetGravity(1)
			ply:StopSound("paranatural/levitation/lower.wav")
			ply:StopSound("paranatural/levitation/raise.wav")
		end

		if ply.paranatural_lv_zlock then
			local real = ply:GetVelocity()
			local mov = Vector()
			if ply:KeyDown(IN_FORWARD) then
				mov = mov + ply:EyeAngles():Forward() * 25
			end
			if ply:KeyDown(IN_BACK) then
				mov = mov - ply:EyeAngles():Forward() * 25
			end
			if ply:KeyDown(IN_MOVELEFT) then
				mov = mov - ply:EyeAngles():Right() * 25
			end
			if ply:KeyDown(IN_MOVERIGHT) then
				mov = mov + ply:EyeAngles():Right() * 25
			end
			if ply:KeyDown(IN_SPEED) then
				mov = mov * 3
			end
			--ply:SetVelocity(Vector(-real.x, -real.y, -real.z))
			ply:SetVelocity(Vector(
				-real.x * FrameTime() * 10 + math.min(200, real.x * FrameTime() * 5 + mov.x),
				-real.y * FrameTime() * 10 + math.min(200, real.y * FrameTime() * 5 + mov.y),
				-real.z))
		end

		if ply:KeyDown(IN_JUMP) and ply.paranatural_lv_id and not ply.paranatural_lv_wasonground then
			timer.Remove("paranatural_lv_lower_"..ply.paranatural_lv_id)
			ply:StopSound("paranatural/levitation/loop.wav")
			ply:SetGravity(1)

			ply.paranatural_lv_zlock = nil
			ply.paranatural_lv_id = nil
			ply.paranatural_lv_wasonground = true
		end

		if not ply:IsOnGround() and ply:KeyDown(IN_JUMP) and not ply:KeyDownLast(IN_JUMP) then
			if ply:GetVelocity().z < -10 then 
				if ply.paranatural_lv_falling then
					ply:SetGravity(1)
					ply.paranatural_lv_falling = false
					ply:StopSound("paranatural/levitation/lower.wav")
				else
					ply:EmitSound("paranatural/levitation/lower.wav")
					ply:SetGravity(0.33)
					ply.paranatural_lv_falling = true
					ply.paranatural_lv_wasonground = false
				end
				return
			end
		end

		if not ply:IsOnGround() and ply.paranatural_lv_wasonground and ply:KeyDown(IN_JUMP) and not ply:KeyDownLast(IN_JUMP) then
			ply.paranatural_lv_wasonground = false
			ply.paranatural_lv_holdingjump = false
			return
		end
		if ply.paranatural_lv_reset and not ply.paranatural_lv_wasonground and ply:KeyDown(IN_JUMP) and not ply:KeyDownLast(IN_JUMP) then
			ply.paranatural_lv_holdingjump = true
			ply.paranatural_lv_reset = false
			ply:EmitSound("paranatural/levitation/raise.wav")
		end
		if not ply:KeyDown(IN_JUMP) and ply.paranatural_lv_holdingjump and not ply.paranatural_lv_wasonground then
			if ply:GetVelocity().z < -10 then return end
			ply:StopSound("paranatural/levitation/raise.wav")
			ply:EmitSound("paranatural/levitation/loop.wav")
			ply.paranatural_lv_holdingjump = false
			ply:SetVelocity(Vector(0, 0, -ply:GetVelocity().z))
			ply:SetGravity(0)
			ply.paranatural_lv_zlock = ply:GetPos().z
			ply.paranatural_lv_id = math.random(1, 65536)
			timer.Create("paranatural_lv_lower_"..ply.paranatural_lv_id, 60, 1, function()
				ply:StopSound("paranatural/levitation/loop.wav")
				ply:EmitSound("paranatural/levitation/lower.wav")
				ply:SetGravity(0.33)
				ply.paranatural_lv_falling = true
				ply.paranatural_lv_zlock = nil
				ply.paranatural_lv_id = nil
				ply.paranatural_lv_wasonground = true
			end)
		end
		if ply.paranatural_lv_holdingjump and not ply.paranatural_lv_wasonground then
			if ply:GetVelocity().z < -10 then return end
			ply:SetVelocity(Vector(0, 0, math.max(0, 50 - math.max(0, ply:GetVelocity().z) * 0.1)))
		end
	end
end)