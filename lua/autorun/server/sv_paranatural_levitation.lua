hook.Add("Think", "paranatural_levitation", function()
	for _,ply in player.Iterator() do
		if ply.paranatural_lv_zlock then
			ply:SetPos(Vector(ply:GetPos().x, ply:GetPos().y, ply.paranatural_lv_zlock))
			--ply:SetVelocity(Vector(0, 0, -ply:GetVelocity().z))
		end
		--print(ply.paranatural_lv_falling)
		if ply.paranatural_lv_falling then
			local zvel = ply:GetVelocity().z
			ply:SetVelocity(Vector(0, 0, -zvel + math.max(zvel, -500)))
		end
		if ply:IsOnGround() and not ply.paranatural_lv_reset then
			ply.paranatural_lv_wasonground = true
			ply.paranatural_lv_holdingjump = false
			ply.paranatural_lv_reset = true
			ply.paranatural_lv_zlock = nil
			ply.paranatural_lv_falling = false
			ply:SetGravity(1)
		end

		if ply:KeyDown(IN_JUMP) and ply.paranatural_lv_id and not ply.paranatural_lv_wasonground then
			timer.Remove("paranatural_lv_lower_"..ply.paranatural_lv_id)
			ply:SetGravity(1)

			ply.paranatural_lv_zlock = nil
			ply.paranatural_lv_id = nil
			ply.paranatural_lv_wasonground = true
		end

		if not ply:IsOnGround() and ply:KeyDown(IN_JUMP) and not ply:KeyDownLast(IN_JUMP) then
			if ply:GetVelocity().z < 0 then 
				if ply.paranatural_lv_falling then
					ply:SetGravity(1)
					ply.paranatural_lv_falling = false
				else
					ply:SetGravity(0.33)
					ply.paranatural_lv_falling = true
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
		end
		if not ply:KeyDown(IN_JUMP) and ply.paranatural_lv_holdingjump and not ply.paranatural_lv_wasonground then
			--print("no longer holding")
			if ply:GetVelocity().z < 0 then return end
			ply.paranatural_lv_holdingjump = false
			ply:SetVelocity(Vector(0, 0, -ply:GetVelocity().z))
			ply:SetGravity(0)
			ply.paranatural_lv_zlock = ply:GetPos().z
			ply.paranatural_lv_id = math.random(1, 65536)
			timer.Create("paranatural_lv_lower_"..ply.paranatural_lv_id, 60, 1, function()
				ply:SetGravity(0.33)
				ply.paranatural_lv_falling = true
				ply.paranatural_lv_zlock = nil
				ply.paranatural_lv_id = nil
				ply.paranatural_lv_wasonground = true
			end)
		end
		if ply.paranatural_lv_holdingjump and not ply.paranatural_lv_wasonground then
			--print("still holding")
			if ply:GetVelocity().z < 0 then return end
			ply:SetVelocity(Vector(0, 0, math.max(0, 500 - ply:GetVelocity().z)))
		end
	end
end)