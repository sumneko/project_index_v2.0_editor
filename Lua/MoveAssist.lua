    
    local g = {}
    
    SetUnitMoveSpeed = function(u, ms)
        if ms > 1000 then
            ms = 1000
        end
        if ms > 522 then
            if g[u] then
                g[u][3] = ms / 522
            else
                g[u] = {GetUnitX(u), GetUnitY(u), ms / 522} --结构为 上次的x坐标, 上次的y坐标, 倍率
            end
            ms = 522
        else
            g[u] = nil
        end
        jass.SetUnitMoveSpeed(u, ms)
    end
    
    Loop(0.01,
        function()
            for u, t in pairs(g) do
                local x, y = GetUnitX(u), GetUnitY(u)
                local now = {x, y}
                local l = GetBetween(now, t)
                if l > 0.001 and l < 5.3 then
                    local a = GetBetween(t, now, true)
                    t[1], t[2] = x + l * Cos(a), y + l * Sin(a)
                    SetUnitX(u, t[1])
                    SetUnitY(u, t[2])
                else
                    t[1], t[2] = x, y
                end
            end
        end
    )
    
    GetUnitMoveSpeed = function(u)
        local t = g[u]
        if t then
            return jass.GetUnitMoveSpeed(u) * t[3]
        end
        return jass.GetUnitMoveSpeed(u)
    end
    
    Event("删除单位",
        function(data)
            g[data.unit] = nil
        end
    )
    
