    
    --跑鞋
    InitItem{
        name = "跑鞋",
        id = |I0AU|,
        skillOnly = {
            ["健步如飞"] = function(this)
                if this.event == "获得" then
                    MoveSpeed(this.unit, 30)
                elseif this.event == "失去" then
                    MoveSpeed(this.unit, -30)
                end
            end
        }
    }
    
    --上条牌运动鞋
    InitItem{
        name = "上条牌运动鞋",
        id = |I0B6|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 10)
                MoveSpeed(this.unit, 10)
            elseif this.event == "失去" then
                Sai(this.unit, -10)
                MoveSpeed(this.unit, -10)
            end
        end,
        skillOnly = {
            ["健步如飞"] = false
        },
        use = function(this)
            local u = this.unit
            MoveSpeed(u, 60)
            local e = AddSpecialEffectTarget("Abilities\\Spells\\Undead\\AbsorbMana\\AbsorbManaBirthMissile.mdl", this.unit, "origin")
            Wait(3,
                function()
                    MoveSpeed(u, -60)
                    DestroyEffect(e)
                end
            )
        end,
        complex = {"跑鞋", "力量手套"}
    }
    
    --动能装置
    InitItem{
        name = "动能装置",
        id = |I0B7|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 0, 10)
                MoveSpeed(this.unit, 10)
            elseif this.event == "失去" then
                Sai(this.unit, 0, -10)
                MoveSpeed(this.unit, -10)
            end
        end,
        skillOnly = {
            ["健步如飞"] = false
        },
        use = function(this)
            local u = this.unit
            AttackSpeed(u, 60)
            local e1 = AddSpecialEffectTarget("Abilities\\Spells\\Undead\\AbsorbMana\\AbsorbManaBirthMissile.mdl", this.unit, "hand,left")
            local e2 = AddSpecialEffectTarget("Abilities\\Spells\\Undead\\AbsorbMana\\AbsorbManaBirthMissile.mdl", this.unit, "hand,right")
            Wait(5,
                function()
                    AttackSpeed(u, -60)
                    DestroyEffect(e1)
                    DestroyEffect(e2)
                end
            )
        end,
        complex = {"跑鞋", "敏捷指环"}
    }
    
    --奥术鞋
    InitItem{
        name = "奥术鞋",
        id = |I0B8|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 0, 0, 10)
                MoveSpeed(this.unit, 10)
            elseif this.event == "失去" then
                Sai(this.unit, 0, 0, -10)
                MoveSpeed(this.unit, -10)
            end
        end,
        skillOnly = {
            ["健步如飞"] = false
        },
        use = function(this)
            local u = this.unit
            AddAP(u, 60)
            local e = AddSpecialEffectTarget("Abilities\\Spells\\Undead\\AbsorbMana\\AbsorbManaBirthMissile.mdl", this.unit, "overhead")
            Wait(5,
                function()
                    AddAP(u, -60)
                    DestroyEffect(e)
                end
            )
        end,
        complex = {"跑鞋", "智力斗篷"}
    }
    
    --特制弹跳鞋
    InitItem{
        name = "特制弹跳鞋",
        id = |I0B9|,
        skill = function(this)
            if this.event == "获得" then
                MoveSpeed(this.unit, 30)
            elseif this.event == "失去" then
                MoveSpeed(this.unit, -30)
            end
        end,
        skillOnly = {
            ["健步如飞"] = false,
            ["弹射保护"] = function(this)
                if this.event == "获得" then
                    local data = {unit = this.unit, timer = CreateTimer()}
                    Mark(this.unit, this.skillname, data)
                    data.func = Event("伤害结算后",
                        function(damage)
                            if damage.from and damage.to == this.unit and damage.from ~= damage.to and damage.damage > 0 and IsUser(GetOwningPlayer(damage.from)) and IsUnitAlive(this.unit) then
                                for i = 0, 5 do
                                    local it = UnitItemInSlot(this.unit, i)
                                    if it and GetItemTypeId(it) == |I0B9| then
                                        local item = Mark(it, "数据")
                                        item:newId(|I0BA|)
                                    end
                                end
                                local u = data.unit
                                TimerStart(data.timer, 3, false,
                                    function()
                                        local func
                                        func = function(that)
                                            if that then
                                                if that.unit == u then
                                                    Event("-复活", func)
                                                else
                                                    return
                                                end
                                            end
                                            for i = 0, 5 do
                                                local it = UnitItemInSlot(u, i)
                                                if it and GetItemTypeId(it) == |I0BA| then
                                                    local item = Mark(it, "数据")
                                                    item:newId(|I0B9|)
                                                end
                                            end
                                        end
                                        if IsUnitAlive(u) then
                                            func()
                                        else
                                            Event("复活", func)
                                        end
                                    end
                                )
                                SetSkillCool(u, |A19Z|)
                            end
                        end
                    )
                elseif this.event == "失去" then
                    local data = Mark(this.unit, this.skillname)
                    Event("-伤害结算后", data.func)
                    DestroyTimer(data.timer)
                end
            end
        },
        use = function(this)
            DestroyEffect(TempEffect(this.unit, "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"))
            if GetBetween(this.target, this.unit) > 1000 then
                local a = GetBetween(this.unit, this.target, true)
                this.target = MovePoint(this.unit, {1000, a})
            end
            Mover({
                    unit = this.unit,
                    target = this.target,
                    high = 500,
                    speed = 2000
                },nil,
                function(move)
                    DestroyEffect(TempEffect(move.unit, "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"))
                end
            )
        end,
        complex = {"跑鞋"}
    }
    
    --加速手套
    InitItem{
        name = "加速手套",
        id = |I0BB|,
        skill = function(this)
            if this.event == "获得" then
                AttackSpeed(this.unit, 15)
            elseif this.event == "失去" then
                AttackSpeed(this.unit, -15)
            end
        end
    }
    
    --唤灵之笛
    InitItem{
        name = "唤灵之笛",
        id = |I0BC|,
        skill = function(this)
            if this.event == "获得" then
                AttackSpeed(this.unit, 45)
            elseif this.event == "失去" then
                AttackSpeed(this.unit, -45)
            end
        end
    }
    
    --高能震动短剑
    InitItem{
        name = "高能震动短剑",
        id = |I0BD|,
        skill = function(this)
            if this.event == "获得" then
                Attack(this.unit, 30)
                AttackSpeed(this.unit, 60)
            elseif this.event == "失去" then
                Attack(this.unit, -30)
                AttackSpeed(this.unit, -60)
            end
        end,
        skillOnly = {
            ["高能震动"] = function(this)
                if this.event == "获得" then
                    local u = this.unit
                    local data = {as = 0}
                    Mark(this.unit, this.skillname, data)
                    data.func = Event("伤害效果",
                        function(damage)
                            if damage.from == u and damage.attack then
                                if data.as < 120 then
                                    data.as = data.as + 8
                                    AttackSpeed(u, 8)
                                end
                                if not data.timer then
                                    data.timer = CreateTimer()
                                    data.e1 = AddSpecialEffectTarget("Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl", u, "hand left")
                                    data.e2 = AddSpecialEffectTarget("Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl", u, "hand right")
                                    data.timerfunc = function()
                                        AttackSpeed(u, - data.as)
                                        data.as = 0
                                        DestroyEffect(data.e1)
                                        DestroyEffect(data.e2)
                                        DestroyTimer(data.timer)
                                        data.timer = false
                                        data.timerfunc = false
                                    end
                                end
                                TimerStart(data.timer, 5, false, data.timerfunc)
                            end
                        end
                    )
                elseif this.event == "失去" then
                    local data = Mark(this.unit, this.skillname)
                    if data.timerfunc then
                        data.timerfunc()
                    end
                    Event("-伤害效果", data.func)
                    Mark(this.unit, this.skillname, false)
                end
            end
        },
        complex = {"菜刀", "大斧", "加速手套", "唤灵之笛"}
    }
    
