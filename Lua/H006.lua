    
    HeroName[6] = "御坂妹妹"
    HeroMain[6] = "敏捷"
    HeroType[6] = |Nngs|
    RDHeroType[6] = |h01H|
    HeroTypePic[6] = "ReplaceableTextures\\CommandButtons\\BTNmeimei.blp"
    HeroSize[6] = 0.99
    LearnSkillId = {|A15R|, |A15S|, |A15T|, |A15U|}
    
    --闪电之枪
    InitSkill{
        name = "闪电之枪",
        type = {"主动", 1},
        ani = "attack slam",
        art = {"BTNChainLightning.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {80, 100, 120, 140},
        cool = 12,
        rng = 700,
        cast = 0.3,
        area = 100,
        dur = {1.5, 2, 2.5, 3},
        targs = GetTargs("地面,空中,敌人,有机生物"),
        tip = "\
利用自己的能力发射出一道闪电,对目标造成伤害并使其|cffffcc00麻痹|r.被闪电贯穿的单位也会受到同样的伤害.\n\
|cff00ffcc技能|r: 单位目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00造成伤害|r: %s(|cff0000ff+%d|r)\n\
|cff888888可以驱散\n处于麻痹状态的单位无法移动或使用普通攻击",
        researchtip = "被贯穿的单位也会被麻痹1秒",
        data = {
            {60, 120, 180, 240}, --造成伤害1
            function(ap) --伤害加成2
                return ap * 0.8 --AP加成为0.8
            end,
        },
        events = {"发动技能"},
        code = function(this)
            --闪电效果
            local x1, y1, z1, x2, y2, z2 = GetUnitX(this.unit), GetUnitY(this.unit), GetUnitZ(this.unit) + 75, GetUnitX(this.target), GetUnitY(this.target), GetUnitZ(this.target) + 75
            local l = Lightning{
                from = this.unit,
                name = 'CLPB',
                check = true,
                x1 = x1,
                y1 = y1,
                z1 = z1,
                x2 = x2,
                y2 = y2,
                z2 = z2,
                cut = true
            }
            local l1 = l.l
            local l2 = AddLightningEx("CLSB", true, l.x1, l.y1, l.z1, l.x2, l.y2, l.z2)
            Wait(0.5,
                function()
                    DestroyLightning(l1)
                    DestroyLightning(l2)
                end
            )
            local d = this:get(1) + this:get(2)
            local p = GetOwningPlayer(this.unit)
            
            if not l.cuted then
            
                --对指定目标的伤害
                
                local time = this:get("dur")
                SkillEffect{
                    name = this.name,
                    from = this.unit,
                    to = this.target,
                    data = this,
                    code = function(data)
                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Orc\\LightningBolt\\LightningBoltMissile.mdl", data.to, "chest"))
                        BenumbUnit{
                            to = data.to,
                            from = data.from,
                            time = time
                        }
                        Damage(data.from, data.to, d, false, true, {damageReason = this.name})
                    end
                }
            end
            --贯穿效果
            forSeg(this.unit, {l.x2, l.y2}, this:get("area"),
                function(u)
                    if EnemyFilter(p, u) and u ~= this.target then
                        SkillEffect{
                            name = this.name,
                            from = this.unit,
                            to = u,
                            data = this,
                            aoe = true,
                            code = function(data)
                                if this.research then
                                    BenumbUnit{
                                        to = data.to,
                                        from = data.from,
                                        aoe = true,
                                        time = 1
                                    }
                                end
                                DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Orc\\LightningBolt\\LightningBoltMissile.mdl", this.target, "chest"))
                                Damage(data.from, data.to, d, false, true, {aoe = true, damageReason = this.name})
                            end
                        }
                    end
                end
            )
        end
    }
    
    --连环狙击
    InitSkill{
        name = "连环狙击",
        type = {"主动", 1},
        ani = "attack",
        art = {"BTNFlakCannons.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {80, 100, 120, 140},
        cool = 30,
        rng = 800,
        time = 5,
        dur = 5,
        area = 100,
        targs = GetTargs("地面,空中,敌人,有机生物"),
        tip = "\
短暂的瞄准后,御坂妹妹用对战车用远距离狙击枪对一个目标进行连续狙击,射出的子弹对沿途击中的第一个单位造成全额伤害,对第二个单位造成一半的伤害.\n\
|cffffcc00需要持续施法\n\n|cff00ffcc技能|r: 单位目标\n|cff00ffcc伤害|r: 物理\n\
|cffffcc00子弹造成伤害|r: %s(|cffff0000+%d|r)\
|cffffcc00子弹数量|r: %s\n\
|cff888888瞄准时间为1秒,瞄准时技能已经开始冷却\n狙击状态可以提前中断,对方离开视野会强制中断\n狙击状态下的最大转身速度为45°/秒\n子弹的最大飞行距离为%s,飞行速度为%s",
        researchtip = "子弹可以击中4个单位,分别造成100%,70%,40%,10%的伤害",
        data = {
            {20, 30, 40, 50}, --造成伤害1
            function(ap, ad) --伤害加成2
                return ad * 0.25 --AD加成为0.25
            end,
            16, --子弹数量3
            2000, --飞行距离4
            1500, --飞行速度5            
        },
        events = {"发动技能"},
        code = function(this)
            local count = 0
            local e = AddSpecialEffectTarget("snipe target.mdx", this.target, "overhead")
            local down = 0.5
            if this.research then
                down = 0.3
            end
            Loop(0.05,
                function()
                    if this.spellflag then
                        count = count + 1
                        local face = GetUnitFacing(this.unit)
                        local to = GetBetween(this.unit, this.target, true)
                        local a = math.A2A(face, to)
                        if a > 2.25 then
                            local to1 = math.A2A(face, to + 2.25)
                            local to2 = math.A2A(face, to - 2.25)
                            if math.A2A(to, to1) < math.A2A(to, to2) then
                                to = to + 2.25
                            else
                                to = to - 2.25
                            end
                        end
                        SetUnitFacing(this.unit, to)
                        if count % 5 == 0 and count > 20 then
                            --发射移动器
                            local t = {} --表示已经伤害过的单位
                            local dd = 1 --伤害系数
                            Mover({
                                from = this.unit,
                                angle = GetUnitFacing(this.unit),
                                modle = "RocketMissile1.mdl",
                                speed = this:get(5),
                                distance = this:get(4),
                                z = 75,
                                aoe = true,
                                data = {damage = this:get(1) + this:get(2)},
                                },
                                function(move)
                                    if dd <= 0 then
                                        move.stop = true
                                        return
                                    end
                                    if move.count % 4 == 0 then
                                        --先选取单位
                                        local p = GetOwningPlayer(move.from)
                                        local t0 = {} --等待排序处理的表
                                        forRange(move.unit, this:get("area"),
                                            function(u)
                                                if not t[u] and EnemyFilter(p, u) then
                                                    table.insert(t0, u)
                                                end
                                            end
                                        )
                                        --根据距离排序单位
                                        table.sort(t0,
                                            function(u1, u2)
                                                return GetBetween(move.from, u1) < GetBetween(move.from, u2)
                                            end
                                        )
                                        for _, u in ipairs(t0) do
                                            t[u] = true
                                            if dd <= 0 or move:newTarget(u) then return end
                                            DestroyEffect(AddSpecialEffectTarget("RocketMissile1.mdl", move.unit, "origin"))
                                            SkillEffect{
                                                name = this.name,
                                                from = move.from,
                                                to = u,
                                                data = this,
                                                aoe = true,
                                                dd = dd,
                                                code = function(data)
                                                    Damage(data.from, data.to, data.dd * move.data.damage, true, false, {damageReason = this.name})
                                                    
                                                end
                                            }
                                            dd = dd - down
                                        end
                                    end
                                end
                            )
                        end
                    else
                        EndLoop()
                        DestroyEffect(e)
                    end
                end
            )
        end
    }
    
    --枪械精通
    InitSkill{
        name = "枪械精通",
        type = {"主动"},
        ani = "stand",
        art = {"BTNHumanMissileUpOne.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = 50,
        cool = 30,
        dur = 10,
        tip = "\
|cff00ccff主动|r: 御坂妹妹进入狙击模式,提高射程与施法距离.\
|cff00ccff被动|r: 御坂妹妹拥有的枪械知识使得其更容易针对敌方的弱点进行攻击,永久获得一定的护甲穿透.\n\
|cff00ffcc技能|r: 无目标\n\
|cffffcc00射程/施法距离提升|r: %s%%\
|cffffcc00护甲穿透|r: %s\n\
|cff888888护甲穿透不会导致对方的护甲为负数",
        researchtip = "狙击模式下拥有800范围的空中视野",
        data = {
            {10, 20, 30, 40}, --射程提升1
            {7.5, 15, 22.5, 30} --护甲穿透2
        },
        events = {"发动技能", "获得技能", "升级技能", "失去技能"},
        code = function(this)
            if this.event == "发动技能" then
                local r = this:get(1)
                local rng = r * GetUnitState(this.unit, ConvertUnitState(0x16)) * 0.01
                local e = AddSpecialEffectTarget("Environment\\NightElfBuildingFire\\ElfSmallBuildingFire1.mdl", this.unit, "weapon")
                local rr = {}
                AttackRange(this.unit, rng)
                for i = 1, 6 do
                    local this = findSkillData(this.unit, i)
                    if this and this.rng then
                        if type(this.rng) == "table" then
                            rr[i] = {}
                            for j in ipairs(this.rng) do
                                rr[i][j] = this.rng[j] * r *0.01
                                this.rng[j] = this.rng[j] + rr[i][j]
                            end
                        elseif type(this.rng) == "number" then
                            rr[i] = this.rng * r * 0.01
                            this.rng = this.rng + rr[i]
                        end
                    end
                end
                RefreshHeroSkills(this.unit)
                RefreshTips(this.unit)
                local data
                if this.research then
                    data = {
                        fm = CreateFogModifierRadius(this.player, FOG_OF_WAR_VISIBLE, GetUnitX(this.unit), GetUnitY(this.unit), 800, true, false),
                        timer = CreateTimer(),
                    }
                    FogModifierStart(data.fm)
                    TimerStart(data.timer, 0.1, true,
                        function()
                            local fm = CreateFogModifierRadius(this.player, FOG_OF_WAR_VISIBLE, GetUnitX(this.unit), GetUnitY(this.unit), 800, true, false)
                            FogModifierStart(fm)
                            DestroyFogModifier(data.fm)
                            data.fm = fm
                        end
                    )
                end
                Wait(this:get("dur"),
                    function()
                        DestroyEffect(e)
                        AttackRange(this.unit, -rng)
                        for i = 1, 6 do
                            local this = findSkillData(this.unit, i)
                            if this and this.rng then
                                if type(this.rng) == "table" then
                                    for j in ipairs(this.rng) do
                                        this.rng[j] = this.rng[j] - rr[i][j]
                                    end
                                elseif type(this.rng) == "number" then
                                    this.rng = this.rng - rr[i]
                                end
                            end
                        end
                        RefreshHeroSkills(this.unit)
                        RefreshTips(this.unit)
                        if data then
                            DestroyTimer(data.timer)
                            DestroyFogModifier(data.fm)
                        end
                    end
                )
            elseif this.event == "获得技能" or this.event == "升级技能" then
                DefPenetrate(this.unit, this:get(2) - (this.def or 0))
                this.def = this:get(2)
            elseif this.event == "失去技能" then
                DefPenetrate(this.unit, nil, -this.def or 0)
            end
        end
    }
    
    --御坂标记
    InitSkill{
        name = "御坂标记",
        type = {"主动", 2},
        ani = "attack slam",
        art = {"BTN__landvin__6.blp"}, --左边是学习,右边是普通.不填右边视为左边
        icon = 2,
        mana = 100,
        rng = {500, 1500, 2500},
        cool = {30, 25, 20},
        dur = {30, 35, 40},
        tip = "\
御坂妹妹在指定位置放出信号,5秒后另一个御坂妹妹将加入战场协助战斗.协助者处于无敌状态始终潜伏在指定位置为你侦查,在允许的情况下会协助你战斗,重复你的攻击动作.\n\
|cff00ffcc技能|r: 点目标\n\
|cff888888信号仅友方可见\n协助者在不攻击或施法的时候是隐身的,进入隐身时间为3秒\n协助者会尝试重复你的攻击与技能,不过条件是你的目标也在协助者的射程之内\n协助者无法移动,不过法力是无限的",
        researchtip = {
            "御坂妹妹进入战场协助的延迟降低为1秒",
            "1000范围内与你最近的御坂妹妹会为你分担33%所受伤害",
            "获得一个副技能,可以与一个御坂妹妹交换位置,冷却60秒",
        },
        data = {},
        group = {},
        events = {"发动技能", "获得技能", "失去技能", "研发"},
        code = function(this)
            if this.event == "获得技能" then
                this.skillfunc = Event("伤害效果", "远程攻击弹道", "英雄技能回调",
                    function(data)
                        local u1, u2
                        if data.event == "伤害效果" then
                            if not data.weapon or data.missile then --如果不是普通攻击或是远程普通攻击的伤害则取消
                                return
                            end
                            u1 = data.from
                            u2 = data.to
                        elseif data.event == "远程攻击弹道" then
                            u1 = data.from
                            u2 = data.target
                        elseif data.event == "英雄技能回调" then
                            if data.skill.name == this.name then return end --本技能自己不会触发
                            u1 = data.skill.unit
                            u2 = data.skill.target
                        end
                        if u1 == this.unit and IsHero(u1) and Mark(u1, "注册英雄") then
                            local r --可以协助的距离
                            if data.event == "伤害效果" then
                                r = GetUnitState(u1, ConvertUnitState(0x16)) --攻击范围
                            elseif data.event == "远程攻击弹道" then
                                r = GetUnitState(u1, ConvertUnitState(0x16)) --攻击范围
                            elseif data.event == "英雄技能回调" then
                                r = data.skill:get("rng") --技能的施放距离
                            end
                            
                            for _, u in ipairs(this.group) do
                                if GetOwningPlayer(u) == GetOwningPlayer(u1) then
                                    local d = GetBetween(u, u2) --协助者与目标的距离
                                    local a = GetBetween(u, u2, true) --角度
                                    Mark(u) --清空协助者当前数据
                                    metaMark(u, u1) --协助者继承所有数据
                                    Mark(u, "注册英雄", false) --协助者移除注册英雄标记
                                    Mark(u, "技能", false) --协助者移除英雄技能
                                    SetHeroAgi(u, GetHeroAgi(u1, true), true)
                                    SetHeroInt(u, GetHeroInt(u1, true), true)
                                    SetHeroStr(u, GetHeroStr(u1, true), true)
                                    if data.event == "伤害效果" or data.event == "远程攻击弹道" then
                                        if d <= r then
                                            --开始进行攻击协助
                                            SetUnitFacing(u, a)
                                            SetUnitAnimation(u, "attack")
                                            QueueUnitAnimation(u, "stand")
                                            UnitRemoveAbility(u, |A160|)
                                            UnitAddAbility(u, |A160|)
                                            UnitMakeAbilityPermanent(u, true, |A160|)
                                            Wait(tonumber(getObj(slk.unit, GetUnitTypeId(u), "dmgpt1", 0)), --等待攻击前摇的时间
                                                function()
                                                    if IsUnitAlive(u) then
                                                        local d = GetRandomInt(GetUnitState(u1, ConvertUnitState(0x14)), GetUnitState(u1, ConvertUnitState(0x15)))
                                                        Damage(u, u2, d, true, false, {attack = true, weapon = true, damageReason = "普通攻击"})
                                                    end
                                                end
                                            )
                                        end
                                    elseif data.event == "英雄技能回调" then
                                        if not r or d <= r then --r为nil说明是无目标技能,可以随意使用
                                            SetUnitFacing(u, a)
                                            UnitRemoveAbility(u, |A160|)
                                            UnitAddAbility(u, |A160|)
                                            UnitMakeAbilityPermanent(u, true, |A160|)
                                            if data.skill.ani then
                                                SetUnitAnimation(u, data.skill.ani)
                                                QueueUnitAnimation(u, "stand")
                                            end
                                            if data.skill.event == "发动技能" then
                                                Wait(data.skill:get("cast"), --等待施法前摇的时间
                                                    function()
                                                        if IsUnitAlive(u) then
                                                            DummyHeroSkill(u, u2, data.skill)
                                                        end
                                                    end
                                                )
                                            else
                                                DummyHeroSkill(u, u2, data.skill)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                )
            elseif this.event == "失去技能" then
                Event("-伤害效果", "-远程攻击弹道", "-英雄技能回调", this.skillfunc)
                RemoveSkill(this.unit, "交换位置")
            elseif this.event == "发动技能" then
                local e
                if IsGod(SELFP) or IsPlayerAlly(GetOwningPlayer(this.unit), SELFP) then
                    e = AddSpecialEffectLoc("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", this.target)
                else
                    e = AddSpecialEffectLoc("", this.target)
                end
                local t = this:get("dur")
                local target = this.target
                local delay = 5
                if this.research and this.research[1] then
                    delay = 1
                end
                Wait(delay,
                    function()
                        DestroyEffect(e)
                        local u = CreateUnitAtLoc(GetOwningPlayer(this.unit), GetUnitTypeId(this.unit), target, GetBetween(this.unit, target, true))
                        UnitAddAbility(u, |Aloc|)
                        UnitAddAbility(u, |A160|)
                        UnitAddAbility(u, |Avul|)
                        UnitMakeAbilityPermanent(u, true, |Aloc|)
                        UnitMakeAbilityPermanent(u, true, |A160|)
                        UnitAddType(u, UNIT_TYPE_SUMMONED)
                        table.insert(this.group, u)
                        SetHeroLevel(u, GetHeroLevel(this.unit), false)
                        UnitModifySkillPoints(u, -100) --清除技能点
                        if this.researchfunc2 == nil and this.research and this.research[2] then
                            this.researchfunc2 = Event("伤害减免",
                                function(damage)
                                    if damage.to == this.unit then
                                        local u = table.getone(this.group,
                                            function(u1, u2)
                                                return GetBetween(u1, this.unit) < GetBetween(u2, this.unit)
                                            end
                                        )
                                        if GetBetween(u, this.unit) < 1000 then
                                            local hp = GetUnitState(u, UNIT_STATE_LIFE)
                                            local d = math.min(damage.damage, damage.odamage * 0.33, hp - 1)
                                            damage.damage = damage.damage - d
                                            SetUnitState(u, UNIT_STATE_LIFE, hp - d)
                                        end
                                    end
                                end
                            )
                        end
                        Wait(t,
                            function()
                                table.remove2(this.group, u)
                                RemoveUnit(u)
                                if #this.group == 0 then
                                    Event("-伤害减免", this.researchfunc2)
                                    this.researchfunc2 = nil
                                end
                            end
                        )
                    end
                )
            elseif this.event == "研发" then
                if this.lastResearch == 3 then
                    AddSkill(this.unit, "交换位置")
                end
            end
        end
    }
    
    --交换位置
    InitSkill{
        name = "交换位置",
        type = {"主动", 2},
        ani = "stand",
        art = {"BTNReplay-Loop.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = 0,
        rng = "全地图",
        cool = 60,
        tip = "\
立即与协助你的御坂妹妹交换位置",
        data = {},
        events = {"发动技能"},
        code = function(this)
            if not IsHero(this.unit) then return end --防止此技能被协助者复制
            if this.event == "发动技能" then
                local that = findSkillData(this.unit, "御坂标记")
                if that then
                    local u = table.getone(that.group,
                        function(u1, u2)
                            return GetBetween(u1, this.target) < GetBetween(u2, this.target)
                        end
                    )
                    if u then
                        local loc1, loc2 = GetUnitLoc(this.unit), GetUnitLoc(u)
                        SetUnitXY(this.unit, loc2)
                        SetUnitXY(u, loc1)
                        TempEffect(loc1, "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl")
                        TempEffect(loc2, "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl")
                    else
                        printTo(this.player, "|cffffcc00没有找到其他御坂妹妹!|r")
                        if SELFP == this.player then
                            StartSound(gg_snd_Error)
                        end
                        this.cool = 1
                        Wait(0,
                            function()
                                this.cool = 60
                            end
                        )
                    end
                end
            end
        end
    }
