SWEP.PrintName = "Telekinesis"
SWEP.Category = "Paranatural"
SWEP.Spawnable = false

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""

SWEP.DrawAmmo = false
SWEP.Slot = 7
SWEP.SlotPos = 128

SWEP.Primary = {Ammo = "none", ClipSize = -1, DefaultClip = -1, Automatic = false}
SWEP.Secondary = {Ammo = "none", ClipSize = -1, DefaultClip = -1, Automatic = false}

function SWEP:Deploy()
end
function SWEP:Think()
	self:SetHoldType("magic")
end

function SWEP:PrimaryAttack()
end
function SWEP:SecondaryAttack()
end