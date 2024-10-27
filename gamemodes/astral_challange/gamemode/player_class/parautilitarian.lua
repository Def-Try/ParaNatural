AddCSLuaFile()

DEFINE_BASECLASS("player_default")
 
local PLAYER = {} 
PLAYER.WalkSpeed = 200
PLAYER.RunSpeed  = 400
function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
	self.Player:Give("paranatural_weapon")
end
player_manager.RegisterClass("parautilitarian", PLAYER, "player_default")