hook.Add("PopulateToolMenu", "paranatural", function()
    spawnmenu.AddToolMenuOption("Utilities", "Paranatural", "paranatural_a_settings", "Server Settings", "", "", function(panel)
        panel:Clear()
        panel:Help("This tab will NOT do anything if you don't have admin permissions on the server.")
        local allow_telekinesis = panel:CheckBox("Allow Telekinesis usage to everyone", "")
        panel:ControlHelp("If unchecked, will limit usage to only admins.")
        local allow_shield = panel:CheckBox("Allow Shield usage to everyone", "")
        panel:ControlHelp("If unchecked, will limit usage to only admins.")
        local allow_dash = panel:CheckBox("Allow Dash usage to everyone", "")
        panel:ControlHelp("If unchecked, will limit usage to only admins.")
        local allow_levitation = panel:CheckBox("Allow Levitation usage to everyone", "")
        panel:ControlHelp("If unchecked, will limit usage to only admins.")

        function allow_telekinesis:OnChange(val) LocalPlayer():ConCommand("paranatural_admincontrol allow_everyone telekinesis "..(val and 1 or 0)) end
        allow_telekinesis:SetConVar(nil)
        function allow_shield:OnChange(val) LocalPlayer():ConCommand("paranatural_admincontrol allow_everyone shield "..(val and 1 or 0)) end
        allow_shield:SetConVar(nil)
        function allow_dash:OnChange(val) LocalPlayer():ConCommand("paranatural_admincontrol allow_everyone dash "..(val and 1 or 0)) end
        allow_dash:SetConVar(nil)
        function allow_levitation:OnChange(val) LocalPlayer():ConCommand("paranatural_admincontrol allow_everyone levitation "..(val and 1 or 0)) end
        allow_levitation:SetConVar(nil)
    end)
    spawnmenu.AddToolMenuOption("Utilities", "Paranatural", "paranatural_settings", "Settings", "", "", function(panel)
        panel:Clear()
        panel:Help("Abilities toggles")
        panel:ControlHelp("Please note that toggling these while using ability will make you unable to stop using disabled ability until you turn it back off and stop using it. For example, you won't be able to let go of a prop you hold with telekinesis ability if you disabled it.")
        panel:CheckBox("Enable Telekinesis", "paranatural_telekinesis_enable")
        panel:ControlHelp("Telekinesis is an ability to grab and throw various entities.")
        panel:CheckBox("Enable Shield", "paranatural_shield_enable")
        panel:ControlHelp("Shield lets you protect yourself with props that you rip out of the ground.")
        panel:CheckBox("Enable Dash", "paranatural_dash_enable")
        panel:ControlHelp("Dash is ability that sends you in the direction you are looking with a great force, damaging everything in your way")
        panel:CheckBox("Enable Levitation", "paranatural_levitation_enable")
        panel:ControlHelp("Levitation lets you levitate above the ground and break your falling avoiding the damage.")
    end)
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

local telekinesis_enable = CreateClientConVar("paranatural_telekinesis_enable", "1", true, true)
local shield_enable = CreateClientConVar("paranatural_shield_enable", "1", true, true)
local dash_enable = CreateClientConVar("paranatural_dash_enable", "1", true, true)
local levitation_enable = CreateClientConVar("paranatural_levitation_enable", "1", true, true)
--[[
    local form_1 = CreateClientConVar("paranatural_weapon_form_1", "grip", true, true)
    local form_2 = CreateClientConVar("paranatural_weapon_form_2", "spin", true, true)
]]

local keys = {telekinesis=false, shield=false, dash=false}
hook.Add("Think", "paranatural_control", function()
    if vgui.CursorVisible() then return end
    if telekinesis_enable:GetBool() and keys.telekinesis and not input.IsButtonDown(telekinesis:GetInt()) then
        LocalPlayer():ConCommand("paranatural_control key telekinesis")
    end
    if shield_enable:GetBool() and keys.shield and not input.IsButtonDown(shield:GetInt()) then
        LocalPlayer():ConCommand("paranatural_control key shield")
    end
    if dash_enable:GetBool() and keys.dash and not input.IsButtonDown(dash:GetInt()) then
        LocalPlayer():ConCommand("paranatural_control key dash")
    end
    keys.telekinesis = input.IsButtonDown(telekinesis:GetInt())
    keys.shield = input.IsButtonDown(shield:GetInt())
    keys.dash = input.IsButtonDown(dash:GetInt())
end)
