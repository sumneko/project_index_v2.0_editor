    
    local heroBaseAnt = 30
    local unitBaseAnt = 0
    local structBaseAnt = 200
    
    GetAnt = function(u)
        local ant = (Mark(u, "魔抗1") or 0) * (1 + 0.01*(Mark(u, "魔抗2") or 0))
        if IsUnitType(u, UNIT_TYPE_STRUCTURE) then
            ant = ant + structBaseAnt
        elseif IsHeroUnitId(GetUnitTypeId(u)) then
            ant = ant + heroBaseAnt
        else
            ant = ant + unitBaseAnt
        end
        return ant
    end
    
    Ant = function(u, a1, a2)
        if a1 then
            Mark(u, "魔抗1", (Mark(u, "魔抗1") or 0) + a1)
        end
        if a2 then
            Mark(u, "魔抗2", (Mark(u, "魔抗2") or 0) + a2)
        end
    end
    
    Event("伤害前",
        function(damage)
            if damage.ant then
                local ant = math.max(0, GetAnt(damage.to))
                damage.damage = damage.damage / (1 + 0.01*ant)
            end
        end
    )
    
    luaDone()
