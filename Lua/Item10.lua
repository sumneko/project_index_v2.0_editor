    
    --当麻面包
    InitItem{
        name = "当麻面包",
        id = |I0CW|,
        skill = function(this)
            if this.event == "获得" then
                PDARestartHeroItemCool(this, this.name)
            end
        end,
        use = function(this)
            if this.isitemtarget then
                this.target = this.unit
            end
            local data = Mark(this.target, this.name)
            local name = this.name
            if not data then
                data = {unit = this.target, timer = CreateTimer(), time = GetTime()}
                Mark(this.target, this.name, data)
                data.func = function()
                    Mark(this.target, name, false)
                    Recover(data.unit, -20)
                    DestroyEffect(data.effect)
                    DestroyTimer(data.timer)
                    Event("-伤害后", data.func2)
                end
                Recover(this.target, 20)
                data.effect = AddSpecialEffectTarget("Abilities\\Spells\\Other\\ANrm\\ANrmTarget.mdl", data.unit, "origin")
                data.func2 = Event("伤害后",
                    function(damage)
                        if damage.to == data.unit and damage.from and damage.from ~= damage.to and IsUser(GetOwningPlayer(damage.from)) then
                            if not damage.dot or damage.damage > 20 then 
                                data.func()
                            end
                        end
                    end
                )
            end
            data.time = data.time + 10
            
            TimerStart(data.timer, data.time - GetTime(), false, data.func)
            
            if not this.pda then
                PDAStartPdaItemCool(this, this.name .. 3)
            end
        end,
        stack = 1000
    }
    
    --运动饮料
    InitItem{
        name = "运动饮料",
        id = |I0CX|,
        skill = function(this)
            if this.event == "获得" then
                PDARestartHeroItemCool(this, this.name)
            end
        end,
        use = function(this)
            if this.isitemtarget then
                this.target = this.unit
            end
            local data = Mark(this.target, this.name)
            local name = this.name
            if not data then
                data = {unit = this.target, timer = CreateTimer(), time = GetTime()}
                Mark(this.target, this.name, data)
                data.func = function()
                    Mark(this.target, name, false)
                    Recover(data.unit, 0, -5)
                    DestroyEffect(data.effect)
                    DestroyTimer(data.timer)
                    Event("-伤害后", data.func2)
                end
                Recover(this.target, 0, 5)
                data.effect = AddSpecialEffectTarget("Abilities\\Spells\\Other\\ANrl\\ANrlTarget.mdl", data.unit, "origin")
                data.func2 = Event("伤害后",
                    function(damage)
                        if damage.to == data.unit and damage.from and damage.from ~= damage.to and IsUser(GetOwningPlayer(damage.from)) then
                            if not damage.dot or damage.damage > 20 then 
                                data.func()
                            end
                        end
                    end
                )
            end
            data.time = data.time + 30
            
            TimerStart(data.timer, data.time - GetTime(), false, data.func)
            
            if not this.pda then
                PDAStartPdaItemCool(this, this.name .. 3)
            end
        end,
        stack = 1000
    }
    
    --镇定剂
    InitItem{
        name = "镇定剂",
        id = |I0CZ|,
        skill = function(this)
            if this.event == "获得" then
                PDARestartHeroItemCool(this, this.name)
            end
        end,
        use = function(this)
            Heal(this.unit, this.unit, 100, {healReason = this.name, modle = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"})
            CleanUnit{
                from = this.unit,
                to = this.unit,
                debuff = true,
                good = true
            }
            
            if not this.pda then
                PDAStartPdaItemCool(this, this.name .. 3)
            end
        end,
        stack = 1000
    }
    
    --黑子的电脑配件
    InitItem{
        name = "黑子的电脑配件",
        id = |I0D0|,
        skill = function(this)
            if this.event == "获得" then
                PDARestartHeroItemCool(this, this.name)
            end
        end,
        use = function(this)
            AttachSoundToUnit(gg_snd_BerserkerCaster, this.unit)
            StartSound(gg_snd_BerserkerCaster)
            local count = 0
            local s = 100
            local u = this.unit
            local func1 = Event("伤害提升",
                function(damage)
                    if damage.to == u then
                        damage.damage = damage.damage + damage.odamage * s / 100
                    end
                end
            )
            
            AttackSpeed(u, 150)
            MoveSpeed(u, 150)
            
            Loop(1,
                function()
                    s = s - 10
                    AttackSpeed(u, -15)
                    MoveSpeed(u, -15)
                    count = count + 1
                    if count == 10 then
                        EndLoop()
                        Event("-伤害提升", func1)
                    end
                end
            )
            
            if not this.pda then
                PDAStartPdaItemCool(this, this.name .. 3)
            end
        end,
        stack = 1000
    }
    
    --体晶
    InitItem{
        name = "体晶",
        id = |I0D1|,
        skill = function(this)
            if this.event == "获得" then
                PDARestartHeroItemCool(this, this.name)
            end
        end,
        use = function(this)
            local u = this.unit
            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIre\\AIreTarget.mdl", u, "origin"))
            Attack(u, 50)
            MaxMana(u, 300, true)
            SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MANA) + 300)
            Wait(10,
                function()
                    Attack(u, - 50)
                    local mp = GetUnitState(u, UNIT_STATE_MANA)
                    local flag
                    if mp < 500 then
                        SetUnitState(u, UNIT_STATE_MANA, 0)
                        local hp = GetUnitState(u, UNIT_STATE_LIFE)
                        if hp > 500 - mp + 1 then
                            SetUnitState(u, UNIT_STATE_LIFE, hp - (500 - mp))
                        else
                            SetUnitState(u, UNIT_STATE_LIFE, 1)
                            flag = true
                        end
                    else
                        SetUnitState(u, UNIT_STATE_MANA, mp - 500)
                    end
                    MaxMana(u, - 300, true)
                    SkillEffect{
                        from = u,
                        to = u,
                        name = this.name,
                        data = this,
                        code = function(data)
                            SilentUnit{
                                from = data.from,
                                to = data.to,
                                time = 5
                            }
                            DisarmUnit{
                                from = data.from,
                                to = data.to,
                                time = 5
                            }
                            if flag then
                                StunUnit{
                                    from = data.from,
                                    to = data.to,
                                    time = 2
                                }
                            end
                        end
                    }
                end
            )
            
            if not this.pda then
                PDAStartPdaItemCool(this, this.name .. 3)
            end
        end,
        stack = 1000
    }
    
    --扰乱之羽
    InitItem{
        name = "扰乱之羽",
        id = |I0D2|,
        skill = function(this)
            if this.event == "获得" then
                PDARestartHeroItemCool(this, this.name)
            end
        end,
        use = function(this)
            TempEffect(this.unit, "Abilities\\Spells\\Other\\Silence\\SilenceAreaBirth.mdl")
            forRange(this.unit, 300,
                function(u)
                    if EnemyFilter(this.player, u) then
                        SkillEffect{
                            from = this.unit,
                            to = u,
                            name = this.name,
                            data = this,
                            aoe = true,
                            code = function(data)
                                SilentUnit{
                                    from = data.from,
                                    to = data.to,
                                    time = 2.5,
                                    aoe = true
                                }
                            end
                        }
                    end
                end
            )
            
            if not this.pda then
                PDAStartPdaItemCool(this, this.name .. 3)
            end
        end,
        stack = 1000
    }
    
