    
    toHelp = function(u1, u2)
        if IsUnitType(u2, UNIT_TYPE_HERO) and not IsUnitType(u2, UNIT_TYPE_SUMMONED) then
            local id1 = GetPlayerId(GetOwningPlayer(u1))
            local id2 = GetPlayerId(GetOwningPlayer(u2))
            HelpTime[id1][id2] = GetTime()
        end
    end
    
