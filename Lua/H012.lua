    
    HeroName[12] = "艾扎力"
    HeroMain[12] = "智力"
    HeroType[12] = |Hmkg|
    RDHeroType[12] = |h017|
    HeroTypePic[12] = "ReplaceableTextures\\CommandButtons\\BTNAiZaLi.blp"
    HeroSize[12] = 1.2
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
                        if GetBetween(u1, u2) > ml or IsUnitDead(u2) then
                            IssueImmediateOrder(u1, "stop")
                            if IsUnitDead(u2) then
                                local that = findSkillData(this.unit, "伪装")
                                if that.openflag then
                                    if this.research then
                                        local name = GetUnitName(u2)
                                        local skill = skilltable[name]
                                        if skill then
                                            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIem\\AIemTarget.mdl", this.unit, "origin"))
                                            that.newdata = {
                                                lv = this.lv,
                                                art = {"BTNInvisibility.blp", getObj(slk.unit, GetUnitTypeId(u2), "Art", "\\BTNInvisibility.blp"):match("([^\\]+.blp)"), "BTNWispSplode.blp"},
                                                data = {name, skill, skill},
                                                unittype = GetUnitTypeId(u2)
                                            }
                                        end
                                    end
                                    return
                                end --如果已经处于伪装状态,则不再获得新的伪装效果
                                local name = GetUnitName(u2)
                                local skill = skilltable[name]
                                if skill then
                                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIem\\AIemTarget.mdl", this.unit, "origin"))
                                    if this.icon > 1 then
                                        RemoveSkill(this.unit, "伪装")
                                        AddSkill(this.unit, "伪装", {
                                            lv = this.lv,
                                            art = {"BTNInvisibility.blp", getObj(slk.unit, GetUnitTypeId(u2), "Art", "\\BTNInvisibility.blp"):match("([^\\]+.blp)"), "BTNWispSplode.blp"},
                                            data = {name, skill, skill},
                                            unittype = GetUnitTypeId(u2)
                                        })
                                    end
                                end
                            end
                            return
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
                if this.icon > 1 then
                    AddSkill(this.unit, "伪装", {type = {"被动"}})
                end
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
                local timer = LoopRun(0.1,
                    function()
                        if GetBetween(this.unit, target) < dis then
                            if not flag then
                                flag = true
                                effect = AddSpecialEffectTarget("Abilities\\Spells\\Other\\Drain\\ManaDrainTarget.mdl", this.unit, "origin")
                            end
                        else
                            if flag then
                                flag = false
                                DestroyEffect(effect)
                                effect = nil
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
                            if effect then
                                DestroyEffect(effect)
                            end
                            DestroyTimer(timer)
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
用黑曜石匕首反射金星的光芒,分解被照射到的的一个单位或建筑,造成大量伤害,此外还会根据对方最大生命值造成额外伤害.\n\
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
                                        local func2 = Reload("Recover",
                                            function(u, hp, mp)
                                                if u == data.to then
                                                    mhp = mhp + hp
                                                    hp = 0
                                                end
                                                Recover(u, hp, mp)
                                            end
                                        )
                                        fakeend = function()
                                            Event("-治疗减免", func)
                                            Reload("-Recover", func2)
                                            Recover(data.to, mhp)
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
        mana = 50,
        cool = 0,
        cast = 3,
        tip = "\
经过3秒的伪装,艾扎力变化为 |cffffcc00%s|r 的外观并拥有技能 |cffffcc00%s|r.\
如果你全程在敌方的视野外完成伪装,敌方将视你为友方单位,同时你的位置不会显示在敌方的小地图上.\
如果你在伪装状态下对敌方单位造成伤害,使用英雄技能或暴露在真视范围内,则会被敌方识破.\n\
|cff888888伪装后攻击范围将对应变化\n对野怪造成伤害不会暴露\n使用 |cffffcc00%s|r |cff888888不会暴露\n在敌方视野外造成伤害不会暴露\n在敌方视野外使用英雄技能不会暴露\n处于真视范围内但是不在敌方视野内不会暴露",
        data = {
            "未知单位类型",
            "未知技能",
            "未知技能"
        },
        events = {"发动技能", "获得技能", "失去技能", "关闭技能"},
        code = function(this)
            if this.event == "发动技能" then
                if this.icon > 1 then
                    RemoveSkill(this.unit, "伪装技能")
                    AddSkill(this.unit, this:get(2), {lv = this.lv})
                end
                local r1 = GetUnitState(this.unit, UNIT_STATE_ATTACK_RANGE)
                local r2 = tonumber(getObj(slk.unit, this.unittype, "rangeN1", r1))
                local r = r2 - r1
                SetUnitState(this.unit, UNIT_STATE_ATTACK_RANGE, r2)
                --判定是否全程处于视野外
                local flag = GetPlayerTeam(this.player) == GetPlayerTeam(SELFP)
                local stime, ustime = Mark(this.unit, "变为可见的时间"), Mark(this.unit, "变为不可见的时间")
                this.flush = nil
                if ustime > stime and GetTime() - ustime > this:get("cast") then
                    local name = "Units\\NightElf\\Owl\\Owl.mdl"
                    if not flag then
                        MinimapIcon(this.unit, false)
                        name = ""
                    end
                    
                    for i = 0, 5 do
                        SetPlayerAlliance(PA[i], this.player, ALLIANCE_PASSIVE, true)
                        SetPlayerAlliance(PB[i], this.player, ALLIANCE_PASSIVE, true)
                    end
                    
                    this.effect = AddSpecialEffectTarget(name, this.unit, "overhead")
                    
                    local func1 = Event("伤害前",
                        function(damage)
                            if damage.from == this.unit then
                                --如果是野怪则跳过
                                if GetOwningPlayer(this.to) == Player(12) then return end
                                --如果是敌方单位
                                if IsUnitEnemy(damage.to, this.player) then
                                    --如果在敌方视野内
                                    if Mark(this.unit, "变为可见的时间") > Mark(this.unit, "变为不可见的时间") then
                                        this.flush()
                                    end
                                end
                            end
                        end
                    )
                    
                    local func2 = Event("发动英雄技能",
                        function(that)
                            if that.unit == this.unit and that.name ~= this:get(2) then
                                --如果在敌方视野内
                                if Mark(this.unit, "变为可见的时间") > Mark(this.unit, "变为不可见的时间") then
                                    this.flush()
                                end
                            end
                        end
                    )
                    
                    local p
                    if GetPlayerTeam(this.player) == 0 then
                        p = PB[1]
                    else
                        p = PA[1]
                    end
                    
                    local timer = Loop(0.1,
                        function()
                            if IsUnitDetected(this.unit, p) and IsUnitVisible(this.unit, p) then
                                this.flush()
                            end
                        end
                    )
                    
                    this.flush = function()
                        Event("-伤害前", func1)
                        Event("-发动英雄技能", func2)
                        if not flag then
                            MinimapIcon(this.unit, true)
                        end
                        local tid = GetPlayerTeam(this.player)
                        local ps
                        if tid == 0 then
                            ps = PB
                        else
                            ps = PA
                        end
                        for i = 0, 5 do
                            SetPlayerAlliance(ps[i], this.player, ALLIANCE_PASSIVE, false)
                        end
                        DestroyEffect(this.effect)
                        DestroyTimer(timer)
                    end
                end
                
                --画面特效
                local dummy = CreateUnitAtLoc(this.player, this.unittype, GetUnitLoc(this.unit), GetUnitFacing(this.unit))
                UnitAddAbility(dummy, |Aloc|)
                UnitAddAbility(dummy, |Abun|)
                RemoveGuardPosition(dummy)
                FlyEnable(dummy)
                local al = 255
                local alf1 = function()
                    al = al - 5
                    return al
                end
                local alf2 = function()
                    al = al + 5
                    return al
                end
                local alf = alf1
                local x, y = GetXY(this.unit)
                local walkflag = false
                local ordertarget
                if flag then
                    SetUnitVertexColor(dummy, 255, 255, 255, 0)
                else
                    SetUnitVertexColor(this.unit, 255, 255, 255, 0)
                end
                local count = 0
                local timer = Loop(0.02,
                    function()
                        count = count + 1
                        if flag then
                            local al2 = math.min(255, alf())
                            
                            SetUnitVertexColor(this.unit, 255, 255, 255, al2)
                            SetUnitVertexColor(dummy, 255, 255, 255, 255 - al2)
                            if al == 0 then
                                alf = alf2
                            elseif al == 255 * 2 then
                                alf = alf1
                            end
                        end
                        local x2, y2 = GetXY(this.unit)
                        SetUnitX(dummy, x2)
                        SetUnitY(dummy, y2)
                        SetUnitFacing(dummy, GetUnitFacing(this.unit))
                        if x == x2 and y == y2 then
                            if GetUnitCurrentOrder(dummy) ~= 0 then
                                IssueImmediateOrder(dummy, "stop")
                                walkflag = false
                            end
                        else
                            if GetUnitCurrentOrder(dummy) == 0 or (walkflag and count % 5 == 0 and math.A2A(GetUnitFacing(this.unit), GetUnitFacing(dummy)) > 15) then
                                if type(ordertarget) == "table" then
                                    IssuePointOrderLoc(dummy, "move", ordertarget)
                                else
                                    IssueTargetOrder(dummy, "move", ordertarget)
                                end
                                walkflag = true
                            end
                        end
                        x, y = x2, y2
                    end
                )
                
                local func1 = Event("无目标指令",
                    function(data)
                        if data.unit == this.unit then
                            IssueImmediateOrder(dummy, "stop")
                            SetUnitAnimation(dummy, "stand")
                            walkflag = false
                        end
                    end
                )
                
                local func2 = Event("攻击",
                    function(data)
                        if data.from == this.unit then
                            local s = (Mark(this.unit, "额外攻击速度") or 0) + 1
                            SetUnitTimeScale(dummy, s)
                            IssueImmediateOrder(dummy, "stop")
                            SetUnitAnimation(dummy, "attack")
                            QueueUnitAnimation(dummy, "stand")  
                            walkflag = false
                        end
                    end
                )
                
                local func3 = Reload("SetUnitAnimation",
                    function(u, name)
                        if u == this.unit then
                            IssueImmediateOrder(dummy, "stop")
                            SetUnitTimeScale(dummy, 1)
                            SetUnitAnimation(dummy, name)
                            
                        end
                        SetUnitAnimation(u, name)
                    end
                )
                
                local func4 = Reload("QueueUnitAnimation",
                    function(u, name)
                        if u == this.unit then
                            QueueUnitAnimation(dummy, name)
                            
                        end
                        QueueUnitAnimation(u, name)
                    end
                )
                
                local func5 = Reload("AddSpecialEffectTarget",
                    function(m, u, p)
                        if not flag and u == this.unit then
                            u = dummy
                        end
                        return AddSpecialEffectTarget(m, u, p)
                    end
                )
                
                local func6 = Event("物体目标指令",
                    function(data)
                        if data.unit == this.unit then
                            ordertarget = GetOrderTarget()
                            IssueTargetOrder(dummy, "move", ordertarget)
                            walkflag = true
                        end
                    end
                )
                
                local func7 = Event("点目标指令",
                    function(data)
                        if data.unit == this.unit then
                            ordertarget = GetOrderPointLoc()
                            IssuePointOrderLoc(dummy, "move", ordertarget)
                            walkflag = true
                        end
                    end
                )
                
                local func8 = Reload("SetUnitFlyHeight",
                    function(u, h, r)
                        if u == this.unit then
                            SetUnitFlyHeight(dummy, h, r)
                        end
                        SetUnitFlyHeight(u, h, r)
                    end
                )
                
                this.flush2 = function()
                    SetUnitState(this.unit, UNIT_STATE_ATTACK_RANGE, GetUnitState(this.unit, UNIT_STATE_ATTACK_RANGE) - r)
                    DestroyTimer(timer)
                    RemoveUnit(dummy)
                    SetUnitVertexColor(this.unit, 255, 255, 255, 255)
                    Event("-无目标指令", func1)
                    Event("-攻击", func2)
                    Reload("-SetUnitAnimation", func3)
                    Reload("-QueueUnitAnimation", func4)
                    Reload("-AddSpecialEffectTarget", func5)
                    Event("-物体目标指令", func6)
                    Event("-点目标指令", func7)
                    Reload("-SetUnitFlyHeight", func8)
                end
                
            elseif this.event == "获得技能" then
                if this.unittype then
                    local name = this:get(2)
                    local sid = SkillTable[name]
                    local skill =  SkillTable[sid]
                    if this.icon > 1 then
                        AddSkill(this.unit, "伪装技能", {lv = this.lv, art = skill.art, tip = skill.tip, data = skill.data, newname = skill.name})
                    end
                end
            elseif this.event == "失去技能" then
                if this.icon > 1 then
                    RemoveSkill(this.unit, "伪装技能")
                    RemoveSkill(this.unit, this:get(2))
                end
            elseif this.event == "关闭技能" then
                if this.flush then
                    this.flush()
                end
                this.flush2()
                if this.icon > 1 then
                    RemoveSkill(this.unit, "伪装技能")
                    RemoveSkill(this.unit, this:get(2))
                end
                Wait(0.01,
                    function()
                        if this.icon > 1 then
                            RemoveSkill(this.unit, this.name)
                            AddSkill(this.unit, this.name, this.newdata or {type = {"被动"}})
                        end
                    end
                )
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
        events = {"获得技能", "升级技能"},
        code = function(this)
            if this.event == "获得技能" or this.event == "升级技能" then
                local ab = japi.EXGetUnitAbility(this.unit, this.id)
                japi.EXSetAbilityDataString(ab, 1, 215, this.newname .. " - |cffffcc00需要伪装状态下才会生效|r")
                RefreshTips(this.unit)
            end
        end
    }
    
    --伪装的技能
    
    --宗教狂热
    skilltable["宗教狂热者"] = "宗教狂热"
    
    InitSkill{
        name = "宗教狂热",
        type = {"被动"},
        art = {"BTNUnholyFrenzy.blp"},
        tip = "\
|cffff00cc武器效果:|r提升自己 |cffffcc00%s|r 点攻击速度,最多提升 |cffffcc00%s|r 点,持续 %s 秒.",
        data = {
            10,
            100,
            {6, 9, 12, 15}
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
                                    this.effect = AddSpecialEffectTarget("Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl", this.unit, "hand right")
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
                Event("-伤害效果", this.func)
            end
        end
    }
    
    --火球术
    skilltable["魔法师"] = "火球术"
    
    InitSkill{
        name = "火球术",
        type = {"主动", 1},
        art = {"BTNFireBolt.blp"},
        ani = "spell",
        rng = 1000,
        cast = 0.1,
        mana = 50,
        cool = 10,
        targs = GetTargs("地面,空中,敌人"),
        tip = "\
对一个目标造成 %s(|cff0000ff+%d|r) 点法术伤害.\
\
|cff888888弹道速度为%d",
        data = {
            {75, 125, 175, 225},
            function(ap)
                return ap * 1.2
            end,
            1500
        },
        events = {"发动技能"},
        code = function(this)
            local d = this:get(1) + this:get(2)
            MoverEx(
                {
                    from = this.unit,
                    target = this.target,
                    modle = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl",
                    size = 1.5,
                    speed = this:get(3),
                    z = 100,
                    tz = 100,
                },
                nil,
                function(move)
                    SkillEffect{
                        from = move.from,
                        to = move.target,
                        name = this.name,
                        data = this,
                        code = function(data)
                            Damage(data.from, data.to, d, false, true, {damageReason = this.name})
                        end
                    }
                    
                end
            )
        end
    }
    
    --圣歌咏唱
    skilltable["主教"] = "圣歌咏唱"
    
    InitSkill{
        name = "圣歌咏唱",
        type = {"被动"},
        art = {"BTNHolyBolt.blp"},
        tip = "\
|cffff00cc武器效果:|r 对建筑物额外造成 %s(|cff0000ff+%d|r) 点法术伤害.",
        data = {
            {50, 75, 100, 125},
            function(ap)
                return ap * 0.75
            end
        },
        events = {"获得技能", "失去技能"},
        code = function(this)
            if this.event == "获得技能" then
                local func1 = Event("伤害效果",
                    function(damage)
                        if damage.from == this.unit and damage.weapon and IsUnitType(damage.to, UNIT_TYPE_STRUCTURE) then
                            Damage(damage.from, damage.to, this:get(1) + this:get(2), false, true, {damageReason = this.name})
                        end
                    end
                )
                
                this.flush = function()
                    Event("-伤害效果", func1)
                end
            elseif this.event == "失去技能" then
                this.flush()
            end
        end
    }
    
    --警卫护盾
    skilltable["警卫"] = "警卫护盾"
    
    InitSkill{
        name = "警卫护盾",
        type = {"被动"},
        art = {"BTNDefend.blp"},
        tip = "\
|cffff00cc受到的攻击伤害减少 %s(|cff0000ff+%d|r) 点.",
        data = {
            {8, 16, 24, 32},
            function(ap)
                return ap * 0.15
            end
        },
        events = {"获得技能", "失去技能"},
        code = function(this)
            if this.event == "获得技能" then
                local func1 = Event("伤害减免",
                    function(damage)
                        if this.unit == damage.to and damage.attack then
                            damage.damage = damage.damage - this:get(1) - this:get(2)
                        end
                    end
                )
                
                this.flush = function()
                    Event("-伤害减免", func1)
                end
            elseif this.event == "失去技能" then
                this.flush()
            end
        end
    }
    
    --震荡手雷
    skilltable["警备员"] = "震荡手雷"
    
    InitSkill{
        name = "震荡手雷",
        type = {"主动", 2, 3},
        art = {"BTNLiquidFire.blp"},
        ani = "spell",
        cast = 0.1,
        mana = 50,
        cool = 15,
        rng = 400,
        area = 200,
        dur = {0.75, 1, 1.25, 1.5},
        tip = "\
向区域内投掷催泪弹,对敌方单位造成 %s(|cff0000ff+%d|r) 点法术伤害并麻痹.\
\
|cff888888弹道速度为%d",
        data = {
            {50, 75, 100, 125},
            function(ap)
                return ap * 0.75
            end,
            250
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                local d = this:get(1) + this:get(2)
                local area = this:get("area")
                local t = this:get("dur")
                MoverEx(
                    {
                        from = this.unit,
                        target = this.target,
                        speed = this:get(3),
                        high = 300,
                        modle = "Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl",
                        size = 2,
                        z = 100
                    },
                    nil,
                    function(move)
                        TempEffect(move.unit, "Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl")
                        forRange(move.unit, area,
                            function(u)
                                if EnemyFilter(this.player, u) then
                                    SkillEffect{
                                        from = move.from,
                                        to = u,
                                        name = this.name,
                                        data = this,
                                        aoe = true,
                                        code = function(data)
                                            BenumbUnit{
                                                from = data.from,
                                                to = data.to,
                                                time = t,
                                                aoe = true
                                            }
                                            
                                            Damage(data.from, data.to, d, false, true, {damageReason = this.name, aoe = true})
                                        end
                                    }
                                end
                            end
                        )
                    end
                )
            end
        end
    }
    
    --驱动火炮
    skilltable["驱动铠"] = "驱动火炮"
    
    InitSkill{
        name = "驱动火炮",
        type = {"被动"},
        art = {"BTNHumanMissileUpThree.blp"},
        cool = 10,
        tip = "\
|cffff00cc武器效果:|r 对建筑物额外造成 %s(|cff0000ff+%d|r) 点法术伤害.",
        data = {
            {250, 375, 500, 625},
            function(ap)
                return ap * 3.75
            end
        },
        events = {"获得技能", "失去技能"},
        code = function(this)
            if this.event == "获得技能" then
                local enable = true
                local func1 = Event("伤害效果",
                    function(damage)
                        if enable and damage.from == this.unit and damage.weapon and IsUnitType(damage.to, UNIT_TYPE_STRUCTURE) then
                            enable = false
                            Damage(damage.from, damage.to, this:get(1) + this:get(2), false, true, {damageReason = this.name})
                            UnitRemoveAbility(this.unit, this.id)
                            UnitAddAbility(this.unit, this.id)
                            local cd = this:get("cool")
                            SetSkillCool(this.unit, this.id, cd, cd)
                            Wait(cd,
                                function()
                                    if this.id ~= 0 then
                                        UnitRemoveAbility(this.unit, this.id)
                                        UnitAddAbility(this.unit, this.id)
                                        enable = true
                                        SetSkillCool(this.unit, this.id, 10000, 1000000)
                                    end
                                end
                            )
                        end
                    end
                )
                
                this.flush = function()
                    Event("-伤害效果", func1)
                end
            elseif this.event == "失去技能" then
                this.flush()
            end
        end
    }
    
    --泥潭
    skilltable["科学突变黏怪"] = "泥潭"
    
    InitSkill{
        name = "泥潭",
        type = {"主动", 1},
        art = {"BTNSlow.blp"},
        ani = "spell",
        rng = 500,
        cast = 0.1,
        mana = 50,
        cool = 15,
        dur = {3, 4, 5, 6},
        targs = GetTargs("地面,空中,敌人"),
        tip = "\
降低一个单位 %s%% 的攻击速度与 %s%% 的移动速度.",
        data = {
            {50, 60, 70, 80},
            {60, 65, 70, 75}
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                SkillEffect{
                    from = move.from,
                    to = move.to,
                    name = this.name,
                    data = this,
                    code = function(data)
                        SlowUnit{
                            from = data.from,
                            to = data.to,
                            time = this:get("dur"),
                            attack = this:get(1),
                            move = this:get(2)
                        }
                    end
                }
            end
        end
    }
    
    --腐蚀酸泥
    skilltable["科学突变淤泥怪"] = "腐蚀酸泥"
    
    InitSkill{
        name = "腐蚀酸泥",
        type = {"主动", 1},
        art = {"BTNHealingSpray.blp"},
        ani = "spell",
        rng = 500,
        cast = 0.1,
        mana = 25,
        cool = 3,
        dur = 10,
        targs = GetTargs("地面,空中,敌人"),
        tip = "\
腐蚀一个单位 %s 点的护甲值.每次叠加腐蚀 %s 点.",
        data = {
            {15, 20, 25, 30},
            {6, 9, 12, 15}
        },
        events = {"获得技能", "发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                local d = this.units[this.target]
                if d then
                    d.def = d.def + this:get(2)
                    Def(this.target, - this:get(2))
                else
                    d = {
                        unit = this.target,
                        def = this:get(1),
                        effect = AddSpecialEffectTarget("Abilities\\Spells\\Undead\\UnholyFrenzy\\UnholyFrenzyTarget.mdl", this.target, "chest"),
                        timer = CreateTimer(),
                        func = function()
                            DestroyTimer(d.timer)
                            DestroyEffect(d.effect)
                            this.units[d.unit] = nil
                            Def(d.unit, d.def)
                        end
                    }
                    this.units[this.target] = d
                    Def(this.target, - this:get(1))
                end
                TimerStart(d.timer, this:get("dur"), false, d.func)
            elseif this.event == "获得技能" then
                this.units = {}
            end
        end
    }
    
    --暴动
    skilltable["驹场利德"] = "暴动"
    
    InitSkill{
        name = "暴动",
        type = {"主动"},
        art = {"BTNBerserkForTrolls.blp"},
        time = 0,
        mana = 25,
        cool = 20,
        dur = 10,
        tip = "\
增加自己 %s%% 的攻击速度与 %s 点移动速度,但是受到的伤害增加 %s%%.",
        data = {
            {75, 90, 105, 120},
            {90, 100, 110, 120},
            75
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                AttachSoundToUnit(gg_snd_BerserkerCaster, this.unit)
                StartSound(gg_snd_BerserkerCaster)
                local as, ms, d = this:get(1), this:get(2), this:get(3)
                AttackSpeed(this.unit, as)
                MoveSpeed(this.unit, ms)
                
                local func1 = Event("伤害加成",
                    function(damage)
                        if damage.to == this.unit then
                            damage.damage = damage.damage + d * damage.odamage / 100
                        end
                    end
                )
                
                Wait(this:get("dur"),
                    function()
                        Event("-伤害加成", func1)
                        AttackSpeed(this.unit, - as)
                        MoveSpeed(this.unit, - ms)
                    end
                )
            end
        end
    }
    
    --醒工砖
    skilltable["板砖混混"] = "醒工砖"
    
    InitSkill{
        name = "醒工砖",
        type = {"主动", 1},
        art = {"BTNFireRocks.blp"},
        ani = "spell",
        rng = 128,
        cast = 0.3,
        mana = 75,
        cool = 20,
        targs = GetTargs("地面,空中,敌人"),
        tip = "\
将一个单位拍晕 %s 秒并造成 %s(|cff0000ff+%d|r) 点法术伤害.",
        data = {
            {1.5, 1.75, 2, 2.25},
            {50, 100, 150, 200},
            function(ap)
                return ap * 1
            end
        },
        events = {"发动技能"},
        code = function(this)
            local t = this:get(1)
            local d = this:get(2) + this:get(3)
            SkillEffect{
                from = this.unit,
                to = this.target,
                name = this.name,
                data = this,
                code = function(data)
                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", data.to, "chest"))
                    
                    StunUnit{
                        from = data.from,
                        to = data.to,
                        time = t
                    }
                
                    Damage(data.from, data.to, d, false, true, {damageReason = this.name})
                    
                end
            }
        end
    }
    
    --巨锤
    skilltable["熊"] = "巨锤"
    
    InitSkill{
        name = "巨锤",
        type = {"被动"},
        art = {"BTNBash.blp"},
        cool = 6,
        tip = "\
|cffff00cc武器效果:|r击晕攻击目标 %s 秒并额外造成 %s(|cff0000ff+%d|r) 点物理伤害.",
        data = {
            {1.5, 1.6, 1.7, 1.8},
            {100, 150, 200, 250},
            function(ap)
                return ap * 1.2
            end
        },
        events = {"获得技能", "失去技能"},
        code = function(this)
            if this.event == "获得技能" then
                local enable = true
                
                local func1 = Event("攻击",
                    function(data)
                        if enable and data.from == this.unit then
                            Wait(0,
                                function()
                                    SetUnitAnimation(this.unit, "attack slam")
                                end
                            )
                        end
                    end
                )
                
                local func2 = Event("伤害效果",
                    function(damage)
                        if enable and damage.from == this.unit and damage.weapon then
                            local d = this:get(2) + this:get(3)
                            local t = this:get(1)
                            SkillEffect{
                                from = this.unit,
                                to = damage.to,
                                name = this.name,
                                data = this,
                                code = function(data)
                                    if not IsUnitType(data.to, UNIT_TYPE_STRUCTURE) then
                                        StunUnit{
                                            from = data.from,
                                            to = data.to,
                                            time = t
                                        }
                                    end
                                    Damage(data.from, data.to, d, true, false, {damageReason = this.name})
                                end
                            }
                            enable = false
                            UnitRemoveAbility(this.unit, this.id)
                            UnitAddAbility(this.unit, this.id)
                            local cd = this:get("cool")
                            SetSkillCool(this.unit, this.id, cd, cd)
                            Wait(cd,
                                function()
                                    if this.id ~= 0 then
                                        UnitRemoveAbility(this.unit, this.id)
                                        UnitAddAbility(this.unit, this.id)
                                        enable = true
                                        SetSkillCool(this.unit, this.id, 10000, 1000000)
                                    end
                                end
                            )
                        end
                    end
                )
                
                this.flush = function()
                    Event("-攻击", func1)
                    Event("-伤害效果", func2)
                end
            elseif this.event == "失去技能" then
                this.flush()
            end
        end
    }
    
    --撕咬
    skilltable["大灰狼"] = "撕咬"
    
    InitSkill{
        name = "撕咬",
        type = {"被动"},
        art = {"BTNRedDragonDevour.blp"},
        tip = "\
暴击率提高 |cffffcc00%s%%|r ,暴击系数提高 |cffffcc00%s%%|r .",
        data = {
            25,
            50,
        },
        events = {"获得技能", "失去技能"},
        code = function(this)
            if this.event == "获得技能" then
                Crit(this.unit, this:get(1), this:get(2))
            elseif this.event == "失去技能" then
                Crit(this.unit, - this:get(1), - this:get(2))
            end
        end
    }
    
    --狂抓
    skilltable["巨狼"] = "狂抓"
    
    InitSkill{
        name = "狂抓",
        type = {"主动", 1},
        art = {"BTNGhoulFrenzy.blp"},
        rng = 600,
        time = 999,
        mana = 75,
        cool = 15,
        targs = GetTargs("地面,空中,敌人"),
        tip = "\
|cffffcc00需要持续施法|r\
\
跳跃到目标身上进行压制使其无法移动,并累计造成 %s(|cff0000ff+%d|r) 点物理伤害,持续 %s 秒.",
        data = {
            {150, 250, 300, 450},
            function(ap)
                return ap * 2
            end,
            {1.5, 1.75, 2, 2.25}
        },
        events = {"发动技能", "停止施放"},
        code = function(this)
            if this.event == "发动技能" then
                local t = this:get(3)
                local d = this:get(1) + this:get(2)
                local sttime
                local timer = CreateTimer()

                local move = Mover(
                    {
                        from = this.unit,
                        target = this.target,
                        unit = this.unit,
                        high = 200,
                        speed = 750,
                    },
                    nil,
                    function(move)
                        if IsUnitAlive(move.from) and IsUnitAlive(move.target) then
                            MoveSpeed(move.target, -10000)
                            sttime = GetTime()
                            SetUnitAnimation(move.from, "attack slam")
                            QueueUnitAnimation(move.from, "attack slam")
                            QueueUnitAnimation(move.from, "attack slam")
                            TimerStart(timer, t, false,
                                function()
                                    MoveSpeed(move.target, 10000)
                                    IssueTargetOrder(move.from, "attack", move.target)
                                end
                            )
                        end
                    end
                )
                this.flush = function()
                    DestroyTimer(timer)
                    if sttime then
                        local nt = GetTime() - sttime
                        local d = d * t / nt
                        Damage(move.from, move.target, d, true, false, {damageReason = this.name})
                    end
                end
            elseif this.event == "停止施放" then
                this.flush()
            end
        end
    }
    
    --疗伤
    skilltable["无能力武装集团小头目"] = "疗伤"
    
    InitSkill{
        name = "疗伤",
        type = {"开关"},
        art = {"BTNHealingSalve.blp", "BTNHealingSalve.blp", "BTNWispSplode.blp"},
        mana = 25,
        area = 600,
        tip = "\
每秒为附近受伤最严重的一个友方英雄进行治疗,为其回复 %s(|cff0000ff+%d|r) 点生命值.每次为英雄治疗需要消耗 |cffffcc00%s|r 点法力.",
        data = {
            {15, 20, 25, 30},
            function(ap)
                return ap * 0.15
            end,
            10
        },
        events = {"发动技能", "关闭技能"},
        code = function(this)
            if this.event == "发动技能" then
                local effect = AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\Tranquility\\TranquilityTarget.mdl", this.unit, "origin")
                local timer = Loop(1,
                    function()
                        local mp = GetUnitState(this.unit, UNIT_STATE_MANA)
                        if mp < this:get(3) then return end
                        local g = {}
                        forRange(this.unit, this:get("area"),
                            function(u)
                                if IsHero(u) and IsUnitAlly(u, this.player) and IsUnitAlive(u) and GetUnitState(u, UNIT_STATE_LIFE) < GetUnitState(u, UNIT_STATE_MAX_LIFE) then
                                    table.insert(g, u)
                                end
                            end
                        )
                        if #g == 0 then return end
                        local u = table.getone(g,
                            function(u1, u2)
                                return GetUnitState(u1, UNIT_STATE_LIFE) < GetUnitState(u2, UNIT_STATE_LIFE)
                            end
                        )
                        SetUnitState(this.unit, UNIT_STATE_MANA, mp - this:get(3))
                        Heal(this.unit, u, this:get(1) + this:get(2), {healReason = this.name, modle = "Abilities\\Spells\\Human\\Heal\\HealTarget.mdl"})
                            
                    end
                )
                
                this.flush = function()
                    DestroyEffect(effect)
                    DestroyTimer(timer)
                end
                
            elseif this.event == "关闭技能" then
                this.flush()
            end
        end
    }
    
    --燃烧弹
    skilltable["无能力武装集团机枪手"] = "燃烧弹"
    
    InitSkill{
        name = "燃烧弹",
        type = {"开关"},
        art = {"BTNFireBolt.blp", "BTNFireBolt.blp", "BTNWispSplode.blp"},
        tip = "\
开启后将使用燃烧弹进行攻击,|cffffcc00燃烧|r 并 |cffffcc00减速|r 目标,总计造成 %s(|cff0000ff+%d|r) 点法术伤害并降低其 |cffffcc00%s%%|r 的移动速度,持续 %s 秒.每次攻击消耗 |cffffcc00%s|r 点法力.",
        data = {
            {20, 35, 50, 65},
            function(ap)
                return ap * 0.3
            end,
            35, --减速3
            {1.5, 2, 2.5, 3}, --持续时间4
            15, --耗蓝5
        },
        events = {"发动技能", "关闭技能"},
        code = function(this)
            if this.event == "发动技能" then
                Mark(this.unit, "弹道模型", "Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl")
                
                local func1 = Event("攻击出手",
                    function(damage)
                        if damage.from == this.unit then
                            local mp = this:get(5)
                            local nmp = GetUnitState(this.unit, UNIT_STATE_MANA)
                            if nmp < mp then return end
                            SetUnitState(this.unit, UNIT_STATE_MANA, nmp - mp)
                            local d = this:get(1) + this:get(2)
                            local ms = this:get(3)
                            local t = this:get(4)
                            
                            table.insert(damage.attackfuncs,
                                function(damage)
                                    SlowUnit{
                                        from = damage.from,
                                        to = damage.to,
                                        time = t,
                                        move = ms
                                    }
                                    
                                    FireUnit{
                                        from = damage.from,
                                        to = damage.to,
                                        time = t,
                                        damage = d
                                    }
                                end
                            )
                        end
                    end
                )
                
                this.flush = function()
                    Event("-攻击出手", func1)
                    Mark(this.unit, "弹道模型", false)
                end
            elseif this.event == "关闭技能" then
                this.flush()
            end
            
        end
    }
    
    --医疗波
    skilltable["类人猿"] = "医疗波"
    
    InitSkill{
        name = "医疗波",
        type = {"主动", 1},
        art = {"BTNHealingWave.blp"},
        rng = 600,
        cast = 0.3,
        mana = {75, 100, 125, 150},
        cool = 15,
        targs = GetTargs("地面,空中,自己,玩家单位,联盟"),
        tip = "\
发射一道可以跳跃 %s 次的医疗波,为友方单位回复 %s(|cff0000ff+%d|r) 的生命值.每次跳跃后治疗效果将比前一次减少 |cffffcc00%s|r%%.",
        data = {
            {5, 6, 7, 8},
            {75, 100, 125, 150},
            function(ap)
                return ap * 1.5
            end,
            15
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                local n = this:get(1)
                local h = this:get(2) + this:get(3)
                local s = this:get(4)
                local lu = this.unit
                local u = this.target
                local area = this:get("rng")
                local units = {}
                
                local func1 = function()
                    local x1, y1 = GetXY(lu)
                    local x2, y2 = GetXY(u)
                    local z1, z2 = GetUnitZ(lu) + 75, GetUnitZ(u) + 75
                    local l = AddLightningEx('HWPB', true, x1, y1, z1, x2, y2, z2)
                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Orc\\HealingWave\\HealingWaveTarget.mdl", u, "origin"))
                    Heal(this.unit, u, h, {healReason = this.name})
                    Wait(0.5,
                        function()
                            local a = 1
                            Loop(0.05,
                                function()
                                    a = a - 0.05
                                    if a > 0 then
                                        SetLightningColor(l, 1, 1, 1, a)
                                    else
                                        DestroyLightning(l)
                                        EndLoop()
                                    end
                                end
                            )
                        end
                    )
                end
                
                LoopRun(0.25,
                    function()
                        func1()
                        if n > 0 then
                            n = n - 1
                            h = h - h * s / 100
                            units[u] = true
                            local g = {}
                            forRange(u, area,
                                function(u)
                                    if not units[u] and IsUnitAlly(u, this.player) and IsUnitAlive(u) and GetUnitState(u, UNIT_STATE_LIFE) < GetUnitState(u, UNIT_STATE_MAX_LIFE) then
                                        table.insert(g, u)
                                    end
                                end
                            )
                            if #g == 0 then
                                EndLoop()
                            else
                                lu = u
                                u = g[GetRandomInt(1, #g)]
                            end
                        else
                            EndLoop()
                        end
                    end
                )
            end
        end
    }
    
    --净化
    skilltable["小混混"] = "净化"
    
    InitSkill{
        name = "净化",
        type = {"主动", 1},
        art = {"BTNPurge.blp"},
        rng = {450, 500, 550, 600},
        mana = {50},
        cool = {12, 11, 10, 9},
        targs = GetTargs("地面,空中"),
        tip = "\
|cffff00cc对友方:|r立即移除目标身上的负面效果.\
|cffff00cc对敌方:|r立即移除目标身上的正面效果,并将其的移动速度降为0.被减少的移动速度将在 %s 秒内逐渐恢复.",
        data = {
            {3, 3.5, 4, 4.5}
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                local t = this:get(1)
                SkillEffect{
                    from = this.unit,
                    to = this.target,
                    name = this.name,
                    data = this,
                    code = function(data)
                        local effect = AddSpecialEffectTarget("Abilities\\Spells\\Orc\\Purge\\PurgeBuffTarget.mdl", data.to, "origin")
                        if IsUnitAlly(data.to, GetOwningPlayer(data.from)) then
                            CleanUnit{
                                from = data.from,
                                to = data.to,
                                debuff = true,
                                good = true
                            }
                        else
                            CleanUnit{
                                from = data.from,
                                to = data.to,
                                buff = true
                            }
                            
                            local ms = GetUnitMoveSpeed(data.to)
                            MoveSpeed(data.to, - ms)
                            local count = math.floor(t / 0.5)
                            local fms = math.floor(ms / count)
                            local mms = 0
                            Loop(0.5,
                                function()
                                    if count == 1 then
                                        MoveSpeed(data.to, ms - mms) --最后一次直接将速度补满,以免除法引起误差
                                        EndLoop()
                                        DestroyEffect(effect)
                                    else
                                        mms = mms + fms
                                        MoveSpeed(data.to, fms)
                                        count = count - 1
                                    end
                                end
                            )
                            
                        end
                    end
                }
            end
        end
    }
    
    --热血战魂
    skilltable["流氓"] = "热血战魂"
    
    InitSkill{
        name = "热血战魂",
        type = {"被动"},
        art = {"BTNCommand.blp"},
        tip = "\
每次攻击击中同一个单位时获得 %s%% 的攻击速度提升,最多提升 %s%% .如果改变攻击目标将损失一半的提升.",
        data = {
            {16, 22, 28, 34},
            {64, 88, 112, 136},
        },
        events = {"获得技能", "失去技能"},
        code = function(this)
            if this.event == "获得技能" then
                local as = 0
                local lastunit
                
                local func1 = Event("伤害效果",
                    function(damage)
                        if damage.from == this.unit and damage.weapon then
                            local mas = this:get(2)
                            local uas = math.min(this:get(1), mas - as)
                            AttackSpeed(this.unit, uas)
                            as = as + uas
                            lastunit = damage.to
                        end
                    end
                )
                
                local func2 = Event("攻击",
                    function(data)
                        if data.from == this.unit and lastunit and data.to ~= lastunit and as > 0 then
                            lastunit = nil
                            local nas = math.floor(as / 2)
                            AttackSpeed(this.unit, nas - as)
                            as = nas
                        end
                    end
                )
                
                this.flush = function()
                    Event("-伤害效果", func1)
                    Event("-攻击", func2)
                    AttackSpeed(this.unit, - as)
                end
            elseif this.event == "失去技能" then
                this.flush()
            end
        end
    }
    
    --怒意狂击
    skilltable["魔法变异熊怪"] = "怒意狂击"
    
    InitSkill{
        name = "怒意狂击",
        type = {"被动"},
        art = {"BTNability_druid_rake.blp"},
        tip = "\
每次攻击撕开目标的伤口,使其受到比上次攻击更多的伤害.撕裂伤口状态持续 |cffffcc00%s|r 秒.每次累积 %s(|cff0000ff+%d|r) 点物理伤害",
        data = {
            6,
            {10, 15, 20, 25},
            function(ap)
                return ap * 0.2
            end
        },
        events = {"获得技能", "失去技能"},
        code = function(this)
            if this.event == "获得技能" then
                local units = {}
                
                local func1 = Event("伤害加成",
                    function(damage)
                        if damage.attack and damage.from == this.unit then
                            local data = units[damage.to]
                            if not data then
                                data = {
                                    unit = damage.to,
                                    effect = AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\BattleRoar\\RoarTarget.mdl", damage.to, "overhead"),
                                    timer = CreateTimer(),
                                    damage = 0,
                                    func = function()
                                        units[data.unit] = nil
                                        DestroyEffect(data.effect)
                                        DestroyTimer(data.timer)
                                    end
                                }
                                units[damage.to] = data
                            end
                            data.damage = data.damage + this:get(2) + this:get(3)
                            damage.damage = damage.damage + data.damage
                            TimerStart(data.timer, this:get(1), false, data.func)
                        end
                    end
                )
                
                this.flush = function()
                    Event("-伤害加成", func1)
                end
            elseif this.event == "失去技能" then
                this.flush()
            end
        end
    }
    
    --霜之新星
    skilltable["雪女"] = "霜之新星"
    
    InitSkill{
        name = "霜之新星",
        type = {"主动", 2},
        art = {"BTNGlacier.blp"},
        ani = "spell",
        rng = 500,
        area = 175,
        cast = 0.1,
        mana = 75,
        cool = 15,
        tip = "\
发射一道霜冻能量,对一条直线上的单位造成 %s(|cff0000ff+%d|r) 点法术伤害并将其 |cffffcc00击晕|r %s 秒.",
        data = {
            {75, 100, 125, 150},
            function(ap)
                return ap * 0.8
            end,
            {0.75, 1, 1.25, 1.5}
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                local loc = GetUnitLoc(this.unit)
                local a = GetBetween(loc, this.target, true)
                local d = this:get(1) + this:get(2)
                local t = this:get(3)
                local area = this:get("area")
                local count = 0
                local g = {}
                Loop(0.05,
                    function()
                        loc = MovePoint(loc, {100, a})
                        TempEffect(loc, "Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl")
                        forRange(loc, area,
                            function(u)
                                if not g[u] and EnemyFilter(this.player, u) then
                                    g[u] = true
                                    SkillEffect{
                                        from = this.unit,
                                        to = u,
                                        name = this.name,
                                        data = this,
                                        aoe = true,
                                        code = function(data)
                                            StunUnit{
                                                from = data.from,
                                                to = data.to,
                                                time = t,
                                                aoe = true
                                            }
                                            
                                            Damage(data.from, data.to, d, false, true, {damageReason = this.name, aoe = true})
                                        end
                                    }
                                end                                
                            end
                        )
                        count = count + 1
                        if count == 5 then
                            EndLoop()
                        end
                    end
                )
            end
        end
    }
    
    --蛛网
    skilltable["黑蜘蛛"] = "蛛网"
    
    InitSkill{
        name = "蛛网",
        type = {"主动", 1},
        art = {"BTNWeb.blp"},
        ani = "spell",
        rng = 600,
        cast = 0.1,
        mana = 75,
        cool = 12,
        targs = GetTargs("地面,空中,敌人"),
        tip = "\
发射蛛网将目标 |cffffcc00束缚|r 在原地无法移动,持续 %s 秒.\
\
|cff888888可以驱散",
        data = {
            {2, 3, 4, 5},
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                local t = this:get(1)
                MoverEx(
                    {
                        from = this.unit,
                        target = this.target,
                        modle = "Abilities\\Spells\\Undead\\Web\\Webmissile.mdl",
                        speed = 1000,
                        z = 50,
                    },
                    nil,
                    function(move)
                        SkillEffect{
                            from = move.from,
                            to = move.target,
                            name = this.name,
                            data = this,
                            code = function(data)
                                BoundUnit{
                                    from = data.from,
                                    to = data.to,
                                    time = t
                                }
                            end
                        }
                    end
                )
            end
        end
    }
    
    --毒性之咬
    skilltable["巨大蜘蛛"] = "毒性之咬"
    
    InitSkill{
        name = "毒性之咬",
        type = {"被动"},
        art = {"BTNSlowPoison.blp"},
        cool = 6,
        tip = "\
|cffff00cc武器效果:|r使目标|cffffcc00中毒|r,在 |cffffcc00%s|r 秒内累计造成 %s(|cff0000ff+%d|r) 点法术伤害.\
\
|cff888888可以驱散|r",
        data = {
            16,
            {120, 200, 280, 360},
            function(ap)
                return ap * 1.7
            end
        },
        events = {"获得技能", "失去技能"},
        code = function(this)
            if this.event == "获得技能" then
                local enable = true
                
                local func1 = Event("伤害效果",
                    function(damage)
                        if enable and damage.weapon and damage.from == this.unit then
                            PoisonUnit{
                                from = this.unit,
                                to = damage.to,
                                damage = this:get(2) + this:get(3),
                                time = this:get(1)
                            }
                            
                            enable = false
                            UnitRemoveAbility(this.unit, this.id)
                            UnitAddAbility(this.unit, this.id)
                            local cd = this:get("cool")
                            SetSkillCool(this.unit, this.id, cd, cd)
                            Wait(cd,
                                function()
                                    if this.id ~= 0 then
                                        UnitRemoveAbility(this.unit, this.id)
                                        UnitAddAbility(this.unit, this.id)
                                        enable = true
                                        SetSkillCool(this.unit, this.id, 10000, 1000000)
                                    end
                                end
                            )
                        end
                    end
                )
                
                this.flush = function()
                    Event("-伤害效果", func1)
                end
            elseif this.event == "失去技能" then
                this.flush()
            end
        end
    }
    
    --冲击波
    skilltable["异教徒"] = "冲击波"
    
    InitSkill{
        name = "冲击波",
        type = {"主动", 2},
        art = {"BTNShockWave.blp"},
        ani = "spell",
        rng = 800,
        area = 175,
        cast = 0.1,
        mana = 75,
        cool = 15,
        tip = "\
发射一道冲击波,对一条直线上的单位造成 %s(|cff0000ff+%d|r) 点法术伤害.",
        data = {
            {75, 125, 175, 225},
            function(ap)
                return ap * 1.1
            end
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                local d = this:get(1) + this:get(2)
                local area = this:get("area")
                local a = GetBetween(this.unit, this.target, true)
                local g = {}
                
                Mover(
                    {
                        from = this.unit,
                        angle = a,
                        speed = 1000,
                        distance = this:get("rng"),
                        modle = "Abilities\\Spells\\Orc\\Shockwave\\ShockwaveMissile.mdl",
                    },
                    function(move)
                        if move.count % 5 == 0 then
                            forRange(move.unit, area,
                                function(u)
                                    if not g[u] and EnemyFilter(this.player, u) then
                                        g[u] = true
                                        Damage(move.from, u, d, false, true, {damageReason = this.name, aoe = true})
                                    end
                                end
                            )
                        end
                    end
                )
            end
        end
    }
    
    --虚妄诺言
    skilltable["逃亡魔法师"] = "虚妄诺言"
    
    InitSkill{
        name = "虚妄诺言",
        type = {"主动", 1},
        art = {"BTNfalsepromise.blp"},
        ani = "spell",
        rng = 600,
        cast = 0.1,
        mana = {125, 150, 175, 200},
        cool = 20,
        dur = 5,
        targs = GetTargs("地面,空中"),
        tip = "\
暂时篡改一个单位的命运,延缓其受到的所有伤害,治疗以及恢复效果,直到虚妄诺言效果结束.\
被延缓的伤害,治疗以及恢复效果将在虚妄诺言结束后立即生效.\
\
|cffff00cc对友方单位:|r被延缓的治疗以及恢复效果在结算时增加 %s%%\
|cffff00cc对敌方单位:|r被延缓的伤害效果在结算时增加 %s%%",
        data = {
            {25, 50, 75, 100},
            {10, 20, 30, 40},
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                local t = this:get("dur")
                local a1 = this:get(1)
                local a2 = this:get(2)
                local effect = AddSpecialEffectTarget("war3mapImported\\falsepromise.mdx", this.target, "chest")
                local u = this.target
                if IsUnitAlly(u, this.player) then
                    a1 = 1 + a1 / 100
                    a2 = 1
                else
                    a1 = 1
                    a2 = 1 + a2 / 100
                end
                
                local damages = {}
                local func1 = Event("伤害无效",
                    function(damage)
                        if damage.to == u then
                            table.insert(damages, damage)
                            dodgeReason = this.name
                            return true
                        end
                    end
                )
                
                local heals = {}
                local func2 = Event("治疗无效",
                    function(heal)
                        if heal.to == u then
                            table.insert(heals, heal)
                            dodgeReason = this.name
                            return true
                        end
                    end
                )
                
                local lasthp = GetRecover(u)
                local mhp = 0
                Recover(u, - lasthp)
                local lasttime = this.spellflag
                
                local func3 = Reload("Recover",
                    function(who, hp, mp)
                        if who == u then
                            local nowtime = GetTime()
                            local passtime = nowtime - lasttime
                            mhp = mhp + lasthp * passtime --记录这段时间内的总恢复
                            lasttime = nowtime
                            lasthp = lasthp + hp --记录新的恢复速度
                            hp = 0
                        end
                        Recover(who, hp, mp)
                    end
                )
                
                Wait(t,
                    function()
                        DestroyEffect(effect)
                        Recover(u, 0) --刷新一下总恢复
                        Event("-伤害无效", func1)
                        Event("-治疗无效", func2)
                        Reload("-Recover", func3)
                        Recover(u, lasthp)
                        
                        --开始回溯
                        MaxLife(u, 50000, true) --增加血量上限,维持当前血量
                        local func = Reload("GetUnitState",
                            function(who, s)
                                if who == u then
                                    if s == UNIT_STATE_MAX_LIFE then
                                        return GetUnitState(who, s) - 50000
                                    elseif s == UNIT_STATE_LIFE then
                                        return math.min(GetUnitState(who, s), GetUnitState(who, UNIT_STATE_MAX_LIFE) - 50000)
                                    end
                                end
                                return GetUnitState(who, s)
                            end
                        )
                        local heal = Heal(this.unit, u, mhp * a1, {healReason = this.name})
                        Debug(("<虚妄诺言>生命恢复:%.3f"):format(heal.heal))
                        for _, heal in ipairs(heals) do
                            local heal = Heal(heal.from, heal.to, heal.sheal * a1, heal)
                            Debug(("<虚妄诺言>回溯治疗:%.3f"):format(heal.heal))
                        end
                        for _, damage in ipairs(damages) do
                            local damage = Damage(damage.from, damage.to, damage.sdamage * a2, damage.def, damage.ant, damage)
                            if damage.result == "死亡" then
                                break
                            end
                            Debug(("<虚妄诺言>回溯伤害:%.3f"):format(damage.damage))
                        end
                        MaxLife(u, -50000, true)
                        Reload("-GetUnitState", func)
                    end
                )
                
            end
        end
    }
