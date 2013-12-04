    
    Event("攻击",
        function(data)
            local u1 = data.from
            local u2 = data.to
            if GetUnitAbilityLevel(u1, 'Aloc') == 0 --非蝗虫
            and IsUnitAlly(u2, GetOwningPlayer(u1)) --队友
            and GetOwningPlayer(u2) ~= Player(15) then --不为中立被动
                local r = GetUnitState(u2, UNIT_STATE_LIFE) / GetUnitState(u2, UNIT_STATE_MAX_LIFE)
                if r > 0.5 or (r > 0.1 and (IsUnitType(u2, UNIT_TYPE_HERO) or IsUnitType(u2, UNIT_TYPE_STRUCTURE))) then
                    IssueImmediateOrder(u1, "stop")
                end
            end
        end
    )
    
    luaDone()
