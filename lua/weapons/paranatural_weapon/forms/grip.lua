local dot = Material("paranatural/crosshair/dot.png")
local line = Material("paranatural/crosshair/line.png")

local shot = 0
local handled = 0
local calm = 0
local w = 4
return {
	Model = "models/paranatural/serviceweapon/c_grip.mdl",
	Primary = {ClipSize = 14, Automatic = false, Delay = 0.1, ReloadDelay = 5 / 14},
	Attack = function(self)
		self.Weapon:EmitSound("paranatural/serviceweapon/grip_shot_"..math.random(1, 2)..".wav", 75, math.random(90, 110), 1, CHAN_STATIC)
		self:ShootBullet(15, 1, 0.01)
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
		surface.DrawTexturedRectRotated(x-w*(1.5 + (shot - calm) * 0.5), y-w*(1.5 + (shot - calm) * 0.5), w, w*3, -45)
		surface.DrawTexturedRectRotated(x-w*(1.5 + (shot - calm) * 0.5), y+w*(1.5 + (shot - calm) * 0.5), w, w*3, 45)
		surface.DrawTexturedRectRotated(x+w*(1.5 + (shot - calm) * 0.5), y-w*(1.5 + (shot - calm) * 0.5), w, w*3, 45)
		surface.DrawTexturedRectRotated(x+w*(1.5 + (shot - calm) * 0.5), y+w*(1.5 + (shot - calm) * 0.5), w, w*3, -45)
	end
}