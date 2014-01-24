    
    HeroName[12] = "艾扎力"
    HeroMain[12] = "智力"
    HeroType[12] = |Hmkg|
    RDHeroType[12] = |h017|
    HeroTypePic[12] = "ReplaceableTextures\\CommandButtons\\BTNAiZaLi.blp"
    HeroSize[12] = 1.1
    LearnSkillId = {|A19S|, |A19T|, |A19U|, |A19V|}
    
    local skilltable = {}
    
    --剥离
    InitSkill{
        name = "剥离",
        type = {"主动", 1},
        ani = "spell 1",
        art = {"BTNTransmute.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {50, 75, 100, 125},
        cool = 5,
        rng = {450, 500, 550, 600},
        icon = 3,
        cast = 0.3,
        time = 6,
        dur = 6,
        targs = GetTargs("地面,空中,敌人,有机生物"),
        tip = "\
艾扎力使用阿兹特克魔法持续剥离一个单位,对其造成持续伤害并恢复自己的生命值.此过程中若目标死亡,你获得一次性的伪装技能.\n\
|cffffcc00需要持续施法\n\
|cff00ffcc技能|r: 单位目标\
|cff00ffcc伤害|r: 法术\n\
|cffffcc00每秒伤害|r: %s(|cff0000ff+%d|r)\
|cffffcc00恢复比例|r: %s%%\n\
|cff888888每0.5秒吸取一次生命\n当距离超过施法距离的1.5倍后技能被打断\n伪装不使用的话可以一直保存,使用后消失\n伪装状态下使用此技能无法获得新的伪装",
        researchtip = "伪装状态下也可以获得新的伪装",
        data = {
            {20, 30, 40, 50}, --每秒伤害1   
            function(ap) --伤害加成2
                return ap * 0.25
            end,
            100, --恢复比例
        },
        events = {"获得技能", "发动技能", "停止施放"},
        code = function(this)
            if this.event == "发动技能" then
                local u1 = this.unit
                local u2 = this.target
                local l = AddLightningEx("DRAL", true, 0, 0, 0, 0, 0, 0)
                local e1 = AddSpecialEffectTarget("Abilities\\Spells\\Other\\Drain\\DrainCaster.mdl", u1, "overhead")
                local e2 = AddSpecialEffectTarget("Abilities\\Spells\\Other\\Drain\\DrainTarget.mdl", u2, "overhead")
                local d = this:get(1) + this:get(2)
                d = d * 0.5
                local s = this:get(3) / 100
                local ml = 1.5 * this:get("rng")
                local count = 0
                local t = LoopRun(0.05,
                    function()
                        if GetBetween(u1, u2) > ml or IsUnitDead(u2) then
                            IssueImmediateOrder(u1, "stop")
                            if IsUnitDead(u2) then
                                local name = GetUnitName(u2)
                                local skill = skilltable[name]
                                if skill then
                                    RemoveSkill(this.unit, "伪装")
                                    AddSkill(this.unit, "伪装", {data = {name, skill, skill}, unittype = GetUnitTypeId(u2)})
                                end
                            end
                            return
                        end
                        local x1, y1, z1 = GetUnitX(u1), GetUnitY(u1), GetUnitZ(u1) + 125
                        local x2, y2, z2 = GetUnitX(u2), GetUnitY(u2), GetUnitZ(u2) + 125
                        MoveLightningEx(l, true, x1, y1, z1, x2, y2, z2)
                        count = count + 1
                        if count % 10 == 0 then
                            SkillEffect{
                                name = this.name,
                                from = u1,
                                to = u2,
                                data = this,
                                dot = true,
                                code = function(data)
                                    local damage = Damage(data.from, data.to, d, false, true, {dot = true, damageReason = this.name})
                                    local dd = damage.damage
                                    if dd > 0 then
                                        Heal(data.from, data.from, dd * s, {healReason = this.name})
                                    end
                                end
                            }
                        end
                    end
                )
                this.flush = function()
                    DestroyLightning(l)
                    DestroyEffect(e1)
                    DestroyEffect(e2)
                    DestroyTimer(t)
                end
            elseif this.event == "停止施放" then
                if this.spellflag then --表示已经发动了技能
                    this.flush() 
                end
            elseif this.event == "获得技能" then
                AddSkill(this.unit, "伪装", {type = {"被动"}})
            end
        end
    }
    
    --原典-操纵武器
    InitSkill{
        name = "原典-操纵武器",
        type = {"主动", 2, 3},
        ani = "spell 1",
        art = {"BTNManaBurn.blp"},
        cast = 0.3,
        mana = {120, 130, 140, 150},
        dur = {2, 2.5, 3, 3.5},
        cool = 15,
        rng = 400,
        area = {250, 300, 350, 400},
        tip = "\
使用原典的力量让一个区域内的敌人被迫放弃武装,使他们|cffffcc00缴械|r并|cffffcc00减速|r.\n\
|cff00ffcc技能|r: 点目标\n\
|cffffcc00降低移速|r: %s%%\n\
|cff888888缴械与减速效果可以驱散",
        researchtip = "受影响的英雄/非英雄提供给你25%的攻击力与25%/5%的移动速度",
        data = {
            {25, 30, 35, 40} --降低移速1
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                local move = this:get(1)
                local time = this:get("dur")
                TempEffect(this.target, "Abilities\\Spells\\Other\\Silence\\SilenceAreaBirth.mdl")
                forRange(this.target, this:get("area"),
                    function(u)
                        if EnemyFilter(this.player, u) then
                            SkillEffect{
                                from = this.unit,
                                to = u,
                                name = this.name,
                                data = this,
                                aoe = true,
                                code = function(data)
                                    if this.research then
                                        local attack = (GetUnitState(data.to, ConvertUnitState(0x14)) + GetUnitState(data.to, ConvertUnitState(0x15))) / 2
                                        local ms = GetUnitMoveSpeed(data.to)
                                        if IsHero(data.to) then
                                            attack = attack * 0.25
                                            ms = ms * 0.25
                                        else
                                            attack = attack * 0.25
                                            ms = ms * 0.05
                                        end
                                        
                                        Attack(data.from, attack)
                                        MoveSpeed(data.from, ms)
                                        Wait(time,
                                            function()
                                                Attack(data.from, - attack)
                                                MoveSpeed(data.from, -ms)
                                            end
                                        )
                                    end
                                    SlowUnit{
                                        from = data.from,
                                        to = data.to,
                                        time = time,
                                        aoe = true,
                                        move = move,
                                    }
                                    DisarmUnit{
                                        from = data.from,
                                        to = data.to,
                                        aoe = true,
                                        time = time
                                    }
                                end
                            }
                        end
                    end
                )
            end
        end
    }
    
    --原典-无远弗届
    InitSkill{
        name = "原典-无远弗届",
        type = {"主动", 2, 3},
        ani = "spell 1",
        art = {"BTNManual3.blp"},
        cast = 0.3,
        mana = 125,
        dur = 10,
        cool = 30,
        area = 400,
        rung = 400,
        tip = "\
将原典抄写在地面上,利用原典的特质来保护自己,为艾扎力吸收伤害并反击伤害来源.当原典吸收到一定的伤害后会自行崩溃.\n\
|cff00ffcc技能|r: 点目标\
|cff00ffcc伤害|r: 法术\n\
|cffffcc00吸收比例|r: %s%%\
|cffffcc00吸收上限|r: %s(|cff0000ff+%d|r)\
|cffffcc00反击伤害|r: %s(|cff0000ff+%d|r)\
|cffffcc00对同一单位的反击间隔|r: %s\n\
|cff888888艾扎力必须处于原典保护范围内才会生效\n弹道速率为%d",
        researchtip = "不再能吸收伤害,但是反击间隔减少3秒",
        data = {
            {50, 60, 70, 80}, --吸收比例1
            {150, 275, 400, 525}, --吸收上限2
            function(ap) --吸收上限加成3
                return ap * 1.25
            end,
            {100, 150, 200, 250}, --反击伤害4
            function(ap) --反击伤害加成5
                return ap * 0.75
            end,
            {6, 5.5, 5, 4.5}, --反击间隔6
            750, --弹道速率7
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                local time = this:get("dur")
                local target = this.target
                local flag = false
                local effect
                local dis = this:get("area")
                local mod = CreateModle("Doodads\\BlackCitadel\\Props\\RuneArt\\RuneArt2.mdl", target, {size = 5, time = time, remove = true})
                LoopRun(0.1,
                    function()
                        if GetBetween(this.unit, target) < dis then
                            if not flag then
                                flag = true
                                effect = AddSpecialEffectTarget("Abilities\\Spells\\Other\\Drain\\ManaDrainTarget.mdl", this.unit, "origin")
                            end
                        end
                    end
                )
                local s = this:get(1)
                local hp = this:get(2) + this:get(3)
                local dam = this:get(4) + this:get(5)
                local cd = this:get(6)
                if this.research then
                    cd = cd - 3
                end
                local speed = this:get(7)
                local lasttime = table.new(0)
                local func = Event("伤害减免",
                    function(damage)
                        if damage.to == this.unit and flag then
                            if not this.research then
                                local d = damage.odamage * s / 100
                                d = math.min(d, damage.damage, hp)
                                damage.damage = damage.damage - d
                                hp = hp - d
                                if hp <= 0 then
                                    KillUnit(mod)
                                end
                            end
                            local time = GetTime()
                            if damage.from and EnemyFilter(this.player, damage.from) and time - lasttime[damage.from] > cd then
                                lasttime[damage.from] = time
                                MoverEx(
                                    {
                                        source = MovePoint(target, {GetRandomInt(0, dis), GetRandomInt(1, 360)}),
                                        from = this.unit,
                                        modle = "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilMissile.mdl",
                                        speed = speed,
                                        target = damage.from,
                                        z = 100,
                                        tz = 100,
                                    },
                                    nil,
                                    function(move)
                                        Damage(move.from, move.target, dam, false, true, {damageReason = this.name})
                                    end
                                )
                            end
                        end
                    end
                )
                local func2
                func2 = Event("死亡",
                    function(data)
                        if data.unit == mod then
                            Event("-伤害减免", func)
                            Event("-死亡", func2)
                            DestroyEffect(effect)
                        end
                    end
                )
            end
        end
    }
    
    --金星之枪
    InitSkill{
        name = "金星之枪",
        type = {"主动", 2},
        ani = "spell 1",
        art = {"BTNJXR Ico.blp"},
        cast = 0.1,
        mana = {150, 200, 250},
        time = 0.75,
        cool = {30, 20, 10},
        area = 50,
        rng = 2000,
        tip = "\
用黑曜石匕首反射金星的光芒,分解被照射到的单位或建筑,造成大量伤害,此外还会根据对方最大生命值造成额外伤害.\n\
|cff00ffcc技能|r: 点目标\
|cff00ffcc伤害|r: 混合\n\
|cffffcc00伤害(最大生命值)|r: %s%%\
|cffffcc00伤害(固定部分)|r: %s(|cff0000ff+%d|r)\n\
|cff888888轨迹线仅友方可见\n施法延迟0.75秒\n伤害在4秒内分5段造成",
        researchtip = {
            "伤害持续期间目标单位无法恢复生命值",
            "每段伤害会溅射给附近的敌方单位,溅射范围由100逐渐扩大至200",
            "金星之枪可以穿透第一个单位,对第二个单位也照成同样的效果",
        },
        data = {
            {30, 40, 50}, --最大生命值部分1
            {200, 400, 600}, --固定伤害部分2
            function(ap) --伤害加成3
                return ap * 2
            end
        },
        events = {"发动技能", "停止施放", "施放结束"},
        code = function(this)
            if this.event == "发动技能" then
                local a = GetBetween(this.unit, this.target, true)
                local x1, y1 = GetXY(this.unit)
                local p2 = MovePoint(this.unit, {this:get("rng"), a})
                local x2, y2 = GetXY(p2)
                local dam = this:get(2) + this:get(3)
                local s = this:get(1)
                local l = AddLightningEx("LN01", false, x1, y1, 100, x2, y2, 100)
                if IsPlayerAlly(this.player, SELFP) then
                    SetLightningColor(l, 1, 0, 0, 0.5)
                else
                    SetLightningColor(l, 1, 0, 0, 0)
                end
                this.stopfunc = function()
                    DestroyLightning(l)
                end
                this.spellfunc = function()
                    local l = Lightning{
                        from = this.unit,
                        name = 'AFOD',
                        check = false,
                        x1 = x1,
                        y1 = y1,
                        z1 = 100,
                        x2 = x2,
                        y2 = y2,
                        z2 = 100,
                        cut = true,
                        time = 0.25
                    }
                    local g = {}
                    local p1 = {l.x1, l.y1}
                    forSeg(p1, p2, this:get("area") * 2,
                        function(u)
                            if EnemyFilter(this.player, u, {["建筑"] = true}) then
                                table.insert(g, u)
                            end
                        end
                    )
                    local round = 1
                    if this.research[3] then
                        round = 2
                    end
                    for i = 1, round do
                        local u = table.getone(g,
                            function(u1, u2)
                                return GetBetween(p1, u1) < GetBetween(p1, u2)
                            end
                        )
                        if u then
                            SkillEffect{
                                name = this.name,
                                from = this.unit,
                                to = u,
                                data = this,
                                code = function(data)
                                    local dam = dam + s * GetUnitState(data.to, UNIT_STATE_MAX_LIFE) / 100
                                    dam = dam / 5
                                    local count = 0
                                    local mhp = GetRecover(data.to)
                                    local fakeend
                                    if this.research[1] then
                                        Recover(data.to, -mhp)
                                        local func = Event("治疗减免",
                                            function(heal)
                                                if heal.to == data.to then
                                                    heal.heal = 0
                                                end
                                            end
                                        )
                                        local oldRecover = Recover
                                        Recover = function(u, hp, mp)
                                            if u == data.to then
                                                mhp = mhp + hp
                                                hp = 0
                                            end
                                            oldRecover(u, hp, mp)
                                        end
                                        fakeend = function()
                                            Event("-治疗减免", func)
                                            Recover = oldRecover
                                        end
                                    end
                                    local aoearea = 100
                                    local p = GetOwningPlayer(data.from)
                                    LoopRun(1,
                                        function()
                                            if IsUnitAlive(data.to) then
                                                DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Demon\\DemonBoltImpact\\DemonBoltImpact.mdl", data.to, "origin"))
                                                Damage(data.from, data.to, dam, true, true, {damageReason = this.name})
                                                if this.research[2] then
                                                    forRange(data.to, aoearea,
                                                        function(u)
                                                            if u ~= data.to and EnemyFilter(p, u, {["建筑"] = true}) then
                                                                DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Demon\\DemonBoltImpact\\DemonBoltImpact.mdl", u, "origin"))
                                                                Damage(data.from, u, dam, true, true, {damageReason = this.name, aoe = true})
                                                            end
                                                        end
                                                    )
                                                    aoearea = aoearea + 25
                                                end
                                            end
                                            count = count + 1
                                            if count == 5 then
                                                EndLoop()
                                                if fakeend then
                                                    fakeend()
                                                end
                                            end
                                        end
                                    )
                                end
                            }
                            local x2, y2 = GetXY(u)
                            MoveLightningEx(l.l, false, l.x1, l.y1, 100, x2, y2, 100)
                            table.remove2(g, u)
                        end
                    end
                end
            elseif this.event == "施放结束" then
                this.spellfunc()
            elseif this.event == "停止施放" then
                if this.spellflag then
                    this.stopfunc()
                end
            end
        end
    }
    
    --伪装
    InitSkill{
        name = "伪装",
        type = {"开关"},
        ani = "stand",
        art = {"BTNInvisibility.blp", "BTNInvisibility.blp", "BTNWispSplode.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {50},
        cool = 0,
        cast = 3,
        tip = "\
经过3秒的伪装,艾扎力变化为 |cffffcc00%s|r 的外观并拥有技能 |cffffcc00%s|r.\
如果你全程在敌方的视野外完成伪装,敌方将视你为友方单位,同时你的位置不会显示在敌方的小地图上.\
如果你在伪装状态下对敌方单位造成伤害或使用英雄技能,则会被敌方识破.\n\
|cff888888对野怪造成伤害不会暴露\n使用 |cffffcc00%s|r |cff888888不会暴露\n在敌方视野外造成伤害不会暴露\n在敌方视野外使用英雄技能不会暴露",
        data = {
            "未知单位类型",
            "未知技能",
            "未知技能"
        },
        events = {"发动技能", "获得技能", "失去技能", "关闭技能"},
        code = function(this)
            if this.event == "发动技能" then
                RemoveSkill(this.unit, "伪装技能")
                AddSkill(this.unit, this:get(2))
            elseif this.event == "获得技能" then
                if this.unittype then
                    local name = this:get(2)
                    local sid = SkillTable[name]
                    local skill =  SkillTable[sid]
                    AddSkill(this.unit, "伪装技能", {tip = skill.tip, data = skill.data})
                end
            elseif this.event == "失去技能" then
                RemoveSkill(this.unit, "伪装技能")
                RemoveSkill(this.unit, this:get(2))
            elseif this.event == "关闭技能" then
                RemoveSkill(this.unit, "伪装技能")
                RemoveSkill(this.unit, this:get(2))
            end
        end
    }
    
    --特殊技能
    InitSkill{
        name = "伪装技能",
        type = {"被动"},
        art = {"BTNInvisibility.blp"},
        tip = "\
在这里显示伪装后的技能说明",
        data = {},
        events = {},
        code = function(this)
        end
    }
    
    --伪装的技能
    skilltable["宗教狂热者"] = "狂热"
    
    InitSkill{
        name = "狂热",
        type = {"被动"},
        art = {"BTNUnholyFrenzy.blp"},
        tip = "\
|cffff00cc武器效果:|r提升自己 |cffffcc00%d|r 点攻击速度,最多提升 |cffffcc00%d|r 点,持续 |cffffcc00%d|r 秒.",
        data = {
            15,
            150,
            5
        },
        events = {"获得技能", "失去技能"},
        code = function(this)
            if this.event == "获得技能" then
                local as = this:get(1)
                local maxas = this:get(2)
                local time = this:get(3)
                this.as = 0
                this.func = Event("伤害效果",
                    function(damage)
                        if damage.from == this.unit and damage.weapon then
                            if this.as < maxas then
                                this.as = this.as + as
                                AttackSpeed(this.unit, as)
                                if not this.effect then
                                    this.effect = AddSpecialEffectTarget("Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl", this.unit, "weapon")
                                end
                            end
                            if not this.timer then
                                this.timer = CreateTimer()
                            end
                            TimerStart(this.timer, time, false, this.flush)
                        end
                    end
                )
                this.flush = function()
                    if this.as > 0 then
                        DestroyEffect(this.effect)
                        DestroyTimer(this.timer)
                        this.effect = nil
                        this.timer = nil
                        AttackSpeed(this.unit, - this.as)
                        this.as = 0
                    end
                end
            elseif this.event == "失去技能" then
                this.flush()
            end
        end
    }