util.AddNetworkString("paranatural")

net.Receive("paranatural", function(_, ply)
    local req = net.ReadUInt(1)
    if req == 0 then
        local cv = net.ReadString()
        if not cv:StartsWith("paranatural_") then return end
        net.Start("paranatural")
            net.WriteString(cv)
            net.WriteString(GetConVar(cv):GetString())
        net.Send(ply)
    end
    if req == 1 then
        if not ply:IsAdmin() then return end
        local cv = net.ReadString()
        if not cv:StartsWith("paranatural_") then return end
        GetConVar(cv):SetString(net.ReadString())
    end
end)