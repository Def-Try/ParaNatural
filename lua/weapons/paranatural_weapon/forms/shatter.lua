local dot = Material("paranatural/crosshair/dot.png")
local line = Material("paranatural/crosshair/line.png")

local shot = 0
local handled = 0
local calm = 0
local w = 4
return {
	Primary = {ClipSize = 6, Automatic = false, Delay = 0.4, ReloadDelay = 0.5},
	Attack = function(self)
		self.Weapon:EmitSound("Weapon_Shotgun.Single")
		self:ShootBullet(30, 10, self.ParanaturalZooming and 0.05 or 0.15)
		self:GetOwner():ViewPunch(Angle(-1, 0, 0))
	end,
	Think = function(self) end,
	DoDrawCrosshair = function(self, x, y)
		if CurTime() - self.ParanaturalLastShot < 0.1 and handled ~= self.ParanaturalLastShot then
			shot = shot - calm + 1
			calm = 0
			handled = self.ParanaturalLastShot
		end
		if CurTime() - self.ParanaturalLastShot >= 0.5 then
			calm = calm + FrameTime() * 50
			if calm >= shot then
				shot = 0
				calm = 0
			end
		end
		if shot > 3 then
			calm = calm - 1
			shot = 3
		end
		if self.ParanaturalZooming then
			shot = 0
			calm = 1
		end
		if self.ParanaturalReloading then
			shot = 0
			calm = -((CurTime() * 2) % 1) * 5
			draw.DrawText("Recharging", "TargetID", x, y + w*5, Color(255, 127-calm/5*127, 127-calm/5*127, 127), TEXT_ALIGN_CENTER)
		end
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(dot)
		surface.DrawTexturedRect(x-w/2, y-w/2, w, w)
		surface.SetMaterial(line)
		surface.DrawTexturedRectRotated(x-w*(10.5 + (shot - calm) * 0.5), y-w*(4.5), w, w*3, -45)
		surface.DrawTexturedRectRotated(x-w*(10.5 + (shot - calm) * 0.5), y+w*(4.5), w, w*3, 45)
		surface.DrawTexturedRectRotated(x+w*(11.5 + (shot - calm) * 0.5), y, w, w*8, 0)


		surface.DrawTexturedRectRotated(x+w*(10.5 + (shot - calm) * 0.5), y-w*(4.5), w, w*3, 45)
		surface.DrawTexturedRectRotated(x+w*(10.5 + (shot - calm) * 0.5), y+w*(4.5), w, w*3, -45)
		surface.DrawTexturedRectRotated(x-w*(11.5 + (shot - calm) * 0.5), y, w, w*8, 0)
	end
}