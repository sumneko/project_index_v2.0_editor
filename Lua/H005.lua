    
    HeroName[5] = "史提尔·马格努斯"
    HeroMain[5] = "智力"
    HeroType[5] = |Hblm|
    RDHeroType[5] = |h018|
    HeroTypePic[5] = "ReplaceableTextures\\CommandButtons\\BTNShiTiEr.blp"
    HeroSize[5] = 1.2
    LearnSkillId = {|A15I|, |A15J|, |A15K|, |A15L|}
    
    --吸血猎杀红十字
    InitSkill{
        name = "吸血猎杀红十字",
        type = {"主动", 2, 3}, --点目标,图标可见+目标选取图像
        ani = "spell throw",
        art = {"BTNlieshashizi.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {75, 80, 85, 90},
        cool = {4.5, 4, 3.5, 3},
        rng = 400,
        cast = 0.1,
        dur = 3,
        area = 150,
        tip = "\
史提尔召唤两把拥有猎杀魔女意义的焰刃,从左右两边交叉攻击目标区域,对沿途的单位造成|cffffcc00燃烧|r效果.不幸被2把焰刃击中的单位将会|cffffcc00晕眩|r.\n\
|cff00ffcc技能|r: 点目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00总伤害|r: %s(|cff1111ff+%d|r)\
|cffffcc00晕眩时间|r: %s\n\
|cff8888882把焰刃的燃烧效果不叠加,不可驱散\n焰刃的飞行速度为%s,最多可飞行%s距离",
        researchtip = "2把焰刃的燃烧效果叠加",
        data = {
            {60, 90, 120, 150}, --总伤害1
            function(ap, ad) --伤害加成2
                return ap * 0.3 --AP加成0.3
            end,
            {0.9, 1.1, 1.3, 1.5}, --晕眩时间3
            1000, --飞行速度4
            800, --飞行距离5
        },
        events = {"发动技能"},
        code = function(this)
            local a = GetBetween(this.unit, this.target, true) --角度
            local p = {MovePoint(this.unit, {200, a - 60}), MovePoint(this.unit, {200, a + 60})} --2把焰刃的创建位置
            local t = {{}, {}}
            local p1 = GetOwningPlayer(this.unit)
            local area = this:get("area")
            local time = this:get(3)
            local dur = this:get("dur")
            local damage = this:get(1) + this:get(2)
            local code = function(move)
                if move.count % 5 == 0 then --0.1秒判定一次
                    forRange(move.unit, area,
                        function(u)
                            if EnemyFilter(p1, u) and not t[move.i][u] then
                                t[move.i][u] = true
                                if t[1][u] and t[2][u] then --被2个焰刃都击中了
                                    SkillEffect{
                                        name = this.name .. "(晕眩)",
                                        from = this.unit,
                                        to = u,
                                        data = this,
                                        code = function(data)
                                            StunUnit{
                                                from = data.from,
                                                to = data.to,
                                                aoe = true,
                                                time = time
                                            }
                                        end
                                    }
                                    if this.research then
                                        SkillEffect{
                                            name = this.name,
                                            from = this.unit,
                                            to = u,
                                            data = this,
                                            aoe = true,
                                            code = function(data)
                                                FireUnit{
                                                    from = data.from,
                                                    to = data.to,
                                                    time = dur,
                                                    damage = damage,
                                                    aoe = true,
                                                    damageReason = this.name
                                                }
                                            end
                                        }
                                    end
                                else
                                    SkillEffect{
                                        name = this.name,
                                        from = this.unit,
                                        to = u,
                                        data = this,
                                        aoe = true,
                                        code = function(data)
                                            FireUnit{
                                                from = data.from,
                                                to = data.to,
                                                time = dur,
                                                damage = damage,
                                                aoe = true,
                                                damageReason = this.name
                                            }
                                        end
                                    }
                                end
                            end
                        end
                    )
                end
            end
            local speed = this:get(4)
            local distance = this:get(5)
            for i = 1, 2 do
                Mover({
                    from = this.unit,
                    source = p[i],
                    modle = "Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl",
                    size = 2,
                    z = 75,
                    speed = speed,
                    distance = distance,
                    angle = GetBetween(p[i], this.target, true),
                    i = i,
                }, code)
            end
        end
    }
    
    --赐予巨人痛苦的赠礼
    InitSkill{
        name = "赐予巨人痛苦的赠礼",
        type = {"主动", 2, 3}, --点目标,图标可见+目标选取图像
        ani = "attack -2",
        art = {"BTNFire.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {125, 140, 155, 170},
        cool = 20,
        rng = 2000,
        cast = 0.1,
        dur = 5,
        area = 250,
        tip = "\
短暂延迟后,史提尔在目标区域召唤一个巨大的火柱,|cffffcc00燃烧|r依然停留在该区域内的敌人,造成高额伤害.\n\
|cff00ffcc技能|r: 点目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00总伤害|r: %s(|cff1111ff+%d|r)\
|cffffcc00效果延迟|r: %s\n\
|cff888888燃烧效果不可驱散\n技能生效前将在目标区域显示一个特效,对双方可见",
        researchtip = "燃烧持续时间增加100%,燃烧总伤害增加50%",
        data = {
            {150, 300, 450, 600}, --总伤害1
            function(ap, ad) --伤害加成2
                return ap * 2 --AP加成2
            end,
            1.5, --延迟时间3
        },
        events = {"发动技能"},
        code = function(this)
            local time = this:get(3)
            local dur = this:get("dur")
            if this.research then
                dur = dur * 2
            end
            local modle = CreateModle("Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeTarget.mdl", this.target)
            Wait(time,
                function()
                    RemoveUnit(modle)
                    CreateModle("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl", this.target, {size = 2.5, time = 1})
                    local p = GetOwningPlayer(this.unit)
                    local damage = this:get(1) + this:get(2)
                    if this.research then
                        damage = damage * 1.5
                    end
                    
                    forRange(this.target, this:get("area"),
                        function(u)
                            if EnemyFilter(p, u) then
                                SkillEffect{
                                    name = this.name,
                                    from = this.unit,
                                    to = u,
                                    data = this,
                                    aoe = true,
                                    code = function(data)
                                        FireUnit{
                                            from = data.from,
                                            to = data.to,
                                            damage = damage,
                                            time = dur,
                                            aoe = true,
                                            damageReason = this.name
                                        }
                                    end
                                }
                            end
                        end
                    )
                end
            )
        end
    }
    
    --符文法阵
    InitSkill{
        name = "符文法阵",
        type = {"主动", 2, 3}, --点目标,图标可见+目标选取图像
        ani = "spell",
        art = {"BTNfuwen.blp"}, --左边是学习,右边是普通.不填右边视为左边
        cool = {4, 6, 8, 10},
        rng = 300,
        cast = 0.1,
        dur = 300,
        area = 200,
        tip = "\
史提尔在目标区域内放置符文,每张符文提供附近友方英雄1点的法力回复速度与5点的法术强度.当符文被摧毁时,摧毁者将受到|cffffcc00燃烧|r效果.当身边的符文数量达到5张时,史提尔可以在不攻击或施法的情况下隐身\n\
|cff00ffcc技能|r: 点目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00符文数量|r :%s\
|cffffcc00判定范围|r: %s\
|cffffcc00燃烧伤害|r: %s(|cff1111ff+%d|r)\
|cffffcc00燃烧持续时间|r: %s\n\
|cff888888燃烧效果不可驱散\n符文拥有100生命值与1000的抗性\n进入隐身时间为2秒\n消耗为已有符文数量*%s",
        researchtip = "符文在白天拥有600的视野",
        data = {
            {1, 2, 3, 4}, --符文数量1
            600, --判定范围2
            50, --燃烧伤害3
            function(ap, ad) --伤害加成4
                return ap * 0.25 --AP加成为0.25
            end,
            3, --燃烧时间5
            10, --魔法消耗6
        },
        cardcount = 0,
        events = {"注册技能", "获得技能", "失去技能", "发动技能"},
        code = function(this)
            if this.event == "注册技能" then
                --法力回复,法伤加成,隐身
                local t = table.new(0)
                local area = this:get(2)
                this.skilltimer = Loop(0.5,
                    function()
                        for _, h in ipairs(AllHeroes) do
                            local n = 0
                            local p = GetOwningPlayer(h)
                            if IsUnitAlive(h) then
                                forRange(h, area,
                                    function(u)
                                        if GetUnitTypeId(u) == |h006| and IsUnitAlly(u, p) then
                                            n = n + 1
                                        end
                                    end
                                )
                            end
                            AddAP(h, 5 * (n - t[h]))
                            t[h] = n
                            SetUnitState(h, UNIT_STATE_MANA, GetUnitState(h, UNIT_STATE_MANA) + 0.5 * n)
                            if n >= 5 and Mark(h, "符文法阵隐身") then
                                UnitAddAbility(h, |A0OS|)
                                UnitMakeAbilityPermanent(h, true, |A0OS|)
                            else
                                UnitRemoveAbility(h, |A0OS|)
                            end
                        end
                    end
                )
            elseif this.event == "获得技能" then
                Mark(this.unit, "符文法阵隐身", true)
                --死亡反噬
                this.skillfunc = Event("死亡",
                    function(data)
                        if GetUnitTypeId(data.unit) == |h006| then
                            local u = Mark(data.unit, "符文创建者")
                            if this.unit == u then
                                this.cardcount = this.cardcount - 1
                                this.mana = this.cardcount * this:get(6)
                                local ability = japi.EXGetUnitAbility(this.unit, this.id)
                                japi.EXSetAbilityDataInteger(ability, 1, 104, this.cost)
                                RefreshTips(this.unit)
                                if data.killer and IsUnitAlive(data.killer) then --如果有凶手
                                    Mover({
                                        from = data.unit,
                                        target = data.killer,
                                        modle = "RunicBreath.mdx",
                                        z = 75,
                                        speed = 300,
                                    }, nil,
                                    function(move)
                                        SkillEffect{
                                            name = this.name,
                                            from = u,
                                            to = data.killer,
                                            data = this,
                                            code = function(data)
                                                FireUnit{
                                                    from = data.from,
                                                    to = data.to,
                                                    damage = this:get(3) + this:get(4),
                                                    time = this:get(5),
                                                    damageReason = this.name
                                                }
                                            end
                                        }
                                    end)
                                end
                            end
                        end
                    end
                )
            elseif this.event == "失去技能" then
                Mark(this.unit, "符文法阵隐身", false)
                Event("-死亡", this.skillfunc)
            elseif this.event == "发动技能" then
                local n = this:get(1)
                local p1 = GetOwningPlayer(this.unit)
                local dur = this:get("dur")
                local uid = |h006|
                if this.research then
                    uid = |h02H|
                end
                if n == 1 then
                    local u = CreateUnitAtLoc(p1, uid, this.target, 0)
                    UnitApplyTimedLife(u, 'BTLF', dur)
                    UnitAddType(u, UNIT_TYPE_SUMMONED)
                    Mark(u, "符文创建者", this.unit)
                    Ant(u, 1000)
                else
                    local area = this:get("area")
                    local a = GetBetween(this.unit, this.target, true)
                    for i = 1, n do
                        local u = CreateUnitAtLoc(p1, uid, MovePoint(this.target, {area, a + 360 / n * i}), 0)
                        UnitApplyTimedLife(u, 'BTLF', dur)
                        UnitAddType(u, UNIT_TYPE_SUMMONED)
                        Mark(u, "符文创建者", this.unit)
                        Ant(u, 1000)
                    end
                end
                this.cardcount = this.cardcount + n
                this.mana = this.cardcount * this:get(6)
                local ability = japi.EXGetUnitAbility(this.unit, this.id)
                japi.EXSetAbilityDataInteger(ability, 1, 104, this.mana)
                RefreshTips(this.unit)
            end
        end
    }
    
    --猎杀魔女之王
    InitSkill{
        name = "猎杀魔女之王",
        type = {"主动", 2, 3}, --点目标,图标可见+目标选取图像
        ani = "spell",
        art = {"BTNhuoren.blp"}, --左边是学习,右边是普通.不填右边视为左边
        cool = 120,
        rng = "全地图",
        cast = 0.1,
        mana = {200, 400, 600},
        area = 300,
        tip = "\
猎杀魔女之王从烈焰中诞生,|cffffcc00燃烧|r区域内的敌人.其能力受到符文的加成并持续伤害附近的单位.\n\
|cff00ffcc技能|r: 点目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00燃烧伤害|r: %s(|cff1111ff+%d|r)\
|cffffcc00燃烧时间|r: %s\
|cffffcc00数量|r: %s\
|cffffcc00攻击|r: %s(|cff1111ff+%d|r)\
|cffffcc00高温伤害|r: %s(|cff1111ff+%d|r)\
|cffffcc00生命|r: %s\n\
|cff888888共享生命值与生命上限",
        researchtip = {
            "拥有2倍的生命值上限,初始生命值不变",
            "召唤时将范围内的单位击晕1.5秒",
            "无法进行普通攻击,但是高温伤害变为3倍"
        },
        data = {
            {200, 350, 500}, --燃烧伤害1
            function(ap) --燃烧伤害加成2
                return ap * 1.25 --AP加成为1.25
            end,
            5, --燃烧持续时间3
            {1, 2, 3}, --猎杀魔女之王数量4
            {50, 100, 150}, --猎杀魔女之王基础攻击力5
            function(ap) --猎杀魔女之王基础攻击力加成6
                return ap * 0.6 --AP加成为0.6
            end,
            {20, 35, 50}, --基础高温伤害7
            function(ap) --基础高温伤害加成8
                return ap * 0.25 --AP加成为0.25
            end,
            {1000, 2500, 4000} --生命9
        },
        unitstip = "猎杀魔女之王会持续对周围的敌人造成伤害.当靠近符文时,每张符文都会加强其能力.\
\
|cffffcc00符文判定范围|r: %s\
|cffffcc00高温影响范围|r: %s\
|cffffcc00额外高温伤害|r: %s/符文\
|cffffcc00额外攻击|r: %s/符文\
|cffffcc00额外生命回复|r: %.1f%%/符文\
\
|cff888888初始生命回复为%d%%",
        unitsdata = {
            600, --判定范围1
            225, --高温判定范围2
            5, --高温伤害3
            10, --攻击4
            1.5, --生命回复5
            -10, --初始生命回复6
        },
        events = {"获得技能", "失去技能", "发动技能"},
        code = function(this)

            if this.event == "获得技能" then
                this.units = {}
                --召唤新的火人时刷新数据
                this.freshunits = function(this)
                    local n = #this.units
                    if n == 0 then return end
                    local hp, mhp = 0, 0
                    for _, u in ipairs(this.units) do
                        hp = hp + GetUnitState(u, UNIT_STATE_LIFE)
                        mhp = mhp + GetUnitState(u, UNIT_STATE_MAX_LIFE)
                    end
                    hp = hp / n
                    mhp = mhp / n
                    for _, u in ipairs(this.units) do
                        MaxLife(u, mhp - GetUnitState(u, UNIT_STATE_MAX_LIFE))
                        SetUnitState(u, UNIT_STATE_LIFE, hp)
                    end
                    this.unitshp = hp
                    if not this.unitstimer then
                        local u = this.units[1]
                        local skill = japi.EXGetUnitAbility(u, |A15Q|)
                        japi.EXSetAbilityDataString(skill, 1, 218, string.format(this.unitstip, unpack(this.unitsdata)))
                        this.unitstimer = LoopRun(1,
                            function()
                                --计算周围符文并造成高温伤害
                                local p = GetOwningPlayer(this.unit)
                                local area = this.unitsdata[1]
                                local area2 = this.unitsdata[2]
                                local fire = this.unitsdata[3]
                                local attack = this.unitsdata[4]
                                local fhp = this.unitsdata[5]
                                local hp = this.unitsdata[6]
                                local count = #this.units
                                local heal = 0
                                for _, u in ipairs(this.units) do
                                    local n = 0
                                    forRange(u, area,
                                        function(u2)
                                            if GetUnitTypeId(u2) == |h006| and IsUnitAlly(u2, p) then
                                                n = n + 1
                                            end
                                        end
                                    )
                                    
                                    --高温伤害
                                    local d = Mark(u, "高温伤害") + n * fire
                                    if this.research and this.research[3] then
                                        d = d * 3
                                    end
                                    forRange(u, area2,
                                        function(u2)
                                            if EnemyFilter(p, u2) then
                                                SkillEffect{
                                                    name = this.name .. "(高温)",
                                                    from = u,
                                                    to = u2,
                                                    data = this,
                                                    aoe = true,
                                                    code = function(data)
                                                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl", u2, "overhead"))
                                                        Damage(data.from, data.to, d, false, true, {aoe = true, damageReason = this.name})
                                                    end
                                                }
                                            end
                                        end
                                    )
                                    
                                    --调整攻击力
                                    local attack = n * attack
                                    Attack(u, attack - Mark(u, "高温攻击力"))
                                    Mark(u, "高温攻击力", attack)
                                    
                                    --回血
                                    local hp = (hp + fhp * n) / count
                                    heal = heal + hp
                                end
                                this:unitscode() --立即同步生命值
                                this.unitshp = this.unitshp + heal * GetUnitState(this.units[1], UNIT_STATE_MAX_LIFE) * 0.01
                                for _, u in ipairs(this.units) do
                                    SetUnitState(u, UNIT_STATE_LIFE, this.unitshp)
                                end
                                this.unitshp = GetUnitState(this.units[1], UNIT_STATE_LIFE)
                            end
                        )
                    end
                end
                
                this.unitscode = function(this)
                    --同步生命值
                    local hp = 0
                    local count = 0
                    local deadflag
                    for _, u in ipairs(this.units) do
                        hp = hp + GetUnitState(u, UNIT_STATE_LIFE) - this.unitshp
                        if IsUnitDead(u) then
                            deadflag = true
                        end
                        count = count + 1
                    end
                    if deadflag then
                        this.unitshp = 0
                    else
                        this.unitshp = this.unitshp + hp
                    end
                    if (count == 0 or this.unitshp <= 0) and this.unitstimer then
                        DestroyTimer(this.unitstimer)
                        this.unitstimer = nil
                        for _, u in ipairs(this.units) do
                            SetUnitState(u, UNIT_STATE_LIFE, this.unitshp)
                        end
                        this.units = {}
                    else
                        for _, u in ipairs(this.units) do
                            SetUnitState(u, UNIT_STATE_LIFE, this.unitshp)
                        end
                        this.unitshp = GetUnitState(this.units[1], UNIT_STATE_LIFE)
                    end
                end
                
                this.skillfunc = Event("伤害结算后", "治疗结算后", "死亡",
                    function(data)
                        local u
                        if data.event == "死亡" then
                            u = data.unit
                        else
                            u = data.to
                        end
                        if GetUnitTypeId(u) == |nlv1| and table.has(this.units, u) then
                            local this = Mark(u, "技能数据")
                            if this then
                                this:unitscode()
                            end
                        end
                    end
                )
            elseif this.event == "失去技能" then
                Event("-伤害结算后", "-治疗结算后", "-死亡", this.skillfunc)
            elseif this.event == "发动技能" then
                --燃烧伤害
                local p = GetOwningPlayer(this.unit)
                local damage = this:get(1) + this:get(2)
                local time = this:get(3)
                local flag = this.research and this.research[2]
                forRange(this.target, this:get("area"),
                    function(u)
                        if EnemyFilter(p, u) then
                            SkillEffect{
                                name = this.name,
                                from = this.unit,
                                to = u,
                                data = this,
                                aoe = true,
                                code = function(data)
                                    FireUnit{
                                        from = data.from,
                                        to = data.to,
                                        damage = damage,
                                        time = time,
                                        aoe = true,
                                        damageReason = this.name
                                    }
                                    if flag then
                                        StunUnit{
                                            from = data.from,
                                            to = data.to,
                                            aoe = true,
                                            time = 1.5
                                        }
                                    end
                                end
                            }
                        end
                    end
                )
                --目标点特效
                CreateModle("Abilities\\Spells\\Human\\FlameStrike\\FlameStrike.mdl", this.target, {time = 5, size = 1.5})
                
                --创建召唤单位
                local a = GetBetween(this.unit, this.target, true)
                local hp = this:get(9)
                local attack = this:get(5) + this:get(6) - 1
                local fire = this:get(7) + this:get(8)
                for i = 1, this:get(4) do
                    local u = CreateUnitAtLoc(p, |nlv1|, this.target, a)
                    table.insert(this.units, u)
                    SetUnitState(u, ConvertUnitState(0x12), attack)
                    SetUnitState(u, ConvertUnitState(0x20), 50)
                    if this.research and this.research[1] then
                        MaxLife(u, hp * 2 - 1)
                        SetUnitState(u, UNIT_STATE_LIFE, hp)
                    else
                        MaxLife(u, hp - 1)
                    end
                    if this.research and this.research[3] then
                        EnableAttack(u, false)
                    end
                    SetUnitAnimation(u, "birth")
                    QueueUnitAnimation(u, "stand")
                    Mark(u, "高温伤害", fire)
                    Mark(u, "高温攻击力", 0)
                    Mark(u, "技能数据", this)
                end
                this:freshunits()
            end
        end
    }
