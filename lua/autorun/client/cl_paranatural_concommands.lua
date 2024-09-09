hook.Add("PopulateToolMenu", "paranatural", function()
    spawnmenu.AddToolMenuOption("Utilities", "paranatural", "paranatural", "Paranatural Binds", "", "", function(panel)
		panel:Clear()
        panel:KeyBinder("Telekinesis", "paranatural_telekinesis_key")
        panel:KeyBinder("Shield", "paranatural_shield_key")
        panel:KeyBinder("Dash", "paranatural_dash_key")
	end)
end)

local telekinesis = CreateClientConVar("paranatural_telekinesis_key", "30", true, false)
local shield = CreateClientConVar("paranatural_shield_key", "31", true, false)
local dash = CreateClientConVar("paranatural_dash_key", "12", true, false)

local keys = {telekinesis=false, shield=false, dash=false}
hook.Add("Think", "paranatural_control", function()
    if keys.telekinesis and not input.IsKeyDown(telekinesis:GetInt()) then
        LocalPlayer():ConCommand("paranatural_telekinesis")
    end
    if keys.shield and not input.IsKeyDown(shield:GetInt()) then
        LocalPlayer():ConCommand("paranatural_shield")
    end
    if keys.dash and not input.IsKeyDown(dash:GetInt()) then
        LocalPlayer():ConCommand("paranatural_dash")
    end
    keys.telekinesis = input.IsKeyDown(telekinesis:GetInt())
    keys.shield = input.IsKeyDown(shield:GetInt())
    keys.dash = input.IsKeyDown(dash:GetInt())
end)