local dot = Material("paranatural/crosshair/dot.png")
local line = Material("paranatural/crosshair/line.png")

local charge = 0
local chargee = 0
local w = 4
local shot = 0
local calm = 0
local delay = 0
local handled = 0
return {
	Model = "models/paranatural/serviceweapon/c_pierce.mdl",
	Primary = {ClipSize = 2, Automatic = true, Delay = 0.1, ReloadDelay = 5 / 2},
	Attack = function(self)
		if CurTime() - delay < 0 then self:SetClip1(self:Clip1() + 1) return end
		if charge == 0 then
			self:EmitSound("paranatural/serviceweapon/pierce_charge.wav", 75, math.random(95, 105), 1, CHAN_WEAPON)
		end
		if not IsFirstTimePredicted() then return end
		--self:ShootBullet(15, 1, 0.01)
		--self:GetOwner():ViewPunch(Angle(-1, 0, 0))
		charge = charge + 1
		self:SetClip1(self:Clip1() + 1)
		return
	end,
	Think = function(self)
		if CurTime() - self.ParanaturalLastShot < 0.15 then
			return
		end
		if charge > 30 then
			self:ShootBullet(1500, 1, 0, self.Primary.Ammo, 1000)
			self:GetOwner():ViewPunch(Angle(-5, 0, 0))
			if SERVER then self:TakePrimaryAmmo(1) end
			charge = 0
			delay = CurTime() + 3
			self:EmitSound("paranatural/serviceweapon/pierce_shot.wav", 75, math.random(75, 125), 1, CHAN_STATIC)
			self:StopSound("paranatural/serviceweapon/pierce_charge.wav")

			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			self:GetOwner():SetAnimation(PLAYER_ATTACK1)
			return
		end
		if charge > 0 then
			self:StopSound("paranatural/serviceweapon/pierce_charge.wav")
			charge = 0
		end

	end,
	DoDrawCrosshair = function(self, x, y)
		if CurTime() - delay < 0 then shot, calm = 0, 0 end
		if CurTime() - self.ParanaturalLastShot < 0.1 and handled ~= self.ParanaturalLastShot then
			shot = shot - calm + 1
			calm = 0
			handled = self.ParanaturalLastShot
		end
		if CurTime() - self.ParanaturalLastShot >= 0.2 then
			shot = 0
			calm = 0
		end
		chargee = math.min(1, shot / 30)
		if self.ParanaturalReloading then
			chargee = -((CurTime() * 2) % 1) * 5
			draw.DrawText("Recharging", "TargetID", x, y + w*5, Color(255, 127-charge/5*127, 127-charge/5*127, 127), TEXT_ALIGN_CENTER)
		end
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(dot)
		surface.DrawTexturedRect(x-w/2, y-w/2, w, w)
		surface.SetMaterial(line)
		surface.DrawTexturedRectRotated(x-w*(4.5 - (chargee - calm / 30) * 3), y-w*(4.5 - (chargee - calm / 30) * 3), w, w*3, 45)
		surface.DrawTexturedRectRotated(x-w*(4.5 - (chargee - calm / 30) * 3), y+w*(4.5 - (chargee - calm / 30) * 3), w, w*3, -45)
		surface.DrawTexturedRectRotated(x+w*(4.5 - (chargee - calm / 30) * 3), y-w*(4.5 - (chargee - calm / 30) * 3), w, w*3, -45)
		surface.DrawTexturedRectRotated(x+w*(4.5 - (chargee - calm / 30) * 3), y+w*(4.5 - (chargee - calm / 30) * 3), w, w*3, 45)
	end
}