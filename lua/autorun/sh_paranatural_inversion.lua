local allowed = CreateConVar("paranatural_inversion_allowed", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED)

if CLIENT then
	CreateClientConVar("paranatural_inversion_key", "19", true, true) -- default key: I
end

hook.Add("EntityTakeDamage", "paranatural_inversion", function(target, dmginfo)
    if (dmginfo:GetAttacker().paranatural_iv_inverted or false) == (target.paranatural_iv_inverted or false) then return end
    if dmginfo:IsDamageType(DMG_DISSOLVE + DMG_FALL + DMG_DROWN) then return end
    local dmg = dmginfo:GetDamage()
    dmginfo:ScaleDamage(0)
    target:SetHealth(math.min(target:GetMaxHealth(), target:Health() + dmg))
end)


-- TODO: inversion animation
-- TODO: sounds
-- TODO: invert screen and controls
-- TODO: way to damage uninverted players
-- TODO: invert chat messages
-- TODO: invert sounds?

local function do_check_antimatdissolve(ent, data)
    local ent1, ent2 = ent, data.HitEntity
    if ent1 == game.GetWorld() or ent2 == game.GetWorld() then return end
    if not IsValid(ent1) or not IsValid(ent2) then return end

    if ent1:GetNWBool("paranatural_iv_inverted", false) == ent2:GetNWBool("paranatural_iv_inverted", false) then return end

    local d_ent1, d_ent2 = DamageInfo(), DamageInfo()
	d_ent1:SetDamage(ent2:Health()) d_ent2:SetDamage(ent1:Health())
	d_ent1:SetAttacker(ent1) d_ent2:SetAttacker(ent2)
	d_ent1:SetDamageType(DMG_DISSOLVE) d_ent2:SetDamageType(DMG_DISSOLVE)

	ent2:TakeDamageInfo(d_ent1)
	ent1:TakeDamageInfo(d_ent2)
end

hook.Add("PlayerButtonDown", "paranatural_inversion", function(ply, button)
    if CLIENT then return end
	if not allowed:GetBool() and not ply:IsAdmin() then return end
	if ply:GetInfoNum("paranatural_inversion_enable", 1) ~= 1 then return end
	if button ~= ply:GetInfoNum("paranatural_inversion_key", 19) then return end
	if not IsFirstTimePredicted() then return end
    ply.paranatural_iv_inverted = not (ply.paranatural_iv_inverted or false)
    ply:SetNWBool("paranatural_iv_inverted", ply.paranatural_iv_inverted)
    if ply.paranatural_iv_inverted then
        ply:ChatPrint("Inverted")
        ply.paranatural_iv_callback = ply:AddCallback("PhysicsCollide", do_check_antimatdissolve)
		-- TODO: play inversion sound
    else
        ply:ChatPrint("Normal")
        ply:RemoveCallback("PhysicsCollide", ply.paranatural_iv_callback)
        ply.paranatural_iv_callback = nil
		-- TODO: play uninversion sound
    end
end)

local need_to_redraw = {}
local drawing = false
local invert_tbl = {
    ["$pp_colour_inv"] = 1,
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}
hook.Add("PreRender", "paranatural_inversion", function() need_to_redraw = {} end)

hook.Add("PlayerDeath", "paranatural_inversion", function(ply)
	ply.paranatural_iv_inverted = false
	ply:SetNWBool("paranatural_iv_inverted", ply.paranatural_iv_inverted)
end)

hook.Add("PrePlayerDraw", "paranatural_inversion", function(ply)
    if drawing then return end
    need_to_redraw[#need_to_redraw+1] = ply
    return true
end)

hook.Add("RenderScreenspaceEffects", "paranatural_inversion", function()
    local local_inverted = LocalPlayer():GetNWBool("paranatural_iv_inverted", false)
    drawing = true
    render.ClearStencil()
    render.SetStencilWriteMask(255)
    render.SetStencilTestMask(255)
    render.SetStencilPassOperation(STENCILOPERATION_KEEP)
    render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilEnable(true)

    render.SetStencilReferenceValue(1)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
    cam.Start3D()

    local function draw(ply)
        local ply_inverted = ply:GetNWBool("paranatural_iv_inverted", false)
		hook.Run("PrePlayerDraw", ply)
            if ply_inverted ~= local_inverted and not ply.paranatural_iv_matrix_enabled then
                local mat = Matrix()
                mat:Scale(Vector(-1, -1, 1))
                ply:EnableMatrix("RenderMultiply", mat)
                ply.paranatural_iv_matrix_enabled = true
            end
			ply:DrawModel()
            
            if ply_inverted == local_inverted and ply.paranatural_iv_matrix_enabled then
                ply:DisableMatrix("RenderMultiply")
                ply.paranatural_iv_matrix_enabled = nil
            end
			if IsValid(ply:GetActiveWeapon()) then ply:GetActiveWeapon():DrawModel() end
		hook.Run("PostPlayerDraw", ply)
    end

    for _,ply in pairs(need_to_redraw) do
        if ply:GetNWBool("paranatural_iv_inverted", false) == local_inverted then continue end
        draw(ply)
    end
    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilPassOperation(STENCILOPERATION_KEEP)
	
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)

    if local_inverted then
        DrawColorModify(invert_tbl)
    end

    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

    --surface.SetMaterial(Material("color"))
    --surface.SetDrawColor(255, 255, 255, 255)
    --surface.DrawRect(0, 0, ScrW(), ScrH())

    for _,ply in pairs(need_to_redraw) do
        if ply:GetNWBool("paranatural_iv_inverted", false) == local_inverted then continue end
		draw(ply)
    end

    DrawColorModify(invert_tbl)

    render.SetStencilEnable(false)
    for _,ply in pairs(need_to_redraw) do
        if ply:GetNWBool("paranatural_iv_inverted", false) ~= local_inverted then continue end
		draw(ply)
    end
    cam.End3D()

    drawing = false
end)

local color_white = Color(255, 255, 255, 255)
hook.Add("OnPlayerChat", "paranatural_inversion", function(ply, strText)
    -- if ply == LocalPlayer() then return end

    if ply:GetNWBool("paranatural_iv_inverted", false) == LocalPlayer():GetNWBool("paranatural_iv_inverted", false) then return end

    local team_color = hook.Run("GetTeamColor", ply)
    team_color = Color(255-team_color.r, 255-team_color.g, 255-team_color.b, team_color.a)

    chat.AddText(team_color, string.reverse(ply:Name()), color_white, ": ", string.reverse(strText))

    return true
end)