AddCSLuaFile()
AddCSLuaFile("autorun/client/cl_paranatural_concommands.lua")

if CLIENT then
	local paranatural_thirdperson = CreateConVar("paranatural_thirdperson", 0, FCVAR_ARCHIVE)
	local fov_cv = GetConVar("fov_desired")
	local pixvis = util.GetPixelVisibleHandle()

	hook.Add("CalcView", "paranatural_thirdperson", function(ply, origin, angles, fov, znear, zfar)
		local diff = (fov_cv:GetFloat() - fov) / 2
		if not paranatural_thirdperson:GetBool() then return end
		local trace = util.QuickTrace(origin, -((angles:Forward() * 100) - (angles:Right() * 50)), ply)
		local view = {
			origin = (not trace.Hit and trace.HitPos or (trace.HitPos + ((angles:Forward() * 5) - (angles:Right() * 5)))) - (angles:Right() * diff),
			angles = angles,
			fov = fov,
			drawviewer = true
		}

		return view
	end)
	hook.Add("HUDShouldDraw", "paranatural_thirdperson", function(item)
		if not paranatural_thirdperson:GetBool() then return end
        if item == "CHudCrosshair" then return false end
    end)
    hook.Add("PostDrawTranslucentRenderables", "paranatural_thirdperson", function()
    	if not paranatural_thirdperson:GetBool() then return end
    	local ply = LocalPlayer()
    	local wep = ply:GetActiveWeapon()
        if wep.DrawCrosshair == false then return end
        if not ply:Alive() then return end
        render.SetColorMaterial()
        local trace = ply:GetEyeTrace()
        local scr_data = trace.HitPos:ToScreen()

        local a = util.PixelVisible(trace.HitPos + vector_up, 16, pixvis)
        surface.SetAlphaMultiplier(a)
        cam.Start2D()
        	if wep.DoDrawCrosshair then
        		wep:DoDrawCrosshair(scr_data.x, scr_data.y)
        	else
		        surface.DrawCircle(scr_data.x, scr_data.y, 1, Color(255, 255, 255, 255))
		        surface.DrawCircle(scr_data.x, scr_data.y, 2, Color(255, 255, 255, 255))
		        surface.DrawCircle(scr_data.x, scr_data.y, 3, Color(0, 0, 0, 255))
		        surface.DrawCircle(scr_data.x, scr_data.y, 4, Color(0, 0, 0, 255))
	       	end
        cam.End2D()
        surface.SetAlphaMultiplier(1)
    end)
end