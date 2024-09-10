SWEP.Category = "Paranatural"
SWEP.Spawnable = true
SWEP.PrintName = "Service Weapon"
SWEP.Author = "googer_"
SWEP.Contact = "no"
SWEP.Purpose = "it shoots stuff"
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.Slot = 0
SWEP.SlotPos = 0

game.AddAmmoType({
	name = "BULLET_PARANATURAL",
	dmgtype = DMG_BULLET, 
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	maxcarry = 120,
	minsplash = 10,
	maxsplash = 5
})

SWEP.Primary = {Ammo = "BULLET_PARANATURAL", ClipSize = 1, DefaultClip = 0, Automatic = false}
SWEP.Secondary = {Ammo = "none", ClipSize = 0, DefaultClip = 0, Automatic = true}
SWEP.AutoSwitchFrom = false
SWEP.AccurateCrosshair = true

SWEP.ParanaturalForms = {
	["grip"] = include("forms/grip.lua"),
	["shatter"] = include("forms/shatter.lua"),
	["spin"] = include("forms/spin.lua"),
	["pierce"] = include("forms/pierce.lua")
}
SWEP.ParanaturalLastShot = 0
SWEP.ParanaturalNextAmmoRegen = 0
SWEP.ParanaturalForm = {Primary = {ClipSize = 0, Automatic = false, Delay = 0}, DoDrawCrosshair = function() end}
SWEP.ParanaturalFormName = "unknown"
SWEP.ParanaturalFormIndex = 1
SWEP.ParanaturalAttack = function() end
SWEP.ParanaturalThink = function() end
SWEP.ParanaturalReloading = false
SWEP.ParanaturalZoom = 0
SWEP.ParanaturalZooming = false
SWEP.ParanaturalJustChangedForm = 0
SWEP.ParanaturalCurrentForm = nil

function SWEP:Reload()
	if CurTime() - self.ParanaturalJustChangedForm < 0.25 then return end
	self.ParanaturalJustChangedForm = CurTime()
	if self.ParanaturalFormIndex ~= 2 then
		self.ParanaturalFormIndex = 2
		self.ParanaturalCurrentForm = self:GetOwner():GetInfo("paranatural_weapon_form_2")
	else
		self.ParanaturalFormIndex = 1
		self.ParanaturalCurrentForm = self:GetOwner():GetInfo("paranatural_weapon_form_1")
	end
	self:ApplyForm(self.ParanaturalCurrentForm)
	self:CallOnClient("ApplyForm", self.ParanaturalCurrentForm)
end

function SWEP:SecondaryAttack()
	self:CallOnClient("SecondaryAttack")
	if SERVER then self:GetOwner():SetFOV(30, 0.05, self) end
	self.ParanaturalZoom = CurTime()
	self.ParanaturalZooming = true
end

function SWEP:Holster()
	if not self.ParanaturalZooming then return true end
	if SERVER then self:GetOwner():SetFOV(0, 0.1, self) end
	self.ParanaturalZooming = false
	return true
end

function SWEP:PrimaryAttack()
	self:CallOnClient("PrimaryAttack")
	if self:Clip1() <= 0 then
		self.ParanaturalReloading = true
	end
	if self:Clip1() >= self:GetMaxClip1() then self.ParanaturalReloading = false end
	if self.ParanaturalReloading then return end
	self:SetNextPrimaryFire(CurTime() + self.ParanaturalForm.Primary.Delay)
	self.ParanaturalLastShot = CurTime()
	if CLIENT then return end
	self.ParanaturalAttack(self)
	self:TakePrimaryAmmo(1)
end
function SWEP:Think()
	if self:Clip1() >= self:GetMaxClip1() then self.ParanaturalReloading = false end

	if CurTime() - self.ParanaturalZoom > FrameTime() * 5 and self.ParanaturalZooming then
		if SERVER then self:GetOwner():SetFOV(0, 0.1, self) end
		self.ParanaturalZooming = false
	end

	if CLIENT then return end

	self.ParanaturalThink(self)

	if CurTime() - self.ParanaturalLastShot < 3 and not self.ParanaturalReloading then return end
	if CurTime() - self.ParanaturalNextAmmoRegen < self.ParanaturalForm.Primary.ReloadDelay then return end
	if self:Clip1() >= self:GetMaxClip1() then return end
	self.ParanaturalNextAmmoRegen = CurTime()
	self:SetClip1(self:Clip1() + 1)
end
function SWEP:DoDrawCrosshair(x, y)
	render.PushFilterMin(2) render.PushFilterMag(2)
	self.ParanaturalForm.DoDrawCrosshair(self, x, y)
	render.PopFilterMin() render.PopFilterMag()
	return true
end

function SWEP:ApplyForm(formname)
	self.ParanaturalCurrentForm = formname
	print(self.ParanaturalCurrentForm)
	local form = self.ParanaturalForms[formname]
	print(not form)
	if not form then return end
	local clip = self:Clip1() / (self.Primary.ClipSize / form.Primary.ClipSize)
	self.Primary.ClipSize = form.Primary.ClipSize
	self.Primary.Automatic = form.Primary.Automatic
	self.ParanaturalAttack = form.Attack
	self.ParanaturalThink = form.Think
	self.ParanaturalForm = form
	self.ParanaturalFormName = formname
	if CLIENT then return end
	self:SetClip1(clip)
end

function SWEP:Deploy()
	self.ParanaturalCurrentForm = self.ParanaturalCurrentForm or self:GetOwner():GetInfo("paranatural_weapon_form_1")
	self:ApplyForm(self.ParanaturalCurrentForm)
	timer.Simple(0.1, function() self:CallOnClient("ApplyForm", self.ParanaturalCurrentForm) end)
end