local dot = Material("paranatural/crosshair/dot.png")
local line = Material("paranatural/crosshair/line.png")

local shot = 0
local handled = 0
local calm = 0
local w = 4

return {
	Model = "models/paranatural/serviceweapon/c_spin.mdl",
	Primary = {ClipSize = 30, Automatic = true, Delay = 0.07, ReloadDelay = 5 / 30},
	Attack = function(self)
		self:EmitSound("paranatural/serviceweapon/spin_shot_"..math.random(1,5)..".wav", 75, 100, 1, CHAN_STATIC)

		self:ShootBullet(5, 1, 0.01)
		self:GetOwner():ViewPunch(Angle(-1 * 0.07, 0, 0))
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
		if shot > 15 then
			calm = calm - 1
			shot = 15
		end
		if self.ParanaturalZooming then
			shot = 0
			calm = 5
		end
		if self.ParanaturalReloading then
			shot = 0
			calm = ((CurTime() * 2) % 1) * 5
			draw.DrawText("Recharging", "TargetID", x, y + w*5, Color(255, 127+calm/5*127, 127+calm/5*127, 127), TEXT_ALIGN_CENTER)
		end
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(dot)
		surface.DrawTexturedRect(x-w/2, y-w/2, w, w)
		surface.SetMaterial(line)
		surface.DrawTexturedRectRotated(x-w*(3.5 + (shot - calm) * 0.2), y+w*(2.5 + (shot - calm) * 0.2), w, w*5, -55)
		surface.DrawTexturedRectRotated(x+w*(3.5 + (shot - calm) * 0.2), y+w*(2.5 + (shot - calm) * 0.2), w, w*5, 55)
		surface.DrawTexturedRectRotated(x, y-w*(4.5 + (shot - calm) * 0.2), w, w*5, 0)
	end
}