    
    --皮鞭
    InitItem{
        name = "皮鞭",
        id = |I0CA|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 3, 3, 3)
                this.data = {}
                this.data.func = Event("伤害效果", "死亡",
                    function(data)
                        if data.event == "伤害效果" then
                            if data.from == this.unit and data.attack then
                                SetUnitState(this.unit, UNIT_STATE_MANA, 3 + GetUnitState(this.unit, UNIT_STATE_MANA))
                            end
                        elseif data.event == "死亡" then
                            if data.killer == this.unit then
                                SetUnitState(this.unit, UNIT_STATE_MANA, 5 + GetUnitState(this.unit, UNIT_STATE_MANA))
                            end
                        end
                    end
                )
            elseif this.event == "失去" then
                Sai(this.unit, -3, -3, -3)
                Event("-伤害效果", "-死亡", this.data.func)
            end
        end,
        complex = {"呱太", "呱太", "呱太"}
    }
    
    --净化宝珠
    InitItem{
        name = "净化宝珠",
        id = |I0CB|,
        skill = function(this)
            if this.event == "获得" then
                this.data = {}
                this.data.func = Event("伤害效果",
                    function(damage)
                        if damage.from == this.unit and damage.attack then
                            local mana, d = 12, 10
                            if IsUnitRange(this.unit) then
                                mana, d = 8, 6
                            end
                            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Feedback\\ArcaneTowerAttack.mdl", damage.to, "origin"))
                            SetUnitState(damage.to, UNIT_STATE_MANA, - mana + GetUnitState(damage.to, UNIT_STATE_MANA))
                            Damage(damage.from, damage.to, d, false, true, {item = this, damageReason = this.name})
                        end
                    end
                )
            elseif this.event == "失去" then
                Event("-伤害效果", this.data.func)
            end
        end
    }
    
    --寒玉
    InitItem{
        name = "寒玉",
        id = |I0CC|,
        skill = function(this)
            if this.event == "获得" then
                this.data = {power = 0}
                this.data.func = Event("伤害效果",
                    function(damage)
                        if damage.from == this.unit and damage.attack then
                            local max = 3
                            if IsUnitRange(this.unit) then
                                max = 5
                            end
                            if this.data.power >= max then
                                this.data.power = 0
                                TempEffect(damage.to, "Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl")
                                forRange(damage.to, 250,
                                    function(u)
                                        if EnemyFilter(this.player, u) then
                                            SkillEffect{
                                                name = this.name,
                                                from = damage.from,
                                                to = u,
                                                data = this,
                                                item = this,
                                                aoe = true,
                                                code = function(data)
                                                    SlowUnit{
                                                        from = data.from,
                                                        to = data.to,
                                                        time = 0.5,
                                                        move = 50,
                                                        aoe = true,
                                                        item = this
                                                    }
                                                    Damage(data.from, data.to, 50, false, true, {aoe = true, item = this, damageReason = this.name})
                                                end
                                            }
                                        end
                                    end
                                )
                            else
                                this.data.power = this.data.power + 1
                            end
                            SetItemCharges(this.item, this.data.power)
                        end
                    end
                )
            elseif this.event == "失去" then
                Event("-伤害效果", this.data.func)
            end
        end
    }
    
    --霜刃
    InitItem{
        name = "霜刃",
        id = |I0CD|,
        skill = function(this)
            if this.event == "获得" then
                Attack(this.unit, 15)
                MaxLife(this.unit, 300, true)
                this.data = {power = 0}
                this.data.func = Event("伤害效果",
                    function(damage)
                        if damage.from == this.unit and damage.attack then
                            local max = 3
                            if IsUnitRange(this.unit) then
                                max = 5
                            end
                            if this.data.power >= max then
                                this.data.power = 0
                                TempEffect(damage.to, "Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl")
                                forRange(damage.to, 250,
                                    function(u)
                                        if EnemyFilter(this.player, u) then
                                            SkillEffect{
                                                name = this.name,
                                                from = damage.from,
                                                to = u,
                                                data = this,
                                                item = this,
                                                aoe = true,
                                                code = function(data)
                                                    SlowUnit{
                                                        from = data.from,
                                                        to = data.to,
                                                        time = 0.75,
                                                        move = 50,
                                                        aoe = true,
                                                        item = this
                                                    }
                                                    Damage(data.from, data.to, 80, false, true, {aoe = true, item = this, damageReason = this.name})
                                                end
                                            }
                                        end
                                    end
                                )
                            else
                                this.data.power = this.data.power + 1
                            end
                            SetItemCharges(this.item, this.data.power)
                        end
                    end
                )
            elseif this.event == "失去" then
                Attack(this.unit, -15)
                MaxLife(this.unit, -300, true)
                Event("-伤害效果", this.data.func)
            end
        end,
        complex = {"寒玉", "菜刀", "生命宝珠"}
    }
    
    --亚德里亚之枪
    InitItem{
        name = "亚德里亚之枪",
        id = |I0CE|,
        skill = function(this)
            if this.event == "获得" then
                Attack(this.unit, 55)
                AttackSpeed(this.unit, 15)
                MaxLife(this.unit, 300, true)
                this.data = {power = 0}
                this.data.func = Event("伤害效果",
                    function(damage)
                        if damage.from == this.unit and damage.attack then
                            local max = 3
                            if IsUnitRange(this.unit) then
                                max = 5
                            end
                            if this.data.power >= max then
                                this.data.power = 0
                                TempEffect(damage.to, "Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl")
                                forRange(damage.to, 250,
                                    function(u)
                                        if EnemyFilter(this.player, u) then
                                            SkillEffect{
                                                name = this.name,
                                                from = damage.from,
                                                to = u,
                                                data = this,
                                                item = this,
                                                aoe = true,
                                                code = function(data)
                                                    SlowUnit{
                                                        from = data.from,
                                                        to = data.to,
                                                        time = 1,
                                                        move = 50,
                                                        aoe = true,
                                                        item = this
                                                    }
                                                    Damage(data.from, data.to, 120, false, true, {aoe = true, item = this, damageReason = this.name})
                                                end
                                            }
                                        end
                                    end
                                )
                            else
                                this.data.power = this.data.power + 1
                            end
                            SetItemCharges(this.item, this.data.power)
                        end
                    end
                )
            elseif this.event == "失去" then
                Attack(this.unit, -55)
                AttackSpeed(this.unit, -15)
                MaxLife(this.unit, -300, true)
                Event("-伤害效果", this.data.func)
            end
        end,
        complex = {"霜刃", "长枪", "加速手套"}
    }
    
    --净化之刃
    InitItem{
        name = "净化之刃",
        id = |I0CF|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 0, 12, 12)
                this.data = {}
                this.data.func = Event("伤害效果",
                    function(damage)
                        if damage.from == this.unit and damage.attack then
                            local mana, d = 18, 15
                            if IsUnitRange(this.unit) then
                                mana, d = 12, 9
                            end
                            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Feedback\\ArcaneTowerAttack.mdl", damage.to, "origin"))
                            SetUnitState(damage.to, UNIT_STATE_MANA, - mana + GetUnitState(damage.to, UNIT_STATE_MANA))
                            Damage(damage.from, damage.to, d, false, true, {item = this, damageReason = this.name})
                        end
                    end
                )
            elseif this.event == "失去" then
                Sai(this.unit, 0, -12, -12)
                Event("-伤害效果", this.data.func)
            end
        end,
        use = function(this)
            if this.isitemtarget then
                this.target = this.unit
            end
            SkillEffect{
                name = this.name,
                from = this.unit,
                to = this.target,
                data =this,
                item = this,
                code = function(data)
                    if IsUnitAlly(data.to, GetOwningPlayer(data.from)) then
                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Orc\\Purge\\PurgeBuffTarget.mdl", data.to, "origin"))
                        CleanUnit{
                            from = data.from,
                            to = data.to,
                            item = this,
                            debuff = true
                        }
                    else
                        CleanUnit{
                            from = data.from,
                            to = data.to,
                            item = this,
                            buff = true
                        }
                        BenumbUnit{
                            from = data.from,
                            to = data.to,
                            time = 1.5
                        }
                        if IsUnitType(data.to, UNIT_TYPE_SUMMONED) then
                            Damage(data.from, data.to, 1000, false, true, {item = this, damageReason = this.name})
                        end
                    end
                end
            }
        end,
        complex = {"净化宝珠", "敏捷之靴", "智力挂饰"}
    }
    
    --光电子剑
    InitItem{
        name = "光电子剑",
        id = |I0CG|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 0, 15, 15)
                AttackSpeed(this.unit, 45)
                this.data = {}
                this.data.func = Event("伤害效果",
                    function(damage)
                        if damage.from == this.unit and damage.attack then
                            local mana, d = 24, 20
                            if IsUnitRange(this.unit) then
                                mana, d = 16, 12
                            end
                            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Feedback\\ArcaneTowerAttack.mdl", damage.to, "origin"))
                            SetUnitState(damage.to, UNIT_STATE_MANA, - mana + GetUnitState(damage.to, UNIT_STATE_MANA))
                            Damage(damage.from, damage.to, d, false, true, {item = this, damageReason = this.name})
                        end
                    end
                )
            elseif this.event == "失去" then
                Sai(this.unit, 0, -15, -15)
                AttackSpeed(this.unit, -45)
                Event("-伤害效果", this.data.func)
            end
        end,
        use = function(this)
            if this.isitemtarget then
                this.target = this.unit
            end
            SkillEffect{
                name = this.name,
                from = this.unit,
                to = this.target,
                data =this,
                item = this,
                code = function(data)
                    if IsUnitAlly(data.to, GetOwningPlayer(data.from)) then
                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Orc\\Purge\\PurgeBuffTarget.mdl", data.to, "origin"))
                        CleanUnit{
                            from = data.from,
                            to = data.to,
                            item = this,
                            debuff = true
                        }
                    else
                        CleanUnit{
                            from = data.from,
                            to = data.to,
                            item = this,
                            buff = true
                        }
                        BenumbUnit{
                            from = data.from,
                            to = data.to,
                            time = 2
                        }
                        if IsUnitType(data.to, UNIT_TYPE_SUMMONED) then
                            Damage(data.from, data.to, 2000, false, true, {item = this, damageReason = this.name})
                        end
                    end
                end
            }
        end,
        complex = {"净化之刃", "唤灵之笛"}
    }
    
    --伪焰形剑
    InitItem{
        name = "伪焰形剑",
        id = |I0CJ|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 3, 3, 3)
                Attack(this.unit, 10)
                AddAP(this.unit, 15)
                AttackStealLife(this.unit, 10, 5)
                this.data = {}
                this.data.func = Event("伤害效果", "死亡",
                    function(data)
                        if data.event == "伤害效果" then
                            if data.from == this.unit and data.attack then
                                SetUnitState(this.unit, UNIT_STATE_MANA, 3 + GetUnitState(this.unit, UNIT_STATE_MANA))
                                forRange(data.to, 300,
                                    function(u)
                                        if u ~= data.to and EnemyFilter(this.player, u, {["魔免"] = true}) then
                                            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl", u, "overhead"))
                                            Damage(this.unit, u, data.damage * 0.25, false, false, {aoe = true, arry = true, item = this, damageReason = this.name})
                                        end
                                    end
                                )
                            end
                        elseif data.event == "死亡" then
                            if data.killer == this.unit then
                                SetUnitState(this.unit, UNIT_STATE_MANA, 5 + GetUnitState(this.unit, UNIT_STATE_MANA))
                            end
                        end
                    end
                )
            elseif this.event == "失去" then
                Sai(this.unit, -3, -3, -3)
                Attack(this.unit, -10)
                AddAP(this.unit, -15)
                AttackStealLife(this.unit, -10, -5)
                Event("-伤害效果", "-死亡", this.data.func)
            end
        end,
        complex = {"吸血鬼指环", "皮鞭", "菜刀", "黑曜石"}
    }
    
    --焰形剑
    InitItem{
        name = "焰形剑",
        id = |I0CK|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 6, 6, 6)
                Attack(this.unit, 20)
                AddAP(this.unit, 30)
                AttackStealLife(this.unit, 25, 15)
                this.data = {}
                this.data.func = Event("伤害效果", "死亡",
                    function(data)
                        if data.event == "伤害效果" then
                            if data.from == this.unit and data.attack then
                                SetUnitState(this.unit, UNIT_STATE_MANA, 6 + GetUnitState(this.unit, UNIT_STATE_MANA))
                                forRange(data.to, 350,
                                    function(u)
                                        if u ~= data.to and EnemyFilter(this.player, u, {["魔免"] = true}) then
                                            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayDamage.mdl", u, "overhead"))
                                            Damage(this.unit, u, data.damage * 0.5, false, false, {aoe = true, arry = true, item = this, damageReason = this.name})
                                        end
                                    end
                                )
                            end
                        elseif data.event == "死亡" then
                            if data.killer == this.unit then
                                SetUnitState(this.unit, UNIT_STATE_MANA, 10 + GetUnitState(this.unit, UNIT_STATE_MANA))
                            end
                        end
                    end
                )
            elseif this.event == "失去" then
                Sai(this.unit, -6, -6, -6)
                Attack(this.unit, -20)
                AddAP(this.unit, -30)
                AttackStealLife(this.unit, -25, -15)
                Event("-伤害效果", "-死亡", this.data.func)
            end
        end,
        complex = {"伪焰形剑", "伪焰形剑"}
    }
