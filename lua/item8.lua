    
    --空气净化装置
    InitItem{
        name = "空气净化装置",
        id = |I0CL|,
        skill = function(this)
            if this.event == "获得" then
                Wage(this.player, 0.25)
                Recover(this.unit, 2)
            elseif this.event == "失去" then
                Wage(this.player, -0.25)
                Recover(this.unit, -2)
            end
        end,
        skillOnly = {
            ["空气净化"] = function(this)
                if this.event == "获得" then
                    UnitAddAbility(this.unit, |A18R|)
                    UnitMakeAbilityPermanent(this.unit, true, |A18R|)
                    local data = {unit, recover = {}}
                    Mark(this.unit, this.skillname, data)
                    data.timer = LoopRun(1, 
                        function()
                            forRange(this.unit, 900,
                                function(u)
                                    if IsUnitAlly(u, this.player) and IsUnitAlive(u) then
                                        if data.recover[u] == nil then
                                            Recover(u, 2)
                                        end
                                        data.recover[u] = true
                                    end
                                end
                            )
                            for u, b in pairs(data.recover) do
                                if b == true then
                                    data.recover[u] = false
                                else
                                    Recover(u, -2)
                                    data.recover[u] = nil
                                end
                            end
                        end
                    )
                elseif this.event == "失去" then
                    local data = Mark(this.unit, this.skillname)
                    DestroyTimer(data.timer)
                    for u in pairs(data.recover) do
                        Recover(u, -2)
                    end
                    UnitRemoveAbility(this.unit, |A18R|)
                end
            end
        },
        complex = {"初春的花环"}
    }
    
    --护盾发生器
    InitItem{
        name = "护盾发生器",
        id = |I0CP|,
        skill = function(this)
            if this.event == "获得" then
                Wage(this.player, 0.25)
                Def(this.unit, 15)
            elseif this.event == "失去" then
                Wage(this.player, -0.25)
                Def(this.unit, -15)
            end
        end,
        skillOnly = {
            ["护盾生成"] = function(this)
                if this.event == "获得" then
                    UnitAddAbility(this.unit, |A18V|)
                    UnitMakeAbilityPermanent(this.unit, true, |A18V|)
                    local data = {unit, def = {}}
                    Mark(this.unit, this.skillname, data)
                    data.timer = LoopRun(1, 
                        function()
                            forRange(this.unit, 900,
                                function(u)
                                    if IsUnitAlly(u, this.player) and IsUnitAlive(u) then
                                        if data.def[u] == nil then
                                            Def(u, 15)
                                        end
                                        data.def[u] = true
                                    end
                                end
                            )
                            for u, b in pairs(data.def) do
                                if b == true then
                                    data.def[u] = false
                                else
                                    Def(u, -15)
                                    data.def[u] = nil
                                end
                            end
                        end
                    )
                elseif this.event == "失去" then
                    local data = Mark(this.unit, this.skillname)
                    DestroyTimer(data.timer)
                    for u in pairs(data.def) do
                        Def(u, -20)
                    end
                    UnitRemoveAbility(this.unit, |A18V|)
                end
            end
        },
        complex = {"锁子甲"}
    }
    
    --天空之墙
    InitItem{
        name = "天空之墙",
        id = |I0CQ|,
        skill = function(this)
            if this.event == "获得" then
                Wage(this.player, 0.5)
                Recover(this.unit, 2)
                Def(this.unit, 15)
            elseif this.event == "失去" then
                Wage(this.player, -0.5)
                Recover(this.unit, -2)
                Def(this.unit, -15)
            end
        end,
        skillOnly = {
            ["空气净化"] = false,
            ["护盾生成"] = false
        },
        complex = {"空气净化装置", "护盾发生器"}
    }
    
    --圣光护腕
    InitItem{
        name = "圣光护腕",
        id = |I0CM|,
        skill = function(this)
            if this.event == "获得" then
                Wage(this.player, 0.5)
                Sai(this.unit, 8)
            elseif this.event == "失去" then
                Wage(this.player, -0.5)
                Sai(this.unit, -8)
            end
        end,
        use = function(this)
            if this.isitemtarget then
                this.target = this.unit
            end
            local r = 30
            if this.target == this.unit then
                r = r / 2
            end
            Recover(this.target, r)
            local u = this.target
            local e = AddSpecialEffectTarget("Abilities\\Spells\\Items\\HealingSalve\\HealingSalveTarget.mdl", u, "origin")
            Wait(5,
                function()
                    Recover(u, - r)
                    DestroyEffect(e)
                end
            )
        end,
        complex = {"力量手套"}
    }
    
    --圣光庇护
    InitItem{
        name = "圣光庇护",
        id = |I0CN|,
        skill = function(this)
            if this.event == "获得" then
                Wage(this.player, 0.75)
                Sai(this.unit, 10)
                MaxLife(this.unit, 300, true)
            elseif this.event == "失去" then
                Wage(this.player, -0.75)
                Sai(this.unit, -10)
                MaxLife(this.unit, -300, true)
            end
        end,
        use = function(this)
            if this.isitemtarget then
                this.target = this.unit
            end
            local r = 50
            if this.target == this.unit then
                r = r / 2
            end
            Recover(this.target, r)
            local u = this.target
            local e = AddSpecialEffectTarget("Abilities\\Spells\\Items\\HealingSalve\\HealingSalveTarget.mdl", u, "origin")
            Wait(5,
                function()
                    Recover(u, - r)
                    DestroyEffect(e)
                end
            )
        end,
        complex = {"圣光护腕", "生命宝珠"}
    }
    
    --圣光普照
    InitItem{
        name = "圣光普照",
        id = |I0CO|,
        skill = function(this)
            if this.event == "获得" then
                Wage(this.player, 2)
                Sai(this.unit, 10)
                MaxLife(this.unit, 300, true)
                Ant(this.unit, 30)
            elseif this.event == "失去" then
                Wage(this.player, -2)
                Sai(this.unit, -10)
                MaxLife(this.unit, -300, true)
                Ant(this.unit, -30)
            end
        end,
        use = function(this)
            if this.isitemtarget then
                this.target = this.unit
            end
            local r = 50
            if this.target == this.unit then
                r = r / 2
            end
            local r2 = GetRecover(this.target)
            r2 = (r + r2) * 2
            if this.target == this.unit then
                r2 = r2 / 2
            end
            r = r + r2
            Recover(this.target, r)
            DestroyEffect(AddSpellEffectTarget("Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl", this.unit, "overhead"))
            CleanUnit{
                from = this.unit,
                to = this.target,
                debuff = true,
                item = this
            }
            local from = this.unit
            local u = this.target
            local e = AddSpecialEffectTarget("Abilities\\Spells\\Items\\HealingSalve\\HealingSalveTarget.mdl", u, "origin")
            Wait(5,
                function()
                    Recover(u, - r)
                    DestroyEffect(e)
                    DestroyEffect(AddSpellEffectTarget("Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl", u, "overhead"))
                    CleanUnit{
                        from = from,
                        to = u,
                        debuff = true,
                        item = this
                    }
                end
            )
        end,
        complex = {"圣光庇护", "驱魔项链"}
    }
    
    --负之遗产
    InitItem{
        name = "负之遗产",
        id = |I0CR|,
        skill = function(this)
            if this.event == "获得" then
                Wage(this.player, 2.25)
                Sai(this.unit, 10)
                MaxLife(this.unit, 300, true)
                Recover(this.unit, 2)
                Def(this.unit, 15)
            elseif this.event == "失去" then
                Wage(this.player, -2.25)
                Sai(this.unit, -10)
                MaxLife(this.unit, -300, true)
                Recover(this.unit, -2)
                Def(this.unit, -15)
            end
        end,
        skillOnly = {
            ["空气净化"] = false,
            ["护盾生成"] = false
        },
        use = function(this)
            TempEffect(this.unit, "Abilities\\Spells\\Items\\AIda\\AIdaCaster.mdl")
            local units = {}
            forRange(this.unit, 400,
                function(u)
                    if IsUnitAlly(u, this.player) and IsUnitAlive(u) then
                        Recover(u, 60)
                        units[u] = AddSpecialEffectTarget("Abilities\\Spells\\Items\\HealingSalve\\HealingSalveTarget.mdl", u, "origin")
                    end
                end
            )
            Wait(5,
                function()
                    for u, e in pairs(units) do
                        Recover(u, -60)
                        DestroyEffect(e)
                    end
                end
            )
        end,
        complex = {"天空之墙", "圣光庇护"}
    }
    
    --巫毒玩偶
    InitItem{
        name = "巫毒玩偶",
        id = |I0CS|,
        skill = function(this)
            if this.event == "获得" then
                Wage(this.player, 0.75)
            elseif this.event == "失去" then
                Wage(this.player, -0.75)
            end
        end,
        skillOnly = {
            ["巫毒光环"] = function(this)
                if this.event == "获得" then
                    UnitAddAbility(this.unit, |A18X|)
                    UnitMakeAbilityPermanent(this.unit, true, |A18X|)
                    local data = {unit, units = {}}
                    Mark(this.unit, this.skillname, data)
                    data.timer = LoopRun(1, 
                        function()
                            forRange(this.unit, 900,
                                function(u)
                                    if IsUnitEnemy(u, this.player) and IsUnitAlive(u) then
                                        if data.units[u] == nil then
                                            Def(u, -30)
                                        end
                                        data.units[u] = true
                                    end
                                end
                            )
                            for u, b in pairs(data.units) do
                                if b == true then
                                    data.units[u] = false
                                else
                                    Def(u, 30)
                                    data.units[u] = nil
                                end
                            end
                        end
                    )
                elseif this.event == "失去" then
                    local data = Mark(this.unit, this.skillname)
                    DestroyTimer(data.timer)
                    for u in pairs(data.units) do
                        Def(u, 30)
                    end
                    UnitRemoveAbility(this.unit, |A18X|)
                end
            end
        },
        complex = {"魔眼之石"}
    }
    
    --君士坦丁大帝之书
    InitItem{
        name = "君士坦丁大帝之书",
        id = |I0CT|,
        skill = function(this)
            if this.event == "获得" then
                Wage(this.player, 1.75)
                Sai(this.unit, 10, 10, 10)
            elseif this.event == "失去" then
                Wage(this.player, -1.75)
                Sai(this.unit, -10, -10, -10)
            end
        end,
        skillOnly = {
            ["巫毒光环"] = false
        },
        use = function(this)
            TempEffect(this.unit, "Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl")
            forRange(this.unit, 900,
                function(u)
                    if EnemyFilter(this.player, u) then
                        SkillEffect{
                            name = this.name,
                            from = this.unit,
                            to = u,
                            data = this,
                            item = this,
                            aoe = true,
                            code = function(data)
                                if toEvent("debuff", data) then return end
                                local e = AddSpecialEffectTarget("Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl", data.to, "origin")
                                Attack(data.to, -50)
                                AddAP(data.to, -50)
                                Def(data.to, -30)
                                Ant(data.to, -30)
                                local hp, mp = GetRecover(data.to)
                                Recover(data.to, - hp, - mp)
                                local func2
                                local timer = CreateTimer()
                                local func = function()
                                    DestroyEffect(e)
                                    Attack(data.to, 50)
                                    AddAP(data.to, 50)
                                    Def(data.to, 30)
                                    Ant(data.to, 30)
                                    Recover(data.to, hp, mp)
                                    Event("-驱散", func2)
                                end
                                func2 = Event("驱散",
                                    function(that)
                                        if that.to == data.to and that.debuff then
                                            DestroyTimer(timer)
                                            func()
                                        end
                                    end
                                )
                                TimerStart(timer, 5, false, func)
                            end
                        }
                    end
                end
            )
        end,
        complex = {"巫毒玩偶", "能量增幅器"}
    }
    
