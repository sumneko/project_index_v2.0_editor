    
    Damage = function(from, to, damage, def, ant, data)
        local Data = {}
        if data then
            setmetatable(Data, {__index = data})
        end
        Data.from = from
        Data.to = to
        Data.sdamage = damage
        Data.odamage = damage
        Data.damage = damage
        Data.mdamage = damage
        Data.def = def
        Data.ant = ant
        return toDamage(Data)
    end

    toDamage = function(damage)            
        if damage.damage == 0 and not damage.attack then return damage end --伤害为0且不是物理攻击则不再结算,节省资源
        
        damage.time = GetTime() --伤害时间
        
        if toEvent("伤害判定", damage) then return damage end --如 远程弹道
        
        if GetUnitAbilityLevel(damage.to, |Avul|) == 1 then
            damage.damage = 0
            damage.result = "无敌"
            return damage
        end
        
        if toEvent("伤害前", damage) then return damage end --如 暴击
        
        if IsUnitDead(damage.to) then
            damage.damage = 0
            damage.result = "死亡"
            return damage
        end
        
        if not damage.skipchange and toEvent("伤害转移", damage) then return end
        
        if not damage.skipdodge and toEvent("伤害无效", damage) then --各种闪躲
            damage.damage = 0
            
            toEvent("伤害无效后", damage) --闪躲后触发
        else     
            if not damage.skipup then
                toEvent("伤害加成", damage)
            end
            
            damage.mdamage = damage.damage
            
            if not damage.skipdown then
                toEvent("伤害减免", damage)
            end
            
            if not damage.skipeffect then
                toEvent("伤害效果", damage) --法球等
            end
            
            if IsUnitDead(damage.to) then
                damage.damage = 0
                damage.result = "死亡"
                return damage
            end
            
            if damage.damage + 0.5 > jass.GetUnitState(damage.to, UNIT_STATE_LIFE) then
            
                if not damage.skipdying and toEvent("伤害致死", damage) then --返回true表示发动不屈
                    damage.damage = jass.GetUnitState(damage.to, UNIT_STATE_LIFE) - 0.5
                end
            end
            
            if not damage.skipdamaged then
                toEvent("伤害后", damage)
            end
            
        end
        
        if IsUnitDead(damage.to) then
            damage.damage = 0
            damage.result = "死亡"
            return damage
        end
        
        if damage.damage < 0 then
            damage.damage = 0
        end
        
        eventDeadFlag = true
        jass.SetUnitState(damage.to, UNIT_STATE_LIFE, jass.GetUnitState(damage.to, UNIT_STATE_LIFE) - damage.damage)
        eventDeadFlag = false
        
        toEvent("伤害结算后", damage)
        
        return damage
    end
    
    --物理攻击
    StartWeaponAttack = function(u1, u2, b, reason)
        local d = GetRandomInt(GetUnitState(u1, ConvertUnitState(0x14)), GetUnitState(u1, ConvertUnitState(0x15)))
        if b and japi.EXGetEventDamageData(6) == 5 then --混乱攻击无视50%护甲值
            Damage(u1, u2, d, true, false, {attack = true, weapon = true, def2 = 50, damageReason = "普通攻击", attackReason = reason})
        else
            Damage(u1, u2, d, true, false, {attack = true, weapon = true, damageReason = "普通攻击", attackReason = reason})    
        end
    end
    
    local trg = CreateTrigger()
    TriggerAddCondition(trg, Condition(
        function()
            if GetEventDamage() == 1 then
                StartWeaponAttack(GetEventDamageSource(), GetTriggerUnit(), b)
            end
        end
    ))
    
    --[[初始化选取地图上所有单位添加事件
    local g = CreateGroup()
    GroupEnumUnitsInRect(g, GetPlayableMapRect(), nil)
    for _,u in group(g) do
        TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_DAMAGED)
        Mark(u, "伤害系统", true)
    end
    DestroyGroup(g)
    --]]
    
    local units = {}
    
    --当有单位被攻击时,添加事件
    Event("攻击",
        function(data)
            local u = data.to
            if not units[u] then
                TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_DAMAGED)
                units[u] = true
            end
        end
    )
    
    Event("删除单位",
        function(data)
            units[data.unit] = nil
        end
    )
    
    luaDone()
