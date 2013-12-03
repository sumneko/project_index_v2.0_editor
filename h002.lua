    
    HeroName[2] = "上条当麻"
    HeroMain[2] = "力量"
    HeroType[2] = |Hart|
    RDHeroType[2] = |h012|
    HeroTypePic[2] = "ReplaceableTextures\\CommandButtons\\BTNShangTiao.blp"
    HeroSize[2] = 0.77
    LearnSkillId = {|A14I|, |A14J|, |A14K|, |A14L|}
    
    --上条之拳
    InitSkill{
        name = "上条之拳",
        type = {"主动", 1},
        ani = "attack slam",
        art = {"BTNquan.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {120, 140, 160, 180},
        cool = {25, 22, 19, 16},
        rng = 150,
        cast = 0.3,
        targs = GetTargs("地面,空中,敌人,有机生物"),
        tip = "\
对目标进行一次强力的脸部拳击,造成伤害并击飞.击飞过程中撞击到障碍物时将再次受到伤害与额外|cffffcc00晕眩|r.障碍物附近的敌方单位也受到同样伤害效果.\n\
|cff00ffcc技能|r: 单位目标\n|cff00ffcc伤害|r: 法术\n|cff00ffcc范围|r: %s\n\
|cffffcc00晕眩|r: %s\n|cffffcc00伤害|r: %s(|cffff0000+%d|r)\n|cffffcc00撞击晕眩|r: %s\n|cffffcc00撞击伤害|r: %s(|cff0000ff+%d|r)\n\
|cff888888击退距离为%d\n击退速度为%d\n撞击后在%s秒内移动%d距离\n技能目标是女性则收入后宫,男性则开后宫",
        researchtip = "击退距离变为2倍",
        data = {
            150, --范围1
            1.5, --晕眩时间2
            {50, 100, 150, 200}, --伤害3
            function(ap, ad) --伤害加成4
                return ad * 0.5 --ad加成0.5
            end,
            {1.25, 1.50, 1.75, 2.00}, --撞击晕眩5
            {50, 75, 100, 125}, --撞击伤害6
            function(ap, ad) --撞击伤害加成7
                return ap * 0.5 --ap加成0.5
            end,
            800, --击退距离8
            1600, --击退速度9
            0.25, --撞击飞行时间10
            100, --撞击飞行距离11
        },
        events = {"发动技能"},
        code = function(this)
            SkillEffect{
                name = this.name,
                from = this.unit,
                to = this.target,
                data = this,
                code = function(data)
                    StunUnit{ --击晕目标
                        from = data.from,
                        to = data.to,
                        time = this:get(2),
                    }
                    Damage(data.from, data.to, this:get(3) + this:get(4), false, true, {damageReason = this.name}) --造成伤害
                    local p1 = GetOwningPlayer(data.from)
                    local unitnear = function(angle)
                        local g = CreateGroup()
                        local r = false
                        GroupEnumUnitsInRange(g, GetUnitX(data.to), GetUnitY(data.to), 75, Condition(
                            function()
                                if data.to ~= GetFilterUnit() and math.A2A(angle, GetBetween(data.to, GetFilterUnit(), true)) < 90 then
                                    r = true
                                end
                            end
                        ))
                        DestroyGroup(g)
                        return r
                    end
                    local dis = this:get(8)
                    if this.research then
                        dis = dis * 2
                    end
                    Mover({    --移动
                        unit = data.to,
                        speed = this:get(9),
                        angle = GetBetween(data.from, data.to, true),
                        time = dis / this:get(9),
                        path = true,
                        move = true,
                        count = 0,
                        from = data.from,
                        },
                        function(move)
                            if move.count%5 == 0 then
                                TempEffect(move.unit, "Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl")
                            else
                                move.count = move.count + 1
                            end
                            if GetBetween({move.nx, move.ny}, move.unit) > 0.1 or unitnear(move.angle) then
                                move.stop = true
                                TempEffect({move.nx, move.ny}, "Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl")
                                local g = CreateGroup()
                                local t = this:get(5)
                                local d = this:get(6) + this:get(7)
                                local time = this:get(10)
                                local speed = this:get(11)/time
                                local p1 = GetOwningPlayer(move.from)
                                GroupEnumUnitsInRange(g, move.nx, move.ny, this:get(1), Condition(
                                    function()
                                        local u2 = GetFilterUnit()
                                        if EnemyFilter(p1, u2) then
                                            SkillEffect{
                                                name = this.name .. "(撞击)",
                                                from = data.from,
                                                to = u2,
                                                data = this,
                                                aoe = true,
                                                code = function(data)
                                                    StunUnit{
                                                        from = data.from,
                                                        to = data.to,
                                                        time = t,
                                                        aoe = true
                                                    }
                                                    Damage(data.from, data.to, d, false, true, {aoe = true, damageReason = this.name})
                                                    local a
                                                    if u2 == move.unit then
                                                        a = move.angle + 180
                                                    else
                                                        a = GetBetween(move.unit, data.to, true)
                                                    end
                                                    Mover{
                                                        unit = data.to,
                                                        speed = speed,
                                                        angle = a,
                                                        high = 200,
                                                        time = time,
                                                    }
                                                end
                                            }
                                        end
                                    end
                                ))
                                DestroyGroup(g)
                            end
                        end
                    )
                end
            }
            
        end,
    }
    
    --幻想杀手
    InitSkill{
        name = "幻想杀手",
        type = {"开关"},
        art = {"BTNshashou.blp", "BTNshashou.blp", "BTNWispSplode.blp"}, --第三个参数为关闭
        mana = {125, 130, 135, 140},
        cool = {18, 15, 12, 9},
        dur = {3, 4, 5, 6},
        tip = "\
上条举起右手,抵挡来自前方的法术攻击.在此状态下上条无法进行普通攻击.\
\
|cff00ffcc技能|r: 开关\
\
|cff888888可以提前关闭|r",
        untip = "\
关闭幻象杀手",
        researchtip = "幻想杀手状态下也可以进行普通攻击",
        data = {},
        undata = {},
        events = {"发动技能", "关闭技能", "获得技能", "失去技能"},
        code = function(this)
            if this.event == "发动技能" then
                if not this.research then
                    this.notattack = true
                    EnableAttack(this.unit, false)
                else
                    this.notattack = false
                end
                this.effect = AddSpecialEffectTarget("DivineAegis.mdx", this.unit, "chest")
                Sound(this.unit, gg_snd_Dama_dazhao)
            elseif this.event == "关闭技能" then
                if this.notattack then
                    EnableAttack(this.unit)
                end
                DestroyEffect(this.effect)
            elseif this.event == "获得技能" then
                this.skillfunc = Event("抵挡",
                    function(data)
                        if this.unit == data.to and this.openflag then
                            if math.A2A(GetUnitFacing(data.to), GetBetween(data.from, data.to, true)) > 90 then --夹角大于90
                                DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", data.to, "origin"))
                                return true
                            end
                        end
                    end
                )
            elseif this.event == "失去技能" then
                Event("-抵挡", this.skillfunc)
            end
        end,
    }
    
    --上条意志
    InitSkill{
        name = "上条意志",
        type = {"被动"},
        art = {"BTNBMZS.blp"},
        tip = "\
上条当麻的生命值越低,就越能爆发出强大的意志力继续战斗,暴击率/暴击系数/移动速度均大幅提升\
当上条受到致命伤害时会获得|cffffff00不屈|r效果,但之后上条意志将失效直到生命值回满.\n\
|cff00ffcc技能|r: 被动\n\
|cffffcc00最大提升的暴击率|r: %s%%(|cffffcc00%d|r%%)\
|cffffcc00最大提升的暴击系数|r: %s%%(|cffffcc00%d|r%%)\
|cffffcc00最大提升的移动速度|r: %s(|cffffcc00%d|r)\n\
|cff888888满血时没有效果\
发动不屈时锁定为最大效果\
不屈结束后效果锁定为0,直到生命值回满\
不屈效果发动时你不会死亡",
        researchtip = "当该技能有效时,你至少拥有25%的加成",
        data = {
            {50, 60, 70, 80},
            0,
            {20, 30, 40, 50},
            0,
            {120, 130, 140, 150},
            0,
        },
        dur = {2.0, 2.5, 3.0, 3.5},
        events = {"获得技能", "失去技能"},
        code = function(this)
            if this.event == "获得技能" then
                this.skilltimer = Loop(1,
                    function()
                        local wound = 1 - GetUnitState(this.unit, UNIT_STATE_LIFE) / GetUnitState(this.unit, UNIT_STATE_MAX_LIFE)
                        if this.research and wound < 0.25 then
                            wound = 0.25
                        end
                        if this.state == "发动中" then
                            wound = 1
                        elseif this.state == "无效" then
                            if GetUnitState(this.unit, UNIT_STATE_LIFE) == GetUnitState(this.unit, UNIT_STATE_MAX_LIFE) then
                                this.art = {"BTNBMZS.blp"}
                                this.state = "未发动"
                            else
                                wound = 0
                            end
                        end
                        local lbjl = wound * this:get(1)
                        local lbjxs = wound * this:get(3)
                        local lms = wound * this:get(5)
                        Crit(this.unit, lbjl - this.data[2], lbjxs - this.data[4])
                        MoveSpeed(this.unit, lms - this.data[6])
                        this.data[2] = lbjl
                        this.data[4] = lbjxs
                        this.data[6] = lms
                        SetSkillTip(this.unit, this.y)
                        RefreshTips(this.unit)
                    end
                )
                this.state = "未发动"
                
                this.skillfunc = Event("伤害致死",
                    function(damage)
                        if this.unit == damage.to then
                            if this.state == "未发动" then
                                this.state = "发动中"
                                this.effect = AddSpecialEffectTarget("Abilities\\Spells\\Human\\Resurrect\\ResurrectCaster.mdl", this.unit, "origin")
                                Wait(this:get("dur"),
                                    function()
                                        DestroyEffect(this.effect)
                                        this.state = "无效"
                                        this.art = {"BTNBMZS3.blp"}
                                        SetSkillTip(this.unit, this.y)
                                        RefreshTips(this.unit)
                                    end
                                )
                            end
                            if this.state == "发动中" then
                                return true   --返回true表示发动不屈效果
                            end
                        end
                    end
                )
            elseif data.event == "失去技能" then
                DestroyTimer(this.skilltimer)
                Event("-伤害致死", this.skillfunc)
            end
        end,
    }
    
    --神净
    InitSkill{
        name = "神净",
        type = {"主动"},
        ani = "spell",
        art = {"BTNWhirlwind.blp"}, --左边是学习,右边是普通.不填右边视为左边
        icon = 2, --占用技能图标,默认为1
        mana = {200, 350, 500},
        cool = 120,
        dur = 10,
        cast = 0.3,
        tip = "\
不明的能量从上条的右手上喷发,使得上条可以攻击更远处的敌人,攻击时燃烧小范围内敌人的法力值并造成等值伤害.\
在此期间你可以发动技能|cffffcc00讨魔|r.\
\
|cff00ffcc技能|r: 无目标\
|cff00ffcc伤害|r: 法术\
|cff00ffcc范围|r: %s\
\
|cffffcc00射程增加|r:%s\
|cffffcc00燃烧法力(对方当前法力值)|r:%s%%\
\
|cff888888可以使用副技能立即结束神净\
依然视为近战攻击",
        researchtip = {
            "发动讨魔也不会立即结束神净(意味着你可以在一次神净的持续时间内多次使用讨魔)",
            "持续时间变为3倍,但是你不再能使用讨魔",
            "虽然燃烧法力依然是按照其当前法力值计算,但造成的伤害将按照其最大法力值计算"
        },
        data = {
            300, --范围
            {128, 256, 512}, --射程增加
            {10, 15, 20}, --燃烧法力
        },
        events = {"获得技能", "升级技能", "发动技能", "失去技能"},
        code = function(this)
            if this.event == "发动技能" then
                this.effect = AddSpecialEffectTarget("war3mapImported\\Shadow_Strikes_State_Hand.mdl", this.unit, "hand,right")
                this.open = true
                this.rngup = this:get(2)
                this.timer = this:get("dur")
                if this.research and this.research[2] then
                    this.timer = this.timer * 3
                end
                AttackRange(this.unit, this.rngup)
                local func = Event("发动英雄技能",
                    function(data)
                        if data.unit == this.unit and data.name == "讨魔" then
                            if not (this.research and this.research[1]) then
                                this.open = false
                            end
                        end
                    end
                )
                Loop(0.1,
                    function()
                        this.timer = this.timer - 0.1
                        if this.timer <= 0 then  --一定要用小于等于,因为实数运算无法精确到整数
                            this.open = false
                        end
                        if not this.open then
                            AttackRange(this.unit, - this.rngup)
                            DestroyEffect(this.effect)
                            EndLoop()
                            if this.skillfunc then
                                Event("-伤害效果", this.skillfunc)
                                this.skillfunc = nil
                            end
                            if not RemoveSkill(this.unit, "讨魔") then return end
                            AddSkill(this.unit, "讨魔", {type = {"被动"}, art = {"BTNBMZS3.blp"}, lv = this.lv})
                            Event("-发动英雄技能", func)
                        end
                    end
                )
                if not (this.research and this.research[2]) and RemoveSkill(this.unit, "讨魔") then
                    AddSkill(this.unit, "讨魔", {lv = this.lv})
                end
                
                this.skillfunc = Event("伤害效果",
                    function(damage)
                        if damage.attack and this.unit == damage.from and this.open then
                            TempEffect(damage.to, "BlackExplosion.mdx")
                            local p1 = GetOwningPlayer(this.unit)
                            local x = this:get(3) * 0.01
                            forRange(damage.to, this:get(1),
                                function(u)
                                    if EnemyFilter(p1, u) then
                                        SkillEffect{
                                            name = this.name,
                                            from = this.unit,
                                            to = u,
                                            data = this,
                                            aoe = true,
                                            code = function(data)
                                                local r = GetUnitState(data.to, UNIT_STATE_MANA) * x
                                                SetUnitState(data.to, UNIT_STATE_MANA, GetUnitState(data.to, UNIT_STATE_MANA) - r)
                                                if this.research and this.research[3] then
                                                    r = GetUnitState(data.to, UNIT_STATE_MAX_MANA) * x
                                                end
                                                Damage(data.from, data.to, r, false, true, {aoe = true, damageReason = this.name})
                                            end
                                        }
                                    end
                                end
                            )
                        end
                    end
                )
            elseif this.event == "获得技能" then
                AddSkill(this.unit, "讨魔", {type = {"被动"}, art = {"BTNBMZS3.blp"}, lv = this.lv})
            elseif this.event == "升级技能" then
                local skill = findSkillData(this.unit, "讨魔")
                skill.lv = this.lv
                SetSkillTip(this.unit, skill.y)
                RefreshTips(this.unit)
            elseif this.event == "失去技能" then
                RemoveSkill(this.unit, "讨魔")
            end
        end,
    }
    
    --讨魔
    InitSkill{
        name = "讨魔",
        type = {"主动", 2},
        ani = "attack slam",
        art = {"BTNWhirlwind.blp"}, --左边是学习,右边是普通.不填右边视为左边
        dur = {2.0, 2.5, 3.0},
        cast = 0.3,
        rng = 2000,
        cool = 6,
        tip = "\
上条施放出所有的能量,对前方的敌人造成伤害,并使他们陷入|cffffcc00末日|r状态\
\
|cff00ffcc技能|r: 点目标\
|cff00ffcc伤害|r: 法术\
|cff00ffcc宽度|r: %s\
\
|cffffcc00基础伤害|r:%s(|cff0000ff+%d|r)\
|cffffcc00每损失1点法力额外造成的伤害|r:%s\
|cffffcc00最大射程|r:%s\
\
|cff888888发动后立即结束神净\
末日状态下的单位所有技能失效且无法使用物品\
能量移动速度为%d,碰撞到单位时会延迟%s秒",
        data = {
            450, --宽度1
            {100, 250, 400}, --基础伤害2
            function(ap, ad) --基础伤害加成3
                return ap * 1.5 --AP加成150
            end,
            {0.4, 0.7, 1.0}, --每损失1点法力额外造成的伤害4
            2000, --最大射程5
            500, --弹道速度6
            0.1, --碰撞到单位时的延迟7
        },
        events = {"发动技能"},
        code = function(this)
            local r = this:get(1) / 2
            local t = this:get(7)
            local p1 = GetOwningPlayer(this.unit)
            local d = this:get(2) + this:get(3)
            local x = this:get(4)
            local doom = this:get("dur")
            Mover({
                from = this.unit,
                modle = "war3mapImported\\Shadow_Strikes_State_Hand.mdl",
                speed = this:get(6),
                z = 100,
                angle = GetBetween(this.unit, this.target, true),
                time = this:get(5) / this:get(6),
                },
                function(move)
                    if move.count % 5 == 0 then --每5个周期(0.1秒)判定一次
                        forRange(move.unit, r,
                            function(u)
                                if not Mark(move.unit, u) and EnemyFilter(p1, u) then
                                    Mark(move.unit, u, true)
                                    SkillEffect{
                                        name = this.name,
                                        from = move.from,
                                        to = u,
                                        data = this,
                                        aoe = true,
                                        code = function(data)
                                            local d2 = d + x * (GetUnitState(data.to, UNIT_STATE_MAX_MANA) - GetUnitState(data.to, UNIT_STATE_MANA))
                                            move.pause = move.pause + t
                                            Damage(data.from, data.to, d2, false, true, {aoe = true, damageReason = this.name})
                                            DoomUnit{
                                                from = data.from,
                                                to = data.to,
                                                time = doom,
                                                aoe = true,
                                            }
                                        end
                                    }
                                end
                            end
                        )
                    end
                end
            )
        end,
    }
