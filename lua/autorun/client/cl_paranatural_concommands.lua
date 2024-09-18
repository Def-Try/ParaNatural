hook.Add("PopulateToolMenu", "paranatural", function()
    spawnmenu.AddToolMenuOption("Utilities", "Paranatural", "paranatural_binds", "Bindings", "", "", function(panel)
        panel:Clear()
        panel:KeyBinder("Telekinesis", "paranatural_telekinesis_key")
        panel:KeyBinder("Shield", "paranatural_shield_key")
        panel:KeyBinder("Dash", "paranatural_dash_key")
    end)
    do return end -- do not generate service weapon forms
    spawnmenu.AddToolMenuOption("Utilities", "Paranatural", "paranatural_sw_forms", "Service Weapon: Forms", "", "", function(panel)
        panel:Clear()
        panel:Help("Form #1")
        panel:Button("Grip", "paranatural_weapon_form_1", "grip")
        panel:ControlHelp("A standard sidearm form similar to a revolver. It has high accuracy and single-shot damage.")
        panel:Button("Spin", "paranatural_weapon_form_1", "spin")
        panel:ControlHelp("A rapid-fire form with lower accuracy and single shot damage, but a significantly higher rate of fire. Good for medium-range combat.")
        panel:Button("Shatter", "paranatural_weapon_form_1", "shatter")
        panel:ControlHelp("A form similar to a shotgun with a wide blast radius, but shorter effective range.")
        panel:Button("Pierce", "paranatural_weapon_form_1", "pierce")
        panel:ControlHelp("A form that charges a powerful, single shot that can one-shot or significantly damage many enemies.")
        panel:Help("Form #2")
        panel:Button("Grip", "paranatural_weapon_form_2", "grip")
        panel:ControlHelp("A standard sidearm form similar to a revolver. It has high accuracy and single-shot damage.")
        panel:Button("Spin", "paranatural_weapon_form_2", "spin")
        panel:ControlHelp("A rapid-fire form with lower accuracy and single shot damage, but a significantly higher rate of fire. Good for medium-range combat.")
        panel:Button("Shatter", "paranatural_weapon_form_2", "shatter")
        panel:ControlHelp("A form similar to a shotgun with a wide blast radius, but shorter effective range.")
        panel:Button("Pierce", "paranatural_weapon_form_2", "pierce")
        panel:ControlHelp("A form that charges a powerful, single shot that can one-shot or significantly damage many enemies.")
    end)
end)

local telekinesis = CreateClientConVar("paranatural_telekinesis_key", "30", true, false)
local shield = CreateClientConVar("paranatural_shield_key", "31", true, false)
local dash = CreateClientConVar("paranatural_dash_key", "12", true, false)
--[[
    local form_1 = CreateClientConVar("paranatural_weapon_form_1", "grip", true, true)
    local form_2 = CreateClientConVar("paranatural_weapon_form_2", "spin", true, true)
]]

local keys = {telekinesis=false, shield=false, dash=false}
hook.Add("Think", "paranatural_control", function()
    if vgui.CursorVisible() then return end
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