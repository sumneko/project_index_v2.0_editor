    
    --黑曜石
    InitItem{
        name = "黑曜石",
        id = |I0BE|,
        skill = function(this)
            if this.event == "获得" then
                AddAP(this.unit, 15)
            elseif this.event == "失去" then
                AddAP(this.unit, -15)
            end
        end
    }
    
    --魔能法杖
    InitItem{
        name = "魔能法杖",
        id = |I0BF|,
        skill = function(this)
            if this.event == "获得" then
                AddAP(this.unit, 30)
            elseif this.event == "失去" then
                AddAP(this.unit, -30)
            end
        end
    }
    
    --携带能量点
    InitItem{
        name = "携带能量点",
        id = |I0BG|,
        skill = function(this)
            if this.event == "获得" then
                AddAP(this.unit, 60)
            elseif this.event == "失去" then
                AddAP(this.unit, -60)
            end
        end
    }
    
    --莲花杖
    InitItem{
        name = "莲花杖",
        id = |I0BH|,
        skill = function(this)
            if this.event == "获得" then
                AddAP(this.unit, 90)
            elseif this.event == "失去" then
                AddAP(this.unit, -90)
            end
        end,
        skillOnly = {
            ["能量洪流"] = function(this)
                if this.event == "获得" then
                    AddAP(this.unit, 0, 25)
                elseif this.event == "失去" then
                    AddAP(this.unit, 0, -25)
                end
            end
        },
        use = function(this)
            SkillEffect{
                name = this.name,
                from = this.unit,
                to = this.target,
                data = this,
                item = this.item,
                code = function(data)
                    if IsUnitDead(data.to) then return end
                    local name = data.name
                    local target = data.to
                    local u = data.from
                    local e = AddSpecialEffectTarget("Abilities\\Spells\\Undead\\UnholyFrenzy\\UnholyFrenzyTarget.mdl", target, "overhead")
                    local func = Event("伤害效果",
                        function(damage)
                            if damage.from == u and not damage.attack and damage.damageReason ~= name then
                                if damage.to == target then
                                    --相当于增幅20%的伤害
                                    Damage(u, target, damage.damage * 0.5, false, true, {damageReason = name, item = data.item})
                                else
                                    local d = damage.damage
                                    if damage.aoe then
                                        d = d * 0.2
                                    else
                                        d = d * 0.5
                                    end
                                    local mover = MoverEx({
                                        source = damage.to,
                                        from = u,
                                        z = 75,
                                        tz = 75,
                                        modle = "Abilities\\Weapons\\BansheeMissile\\BansheeMissile.mdl",
                                        target = target,
                                        speed = 500,
                                        high = 200,
                                        },nil,
                                        function(move)
                                            Damage(move.from, move.target, d, false, true, {damageReason = name, item = true, aoe = damage.aoe})
                                        end
                                    )
                                end
                            end
                        end
                    )
                    Wait(5,
                        function()
                            DestroyEffect(e)
                            Event("-伤害效果", func)
                        end
                    )
                end
            }
        end,
        complex = {"魔能法杖", "携带能量点"}
    }
    
    --散热器
    InitItem{
        name = "散热器",
        id = |I0BI|,
        skillOnly = {
            ["空气散热"] = function(this)
                if this.event == "获得" then
                    SetCoolDown(this.unit, 10)
                elseif this.event == "失去" then
                    SetCoolDown(this.unit, -10)
                end
            end
        }
    }
    
    --冷凝核心
    InitItem{
        name = "冷凝核心",
        id = |I0BJ|,
        skillOnly = {
            ["空气散热"] = false,
            ["液冷散热"] = function(this)
                if this.event == "获得" then
                    SetCoolDown(this.unit, 10)
                elseif this.event == "失去" then
                    SetCoolDown(this.unit, -10)
                end
            end
        },
        complex = {"散热器"}
    }
    
    --钻石星辰
    InitItem{
        name = "钻石星辰",
        id = |I0BK|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 0, 0, 20)
            elseif this.event == "失去" then
                Sai(this.unit, 0, 0, -20)
            end
        end,
        skillOnly = {
            ["空气散热"] = false,
            ["液冷散热"] = false,
            ["液氮散热"] = function(this)
                if this.event == "获得" then
                    local u = this.unit
                    local data = {c = 0}
                    data.timer = Mark(this.unit, this.skillname, data)
                    Loop(1,
                        function()
                            local tc = 30 - GetUnitState(u, UNIT_STATE_MANA) / GetUnitState(u, UNIT_STATE_MAX_MANA) * 30
                            if math.abs(tc - data.c) < 0.1 then return end
                            SetCoolDown(u, tc - data.c)
                            data.c = tc
                        end
                    )
                elseif this.event == "失去" then
                    local data = Mark(this.unit, this.skillname)
                    Mark(this.unit, this.skillname, false)
                    DestroyTimer(data.timer)
                    SetCoolDown(this.unit - data.c)
                end
            end
        },
        complex = {"冷凝核心", "智力斗篷", "智力挂饰"}
    }
    
    --血珠
    InitItem{
        name = "血珠",
        id = |I0BL|,
        skill = function(this)
            if this.event == "获得" then
                SkillStealLife(this.unit, 12)
            elseif this.event == "失去" then
                SkillStealLife(this.unit, -12)
            end
        end
    }
    
    --恶魔坠饰
    InitItem{
        name = "恶魔坠饰",
        id = |I0BM|,
        skill = function(this)
            if this.event == "获得" then
                AddAP(this.unit, 30)
                SkillStealLife(this.unit, 15)
            elseif this.event == "失去" then
                AddAP(this.unit, -30)
                SkillStealLife(this.unit, -15)
            end
        end,
        complex = {"血珠", "魔能法杖"}
    }
    
    --血族面具
    InitItem{
        name = "血族面具",
        id = |I0BN|,
        skill = function(this)
            if this.event == "获得" then
                Attack(this.unit, 30)
                AddAP(this.unit, 45)
                AttackStealLife(this.unit, 20, 10)
                SkillStealLife(this.unit, 30)
            elseif this.event == "失去" then
                Attack(this.unit, -30)
                AddAP(this.unit, -45)
                AttackStealLife(this.unit, -20, -10)
                SkillStealLife(this.unit, -30)
            end
        end,
        use = function(this)
            local u = this.unit
            local e1 = DestroyEffect(AddSpecialEffectTarget("war3mapImported\\Hellfire.mdx", u, "hand left"))
            local e2 = DestroyEffect(AddSpecialEffectTarget("war3mapImported\\Hellfire.mdx", u, "hand right"))
            AttackStealLife(u, 60, 20)
            SkillStealLife(u, 90)
            Wait(5,
                function()
                    DestroyEffect(e1)
                    DestroyEffect(e2)
                    AttackStealLife(u, -60, -20)
                    SkillStealLife(u, -90)
                end
            )
        end,
        complex = {"菜刀", "黑曜石", "吸血鬼指环", "血珠", "吸血鬼之触", "恶魔坠饰"}
    }
    
