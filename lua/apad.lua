
    GetMain = function(u)
        if not IsHeroUnitId(GetUnitTypeId(u)) then
            return
        end
        return HeroMain[GetUnitPointValue(u)]
    end
    
    GetAP = function(u)
        local r = Mark(u, "AP1") or 0
        if GetMain(u) == "力量" then
            r = r + GetHeroStr(u, true)
        elseif GetMain(u) == "智力" then
            r = r + GetHeroInt(u, true)
        elseif GetMain(u) == "敏捷" then
            r = r + GetHeroAgi(u, true)
        end
        return (1 + (Mark(u, "AP2") or 0)*0.01) * r 
    end
    
    AddAP = function(u, ap1, ap2)
        if ap1 then
            Mark(u, "AP1", (Mark(u, "AP1") or 0) + ap1)
        end
        if ap2 then
            Mark(u, "AP2", (Mark(u, "AP2") or 0) + ap2)
        end
        RefreshHeroSkills(u)
        RefreshTips(u)
    end
    
    GetAD = function(u)
        local r = GetUnitState(u, ConvertUnitState(0x13))
        if GetMain(u) == "力量" then
            r = r + GetHeroStr(u, true) - GetHeroStr(u, false)
        elseif GetMain(u) == "智力" then
            r = r + GetHeroInt(u, true) - GetHeroInt(u, false)
        elseif GetMain(u) == "敏捷" then
            r = r + GetHeroAgi(u, true) - GetHeroAgi(u, false)
        end
        return r
    end
    
    luaDone()
