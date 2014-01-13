    
    HeroName[12] = "艾扎力"
    HeroMain[12] = "智力"
    HeroType[12] = |Hmkg|
    RDHeroType[12] = |h017|
    HeroTypePic[12] = "ReplaceableTextures\\CommandButtons\\BTNAiZaLi.blp"
    HeroSize[12] = 1.1
    LearnSkillId = {|A19S|, |A19T|, |A19U|, |A19V|}
    
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
        area = {250, 300, 350, 400},
        tip = "\
使用原典的力量让一个区域内的敌人被迫放弃武装,使他们|cffffcc00缴械|r并|cffffcc00减速|r.\n\
|cff00ffcc技能|r: 点目标\n\
|cffffcc00降低移速|r: %s%%\n\
|cff888888缴械与减速效果可以驱散",
        researchtip = "受影响的英雄/非英雄提供给你25%的攻击力与10%/5%的移动速度",
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
                                            ms = ms * 0.1
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
        cool = 20,
        area = 400,
        tip = "\
将原典抄写在地面上,利用原典的特质来保护自己,为艾扎力吸收伤害并反击伤害来源.当原典吸收到一定的伤害后会自行崩溃.\n\
|cff00ffcc技能|r: 点目标\
|cff00ffcc伤害|r: 法术\n\
|cffffcc00吸收比例|r: %s%%\
|cffffcc00吸收上限|r: %s(|cff0000ff+%d|r)\
|cffffcc00反击伤害|r: %s(|cff0000ff+%d|r)\
|cffffcc00对同一单位的反击间隔|r: %s\n\
|cff888888艾扎力必须处于原典保护范围内才会生效\n弹道速率为%d",
        researchtip = "不再能吸收伤害,但是反击间隔减少1秒",
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
            {2, 1.75, 1.5, 1.25}, --反击间隔6
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
                    cd = cd - 1
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
        type = {"主动", 1},
        ani = "spell 1",
        art = {"BTNJXR Ico.blp"},
        cast = 0.1,
        mana = {150, 200, 250},
        time = 0.75,
        cool = {30, 20, 10},
        area = 100,
        tip = "\
用黑曜石匕首反射金星的光芒,分解被照射到的单位或建筑,造成大量伤害,此外还会根据对方最大生命值造成额外伤害.\n\
|cff00ffcc技能|r: 点目标\
|cff00ffcc伤害|r: 混合\n\
|cffffcc00伤害(最大生命值)|r: %s%%\
|cffffcc00伤害(固定部分)|r: %s(|cff0000ff+%d|r)\n\
|cff888888轨迹线仅友方可见\n施法延迟0.75秒\n伤害在4秒内分5段造成",
        researchtip = {
            "",
            "",
            "",
        },
        data = {
            {30, 40, 50}, --最大生命值部分1
            {200, 400, 600}, --固定伤害部分2
            function(ap) --伤害加成3
                return ap * 2
            end
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                
            end
        end
    }
    
    --伪装
    InitSkill{
        name = "伪装",
        type = {"主动"},
        ani = "stand",
        art = {"BTNInvisibility.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {50},
        cool = 0,
        cast = 3,
        tip = "\
经过3秒的伪装,艾扎力变化为 |cffffcc00%s|r 的外观并拥有技能 |cffffcc00%s|r.\
如果你全程在敌方的视野外完成伪装,敌方将视你为友方单位,同时你的位置不会显示在敌方的小地图上.\
如果你在伪装状态下对敌方单位造成伤害或使用英雄技能,则会被敌方识破.\n\
|cff888888对野怪造成伤害不会暴露\n使用 |cffffcc00%s|r 不会暴露\n在敌方视野外造成伤害不会暴露\n在敌方视野外使用英雄技能不会暴露\
        ",
        data = {
            "未知单位类型",
            "未知技能"
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
            end
        end
    }
        
