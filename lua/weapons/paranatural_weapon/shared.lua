SWEP.Category = "Paranatural"
SWEP.Spawnable = true
SWEP.PrintName = "Service Weapon"
SWEP.Author = "googer_"
SWEP.Contact = "no"
SWEP.Purpose = "it shoots stuff"
SWEP.ViewModel = "models/paranatural/serviceweapon/c_grip.mdl"
SWEP.WorldModel = "models/paranatural/serviceweapon/c_grip.mdl"
SWEP.Slot = 0
SWEP.SlotPos = 0

SWEP.UseHands = true
SWEP.ViewModelFOV = 54

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
	["pierce"] = include("forms/pierce.lua"),
	["charge"] = include("forms/charge.lua")
}
SWEP.ParanaturalLastShot = 0
SWEP.ParanaturalNextAmmoRegen = 0
SWEP.ParanaturalForm = {Primary = {ClipSize = 0, Automatic = false, Delay = 0, ReloadDelay = 10000}, DoDrawCrosshair = function(...) end}
SWEP.ParanaturalFormName = "unknown"
SWEP.ParanaturalFormIndex = 1
SWEP.ParanaturalAttack = function(...) end
SWEP.ParanaturalThink = function(...) end
SWEP.ParanaturalReloading = false
SWEP.ParanaturalZoom = 0
SWEP.ParanaturalZooming = false
SWEP.ParanaturalJustChangedForm = 0
SWEP.ParanaturalCurrentForm = nil
SWEP.ParanaturalLastApply = 0

function SWEP:ParanaturalGetOwner()
	local owner = self:GetOwner()
	if owner:IsNPC() then return end -- NPCs not allowed to change form
	---@diagnostic disable-next-line: undefined-field
	if owner:IsNextBot() and not owner.ParanaturalCanUseServiceWeapon then return end
	---@cast owner Player
	return owner
end

function SWEP:CalcViewModelView(vm, _, _, pos, ang)
	--pos = pos + ang:Right() * 3 +
	--			ang:Forward() * 100 --+
	--			ang:Up() * -3
	--ang = ang + Angle(0, 90, 0)
    return pos, ang
end

function SWEP:Reload()
	if CurTime() - self.ParanaturalJustChangedForm < 0.25 then return end
	self.ParanaturalJustChangedForm = CurTime()
	local owner = self:ParanaturalGetOwner()
	if not owner then return end
	if self.ParanaturalFormIndex ~= 2 then
		self.ParanaturalFormIndex = 2
		self.ParanaturalCurrentForm = owner:GetInfo("paranatural_weapon_form_2")
	else
		self.ParanaturalFormIndex = 1
		self.ParanaturalCurrentForm = owner:GetInfo("paranatural_weapon_form_1")
	end
	self:ApplyForm(self.ParanaturalCurrentForm)
	if game.SinglePlayer() then self:CallOnClient("ApplyForm", self.ParanaturalCurrentForm) end
end

function SWEP:SecondaryAttack()
	if game.SinglePlayer() then self:CallOnClient("SecondaryAttack") end
	local owner = self:ParanaturalGetOwner()
	if not owner then return end
	if not self.ParanaturalZooming then
		owner:SetFOV(30, 0.05, self)
	end
	self.ParanaturalZoom = CurTime()
	self.ParanaturalZooming = true
end

function SWEP:Holster()
	if not self.ParanaturalZooming then return true end
	local owner = self:ParanaturalGetOwner()
	if not owner then return end
	if CLIENT then owner:SetFOV(0, 0.1, self) end
	self.ParanaturalZooming = false
	return true
end

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then
		self.ParanaturalReloading = true
		self:SendWeaponAnim(ACT_VM_HOLSTER)
	end
	if game.SinglePlayer() then self:CallOnClient("PrimaryAttack") end
	if self:Clip1() >= self:GetMaxClip1() then self.ParanaturalReloading = false end
	if self.ParanaturalReloading then return end
	self:SetNextPrimaryFire(CurTime() + self.ParanaturalForm.Primary.Delay)
	if self.ParanaturalAttack(self) then return end
	self.ParanaturalLastShot = CurTime()
	if CLIENT then return end
	self:TakePrimaryAmmo(1)
end
function SWEP:RenderOverride()
	self:DrawModel()
	self.WorldModel = self:GetNWString("WorldModel")
	self:SetModel(self.WorldModel)
end
function SWEP:Think()
	if self:Clip1() >= self:GetMaxClip1() and self.ParanaturalReloading then self.ParanaturalReloading = false self:SendWeaponAnim(ACT_VM_DRAW) end

	local owner = self:ParanaturalGetOwner()
	if not owner then return end

	if CurTime() - self.ParanaturalZoom > engine.TickInterval() * 5 and self.ParanaturalZooming then
		owner:SetFOV(0, 0.1, self)
		self.ParanaturalZooming = false
	end

	self.ParanaturalThink(self)

	if CLIENT then return end

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
	if CurTime() - self.ParanaturalLastApply < 1 then return end
	local form = self.ParanaturalForms[formname]
	if not form then return end
	self.ParanaturalForm = form
	self:SetNWString("WorldModel", form.Model)
	self.ParanaturalFormName = formname
	--if form.Model == self:GetModel() then return end
	self.ParanaturalCurrentForm = formname
	self.ParanaturalLastApply = CurTime()
	self:SendWeaponAnim(ACT_VM_HOLSTER)
	timer.Simple(0.5, function()
		self.ParanaturalCurrentForm = formname
		local clip = self:Clip1() / (self.Primary.ClipSize / form.Primary.ClipSize)
		self.Primary.ClipSize = form.Primary.ClipSize
		self.Primary.Automatic = form.Primary.Automatic
		self.ParanaturalAttack = form.Attack
		self.ParanaturalThink = form.Think
		local owner = self:ParanaturalGetOwner()
		if not owner then return end
		if IsValid(owner) then
			owner:GetViewModel():SetModel(form.Model)
		end
		self:SetModel(form.Model)
		self.WorldModel = form.Model
		self:SetNWString("WorldModel", self.WorldModel)
		self.ViewModel = form.Model
		self.ParanaturalForm = form
		self.ParanaturalFormName = formname
		if CLIENT then return end
		
		self:SendWeaponAnim(ACT_VM_DRAW)
		self:SetClip1(clip)
	end)
end

function SWEP:DeployClient()
	self:Deploy(true)
end

function SWEP:Deploy(called)
	if CLIENT and not called then return self:DeployClient() end
	self:CallOnClient("DeployClient")
	local owner = self:ParanaturalGetOwner()
	if not owner then return end
	self.ParanaturalCurrentForm = self.ParanaturalCurrentForm or owner:GetInfo("paranatural_weapon_form_1") or "grip"
	self:ApplyForm(self.ParanaturalCurrentForm)
	if game.SinglePlayer() then
		timer.Simple(0.5, function() if not IsValid(self) then return end self:CallOnClient("ApplyForm", self.ParanaturalCurrentForm) end)
	end
end