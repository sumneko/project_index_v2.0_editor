    
    HeroName[1] = "神裂火织"
    HeroMain[1] = "敏捷"
    HeroType[1] = |Ekee|
    RDHeroType[1] = |h011|
    IllHeroType[1] = |E035|
    HeroTypePic[1] = "ReplaceableTextures\\CommandButtons\\BTNSLHZ.blp"
    HeroSize[1] = 1.1
    LearnSkillId = {|A13T|, |A13U|, |A13V|, |A13W|}
    
    --圣能
    local Point = function(u)
        local point = Mark(u, "神裂圣能") or 0
        if point == 0 then
            Mark(u, "神裂圣能", 1)
            Mark(u, "神裂圣能1", AddSpecialEffectTarget("Abilities\\Weapons\\SerpentWardMissile\\SerpentWardMissile.mdl", u, "weapon"))
        elseif point == 1 then
            Mark(u, "神裂圣能", 2)
            Mark(u, "神裂圣能2", AddSpecialEffectTarget("Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl", u, "weapon"))
        elseif point == 2 then
            if Mark(u, "圣痕") then
                Mark(u, "神裂圣能", 1)
                DestroyEffect(Mark(u, "神裂圣能2"))
            else
                Mark(u, "神裂圣能", 0)
                DestroyEffect(Mark(u, "神裂圣能1"))
                DestroyEffect(Mark(u, "神裂圣能2"))
            end
        end
        return point
    end
    
    --七闪
    InitSkill{
        name = "七闪",
        type = {"主动", 2},
        art = {"BTNThoriumMelee.blp"},
        dur = {1, 1.2, 1.4, 1.6},
        area = 175,
        mana = {90, 120, 150, 180},
        cool = {15, 13, 11, 9},
        ani = "spell 1",
        cast = 0.1,
        rng = 1000,
        tip = "\
神裂发射出7根钢丝,对沿途的单位造成伤害.\n\
|cffffcc00圣能0|r: 产生1点圣能\
|cffffcc00圣能1|r: 产生1点圣能.钢丝将在0.5秒后收回,再次对沿途的单位造成50%%的伤害\
|cffffcc00圣能2|r: 消耗2点圣能.钢丝收回时将单位拖拽到自己面前并|cffffcc00减速|r\n\
|cff00ffcc技能|r: 点目标\
|cff00ffcc伤害|r: 物理\n\
|cffffcc00总伤害|r: %s(|cffff1111+%d|r)\
|cffffcc00降低移动速度|r: 100%%\n\
|cff888888减速效果不叠加,可被驱散\n弹道移动速度为%s|r",
        researchtip = "钢丝在收回时造成150%的伤害",
        data = {
            {90, 130, 170, 210}, --伤害1
            function(ap, ad, data) --伤害加成2
                return ad * (0.2 + 0.2*data.lv) --AD加成为 0.4/0.6/0.8/1.0
            end,
            1000, --弹道移动速度3
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                local point = Point(this.unit)
                local d = this:get(1) + this:get(2)
                local g = {}
                local area = this:get("area")
                local p = GetOwningPlayer(this.unit)
                local dur = this:get("dur")
                Mover({
                        from = this.unit,
                        distance = this:get("rng"),
                        speed = this:get(3),
                        angle = GetBetween(this.unit, this.target, true),
                        modle = "RedBladeShockwave.mdl",
                        size = 2,
                    },
                    function(move)
                        if move.count % 5 == 0 then --每0.1秒判定一次
                            forRange(move.unit, area,
                                function(u)
                                    if not g[u] and EnemyFilter(p, u) then
                                        g[u] = true
                                        Damage(move.from, u, d, true, false, {aoe = true, damageReason = this.name})
                                    end
                                end
                            )
                            --特效
                            local us = CreateUbersplatBJ(GetUnitLoc(move.unit), "THND", 100, 100, 100, 0, false, false )
                            FinishUbersplat(us)
                            TempEffect(move.unit, "Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl")
                        end
                    end,nil,
                    function(move)
                        if point == 0 then return end
                        local loc = GetUnitLoc(move.unit)
                        Wait(0.5,
                            function()
                                local g = {}
                                if this.research then
                                    d = d * 1.5
                                else
                                    d = d / 2
                                end
                                Mover({
                                        from = move.from,
                                        source = loc,
                                        distance = GetBetween(loc, move.from),
                                        speed = this:get(3),
                                        angle = GetBetween(move.unit, move.from, true),
                                        modle = "RedBladeShockwave.mdl",
                                        size = 1.5,
                                    },
                                    function(move)
                                        if move.count % 5 == 0 then --每0.1秒判定一次
                                            forRange(move.unit, area,
                                                function(u)
                                                    if not g[u] and EnemyFilter(p, u) then
                                                        g[u] = true
                                                        Damage(move.from, u, d, true, false, {aoe = true, damageReason = this.name})
                                                        if point > 1 then
                                                            MoveSpeed(u, -10000)
                                                        end
                                                    end
                                                end
                                            )
                                            if point > 1 then
                                                for u in pairs(g) do
                                                    SetUnitXY(u, move.unit)
                                                end
                                            end
                                            --特效
                                            local us = CreateUbersplatBJ(GetUnitLoc(move.unit), "THND", 100, 100, 100, 0, false, false )
                                            FinishUbersplat(us)
                                            TempEffect(move.unit, "Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl")
                                        end
                                    end,nil,
                                    function(move)
                                        if point > 1 then
                                            for u in pairs(g) do
                                                MoveSpeed(u, 10000)
                                                SkillEffect{
                                                    name = this.name,
                                                    from = move.from,
                                                    to = u,
                                                    data = this,
                                                    aoe = true,
                                                    code = function(data)
                                                        SlowUnit{
                                                            from = data.from,
                                                            to = data.to,
                                                            time = dur,
                                                            aoe = true,
                                                            move = 100
                                                        }
                                                    end
                                                }
                                            end
                                        end
                                    end
                                )
                            end
                        )
                    end
                )
            end
        end,
    }
    
    --唯闪
    InitSkill{
        name = "唯闪",
        type = {"主动"},
        ani = "stand",
        art = {"BTNWhirlwind.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = 75,
        cool = {18, 17, 16, 15},
        area = {600, 700, 800, 900},
        cast = 0.1,
        tip = "\
快速从刀鞘中拔刀并进行一次以圣人力量发动的拔刀斩,瞬间对附近所有单位都进行一次斩击.\n\
|cffffcc00圣能0|r: 产生1点圣能\
|cffffcc00圣能1|r: 产生1点圣能.可以重复斩击同一单位2次,第二次斩击伤害减半\
|cffffcc00圣能2|r: 消耗2点圣能.将斩击的目标|cffffcc00击晕|r\n\
|cff00ffcc技能|r: 无目标\n\
|cffffcc00晕眩时间|r: %s\n\
|cff888888对每个单位进行一次普通攻击,间隔%s秒\n缴械状态也可以正常发动\n斩击非英雄单位不触发武器效果或攻击效果\n获得整个范围的空中视野\n被斩击之前逃离区域可以逃脱斩击",
        researchtip = "斩击非英雄单位也会触发武器效果与攻击效果",
        data = {
            {1.00, 1.25, 1.50, 1.75}, --晕眩时间1
            0.2, --间隔时间2
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                local point = Point(this.unit)
                EnableAttack(this.unit, false)
                --EnableGod(this.unit)
                local e1 = AddSpecialEffectTarget("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", this.unit, "hand left")
                local e2 = AddSpecialEffectTarget("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", this.unit, "hand right")
                local g1 = table.new(0) --记录已经斩击过的单位,斩击次数
                local loc = GetUnitLoc(this.unit)
                local area = this:get("area")
                local p = GetOwningPlayer(this.unit)
                local max = 1
                if point > 0 then
                    max = 2
                end
                
                local dur = this:get(1)
                local fm = CreateFogModifierRadius(p, FOG_OF_WAR_VISIBLE, loc[1], loc[2], area, true, false)
                FogModifierStart(fm)
                SetUnitVertexColor(this.unit, 255, 255, 255, 0)
                
                local endthis = function()
                    EndLoop()
                    SetUnitXY(this.unit, loc)
                    SetUnitVertexColor(this.unit, 255, 255, 255, 255)
                    DestroyEffect(e1)
                    DestroyEffect(e2)
                    EnableAttack(this.unit)
                    --EnableGod(this.unit, false)
                    DestroyFogModifier(fm)
                end--结束技能
                
                local sound
                local si1 = 0
                local si2 = 0
                Loop(this:get(2),   
                    function()
                        if IsUnitDead(this.unit) then
                            endthis()
                            return
                        end
                        local g2 = {} --寻找本次要斩击的目标
                        forRange(loc, area,
                            function(u)
                                if g1[u] < max and EnemyFilter(p, u, {["魔免"] = true}) then
                                    table.insert(g2, u)
                                end
                            end
                        )
                        local n = #g2
                        if n == 0 then
                            endthis()
                            return
                        end
                        local u = g2[GetRandomInt(1, n)] --决定本次要斩击的对象
                        g1[u] = g1[u] + 1
                        SetUnitXY(this.unit, u)
                        local d = GetRandomInt(GetUnitState(this.unit, ConvertUnitState(0x14)), GetUnitState(this.unit, ConvertUnitState(0x15)))
                        local name
                        if g1[u] == 2 then
                            d = d / 2
                            name = "gg_snd_MetalMediumChopFlesh" .. (si1 % 3 + 1)
                            si1 = si1 + 1
                        else
                            name = "gg_snd_MetalHeavyChopFlesh" .. (si2 % 3 + 1)
                            si2 = si2 + 1
                        end
                        sound = _G[name]
                        if this.research or IsHero(u) then
                            Damage(this.unit, u, d , true, false, {attack = true, weapon = true, damageReason = this.name})
                        else
                            Damage(this.unit, u, d , true, false, {damageReason = this.name})
                        end
                        
                        TempEffect(this.unit, "basicstrike.mdx")
                        local x, y = GetXY(u)
                        SetSoundPosition(sound, x, y, 0)
                        StartSound(sound)
                        if point > 1 then
                            SkillEffect{
                                name = this.name,
                                from = this.unit,
                                to = u,
                                data = this,
                                aoe = true,
                                code = function(data)
                                    StunUnit{
                                        from = data.from,
                                        to = data.to,
                                        time = dur
                                    }
                                end
                            }
                        end
                    end
                )
            end
        end,
    }
    
    --影闪
    InitSkill{
        name = "影闪",
        type = {"开关", 2},
        art = {"BTNAnimalWarTraining.blp", "BTNAnimalWarTraining.blp", "BTNAttackGround.blp"},
        cool = {12, 11, 10, 9},
        mana = {80, 70, 60, 50},
        rng = "全地图",
        dur = 3,
        tip = "\
神裂向目标方向冲刺一小段距离,并在冲刺结束后获得100%%的攻击闪躲.\n\
|cffffcc00圣能0|r: 产生1点圣能\
|cffffcc00圣能1|r: 产生1点圣能.冲刺后的3秒内可以回到起始位置\
|cffffcc00圣能2|r: 消耗2点圣能.回到起始位置后重置该技能冷却时间\n\
|cff00ffcc技能|r: 点目标\n\
|cffffcc00冲刺距离|r: %s\
|cffffcc00闪躲时间|r: %s\n\
|cff888888冲刺速度为%s|r",
        researchtip = "冲刺结束后完全免疫所有伤害.取代100%%的攻击闪躲",
        data = {
            {350, 400, 450, 500}, --冲刺距离1
            {0.75, 1, 1.25, 1.5}, --闪躲时间2
            2000, --冲刺速度3
        },
        events = {"发动技能", "关闭技能"},
        code = function(this)
            if this.event == "发动技能" then
                local point = Point(this.unit)
                if point == 0 then
                    this.type[1] = "主动"
                else
                    this.type[1] = "开关"
                    this.point = point
                    this.backloc = GetUnitLoc(this.unit)
                    this.backeffect = AddSpecialEffect("Abilities\\Spells\\Human\\MagicSentry\\MagicSentryCaster.mdl", GetXY(this.backloc))
                end
                local e = AddSpecialEffectTarget("Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl", this.unit, "origin")
                local t = this:get(2)
                Mover({
                        unit = this.unit,
                        speed = this:get(3),
                        angle = GetBetween(this.unit, this.target, true),
                        distance = this:get(1),
                    }, nil, nil,
                    function(move)
                        IssuePointOrder(this.unit, "move", GetXY(this.target))
                        DestroyEffect(e)
                        local func
                        if this.research then
                            func = Event("伤害无效",
                                function(damage)
                                    if damage.to == this.unit then
                                        damage.dodgReason = this.name
                                        return true
                                    end
                                end
                            )
                        else
                            func = Event("伤害无效",
                                function(damage)
                                    if damage.weapon and damage.to == this.unit then
                                        damage.dodgReason = "闪躲"
                                        return true
                                    end
                                end
                            )
                        end
                        Wait(t,
                            function()
                                Event("-伤害无效", func)
                            end
                        )
                    end
                )
            elseif this.event == "关闭技能" then
                DestroyEffect(this.backeffect)
                if this.closereason == "手动关闭" then
                    SetUnitXY(this.unit, this.backloc)
                    TempEffect(this.backloc, "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl")
                    if this.point > 1 then
                        this.freshcool = 0
                    end
                end
            end
        end,
    }
    
    --圣痕
    InitSkill{
        name = "圣痕",
        type = {"开关"},
        art = {"BTNPriestMaster.blp", "BTNPriestMaster.blp", "BTNPriestAdept.blp"}, --第三个参数为关闭
        mana = {125, 175, 225},
        cool = {45.0, 37.5, 30.0},
        dur = 30,
        tip = "\
神裂拥有着远超人类所能掌控的\"天使\"之力,能够短时间的开启圣痕获得天使级别的战斗力并扭转战局.\
圣痕状态的神裂使用技能将至少保留一点圣能,并大幅提升攻击速度与法力恢复速度,但是每次使用技能都会按当前比例损耗自身的生命值.\n\
|cff00ffcc技能|r: 开关\n\
|cffffcc00攻击速度|r: %s\
|cffffcc00法力恢复|r: %s\
|cffffcc00生命损耗|r: %s%%\n\
|cff888888可以通过再次使用此技能提前关闭(无消耗)\n技能关闭后开始计算冷却时间|r",
        researchtip = {
            "圣痕状态下还会增加75点移动速度",
            "圣痕状态下每点溢出的攻击速度会增加你1点的攻击力",
            "圣痕状态下使用英雄技能不再消耗生命值",
        },
        data = {
            {100, 150, 200}, --攻击速度1
            {20, 25, 30}, --法力恢复2
            {20, 18, 16}, --生命损耗3
        },
        events = {"发动技能", "关闭技能"},
        code = function(this)
            if this.event == "发动技能" then
                this.e1 = AddSpecialEffectTarget("Abilities\\Spells\\Orc\\TrollBerserk\\HeadhunterWEAPONSRight.mdl", this.unit, "hand left")
                this.e2 = AddSpecialEffectTarget("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile.mdl", this.unit, "weapon")
                this.lastAttackspeed = this:get(1)
                AttackSpeed(this.unit, this.lastAttackspeed)
                Mark(this.unit, this.name, true)
                this.lastRecover = this:get(2)
                Recover(this.unit, 0, this.lastRecover)
                local s = 1 - this:get(3) / 100
                this.skillFunc = Event("发动英雄技能",
                    function(data)
                        if data.unit == this.unit and not (this.research and this.research[3]) then
                            SetUnitState(this.unit, UNIT_STATE_LIFE, s * GetUnitState(this.unit, UNIT_STATE_LIFE))
                        end
                    end
                )
                this.lastMovespeed = 0
                if this.research and this.research[1] then
                    this.lastMovespeed = 75
                    MoveSpeed(this.unit, this.lastMovespeed)
                end
                this.lastAttack = 0
                if this.research and this.research[2] then
                    this.attimer = LoopRun(1,
                        function()
                            local as = Mark(this.unit, "额外攻击速度") * 100
                            if as > 400 then
                                as = as - 400
                                if as ~= this.lastAttack then
                                    Attack(this.unit, as - this.lastAttack)
                                    this.lastAttack = as
                                end
                            end
                        end
                    )
                end
            elseif this.event == "关闭技能" then
                AttackSpeed(this.unit, - this.lastAttackspeed)
                MoveSpeed(this.unit, - this.lastMovespeed)
                Mark(this.unit, this.name, false)
                Recover(this.unit, 0, - this.lastRecover)
                Event("-发动英雄技能", this.skillFunc)
                if this.attimer then
                    DestroyTimer(this.attimer)
                    this.attimer = nil
                    Attack(this.unit, - this.lastAttack)
                end
                DestroyEffect(this.e1)
                DestroyEffect(this.e2)
                this.freshcool = this:get("cool")
            end
        end,
    }
                        
