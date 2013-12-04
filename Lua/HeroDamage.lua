
    DamageStat = {}
    
    DamageTime = {}
    
    HelpTime = {}
    
    DamageWood = {}
    
    DamageWoodS = {} --存在感获得率
    
    for id = 0, 11 do
        DamageStat[id] = {}
        DamageStat[id][1] = 0 --伤害输出
        DamageStat[id][2] = 0 --最大伤害输出
        DamageStat[id][3] = 0 --承受伤害
        DamageStat[id][4] = 0 --最大承受伤害
        DamageTime[id] = {}
        HelpTime[id] = {}
        for id2 = 0, 11 do
            DamageStat[id][id2] = 0
            DamageTime[id][id2] = -1000
            HelpTime[id][id2] = -1000
        end
        DamageWood[id] = 0
        DamageWoodS[id] = 1
    end
    
    Event("伤害后",
        function(damage)
            if IsUnitType(damage.to, UNIT_TYPE_HERO) and not IsUnitType(damage.to, UNIT_TYPE_SUMMONED) then
                
                local p1 = GetOwningPlayer(damage.from)
                local p2 = GetOwningPlayer(damage.to)
                
                if IsUser(p1) and IsUser(p2) then
                    
                    local id1 = GetPlayerId(p1)
                    local id2 = GetPlayerId(p2)
                    
                    DamageStat[id1][1] = DamageStat[id1][1] + damage.damage
                    if damage.damage > DamageStat[id1][2] then
                        DamageStat[id1][2] = damage.damage
                    end
                    DamageStat[id2][3] = DamageStat[id2][3] + damage.damage
                    if damage.damage > DamageStat[id2][4] then
                        DamageStat[id2][4] = damage.damage
                    end
                    DamageStat[id1][id2] = DamageStat[id1][id2] + damage.damage
                    DamageTime[id1][id2] = GetTime()
                    
                    --存在感
                    local r = damage.damage / GetUnitState(damage.to, UNIT_STATE_MAX_LIFE) * 100
                    DamageWood[id1] = DamageWood[id1] + r * DamageWoodS[id1]
                    DamageWood[id2] = DamageWood[id2] + r
                    local a, b = math.floor(DamageWood[id1]), math.floor(DamageWood[id2])
                    DamageWood[id1] = DamageWood[id1] - a
                    DamageWood[id2] = DamageWood[id2] - b
                    SetPlayerState(p1, PLAYER_STATE_RESOURCE_LUMBER, a + GetPlayerState(p1, PLAYER_STATE_RESOURCE_LUMBER))
                    SetPlayerState(p2, PLAYER_STATE_RESOURCE_LUMBER, b + GetPlayerState(p2, PLAYER_STATE_RESOURCE_LUMBER))
                end
            end
        end
    )
    
    --记录游戏中最近的1000次伤害数据
    DamageStack = {}
    DamageStackTop = 0
    
    Event("伤害后",
        function(damage)
            if DamageStackTop == 1000 then
                DamageStackTop = 1
            else
                DamageStackTop = DamageStackTop + 1
            end
            DamageStack[DamageStackTop] = damage
            --伤害文字
            DamageText(damage)
        end
    )

