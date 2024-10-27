local dot = Material("paranatural/crosshair/dot.png")
local line = Material("paranatural/crosshair/line.png")

local shot = 0
local handled = 0
local calm = 0
local w = 4
return {
	Model = "models/paranatural/serviceweapon/c_charge.mdl",
	Primary = {ClipSize = 3, Automatic = false, Delay = 0.4, ReloadDelay = 5 / 3},
	Attack = function(self)
		self:EmitSound("paranatural/serviceweapon/charge_shot.wav", 75, 100, 1, CHAN_WEAPON)
		if SERVER then
			local g = ents.Create("npc_grenade_frag")
			g:SetPos(util.QuickTrace(self:GetOwner():EyePos(), self:GetOwner():GetAimVector() * 50, self:GetOwner()).HitPos - self:GetOwner():GetAimVector()*5)
			g:SetAngles(AngleRand())
			g:Spawn()
			g:GetPhysicsObject():SetVelocity(self:GetOwner():GetAimVector() * 500 + self:GetOwner():GetVelocity())
			g:Activate()
			g:Input("SetTimer", self:GetOwner(), self, 5)
		end
		self:GetOwner():ViewPunch(Angle(-1, 0, 0))
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
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

		surface.DrawTexturedRectRotated(x+w*(3.5 + (shot - calm) * 0.5), y, w, w*8, -25)
		surface.DrawTexturedRectRotated(x-w*(3.5 + (shot - calm) * 0.5), y, w, w*8, 25)
		surface.DrawTexturedRectRotated(x, y-w*3.5, w, w*8, 90)
	end
}