    
    HeroName[7] = "茵蒂克丝"
    HeroMain[7] = "智力"
    HeroType[7] = |Eevi|
    RDHeroType[7] = |h01Q|
    HeroTypePic[7] = "ReplaceableTextures\\CommandButtons\\BTNIndex.blp"
    HeroSize[7] = 0.71
    LearnSkillId = {|A168|, |A169|, |A16A|, |A16B|}
    
    --魔法解析
    InitSkill{
        name = "魔法解析",
        type = {"主动", 1},
        ani = "spell",
        art = {"BTNMagicalSentry.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {60, 70, 80, 90},
        cool = 20,
        rng = 600,
        cast = 0.3,
        dur = 10,
        icon = 2,
        targs = GetTargs("地面,空中,敌人,有机生物"),
        tip = "\
茵蒂克丝尝试解析对方使用的技能,持续造成伤害并燃烧等值的法力值.在此期间对方使用英雄技能时将移除该效果,同时茵蒂克丝将学会该技能.\n\
|cff00ffcc技能|r: 单位目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00总伤害|r: %s(|cffff00ff+%d|r)\
|cffffcc00技能记忆时间|r: %s\n\
|cff888888无法驱散\n弹道速度为%s\n获得的技能处于冷却完毕状态\n茵蒂克丝死亡时将立即失去技能",
        researchtip = "使用英雄技能无法解除魔法解析的效果,而你依然可以学会该技能",
        data = {
            {50, 100, 150, 200}, --造成伤害1
            function(ap, ad, data) --伤害加成2
                return ap * (0.4 + 0.2 * data.lv) + ad * 1 --AP加成为0.6/0.8/1.0/1.2,AD加成为1.0
            end,
            {30, 60, 120, 240}, --记忆时间3
            500, --弹道速度4
        },
        events = {"注册技能", "获得技能", "失去技能", "发动技能"},
        code = function(this)
            if this.event == "注册技能" then
                Event("发动英雄技能",
                    function(data)
                        if data.event == "发动英雄技能" then
                            if GetUnitAbilityLevel(data.unit, |A10T|) == 1 then
                                local this = Mark(data.unit, "魔法解析")
                                if not this.research then
                                    DestroyTimer(this.skilltimer)
                                    UnitRemoveAbility(data.unit, |A10T|)
                                    UnitRemoveAbility(data.unit, |Bslo|)
                                end
                                local from = this.unit
                                Mover({
                                        from = this.unit,
                                        source = data.unit,
                                        target = from,
                                        modle = "Abilities\\Weapons\\SpiritOfVengeanceMissile\\SpiritOfVengeanceMissile.mdl",
                                        speed = this:get(4),
                                        size = 2,
                                        good = true,
                                        z = 100,
                                        data = {that = findSkillData(data.unit, data.skill)},
                                    },nil,
                                    function(move)
                                        if IsUnitDead(move.target) then
                                            Text{
                                                unit = move.target,
                                                word = "解析失败(死亡)",
                                                size = 16,
                                                x = - 50,
                                                z = 50,
                                                color = {0, 50, 100},
                                                life = {2, 3},
                                                speed = {90, 90}
                                            }
                                            return
                                        end
                                        if not findSkillData(move.target, this.name) or not Mark(move.target, "注册英雄") then
                                            Text{
                                                unit = move.target,
                                                word = "解析失败(没有解析能力)",
                                                size = 16,
                                                x = - 50,
                                                z = 50,
                                                color = {0, 50, 100},
                                                life = {2, 3},
                                                speed = {90, 90}
                                            }
                                            return
                                        end
                                        if this.learnedtimer then
                                            RemoveSkill(this.unit, this.learnedskill)
                                            DestroyTimer(this.learnedtimer)
                                        end
                                        local that = move.data.that
                                        this.learnedskill = that.name .. "(" .. this.name .. ")"
                                        AddSkill(this.unit, that.name, {lv = that.lv, name = this.learnedskill})
                                        this.learnedtimer = Wait(this:get(3),
                                            function()
                                                RemoveSkill(this.unit, this.learnedskill)
                                                this.learnedtimer = nil
                                            end
                                        )
                                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIim\\AIimTarget.mdl", move.target, "origin"))
                                        Text{
                                            unit = move.target,
                                            word = that.name,
                                            size = 16,
                                            x = - 50,
                                            z = 50,
                                            color = {0, 50, 100},
                                            life = {2, 3},
                                            speed = {90, 90}
                                        }
                                    end
                                )
                            end
                        end
                    end
                )
            elseif this.event == "获得技能" then
                this.skillfunc = Event("死亡",
                    function(data)
                        if data.unit == this.unit and this.learnedtimer then
                            RemoveSkill(this.unit, this.learnedskill)
                            DestroyTimer(this.learnedtimer)
                            this.learnedtimer = nil
                        end
                    end
                )
            elseif this.event == "失去技能" then
                Event("-死亡", this.skillfunc)
            elseif this.event == "发动技能" then
                SkillEffect{
                    name = this.name,
                    from = this.unit,
                    to = this.target,
                    data = this,
                    filter = "英雄",
                    code = function(data)
                        if GetUnitAbilityLevel(data.to, |A10T|) == 1 then
                            DestroyTimer(Mark(data.to, "魔法解析").skilltimer)
                        else
                            UnitAddAbility(data.to, |A10T|)
                            UnitMakeAbilityPermanent(data.to, true, |A10T|)
                        end
                        local count = this:get("dur")
                        local d = (this:get(1) + this:get(2)) / count
                        this.skilltimer = Loop(1,
                            function()
                                count = count - 1
                                SkillEffect{
                                    name = this.name .. "(周期效果)",
                                    from = data.from,
                                    to = data.to,
                                    data = this,
                                    dot = true,
                                    code = function(data)
                                        local damage = Damage(data.from, data.to, d, false, true, {dot = true, damageReason = this.name})
                                        if damage.damage > 0 then
                                            SetUnitState(data.to, UNIT_STATE_MANA, GetUnitState(data.to, UNIT_STATE_MANA) - damage.damage)
                                            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Feedback\\ArcaneTowerAttack.mdl", damage.to, "origin"))
                                        end
                                    end
                                }
                                if count <= 0 then
                                    EndLoop()
                                    UnitRemoveAbility(data.to, |A10T|)
                                    UnitRemoveAbility(data.to, |Bslo|)
                                end
                            end
                        )
                        Mark(data.to, "魔法解析", this)
                    end
                }
            end
        end
    }
    
    --灭魔之声
    InitSkill{
        name = "灭魔之声",
        type = {"主动"},
        ani = "stand channel",
        art = {"BTNDevourMagic.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {90, 110, 130, 150},
        cool = 30,
        area = 600,
        cast = 0.3,
        time = 10,
        tip = "\
|cff00ccff主动|r: 茵蒂克丝干扰周围的敌方英雄使用技能,增加他们技能的消耗与冷却.茵蒂克丝吟唱的时间越长效果持续时间越长.\
|cff00ccff被动|r: 茵蒂克丝的技能效果将会造成额外伤害,伤害值取决于对方的法术强度.\n\
|cff00ffcc技能|r: 无目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00持续时间|r: %s\
|cffffcc00吟唱一秒增加时间|r: %s\
|cffffcc00消耗与冷却增加|r: %s%%\
|cffffcc00每点法术强度造成伤害|r: %s(|cffff00ff+%.2f|r)\n\
|cff888888吟唱结束时发动效果,最多吟唱10秒\n负面效果可以驱散\n持续性效果造成1/3的伤害",
        researchtip = "变为开关类技能,技能关闭时发动效果.",
        data = {
            {3, 4, 5, 6}, --持续时间1
            {1.1, 1.4, 1.7, 2}, --吟唱与持续时间的换算2
            {50, 100, 150, 200}, --消耗与冷却延长3
            {0.3, 0.4, 0.5, 0.6}, --每点法术强度造成的伤害4
            function(ap, ad) --加成5
                return ap * 0.003 + ad * 0.003
            end,
        },
        events = {"注册技能", "停止施放", "发动技能", "获得技能", "失去技能", "关闭技能", "研发"},
        code = function(this)
            if this.event == "注册技能" then
                --灭魔
                KillmanaGet = function(data)
                    data.skillmana = {}
                    data.skilldata = {}
                    for i = 1, 6 do
                        local this = findSkillData(data.to, i)
                        if this then
                            local mana = this.mana
                            data.skilldata[i] = this
                            if mana then
                                if type(mana) == "table" then
                                    data.skillmana[i] = {}
                                    for j, mana in ipairs(mana) do
                                        local cm = mana * data.mana * 0.01
                                        data.skillmana[i][j] = cm
                                        this.mana[j] = this.mana[j] + cm
                                    end
                                else
                                    local cm = mana * data.mana * 0.01
                                    data.skillmana[i] = cm
                                    this.mana = this.mana + cm
                                end
                            end
                        end
                    end
                    SetCoolDown(data.to, -data.cool)
                end
                
                KillmanaLose = function(data)
                    for i = 1, 6 do
                        local this = findSkillData(data.to, i)
                        if this and data.skilldata[i] == this then
                            if this.mana then
                                if type(this.mana) == "table" then
                                    for j in ipairs(this.mana) do
                                        this.mana[j] = this.mana[j] - data.skillmana[i][j]
                                    end
                                else
                                    this.mana = this.mana - data.skillmana[i]
                                end
                            end
                        end
                    end
                    SetCoolDown(data.to, data.cool)
                end
                
                KillmanaUnit = function(data)
                    if toEvent("debuff", "灭魔", data) then return end
                    local that = Mark(data.to, "灭魔")
                    if that then
                        TimerStart(that.timer, data.time, false, that.func())
                    else
                        UnitAddAbility(data.to, |A16F|)
                        data.timer, data.func = Wait(data.time,
                            function()
                                local data = Mark(data.to, "灭魔")
                                if data then
                                    Mark(data.to, "灭魔", false)
                                    UnitRemoveAbility(data.to, |A16F|)
                                    UnitRemoveAbility(data.to, |B06C|)
                                    DestroyTimer(data.timer)
                                    KillmanaLose(data)
                                end
                            end
                        )
                        Mark(data.to, "灭魔", data)
                        KillmanaGet(data)
                    end
                end
                
                Event("死亡", "驱散",
                    function(this)
                        local that
                        if this.event == "死亡" then
                            that = Mark(this.unit, "灭魔")
                        elseif this.event == "驱散" then
                            if this.debuff then
                                that = Mark(this.to, "灭魔")
                            end
                        end
                        if that then
                            DestroyTimer(that.timer)
                            UnitRemoveAbility(that.to, |A16F|)
                            UnitRemoveAbility(that.to, |B06C|)
                            Mark(that.to, "致盲", false)
                            KillmanaLose(that)
                        end
                    end
                )
            elseif this.event == "获得技能" then
                --被动效果
                this.skillfunc = Event("技能效果",
                    function(data)
                        if this.unit == data.from then
                            local ap = GetAP(data.to)
                            if ap == 0 then return end
                            local d = (this:get(4) + this:get(5)) * ap
                            if data.dot then
                                d = d / 3
                            end
                            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayTarget.mdl", data.to, "overhead"))
                            Damage(this.unit, data.to, d, false, true, {aoe = data.aoe, dot = data.dot, damageReason = this.name})
                        end
                    end
                )
            elseif this.event == "失去技能" then
                Event("-技能效果", this.skillfunc)
            elseif (this.event == "停止施放" and this.type[1] == "主动" and this.spellflag) or this.event == "关闭技能" then
                if IsUnitAlive(this.unit) then
                    RemoveUnit(this.areaunit)
                    local t = GetTime() - this.spellflag --吟唱时间
                    t = this:get(1) + t * this:get(2) --debuff持续时间
                    local p = GetOwningPlayer(this.unit)
                    local mana = this:get(3)
                    local cool = this:get(3)
                    forRange(this.unit, this:get("area"),
                        function(u)
                            if IsHeroUnitId(GetUnitTypeId(u)) and EnemyFilter(p, u) then
                                SkillEffect{
                                    name = this.name,
                                    from = this.unit,
                                    to = u,
                                    data = this,
                                    aoe = true,
                                    code = function(data)
                                        KillmanaUnit{
                                            from = data.from,
                                            to = data.to,
                                            time = t,
                                            mana = mana,
                                            cool = cool,
                                            aoe = true            
                                        }
                                    end
                                }
                            end
                        end
                    )
                end
            elseif this.event == "发动技能" then
                this.areaunit = CreateModle("war3mapImported\\unstableconcoctionrangedisplay3.mdl", this.unit, {size = this:get("area") / 710})
            elseif this.event == "研发" then
                this.type = {"开关"}
            end
        end
    }
    
    --强制咏唱
    InitSkill{
        name = "强制咏唱",
        type = {"主动"},
        ani = "spell",
        art = {"BTNFeedBack.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {110, 140, 170, 200},
        cool = 30,
        area = 600,
        cast = 0.3,
        dur = {5, 10, 15, 20},
        tip = "\
|cff00ccff主动|r: 茵蒂克丝在敌人的术式中插入自己的术式,发动时移除友方单位身上的负面状态并持续冻结/|cffffcc00击晕|r周围的技能弹道/召唤单位.\
|cff00ccff被动|r: 茵蒂克丝的保护友方单位免受弱小的法术伤害,增加他们的抗性.\n\
|cff00ffcc技能|r: 无目标\n\
|cffffcc00抗性增加|r: %s\n\
|cff888888冻结与击晕时间均为%s秒,判定周期为%s秒\n处于冻结状态的弹道无法移动,也不会产生命中判定",
        researchtip = "技能弹道冻结时间延长为2秒(意味着即使影响区域不再覆盖被冻结了的弹道,它依然会被继续冻结2秒)",
        data = {
            {5, 10, 15, 20}, --抗性1
            0.1, --击晕周期2
            0.05, --判定周期3
        },
        events = {"获得技能", "失去技能", "发动技能"},
        code = function(this)
            if this.event == "获得技能" then
                UnitAddAbility(this.unit, |A16G|)
                this.group = {}
                this.nowant = 0
                local p = GetOwningPlayer(this.unit)
                this.timer = Loop(1,
                    function()
                        for _, u in ipairs(this.group) do
                            Ant(u, -this.nowant)
                        end
                        this.group = {}
                        this.nowant = this:get(1)
                        if IsUnitAlive(this.unit) then
                            forRange(this.unit, this:get("area"),
                                function(u)
                                    if IsUnitAlly(u, p) and EnemyFilter(p, u, {["友军"] = true}) then
                                        Ant(u, this.nowant)
                                        table.insert(this.group, u)
                                    end
                                end
                            )
                        end
                    end
                )
            elseif this.event == "失去技能" then
                DestroyTimer(this.timer)
                for _, u in ipairs(this.group) do
                    SetAnt(u, -this.nowant)
                end
            elseif this.event == "发动技能" then
                local area = this:get("area")
                local m = CreateModle("war3mapImported\\unstableconcoctionrangedisplay3.mdl", this.unit, {size = area / 710})
                local time = this:get("dur")
                local flash = this:get(3)
                local timed = 0
                local p = GetOwningPlayer(this.unit)
                local pause = this:get(2)
                local pause2 = pause
                if this.research then
                    pause2 = 2
                end
                Loop(flash,
                    function()
                        timed = timed + flash
                        if IsUnitAlive(this.unit) then
                            SetUnitX(m, GetUnitX(this.unit))
                            SetUnitY(m, GetUnitY(this.unit))
                            forRange(this.unit, area,
                                function(u)
                                    if GetUnitTypeId(u) == |e031| then
                                        local move = Mark(u, "移动器")
                                        if move and not move.attack and IsUnitEnemy(move.from, p) then
                                            move.pause = pause2
                                        end
                                    elseif IsUnitType(u, UNIT_TYPE_SUMMONED) and IsUnitEnemy(u, p) then
                                        SkillEffect{
                                            name = this.name,
                                            from = this.unit,
                                            to = u,
                                            data = this,
                                            code = function(data)
                                                StunUnit{
                                                    from = data.from,
                                                    to = data.to,
                                                    time = pause,
                                                    aoe = true
                                                }
                                            end
                                        }
                                    end
                                end
                            )
                        else
                            timed = time
                        end
                        if timed >= time then
                            EndLoop()
                            RemoveUnit(m)
                        end
                    end
                )
                forRange(this.unit, area,
                    function(u)
                        if IsUnitAlly(u, P) and EnemyFilter(p, u, {["友军"] = true}) then
                            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl", u, "overhead"))
                            CleanUnit{
                                from = this.unit,
                                to = u,
                                debuff = true
                            }
                        end
                    end
                )
            end
        end
    }
    
    --自动书记
    InitSkill{
        name = "自动书记",
        type = {"主动"},
        ani = "stand",
        art = {"BTNshuji.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {150, 275, 400},
        cool = 180,
        icon = 2,
        cast = 0.3,
        area = 750,
        tip = "\
茵蒂克丝进入自动书记状态,展开的圣乔治领域会消耗法力值来吸收部分伤害.自动书记将自动扫描并标记威胁最高的一个敌人,持续对其造成伤害.在此期间你可以使用|cffffcc00龙王叹息|r,效果持续直到排除了附近的威胁.\n\
|cff00ffcc技能|r: 无目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00吸收系数|r: %s%%\
|cffffcc00每点魔法抵消伤害|r: %s\
|cffffcc00持续伤害|r: %s(|cffff00ff+%d|r)\n\
|cff888888扫描角度为%s,转动角度为%s\n只寻找视野内的威胁,持续%s秒没有找到则效果结束",
        researchtip = {
            "对被标记的单位造成的伤害提高100%",
            "自动书记状态下免疫\"无法控制\"的效果(如晕眩,吹风,变羊等)",
            "变为被动技能永久处于开启状态,失去标记效果.龙王叹息的冷却延长为60秒",
        },
        data = {
            50, --吸收系数1
            {1.5, 1.75, 2}, --抵消伤害2
            {20, 60, 100}, --持续伤害3
            function(ap, ad, data) --持续伤害加成4
                return ap * 0.4 + ad * 0.6 --AP加成为0.4,--AD加成为0.6
            end,
            30, --扫描角度5
            120, --转动角度6
            10, --关闭判定7
        },
        events = {"失去技能", "获得技能", "发动技能", "研发"},
        code = function(this)
            if this.event == "研发" then
                if this.lastResearch == 3 then
                    this.type[1] = "被动"
                    local ab = japi.EXGetUnitAbility(this.unit, this.id)
                    japi.EXSetAbilityDataReal(ab, 1, 105, 1000000)
                    japi.EXSetAbilityState(ab, 1, 10000) --将被动技能设置为永久处于冷却状态
                    RemoveSkill(this.unit, "龙王叹息")
                    AddSkill(this.unit, "龙王叹息", {lv = this.lv, cool = 60})
                    this.open2 = true
                    this.open = false
                    local e = AddSpecialEffectTarget("DeathSeal.mdx", this.unit, "origin")
                    Loop(0.1,
                        function()
                            if this.open2 then
                                Mark(this.unit, "弹道模型", this.missile[GetRandomInt(1, this.missilecount)])
                            else
                                DestroyEffect(e)
                                Mark(this.unit, "弹道模型", false)
                            end
                        end
                    )
                end
            elseif this.event == "失去技能" then
                RemoveSkill(this.unit, "龙王叹息")
                Event("-伤害减免", "-伤害加成", "-无法控制", this.skillfunc)
                this.open = false
                this.open2 = false
            elseif this.event == "获得技能" then
                this.skillfunc = Event("伤害减免", "伤害加成", "无法控制",
                    function(damage)
                        if not this.open then return end
                        if damage.event == "伤害减免" then
                            if this.unit == damage.to then
                                local mana = GetUnitState(damage.to, UNIT_STATE_MANA)
                                local d = math.min(damage.damage, damage.mdamage * this:get(1) * 0.01) --最多可吸收的伤害
                                local x = this:get(2)
                                local nmana = d / x --吸收这些伤害所需要的法力
                                if nmana > mana then
                                    nmana = mana
                                    d = nmana * x
                                end
                                damage.damage = damage.damage - d
                                SetUnitState(damage.to, UNIT_STATE_MANA, mana - nmana)
                            end
                        elseif damage.event == "伤害加成" then
                            if this.unit == damage.from and this.markunit == damage.to and this.research and this.research[1] then
                                damage.damage = damage.damage + damage.odamage * 1
                                DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\StaffOfPurification\\PurificationTarget.mdl", damage.to, "origin"))
                            end
                        elseif damage.event == "无法控制" then
                            if this.unit == damage.to and this.research and this.research[2] then
                                return true
                            end
                        end
                    end
                )
                
                AddSkill(this.unit, "龙王叹息", {type = {"被动"}, lv = this.lv})
                
                --弹道模型
                this.missile ={
                    "Abilities\\Weapons\\ZigguratFrostMissile\\ZigguratFrostMissile.mdl",
                    "Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl",
                    "Abilities\\Weapons\\DemonHunterMissile\\DemonHunterMissile.mdl",
                    "Units\\Creeps\\StormPandarenBrewmaster\\StormPandarenBrewmaster_Missile.mdl",
                    "war3mapImported\\Shadow_Strikes_State_Hand.mdx",
                    "Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl",
                    "Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile.mdl",
                    "Abilities\\Weapons\\BallsOfFireMissile\\BallsOfFireMissile.mdl",
                    "Fireball.mdx",
                    "Abilities\\Spells\\Other\\Volcano\\VolcanoMissile.mdl",
                    "Units\\Creeps\\FirePandarenBrewmaster\\FirePandarenBrewmaster_Missile.mdl",
                    "Abilities\\Weapons\\LordofFlameMissile\\LordofFlameMissile.mdl",
                    "Objects\\InventoryItems\\BundleofGifts\\BundleofGifts.mdl",
                    "Abilities\\Weapons\\GreenDragonMissile\\GreenDragonMissile.mdl",
                    "units\\critters\\Sheep\\Sheep.mdl",
                    "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl",
                    "Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl",
                    "war3mapImported\\WaterHands.mdx",
                    "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilMissile.mdl",
                    "Units\\Creeps\\EarthPandarenBrewmaster\\EarthPandarenBrewmaster_Missile.mdl",
                    "Abilities\\Weapons\\LavaSpawnMissile\\LavaSpawnBirthMissile.mdl",
                    "Abilities\\Weapons\\IllidanMissile\\IllidanMissile.mdl",
                    "sonicbreathstream.mdx",
                }
                this.missilecount = #this.missile
            elseif this.event == "升级技能" then
                local skill = findSkillData(this.unit, "龙王叹息")
                skill.lv = this.lv
                SetSkillTip(this.unit, skill.y)
                RefreshTips(this.unit)
            elseif this.event == "发动技能" then
                RemoveSkill(this.unit, "龙王叹息")
                AddSkill(this.unit, "龙王叹息", {lv = this.lv})
                local area = this:get("area")
                local m = CreateModle("war3mapImported\\unstableconcoctionrangedisplay3.mdl", this.unit, {size = area / 710})
                local face = GetUnitFacing(this.unit)
                local x, y, z = GetUnitX(this.unit), GetUnitY(this.unit), getZ(this.unit)
                local a = this:get(5)
                local a1 = face - a / 2
                local p1 = MovePoint({x, y}, {area, a1})
                local l1 = AddLightningEx('LN01', false, x, y, z, p1[1], p1[2], z)
                local a2 = face + a / 2
                local p2 = MovePoint({x, y}, {area, a2})
                local l2 = AddLightningEx('LN01', false, x, y, z, p2[1], p2[2], z)
                if IsUnitVisible(m, SELFP) then
                    SetLightningColor(l1, 1, 0, 0, 1)
                    SetLightningColor(l2, 1, 0, 0, 1)
                else
                    SetLightningColor(l1, 1, 0, 0, 0)
                    SetLightningColor(l2, 1, 0, 0, 0)
                end
                local fa = 0.025 * this:get(6)
                this.open = true
                local e = AddSpecialEffectTarget("DeathSeal.mdx", this.unit, "origin")
                local count = 0
                local closecount = 0
                local maxclosecount = this:get(7)
                Loop(0.025,
                    function()
                        if IsUnitAlive(this.unit) and this.open then
                            --移动扫描器特效
                            face = face - fa
                            local x, y, z = GetUnitX(this.unit), GetUnitY(this.unit), getZ(this.unit)
                            SetUnitX(m, x)
                            SetUnitY(m, y)
                            local a1 = face - a / 2
                            local p1 = MovePoint({x, y}, {area, a1})
                            MoveLightningEx(l1, false, x, y, z, p1[1], p1[2], z)
                            local a2 = face + a / 2
                            local p2 = MovePoint({x, y}, {area, a2})
                            MoveLightningEx(l2, false, x, y, z, p2[1], p2[2], z)
                            if IsUnitVisible(m, SELFP) then
                                SetLightningColor(l1, 1, 0, 0, 1)
                                SetLightningColor(l2, 1, 0, 0, 1)
                            else
                                SetLightningColor(l1, 1, 0, 0, 0)
                                SetLightningColor(l2, 1, 0, 0, 0)
                            end
                            
                            --寻找单位
                            local p = GetOwningPlayer(this.unit)
                            if this.markunit then
                                if IsUnitDead(this.markunit) or GetBetween(this.unit, this.markunit) > area or IsUnitInvisible(this.markunit, p) then
                                    this.markunit = nil
                                    DestroyEffect(this.markeffect)
                                    this.markeffect = nil
                                end
                            end
                            
                            local nu = this.markunit
                            forRange(this.unit, area,
                                function(u)
                                    if IsUnitVisible(u, p) and EnemyFilter(p, u) and math.A2A(face, GetBetween(this.unit, u, true)) < a / 2 then
                                        if nu then
                                            if IsHero(nu) then
                                                if IsHero(u) then
                                                    if GetBetween(this.unit, u) < GetBetween(this.unit, nu) then
                                                        nu = u
                                                    end
                                                end
                                            elseif IsUser(nu) then
                                                if IsHero(u) then
                                                    nu = u
                                                elseif IsUser(u) then
                                                    if GetBetween(this.unit, u) < GetBetween(this.unit, nu) then
                                                        nu = u
                                                    end
                                                end
                                            else
                                                if IsHero(u) then
                                                    nu = u
                                                elseif IsUser(u) then
                                                    nu = u
                                                else
                                                    if GetBetween(this.unit, u) < GetBetween(this.unit, nu) then
                                                        nu = u
                                                    end
                                                end
                                            end                                                
                                        else
                                            nu = u
                                        end
                                    end
                                end
                            )
                            if nu ~= this.markunit then
                                this.markunit = nu
                                if this.markeffect then
                                    DestroyEffect(this.markeffect)
                                end
                                this.markeffect = AddSpecialEffectTarget("snipe target.mdx", nu, "chest")
                            end
                            
                            Mark(this.unit, "弹道模型", this.missile[GetRandomInt(1, this.missilecount)])
                            
                            --造成伤害
                            count = count + 1
                            if this.markunit then
                                closecount = 0
                                if count % 20 == 0 then
                                    Damage(this.unit, this.markunit, (this:get(3) + this:get(4)) / 2, false, true, {damageReason = this.name})
                                end
                            else
                                closecount = closecount + 0.025
                                if closecount >= maxclosecount then
                                    this.open = false
                                end
                            end
                        else
                            EndLoop()
                            DestroyLightning(l1)
                            DestroyLightning(l2)
                            RemoveUnit(m)
                            DestroyEffect(e)
                            this.markunit = nil
                            if this.markeffect then
                                DestroyEffect(this.markeffect)
                                this.markeffect = nil
                            end
                            this.open = false
                            Mark(this.unit, "弹道模型", false)
                            RemoveSkill(this.unit, "龙王叹息")
                            AddSkill(this.unit, "龙王叹息", {type = {"被动"}, lv = this.lv})
                        end
                    end
                )
            end
        end
    }
    
    --龙王叹息
    InitSkill{
        name = "龙王叹息",
        type = {"主动", 2},
        ani = "stand channel",
        art = {"BTNResurrection.blp"}, --左边是学习,右边是普通.不填右边视为左边
        cast = 0.3,
        cool = 1,
        rng = 1500,
        time = 3600,
        area = 250,
        tip = "\
分析出敌人的能力对敌人有针对性的进行魔法攻击,对一条直线上的敌人造成惊人伤害\n\
|cff00ffcc技能|r: 点目标\
|cff00ffcc伤害|r: 法术\n\
|cffffcc00每秒伤害|r: %s(|cffff00ff+%d|r)\
|cffffcc00生效延迟|r: %s\
|cffffcc00每秒法力消耗|r: %s%%\n\
|cff888888%s距离后伤害开始减少,最远处为%s%%伤害\n每0.25秒造成一次伤害",
        data = {
            {75, 150, 225}, --伤害1
            function(ap, ad, data) --伤害加成2
                return ap * 0.75 + ad * (-0.1 + data.lv * 0.3) --AP加成为0.75,AD加成为0.2/0.5/0.8
            end,
            1, --生效延迟3
            {5, 6, 7}, --每秒法力消耗4
            750, --伤害减少距离5
            50, --最远处所能造成的伤害6
        },
        events = {"发动技能", "停止施放"},
        code = function(this)
            if this.event == "发动技能" then
                local face = GetBetween(this.unit, this.target, true)
                local mp = MovePoint(this.unit, {75, face})
                local m1 = CreateUnitAtLoc(Player(15), |hprt|, mp, face)
                local m2 = CreateUnitAtLoc(Player(15), |e00K|, mp, face)
                SetUnitAnimation(m1, "birth")
                SetUnitTimeScale(m1, 4)
                SetUnitTimeScale(m2, 0)
                UnitShareVision(m2, PA[1], true)
                UnitShareVision(m2, PB[1], true)
                this.unit1 = m1
                this.unit2 = m2
                this.count = 0
                local d = (this:get(1) + this:get(2)) * 0.25
                local area = this:get("area")
                local rng = this:get("rng") + 100
                local rng2 = this:get(5)
                local d2 = this:get(6)
                local tt = this:get(3) / 0.25
                local mana = this:get(4) * 0.25
                local p = GetOwningPlayer(this.unit)
                this.timer = Loop(0.25,
                    function()
                        this.count = this.count + 1
                        if this.count >= tt then
                            --光柱模型
                            if this.count == tt then
                                SetUnitTimeScale(m2, 1)
                            elseif this.count > tt + 4 then
                                if this.count % 2 == 1 then
                                    SetUnitTimeScale(m2, 1)
                                else
                                    SetUnitTimeScale(m2, -1)
                                end
                            end
                            local mp = MovePoint(this.unit, {75, face})
                            SetUnitXY(m1, mp)
                            SetUnitXY(m2, mp)
                            --伤害
                            forSeg(this.unit, MovePoint(this.unit, {rng, face}), area,
                                function(u)
                                    if EnemyFilter(p, u) then
                                        local d = d
                                        local dis = GetBetween(this.unit, u)
                                        if dis > rng2 then
                                            d =  d * ((rng - dis) / (rng - rng2) * d2 * 0.005 + 0.5)
                                        end
                                        SkillEffect{
                                            name = this.name,
                                            from = this.unit,
                                            to = u,
                                            data = this,
                                            aoe = true,
                                            code = function(data)
                                                Damage(data.from, data.to, d, false, true, {aoe = true, damageReason = this.name})
                                                if IsUnitDead(data.to) and not IsHero(data.to) then
                                                    SetUnitVertexColor(data.to, 40, 40, 40, 255)
                                                    DestroyEffect(AddSpecialEffectTarget("Environment\\LargeBuildingFire\\LargeBuildingFire1.mdl", data.to, "chest"))
                                                end
                                            end
                                        }
                                    end
                                end
                            )
                            --法力消耗
                            SetUnitState(this.unit, UNIT_STATE_MANA, GetUnitState(this.unit, UNIT_STATE_MANA) - mana * GetUnitState(this.unit, UNIT_STATE_MAX_MANA) * 0.01)
                            if GetUnitState(this.unit, UNIT_STATE_MANA) == 0 then
                                IssueImmediateOrder(this.unit, "stop")
                            end
                        end
                    end
                )
            elseif this.event == "停止施放" then
                if this.spellflag then
                    KillUnit(this.unit1)
                    KillUnit(this.unit2)
                    if this.count > this:get(3) / 0.25 then
                        SetUnitTimeScale(this.unit2, 2)
                    end
                    DestroyTimer(this.timer)
                end
            end
        end
    }
