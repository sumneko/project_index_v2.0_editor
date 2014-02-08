    
    --月之石
    InitItem{
        name = "月之石",
        id = |I0C1|,
        skill = function(this)
            if this.event == "获得" then
                Recover(this.unit, 0, 1)
            elseif this.event == "失去" then
                Recover(this.unit, 0, -1)
            end
        end
    }
    
    --能量宝珠
    InitItem{
        name = "能量宝珠",
        id = |I0C2|,
        skill = function(this)
            if this.event == "获得" then
                MaxMana(this.unit, 200, true)
            elseif this.event == "失去" then
                MaxMana(this.unit, -200, true)
            end
        end
    }
    
    --幸运护符
    InitItem{
        name = "幸运护符",
        id = |I0BY|,
        skill = function(this)
            if this.event == "获得" then
                Ant(this.unit, 15)
            elseif this.event == "失去" then
                Ant(this.unit, -15)
            end
        end
    }
    
    --驱魔项链
    InitItem{
        name = "驱魔项链",
        id = |I0CI|,
        skill = function(this)
            if this.event == "获得" then
                Ant(this.unit, 30)
            elseif this.event == "失去" then
                Ant(this.unit, -30)
            end
        end,
        use = function(this)
            DestroyEffect(AddSpellEffectTarget("Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl", this.unit, "overhead"))
            CleanUnit{
                from = this.unit,
                to = this.unit,
                debuff = true,
                item = this
            }
        end,
        complex = {"幸运护符", "幸运护符"}
    }
    
    --黑刃魔剑
    InitItem{
        name = "黑刃魔剑",
        id = |I0CH|,
        skill = function(this)
            if this.event == "获得" then
                Attack(this.unit, 25)
                Ant(this.unit, 35)
                AttackStealLife(this.unit, 12, 6)
            elseif this.event == "失去" then
                Attack(this.unit, -25)
                Ant(this.unit, -35)
                AttackStealLife(this.unit, -12, -6)
            end
        end,
        skillOnly = {
            ["观察之眼"] = false,
            ["黄金之眼"] = false,
        },
        use = function(this)
            DestroyEffect(AddSpellEffectTarget("Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl", this.unit, "overhead"))
            CleanUnit{
                from = this.unit,
                to = this.unit,
                debuff = true,
                item = this
            }
            local a = GetAnt(this.unit)
            local e = AddSpecialEffectTarget("Abilities\\Spells\\Undead\\Cripple\\CrippleTarget.mdl", this.unit, "origin")
            Ant(this.unit, a)
            Wait(3,
                function()
                    DestroyEffect(e)
                    Ant(this.unit, - a)
                end
            )
        end,
        complex = {"吸血鬼之触", "驱魔项链", "魔眼之石"}
    }
    
    --主教服
    InitItem{
        name = "主教服",
        id = |I0C3|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 10, 10, 10)
                Ant(this.unit, 20)
            elseif this.event == "失去" then
                Sai(this.unit, -10, -10, -10)
                Ant(this.unit, -20)
            end
        end,
        skillOnly = {
            ["御魔结界"] = function(this)
                if this.event == "获得" then
                    local data = {unit = this.unit, power = 0, timer = CreateTimer()}
                    Mark(this.unit, this.skillname, data)
                    local func = function()
                        local max = 3
                        if Mark(data.unit, "御魔增幅") then
                            max = 5
                        end
                        data.power = data.power + 1
                        if data.power == 1 then
                            data.effect = AddSpecialEffectTarget("PsiShield.mdl", data.unit, "chest")
                        end
                        if data.power == max then
                            DestroyTimer(data.timer)
                            data.timer = false
                        else
                            SetSkillCool(this.unit, |A1A0|)
                        end
                        SetItemCharges(this.item, data.power)
                    end
                    SetSkillCool(this.unit, |A1A0|)
                    TimerStart(data.timer, 20, true, func)
                    data.func = Event("技能效果",
                        function(that)
                            if that.to == data.unit and not that.good then
                                local cost = 3
                                if that.aoe then
                                    cost = cost - 1
                                end
                                if that.dot then
                                    cost = cost - 1
                                end
                                if data.power < cost then return end
                                data.power = data.power - cost
                                SetItemCharges(this.item, data.power)
                                if not data.timer then
                                    data.timer = CreateTimer()
                                    TimerStart(data.timer, 20, true, func)
                                    SetSkillCool(this.unit, |A1A0|)
                                end
                                if data.power == 0 and data.effect then
                                    DestroyEffect(data.effect)
                                    data.effect = false
                                end
                                DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", data.unit, "origin"))
                                return true --表示取消该技能效果
                            end
                        end
                    )
                elseif this.event == "失去" then
                    local data = Mark(this.unit, this.skillname)
                    if data.timer then
                        DestroyTimer(data.timer)
                    end
                    if data.effect then
                        DestroyEffect(data.effect)
                    end
                    Event("-技能效果", data.func)
                end
            end
        },
        complex = {"能量增幅器", "幸运护符"}
    }
    
    --大主教服
    InitItem{
        name = "大主教服",
        id = |I0C5|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 20, 20, 20)
                Ant(this.unit, 20)
            elseif this.event == "失去" then
                Sai(this.unit, -20, -20, -20)
                Ant(this.unit, -20)
            end
        end,
        skillOnly = {
            ["御魔结界"] = false,
            ["御魔增幅"] = function(this)
                if this.event == "获得" then
                    Mark(this.unit, this.skillname, true)
                elseif this.event == "失去" then
                    Mark(this.unit, this.skillname, false)
                end
            end
        },
        complex = {"主教服", "能量增幅器"}
    }
    
    --演算代理装置
    InitItem{
        name = "演算代理装置",
        id = |I0C7|,
        skill = function(this)
            if this.event == "获得" then
                MaxMana(this.unit, 200, true)
                Recover(this.unit, 0, 1.5)
            elseif this.event == "失去" then
                MaxMana(this.unit, -200, true)
                Recover(this.unit, 0, -1.5)
            end
        end,
        skillOnly = {
            ["思维加速"] = function(this)
                if this.event == "获得" then
                    local data = {unit = this.unit, recover = 0}
                    Mark(this.unit, this.skillname, data)
                    data.func = Event("发动英雄技能后",
                        function(that)
                            if data.unit == that.unit then
                                if not data.timer then
                                    data.timer = CreateTimer()
                                    data.effect = AddSpecialEffectTarget("Abilities\\Spells\\Other\\ANrl\\ANrlTarget.mdl", data.unit, "origin")
                                end
                                local _, mp = GetRecover(data.unit)
                                mp = mp - data.recover
                                Recover(data.unit, 0, mp - data.recover)
                                data.recover = mp
                                TimerStart(data.timer, 5, false, data.func2)
                            end
                        end
                    )
                    data.func2 = function()
                        DestroyTimer(data.timer)
                        DestroyEffect(data.effect)
                        data.timer = false
                        Recover(data.unit, 0, - data.recover)
                        data.recover = 0
                    end
                elseif this.event == "失去" then
                    local data = Mark(this.unit, this.skillname)
                    if data.timer then
                        data.func2()
                    end
                    Event("-发动英雄技能后", data.func)
                end
            end
        },
        complex = {"月之石", "能量宝珠"}
    }
    
    --风神杖
    InitItem{
        name = "风神杖",
        id = |I0C8|,
        skill = function(this)
            if this.event == "获得" then
                MaxMana(this.unit, 200, true)
                Recover(this.unit, 0, 1.5)
            elseif this.event == "失去" then
                MaxMana(this.unit, -200, true)
                Recover(this.unit, 0, -1.5)
            end
        end,
        skillOnly = {
            ["空气散热"] = false,
            ["液冷散热"] = false,
            ["思维加速"] = false,
            ["风之祈福"] = function(this)
                if this.event == "获得" then
                    MoveSpeed(this.unit, 25)
                elseif this.event == "失去" then
                    MoveSpeed(this.unit, -25)
                end
            end
        },
        use = function(this)
            local t = 3
            if this.isitemtarget then
                this.target = this.unit
            end
            local good
            if IsUnitAlly(this.target, this.player) then
                t = t / 2
                good = true
            end
            SkillEffect{
                name = this.name,
                from = this.unit,
                to = this.target,
                good = good,
                data = this,
                item = this,
                code = function(data)
                    BlowUnit{
                        from = data.from,
                        to = data.to,
                        good = data.good,
                        item = this,
                        time = t
                    }
                end
            }
        end,
        complex = {"演算代理装置", "冷凝核心"}
    }
    
    --魔神之杖
    InitItem{
        name = "魔神之杖",
        id = |I0C9|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 0, 0, 25)
                MaxMana(this.unit, 200, true)
                Recover(this.unit, 0, 2.5)
            elseif this.event == "失去" then
                Sai(this.unit, 0, 0, -25)
                MaxMana(this.unit, -200, true)
                Recover(this.unit, 0, -2.5)
            end
        end,
        skillOnly = {
            ["思维加速"] = false,
        },
        use = function(this)
            SkillEffect{
                name = this.name,
                from = this.unit,
                to = this.target,
                data = this,
                item = this,
                code = function(data)
                    HexUnit{
                        from = data.from,
                        to = data.to,
                        time = 2.5,
                        item = this
                    }
                end
            }
        end,
        complex = {"携带能量点", "演算代理装置", "月之石"}
    }
    
