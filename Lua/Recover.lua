    local units = {}
    
    Loop(0.2,
        function()
            for u, r in pairs(units) do
                local hp = GetUnitState(u, UNIT_STATE_LIFE)
                if hp > 0.1 then
                    SetUnitState(u, UNIT_STATE_LIFE, hp + 0.2 * r[1])
                    SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MANA) + 0.2 * r[2])
                end
            end
        end
    )
    
    Recover = function(u, life, mana)
        if not mana then
            mana = 0
        end
        local r = units[u]
        if not r then
            units[u] = {life, mana}
            return
        end
        r[1] = r[1] + life
        r[2] = r[2] + mana
        if r[1] < 0.01 and r[1] > -0.01 and r[2] < 0.01 and r[2] > -0.01 then
            units[u] = nil
        end
    end
    
    GetRecover = function(u)
        local r = units[u]
        if r then
            return r[1], r[2]
        else
            return 0, 0
        end
    end
    
    Event("删除单位",
        function(data)
            units[data.unit] = nil
        end
    )
    
    --英雄基础回血回蓝速度为1/0.5
    Event("创建英雄",
        function(data)
            local hp, mp = 1, 0.5
            hp = hp + 0.05 * GetHeroStr(data.unit, true)
            mp = mp + 0.03 * GetHeroInt(data.unit, true)
            Recover(data.unit, hp, mp)
            AttackSpeed(data.unit, 1 * GetHeroAgi(data.unit, true)) --顺便关联敏捷与攻击速度
        end
    )
    
    --升级或改变属性时变化回血速度
    Event("英雄升级", "附加属性变化",
        function(this)
            local s, a, i
            if this.event == "英雄升级" then
                local ut = GetUnitTypeId(this.unit)
                local ou = getObj(slk.unit, ut)
                s, a, i = ou.STRplus, ou.AGIplus, ou.INTplus
                toEvent("属性变化", {unit = this.unit, str = s, agi = a, int = i})
            else
                s, a, i = this.str, this.agi, this.int
                toEvent("属性变化", this)
            end
            Recover(this.unit, 0.05 * s, 0.03 * i)
            AttackSpeed(this.unit, 1 * a) --顺便关联敏捷与攻击速度
        end
    )

    --温泉回血
    local baseRecover = {}
    local base = {gg_unit_h000_0024, gg_unit_h000_0025}
    Loop(1,
        function()
            for u, r in pairs(baseRecover) do
                if IsUnitAlly(u, PA[0]) then
                    if GetBetween(u, base[1]) > 1000 or (IsFullLife(u) and IsFullMana(u)) then
                        Recover(u, - r[1], - r[2])
                        DestroyEffect(r[3])
                        baseRecover[u] = nil
                    end
                else
                    if GetBetween(u, base[2]) > 1000 or (IsFullLife(u) and IsFullMana(u)) then
                        Recover(u, - r[1], - r[2])
                        DestroyEffect(r[3])
                        baseRecover[u] = nil
                    end
                end
            end
            forRange(base[1], 1000,
                function(u)
                    if IsUnitAlly(u, PA[0]) and GetUnitAbilityLevel(u, |Avul|) == 0 and GetUnitAbilityLevel(u, |Aloc|) == 0 and (not IsFullLife(u) or not IsFullMana(u)) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and IsUnitAlive(u) then
                        if not baseRecover[u] then
                            baseRecover[u] = {0, 0, AddSpecialEffectTarget("Abilities\\Spells\\Other\\ANrl\\ANrlTarget.mdl", u, "origin")}
                        end
                        local life = GetUnitState(u, UNIT_STATE_MAX_LIFE) * 0.03 + 50
                        local mana = GetUnitState(u, UNIT_STATE_MAX_MANA) * 0.03 + 30
                        Recover(u, life - baseRecover[u][1], mana - baseRecover[u][2])
                        baseRecover[u][1], baseRecover[u][2] = life, mana
                    end
                end
            )
            forRange(base[2], 1000,
                function(u)
                    if IsUnitAlly(u, PB[0]) and GetUnitAbilityLevel(u, |Avul|) == 0 and GetUnitAbilityLevel(u, |Aloc|) == 0 and (not IsFullLife(u) or not IsFullMana(u)) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and IsUnitAlive(u) then
                        if not baseRecover[u] then
                            baseRecover[u] = {0, 0, AddSpecialEffectTarget("Abilities\\Spells\\Other\\ANrl\\ANrlTarget.mdl", u, "origin")}
                        end
                        local life = GetUnitState(u, UNIT_STATE_MAX_LIFE) * 0.03 + 50
                        local mana = GetUnitState(u, UNIT_STATE_MAX_MANA) * 0.03 + 30
                        Recover(u, life - baseRecover[u][1], mana - baseRecover[u][2])
                        baseRecover[u][1], baseRecover[u][2] = life, mana
                    end
                end
            )
        end
    )
    
