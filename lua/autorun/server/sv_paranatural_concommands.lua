concommand.Add("paranatural_control", function(ply, cmd, args)
    if args[1] == "key" then
        if args[2] == "telekinesis" then
            ply.paranatural_tk_control = true
            return
        end
        if args[2] == "shield" then
            ply.paranatural_sh_control = true
            return
        end
        if args[2] == "dash" then
            ply.paranatural_ds_control = true
            return
        end
    end
end)

concommand.Add("paranatural_admincontrol", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
    if args[1] == "allow_everyone" then
        if args[2] == "telekinesis" then
            _G.paranatural.telekinesis_allowed:SetBool(args[3] == 1)
            return
        end
        if args[2] == "shield" then
            _G.paranatural.shield_allowed:SetBool(args[3] == 1)
            return
        end
        if args[2] == "dash" then
            _G.paranatural.dash_allowed:SetBool(args[3] == 1)
            return
        end
        if args[2] == "levitation" then
            _G.paranatural.levitation_allowed:SetBool(args[3] == 1)
            return
        end
    end
end)