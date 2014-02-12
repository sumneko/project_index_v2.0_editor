
    GetCoolDown = function(u, c, lv, t)
        local cd = Mark(u, "冷却缩减")
        if not cd then return 0 end
        if type(c) == "table" then
            local c2 = c[lv or 1]
            if c2 then
                return c2 * math.min(cd, 50) * 0.01
            else
                Debug("<获取冷却缩减错误>")
                Debug("<t.name>" .. t.name)
                Debug("<lv>" .. (lv or 1))
                for i, c2 in ipairs(c) do
                    Debug("<c[" .. i .. "]>" .. c2)
                end
                return 0
            end
        else
            return c * math.min(cd, 50) * 0.01
        end
    end
    
    SetCoolDown = function(u, c)
        Mark(u, "冷却缩减", (Mark(u, "冷却缩减") or 0) + c)
        RefreshHeroSkills(u)
        RefreshTips(u)
    end
    
    luaDone()
