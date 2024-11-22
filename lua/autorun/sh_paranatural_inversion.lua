local allowed = CreateConVar("paranatural_inversion_allowed", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED)

if CLIENT then
	CreateClientConVar("paranatural_inversion_key", "19", true, true) -- default key: I
end

hook.Add("EntityTakeDamage", "paranatural_inversion", function(target, dmginfo)
    if (dmginfo:GetAttacker().paranatural_iv_inverted or false) == (target.paranatural_iv_inverted or false) then return end
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
		-- TODO: play inversion sound
    else
        ply:ChatPrint("Normal")
		-- TODO: play uninversion sound
    end
end)

local need_to_redraw = {}
local drawing = false
local invert_tbl = {["$pp_colour_inv"] = 1}
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