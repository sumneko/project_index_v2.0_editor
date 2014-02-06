    
    HeroName[9] = "麦野沈利"
    HeroMain[9] = "智力"
    HeroType[9] = |Ntin|
    RDHeroType[9] = |h01I|
    HeroTypePic[9] = "ReplaceableTextures\\CommandButtons\\BTNMai.blp"
    HeroSize[9] = 0.99
    LearnSkillId = {|A17L|, |A17M|, |A17N|, |A17O|}
    
    --闪电攻击
    Event("远程攻击弹道", "伤害后",
        function(move)
            if GetUnitTypeId(move.from) == HeroType[9] then
                if move.event == "远程攻击弹道" then
                    local l = Lightning{
                        from = move.from,
                        name = 'LN00',
                        check = true,
                        x1 = move.x + GetUnitX(move.from),
                        y1 = move.y + GetUnitY(move.from),
                        z1 = move.z + GetUnitZ(move.from),
                        x2 = GetUnitX(move.target),
                        y2 = GetUnitY(move.target),
                        z2 = GetUnitZ(move.target) + move.tz,
                        time = 0.25,
                        cut = true
                    }
                elseif move.event == "伤害后" then
                    if move.weapon then
                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\ChimaeraLightningMissile\\ChimaeraLightningMissile.mdl", move.to, "chest"))
                    end
                end
            end
        end
    )
    
    --粒机波形高速炮
    InitSkill{
        name = "粒机波形高速炮",
        type = {"主动", 2}, --点目标
        ani = "spell",
        art = {"BTNManaFlare.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {120, 150, 180, 210},
        cool = {40, 36, 32, 28},
        rng = {1500, 1600, 1700, 1800},
        time = 1,
        area = 100,
        tip = "\
操纵并改变自由电子的性质轰击一条直线上的敌人,给予他们毁灭性的打击.自身会因为强大的反作用力而向后反冲一小段距离\n\
|cff00ffcc技能|r: 点目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00造成伤害|r: %s(|cff0000ff+%d|r)\
|cffffcc00施法延迟|r: %s\
|cffffcc00反冲距离|r: %s\n\
|cff888888施法延迟中技能已经进入冷却\n可对建筑造成伤害",
        researchtip = "敌方玩家看不到轨迹线",
        data = {
            {60, 120, 180, 240}, --伤害1
            function(ap, ad, data) --伤害加成2
                return ap * (0.4 + 0.1 * data.lv) --AP加成0.5/0.6/0.7/0.8
            end,
            1, --施法延迟3
            400, --反冲距离4
        },
        events = {"发动技能", "停止施放", "施放结束"},
        code = function(this)
            if this.event == "发动技能" then
                this.p1 = {
                    GetUnitX(this.unit),
                    GetUnitY(this.unit),
                    GetUnitZ(this.unit) + 75
                }
                this.face = GetBetween(this.unit, this.target, true)
                this.p2 = MovePoint(this.unit, {this:get("rng"), this.face})
                this.p2[3] = GetZ(this.p2) + 75
                this.l1 = AddLightningEx('LN01', false, this.p1[1], this.p1[2], this.p1[3], this.p2[1], this.p2[2], this.p2[3])
                if this.research and IsUnitEnemy(this.unit, SELFP) then
                    SetLightningColor(this.l1, 1, 0, 0, 0)
                else
                    SetLightningColor(this.l1, 1, 0, 0, 0.25)
                end
            elseif this.event == "施放结束" then
                local p = GetOwningPlayer(this.unit)
                local d = this:get(1) + this:get(2)
                local l = Lightning{
                    from = this.unit,
                    name = 'LN03',
                    check = false,
                    x1 = this.p1[1],
                    y1 = this.p1[2],
                    z1 = this.p1[3],
                    x2 = this.p2[1],
                    y2 = this.p2[2],
                    z2 = this.p2[3],
                    color = {1, 1, 1, 0},
                    cut = true
                }
                forSeg({l.x1, l.y1}, {l.x2, l.y2}, this:get("area") * 2,
                    function(u)
                        if EnemyFilter(p, u, {["建筑"] = true}) then
                            SkillEffect{
                                name = this.name,
                                from = this.unit,
                                to = u,
                                data = this,
                                aoe = true,
                                code = function(data)
                                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\ChimaeraLightningMissile\\ChimaeraLightningMissile.mdl", data.to, "chest"))
                                    Damage(data.from, data.to, d, false, true, {aoe = true, damageReason = this.name})
                                end
                            }
                        end
                    end
                )
                --光束特效
                local a = 0
                local flag = true
                Loop(0.02,
                    function()
                        if flag then
                            SetLightningColor(l.l, 1, 1, 1, a)
                            a = a + 0.1
                            if a >= 1 then
                                a = 1
                                flag = false
                            end
                        else
                            SetLightningColor(l.l, 1, 1, 1, a)
                            a = a - 0.01
                            if a <= 0 then
                                EndLoop()
                                DestroyLightning(l.l)
                            end
                        end
                    end
                )
                --反冲效果
                Mover{
                    unit = this.unit,
                    angle = this.face + 180,
                    distance = this:get(4),
                    time = 0.2,
                }
            elseif this.event == "停止施放" then
                DestroyLightning(this.l1)
            end
        end
    }
    
    --浮游粒子炮
    InitSkill{
        name = "浮游粒子炮",
        type = {"主动"},
        ani = "attack slam",
        art = {"BTNHeartOfAszune.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {90, 100, 110, 120},
        cool = 40,
        dur = 15,
        tip = "\
将超能力集聚起来创造散发能量的结晶体在自己身边随机游走,它们会持续对随机目标进行攻击.结晶体在攻击同一个单位时伤害会逐渐递减.\n\
|cff00ffcc技能|r: 无目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00结晶数量|r: %s\
|cffffcc00结晶伤害|r: %s(|cff0000ff+%d|r)\
|cffffcc00伤害递减|r: %s%%\
|cffffcc00游走范围|r: %s\
|cffffcc00攻击范围|r: %s\n\
|cff888888结晶体的生产间隔为%s\n结晶体的攻击间隔为%s\n最少造成%s%%伤害",
        researchtip = "结晶体优先攻击英雄",
        data = {
            {3, 4, 5, 6}, --数量1
            {24, 36, 48, 60}, --伤害2
            function(ap, ad, data) --伤害加成3
                return ap * 0.2 --AP加成0.2
            end,
            5, --伤害递减4
            400, --游走范围5
            400, --攻击范围6
            0.7, --生产间隔7
            1, --攻击间隔8
            25, --最小伤害9
        },
        events = {"失去技能", "获得技能", "发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                --生产结晶体
                local count = this:get(1) + 1
                local a1 = this:get(5)
                local a2 = this:get(6)
                local attckflash = this:get(8)
                local p = GetOwningPlayer(this.unit)
                local targets = {}
                local min = this:get(9) / 100
                LoopRun(this:get(7),
                    function()
                        count = count - 1
                        if count == 0 or IsUnitDead(this.unit) then
                            EndLoop()
                        else
                            local u = CreateModle("Abilities\\Weapons\\WitchDoctorMissile\\WitchDoctorMissile.mdl", this.unit, {size = 0.5})
                            table.insert(this.units, u)
                            SetUnitFlyHeight(u, 150, 0)
                            local callback
                            callback = function()
                                Mover({
                                        from = this.unit,
                                        unit = u,
                                        target = MovePoint(this.unit, {GetRandomInt(0, a1), GetRandomInt(1, 360)}),
                                        speed = 1000,
                                    },
                                    function(move)
                                        move.speed = move.speed - 0.4
                                        if move.speed <= 0 or IsUnitDead(move.unit) then
                                            move.stop = true
                                        end
                                    end,nil,
                                    function(move)
                                        if IsUnitAlive(move.unit) and IsUnitAlive(move.from) then
                                            Wait(GetRandomReal(0, 1), callback)
                                        end
                                    end
                                )
                            end
                            callback()
                            Wait(this:get("dur"),
                                function()
                                    KillUnit(u)
                                end
                            )
                            Loop(attckflash,
                                function()
                                    if IsUnitAlive(u) then
                                        local g = {}
                                        local u0
                                        forRange(u, a2,
                                            function(u)
                                                if IsUnitVisible(u, p) and EnemyFilter(p, u) then
                                                    table.insert(g, u)
                                                    if this.research and IsHero(u) then
                                                        u0 = u
                                                    end
                                                end
                                            end
                                        )
                                        local n = #g
                                        if n == 0 then return end
                                        local u2 = g[GetRandomInt(1, n)]
                                        if u0 then
                                            u2 = u0
                                        end
                                        local l = Lightning{
                                            from = this.unit,
                                            name = 'LN00',
                                            check = true,
                                            x1 = GetUnitX(u),
                                            y1 = GetUnitY(u),
                                            z1 = GetUnitZ(u),
                                            x2 = GetUnitX(u2),
                                            y2 = GetUnitY(u2),
                                            z2 = GetUnitZ(u2) + 75,
                                            cut = true,
                                            time = 0.1
                                        }
                                        if not l.cuted then
                                            targets[u2] = (targets[u2] or 1)
                                            local d = (this:get(2) + this:get(3)) * targets[u2]
                                            targets[u2] = math.max(min, targets[u2] - this:get(4) * 0.01)
                                            Damage(this.unit, u2, d, false, true, {aoe = true, damageReason = this.name})
                                            DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\ChimaeraLightningMissile\\ChimaeraLightningMissile.mdl", u2, "chest"))
                                        end
                                    else
                                        EndLoop()
                                    end
                                end
                            )
                        end
                    end
                )
            elseif this.event == "失去技能" then
                Event("-死亡", this.skillfunc)
            elseif this.event == "获得技能" then
                this.units = {}
                this.stopskill = function(this)
                    for _, u in ipairs(this.units) do
                        KillUnit(u)
                    end
                    this.units = {}
                end
                this.skillfunc = Event("死亡",
                    function(data)
                        if data.unit == this.unit and IsHero(this.unit) then
                            this:stopskill()
                        end
                    end
                )
            end
        end
    }
    
    --立场崩坏
    InitSkill{
        name = "立场崩坏",
        type = {"主动", 2, 3},
        ani = "spell",
        art = {"BTNAntiMagicShell.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = 75,
        cool = 20,
        rng = 350,
        dur = {2, 4, 6, 8},
        area = 150,
        tip = "\
将一个区域内的粒子崩坏,任何穿过该区域的弹道将被吞噬并截断光束.\n\
|cff00ffcc技能|r: 点目标\n\
|cff888888无视敌我\n以光束为弹道的效果被截断后将失效",
        researchtip = "你自己的弹道与光束可以穿过立场",
        data = {
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                local mod = CreateModle("Abilities\\Spells\\Demon\\DarkConversion\\ZombifyTarget.mdl", this.target, {time = this:get("dur"), size = 1.5, remove = true})
                local area = this:get("area")
                local func = Event("截断光束",
                    function(l)
                        if IsUnitDead(mod) or (this.research and GetOwningPlayer(l.from) == this.player) then return end
                        if GetBetween({l.x1, l.y1}, mod) < area then
                            l.x2 = l.x1
                            l.y2 = l.y1
                            l.cuted = true
                            l.length = 0
                        else
                            --计算出点到直线的距离
                            local A, B, C = l.y1 - l.y2, l.x2 - l.x1, (l.y2 - l.y1) * l.x1 + (l.x1 - l.x2) * l.y1
                            local s = math.sqrt(A * A + B * B)
                            local b = math.abs(A * GetUnitX(mod) + B * GetUnitY(mod) + C) / s
                            if b < area then --距离小于判定点(在圆内)
                                local c = GetBetween({l.x1, l.y1}, mod) --构建直角三角形
                                local a1 = math.sqrt(c * c - b * b) --计算出垂足到起点的距离
                                local a2 = math.sqrt(area * area - b * b) --计算出圆内的距离
                                local a = a1 - a2
                                if l.length > a then --光束长度大于这个距离
                                    local s = a / l.length --算出比例
                                    l.x2 = l.x1 + (l.x2 - l.x1) * s
                                    l.y2 = l.y1 + (l.y2 - l.y1) * s
                                    l.z2 = l.z1 + (l.z2 - l.z1) * s
                                    l.cuted = true
                                    l.length = a
                                end
                            end
                        end
                    end
                )
                Loop(0.05,
                    function()
                        if IsUnitAlive(mod) then
                            forRange(mod, area,
                                function(u)
                                    if GetUnitTypeId(u) == |e031| then
                                        local move = Mark(u, "移动器")
                                        if move then
                                            if not (this.research and GetOwningPlayer(move.from) == this.player) then
                                                move.stop = true
                                            end
                                        end
                                    end
                                end
                            )
                        else
                            EndLoop()
                            Event("-截断光束", func)
                        end
                    end
                )
                
            end
        end
    }
    
    --完美主义
    InitSkill{
        name = "完美主义",
        type = {"被动"},
        art = {"BTNPossession.blp"},
        tip = "\
麦野沈利的强化自己的攻击,附带额外的法术伤害.当她负伤时将进入狂怒的暴走状态,根据已损失的生命值有几率进行多重施法.\n\
|cff00ffcc技能|r: 被动\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00额外伤害|r: %s\
|cffffcc00临界生命|r: %s%%\
|cffffcc00最大双重几率|r: %s%%\
|cffffcc00最大三重几率|r: %s%%\
|cffffcc00最大四重几率|r: %s%%\n\
|cff888888技能目标会有误差\n同时触发时取最高|r\n\
当前的多重几率:\
双重: |cffffcc00%d|r%%\
三重: |cffffcc00%d|r%%\
四重: |cffffcc00%d|r%%",
        researchtip = {
            "至少拥有50%生命值时的效果",
            "变为开关技能,开启后多重几率倍乘150%,每重额外施法需要消耗同等法力值",
            "英雄技能造成伤害时为对方附加5秒的暴走标记,你的普通攻击会移除暴走标记并造成你最大生命值20%的法术伤害.取代攻击附带的额外法术伤害"
        },
        data = {
            function(ap) --额外伤害1
                return ap * 0.5
            end,
            75, --临界判定2
            {60, 80, 100}, --双重几率3
            {30, 40, 50}, --三重几率4
            {15, 20, 25}, --四重几率5
            0, --双重6
            0, --三重7
            0, --四重8
        },
        events = {"获得技能", "研发", "失去技能"},
        code = function(this)
            if this.event == "失去技能" then
                DestroyTimer(this.skilltimer)
                Event("-伤害效果", "-英雄技能回调", this.skillfunc)
            elseif this.event == "研发" then
                if this.lastResearch == 2 then
                    this.type[1] = "开关"
                    this.art[2] = this.art[1]
                    this.art[3] = "BTNWispSplode.blp"
                    this.ani = "stand"
                    this.cast = 0
                    this.time = 0.01
                    local ab = japi.EXGetUnitAbility(this.unit, this.id)
                    japi.EXSetAbilityDataReal(ab, 1, 105, 0)
                    japi.EXSetAbilityState(ab, 1, 0)
                end
            elseif this.event == "获得技能" then
                this.spellgroup = {}
                this.skilltimer = Loop(1,
                    function()
                        local a = GetUnitState(this.unit, UNIT_STATE_LIFE) / GetUnitState(this.unit, UNIT_STATE_MAX_LIFE) * 100
                        if a > 50 and this.research and this.research[1] then
                            a = 50
                        end
                        if a > this:get(2) then
                            this.data[6] = 0
                            this.data[7] = 0
                            this.data[8] = 0
                        else
                            a = 1 - a / 75
                            if this.openflag then
                                a = a * 1.5
                            end
                            this.data[6] = a * this:get(3)
                            this.data[7] = a * this:get(4)
                            this.data[8] = a * this:get(5)
                        end
                        
                        SetSkillTip(this.unit, this.name)
                        RefreshTips(this.unit)
                    end
                )
               this.skillfunc = Event("伤害效果", "英雄技能回调",
                    function(data)
                        if data.event == "伤害效果" then
                            if this.unit == data.from then
                                if data.weapon then
                                    if this.research and this.research[3] then
                                        local t = Mark(data.to, "暴走标记")
                                        if t then
                                            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\ManaFlare\\ManaFlareBoltImpact.mdl", data.to, "overhead"))
                                            local d = 0.2 * GetUnitState(this.unit, UNIT_STATE_MAX_LIFE)
                                            Damage(this.unit, data.to, d, false, true, {damageReason = "暴走标记"})
                                            t.timer[4]()
                                        end
                                    else
                                        Damage(this.unit, data.to, this:get(1), false, true, {damageReason = this.name})
                                    end
                                elseif not data.item and this.research and this.research[3] and data.damageReason ~= "暴走标记" then
                                    local t = Mark(data.to, "暴走标记")
                                    if t then
                                        TimerRestart(t.timer)
                                    else
                                        t = {timer = CreateTimer(), effect = AddSpecialEffectTarget("Abilities\\Spells\\Human\\ManaFlare\\ManaFlareTarget.mdl", data.to, "overhead")}
                                        Mark(data.to, "暴走标记", t)
                                        TimerStart(t.timer, 5, false,
                                            function()
                                                DestroyEffect(t.effect)
                                                DestroyTimer(t.timer)
                                                Mark(data.to, "暴走标记", false)
                                            end
                                        )
                                    end
                                end
                            end
                        elseif data.event == "英雄技能回调" then
                            if this.unit == data.skill.unit then
                                local that = data.skill
                                if that.event == "发动技能" then
                                    if GetRandomInt(0, 99) < this:get(8) then
                                        this.double = 4
                                    elseif GetRandomInt(0, 99) < this:get(7) then
                                        this.double = 3
                                    elseif GetRandomInt(0, 99) < this:get(6) then
                                        this.double = 2
                                    else
                                        this.double = false
                                    end
                                    if this.double then
                                        local x = this.double
                                        Text{
                                            unit = this.unit,
                                            word = "×" .. x,
                                            size = 20,
                                            color = {100, 0, 0},
                                            speed = {32, 60},
                                            life = {3, 5},
                                            x = 50,
                                            y = 50
                                        }
                                        this.spellgroup[that.name] = this.spellgroup[that.name] or {} --新建技能栈
                                        local target = that.target
                                        local event = that.event
                                        Loop(0.5,
                                            function()
                                                x = x - 1
                                                if x == 0 then
                                                    EndLoop()
                                                else
                                                    if this.openflag then
                                                        SetUnitState(this.unit, UNIT_STATE_MANA, GetUnitState(this.unit, UNIT_STATE_MANA) - that:get("mana"))
                                                    end
                                                    local ntarget = target
                                                    if type(target) == "table" then
                                                        target = MovePoint(target, {GetRandomInt(100, 400), GetRandomInt(0, 360)})
                                                    end
                                                    that.event = event
                                                    DummyHeroSkill(this.unit, target, that, that.name .. "(" .. this.name .. x .. ")") --使用新的技能名来保存技能
                                                    table.insert(this.spellgroup[that.name], that.name .. "(" .. this.name .. x .. ")") --进栈
                                                end
                                            end
                                        )
                                    end
                                elseif that.event == "停止施放" or that.event == "施放结束" then
                                    local event = that.event
                                    local i = 0
                                    Loop(0.5,
                                        function()
                                            if this.spellgroup[that.name] then --技能栈是否存在
                                                local name = this.spellgroup[that.name][1] --取出栈底技能
                                                if name then
                                                    that.event = event
                                                    DummyHeroSkill(this.unit, target, that, name)
                                                    if event == "停止施放" then
                                                        table.remove(this.spellgroup[that.name], 1)
                                                    end
                                                else
                                                    EndLoop()
                                                end
                                            else
                                                EndLoop()
                                            end
                                        end
                                    )
                                end
                            end
                        end
                    end
                )
            end
        end
    }
