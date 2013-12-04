
    GetCoolDown = function(u, c, lv)
        local cd = Mark(u, "冷却缩减")
        if not cd then return 0 end
        if type(c) == "table" then
            return c[lv or 1] * math.min(cd, 50) * 0.01
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
