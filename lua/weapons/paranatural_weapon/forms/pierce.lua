local dot = Material("paranatural/crosshair/dot.png")
local line = Material("paranatural/crosshair/line.png")

local charge = 0
local w = 4
local shot = 0
local calm = 0
local delay = 0
return {
	Primary = {ClipSize = 2, Automatic = true, Delay = 0.1, ReloadDelay = 2},
	Attack = function(self)
		if CurTime() - delay < 0 then self:SetClip1(self:Clip1() + 1) return end
		--self.Weapon:EmitSound("Weapon_Pistol.Single")
		--self:ShootBullet(15, 1, 0.01)
		--self:GetOwner():ViewPunch(Angle(-1, 0, 0))
		charge = charge + 1
		self:SetClip1(self:Clip1() + 1)
	end,
	Think = function(self)
		if CurTime() - self.ParanaturalLastShot < 0.15 then return end
		if charge > 30 then
			self:ShootBullet(1500, 1, 0)
			self:GetOwner():ViewPunch(Angle(-5, 0, 0))
			self:TakePrimaryAmmo(1)
			charge = 0
			delay = CurTime() + 3
		end
	end,
	DoDrawCrosshair = function(self, x, y)
		if CurTime() - self.ParanaturalLastShot < 0.1 and handled ~= self.ParanaturalLastShot then
			shot = shot - calm + 1
			calm = 0
			handled = self.ParanaturalLastShot
		end
		if CurTime() - self.ParanaturalLastShot >= 0.2 then
			calm = calm + FrameTime() * 50
			if calm > shot then
				shot = 0
				calm = 0
			end
		end
		charge = math.min(1, shot / 30)
		if self.ParanaturalReloading then
			charge = -((CurTime() * 2) % 1) * 5
			draw.DrawText("Recharging", "TargetID", x, y + w*5, Color(255, 127-charge/5*127, 127-charge/5*127, 127), TEXT_ALIGN_CENTER)
		end
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(dot)
		surface.DrawTexturedRect(x-w/2, y-w/2, w, w)
		surface.SetMaterial(line)
		surface.DrawTexturedRectRotated(x-w*(4.5 - (charge - calm / 30) * 3), y-w*(4.5 - (charge - calm / 30) * 3), w, w*3, 45)
		surface.DrawTexturedRectRotated(x-w*(4.5 - (charge - calm / 30) * 3), y+w*(4.5 - (charge - calm / 30) * 3), w, w*3, -45)
		surface.DrawTexturedRectRotated(x+w*(4.5 - (charge - calm / 30) * 3), y-w*(4.5 - (charge - calm / 30) * 3), w, w*3, -45)
		surface.DrawTexturedRectRotated(x+w*(4.5 - (charge - calm / 30) * 3), y+w*(4.5 - (charge - calm / 30) * 3), w, w*3, 45)
	end
}