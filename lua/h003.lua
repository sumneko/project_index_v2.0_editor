    
    HeroName[3] = "土御门元春"
    HeroMain[3] = "力量"
    HeroType[3] = |Edem|
    RDHeroType[3] = |h013|
    HeroTypePic[3] = "ReplaceableTextures\\CommandButtons\\BTNTuYuMen.blp"
    HeroSize[3] = 0.99
    LearnSkillId = {|A14Q|, |A14R|, |A14S|, |A14T|}
    
    --黑水术式
    InitSkill{
        name = "黑水术式",
        type = {"主动", 1},
        ani = "spell",
        art = {"BTNRejuvenationPotion.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {90, 120, 150, 180},
        cool = {16, 14, 12, 10},
        rng = 600,
        cast = 0.3,
        dur = 6,
        targs = GetTargs("地面,空中,敌人,有机生物"),
        tip = "\
土御门最擅长使用的术式,以自身受到反噬为代价使敌人|cffffcc00中毒|r,|cffffcc00减速|r与|cffffcc00致盲|r.\n\
|cff00ffcc技能|r: 单位目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00总计伤害|r: %s(|cff0000ff+%d|r)\
|cffffcc00降低移动速度|r: %s%%\
|cffffcc00降低命中|r: %s%%\
|cffffcc00反噬伤害|r: %s\n\
|cff888888可以驱散\n弹道飞行速度为%s",
        researchtip = "黑水术式会在不同的单位之间弹射2次(即最多击中3个目标)",
        data = {
            {60, 120, 180, 240}, --总计伤害1
            function(ap) --伤害加成
                return ap * 1.5 --AP加成为1.5
            end,
            {20, 30, 40, 50}, --降低移动速度3
            {40, 50, 60, 70}, --降低命中率4
            {60, 120, 180, 240}, --反噬伤害5
            1000, --弹道飞行速度6
        },
        events = {"发动技能"},
        code = function(this)
            Wait(0,
                function()
                    Damage(this.unit, this.unit, this:get(5), false, true, {damageReason = this.name})
                end
            )
            local g = {}
            local count = 2
            local moverdata = {
                modle = "Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl",
                size = 1.5,
                z = 100,
                tz = 100,
                from = this.unit,
                target = this.target,
                speed = this:get(6),
                data = {damage = this:get(1) + this:get(2), slow = this:get(3), miss = this:get(4), dur = this:get("dur")},
            }
            local hitfunc
            hitfunc = function(move)
                if IsUnitAlive(move.target) then
                    SkillEffect{
                        name = this.name,
                        from = move.from,
                        to = move.target,
                        data = this,
                        code = function(data)
                            PoisonUnit{
                                from = data.from,
                                to = data.to,
                                damage = move.data.damage,
                                time = move.data.dur,
                                damageReason = this.name
                            }
                            SlowUnit{
                                from = data.from,
                                to = data.to,
                                attack = move.data.slow,
                                time = move.data.dur,
                            }
                            BlindUnit{
                                from = data.from,
                                to = data.to,
                                miss = move.data.miss,
                                time = move.data.dur
                            }
                        end
                    }
                end
                if this.research and count > 0 then
                    g[move.target] = true
                    count = count - 1
                    local g2 = {}
                    forRange(move.target, this:get("rng"),
                        function(u)
                            if not g[u] and EnemyFilter(GetOwningPlayer(move.from), u) then
                                table.insert(g2, u)
                            end
                        end
                    )
                    local n = #g2
                    if n == 0 then return end
                    moverdata.from = move.from
                    moverdata.source = move.target
                    moverdata.target = g2[GetRandomInt(1, n)]
                    MoverEx(table.copy(moverdata, false), nil, hitfunc)
                end
            end
            MoverEx(table.copy(moverdata, false), nil, hitfunc)
        end,
    }
    
    --体术达人
    InitSkill{
        name = "体术达人",
        type = {"主动"},
        ani = "attack slam",
        cast = 0.5,
        art = {"BTNDrunkenDodge.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = 50,
        cool = {15, 14, 13, 12},
        tip = "\
|cff00ccff主动|r: 土御门对前方最近的一个单位造成高额伤害并将其击晕.\
|cff00ccff被动|r: 土御门可以闪躲敌人的攻击.每当成功闪躲一次攻击,此技能的冷却时间就会减少.\n\
|cff00ffcc技能|r: 无目标\n|cff00ffcc伤害|r: 物理\n\
|cffffcc00伤害|r: %s(|cffff0000+%d|r)\
|cffffcc00击晕时间|r: %s\
|cffffcc00闪躲率|r: %s%%\
|cffffcc00减少冷却(英雄)|r: %s\
|cffffcc00减少冷却(非英雄)|r: %s\n\
|cff888888最大范围为%s\n可以触发攻击效果与武器效果",
        researchtip = "对背对着你的单位必定暴击",
        data = {
            {140, 220, 300, 380}, --伤害1
            function(ap, ad, data) --伤害加成2
                return ad * (0.75 + data.lv * 0.25) --AD加成为 1/1.25/1.5/1.75
            end,
            {0.75, 1.25, 1.75, 2.25}, --击晕时间3
            {10, 15, 20, 25}, --闪躲率4
            {2.5, 3.0, 3.5, 4.0}, --减少冷却(英雄)5
            {1.25, 1.50, 1.75, 2.00}, --减少冷却(非英雄)6
            200, --最大范围7
        },
        events = {"获得技能", "发动技能", "失去技能"},
        code = function(this)
            if this.event == "发动技能" then
                local p1 = GetOwningPlayer(this.unit)
                local g = {}
                forRange(this.unit, this:get(7),
                    function(u)
                        if EnemyFilter(p1, u) then
                            table.insert(g, u)
                        end
                    end
                )
                if #g == 0 then return end
                local point = MovePoint(this.unit, {this:get(7), GetUnitFacing(this.unit)})
                local r = 9999999
                local l = this:get(7)
                local uu
                for _, u in ipairs(g) do
                    if GetBetween(u, point) <= l then
                        local l = GetBetween(u, this.unit)
                        if l < r then
                            r = l
                            uu = u
                        end
                    end
                end
                if uu then
                    SkillEffect{
                        name = this.name,
                        from = this.unit,
                        to = uu,
                        data = this,
                        code = function(data)
                            local flag
                            if this.research and math.A2A(GetUnitFacing(data.to), GetUnitFacing(data.from)) < 60 then
                                flag = true
                                Crit(data.from, 100)
                            end
                            Damage(data.from, data.to, this:get(1) + this:get(2), true, false, {attack = true, weapon = true, damageReason = this.name})
                            if flag then
                                Crit(data.from, -100)
                            end
                            if IsUnitAlive(data.to) then
                                StunUnit{
                                    from = data.from,
                                    to = data.to,
                                    time = this:get(3)
                                }
                            end
                        end
                    }
                end
            elseif this.event == "获得技能" then
                this.skillfunc = Event("伤害无效", "伤害无效后",
                    function(damage)
                        if damage.weapon and this.unit == damage.to then
                            if damage.event == "伤害无效" then
                                if Random(this:get(4)) then
                                    damage.dodgReason = "闪躲"
                                    return true
                                end
                            elseif damage.event == "伤害无效后" then
                                if this.unit == damage.to and damage.dodgReason == "闪躲" then
                                    local ab = japi.EXGetUnitAbility(this.unit, this.id)
                                    local cd = japi.EXGetAbilityState(ab, 1) --获取冷却时间
                                    if cd > 0 then
                                        if IsUnitType(damage.from, UNIT_TYPE_HERO) then
                                            cd = cd - this:get(5)
                                        else
                                            cd = cd - this:get(6)
                                        end
                                        japi.EXSetAbilityState(ab, 1, cd)
                                    end
                                end
                            end
                        end
                    end
                )
            elseif this.event == "失去技能" then
                Event("-伤害无效", "-伤害无效后", this.skillfunc)
            end
        end
    }
    
    --肉体再生
    InitSkill{
        name = "肉体再生",
        type = {"被动"},
        art = {"BTNPASRTZS.blp", "BTNRTZS.blp"},
        tip = "\
作为能力者土御门元春拥有LV0的肉体再生能力,可以在受到超过当前生命值一定比例的伤害后高速愈合伤口,完全回复此次伤害\n\
|cff00ffcc技能|r: 被动\n\
|cffffcc00伤害判定|r: %s%%\
|cffffcc00回血速度|r: %s(|cffff00ff+%d|r)\n\
|cff888888多次触发,回复总量可以叠加\
不可驱散",
        researchtip = "可以超额回复50%",
        data = {
            {15, 14, 13, 12}, --判定系数1
            {5, 10, 15, 20}, --回复速度2
            function(ad, ap) --恢复速度加成
                return ad * 0.1 + ap * 0.1 --AD加成0.15,AP加成0.1
            end,
        },
        events = {"获得技能", "失去技能"},
        code = function(this)
            if this.event == "获得技能" then
                this.recover = 0
                this.skillfunc = Event("伤害后",
                    function(damage)
                        if this.unit == damage.to and damage.damage > this:get(1) * 0.01 * GetUnitState(this.unit, UNIT_STATE_LIFE) then
                            if this.research then
                                this.recover = this.recover + damage.damage * 1.5
                            else
                                this.recover = this.recover + damage.damage
                            end
                            if this.recover > 0 and GetUnitAbilityLevel(this.unit, |A0RZ|) == 0 then
                                UnitAddAbility(this.unit, |A0RZ|)
                                Loop(0.5,
                                    function()
                                        local r = math.min(this.recover, this:get(2) + this:get(3))
                                        this.recover = this.recover - r
                                        if this.recover < 0.001 then
                                            EndLoop()
                                            UnitRemoveAbility(this.unit, |A0RZ|)
                                            UnitRemoveAbility(this.unit, |B053|)
                                        end
                                        Heal(this.unit, this.unit, r, {healReason = this.name})
                                    end
                                )
                            end
                        end
                    end
                )
            elseif this.event == "失去技能" then
                Event("-伤害后", this.skillfunc)
            end
        end,
    }
    
    --赤术式
    InitSkill{
        name = "赤术式",
        type = {"主动", 2, 3}, --点目标,图标可见+目标选取图像
        ani = "spell",
        art = {"BTNWallOfFire.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {150, 300, 450},
        cool = {150, 135, 120},
        rng = "全地图",
        cast = 0.3,
        dur = {1.25, 1.75, 2.25},
        area = 450,
        tip = "\
释放一个蕴含庞大能量的赤术式,可无限制距离击毁目标范围内的一切敌友单位并|cffffcc00击晕|r.\n\
|cff00ffcc技能|r: 点目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00造成伤害|r: %s(|cff0000ff+%d|r)\
|cffffcc00反噬伤害|r: %s\n\
|cff888888对建筑有效\n弹道速度为%d\n友方单位受到50%%的效果\n单位0.5秒内被击飞200距离\n获得落点的视野\n施法距离超过1000时,友方可以在落点看到一个魔法效果",
        researchtip = {
            "不对友方单位造成影响",
            "燃烧被击中的单位,在10秒内累计造成150%的伤害.取代直接造成的伤害",
            "弹道飞行速度变为3倍",
        },
        data = {
            {175, 300, 425}, --伤害1
            function(ap) --伤害加成2
                return ap * 2 --AP加成为2
            end,
            {100, 175, 250}, --反噬伤害3
            2000, --弹道飞行速度4
        },
        events = {"发动技能"},
        code = function(this)
            --反噬
            Wait(0,
                function()
                    Damage(this.unit, this.unit, this:get(3), false, true, {damageReason = this.name})
                end
            )
            local filter
            if this.research and this.research[1] then
                filter = {["建筑"] = true}
            else
                filter = {["友军"] = true, ["建筑"] = true}
            end
            local speed = this:get(4)
            if this.research and this.research[3] then
                speed = speed * 3
            end
            --移动效果
            Mover({
                modle = "Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile.mdl",
                size = 3,
                z = 200,
                from = this.unit,
                target = this.target,
                speed = speed,
                data = {damage = this:get(1) + this:get(2), time = this:get("dur"), area = this:get("area")},
                }, nil,
                function(move)
                    local p1 = GetOwningPlayer(this.unit)
                    for i = 0, 7 do
                        DummySkill{point = move.target, skill = |A00I|, order = "breathoffrost", target = MovePoint(move.target, {100, i * 45})}
                    end
                    forRange(move.target, move.data.area,
                        function(u2)
                            if EnemyFilter(p1, u2, filter) then
                                SkillEffect{
                                    name = this.name,
                                    from = move.from,
                                    to = u2,
                                    data = this,
                                    aoe = true,
                                    filter = "建筑",
                                    code = function(data)
                                        local d, t
                                        if IsUnitAlly(data.to, GetOwningPlayer(data.from)) then
                                            d = move.data.damage * 0.5
                                            t = move.data.time * 0.5
                                        else
                                            d = move.data.damage
                                            t = move.data.time
                                        end
                                        if this.research and this.research[2] then
                                            FireUnit{
                                                from = data.from,
                                                to = data.to,
                                                damage = d * 1.5,
                                                time = 10,
                                                aoe = true,
                                                damageReason = this.name
                                            }
                                        else
                                            Damage(data.from, data.to, d, false, true, {aoe = true, damageReason = this.name})
                                        end
                                        StunUnit{
                                            from = data.from,
                                            to = data.to,
                                            time = t,
                                            aoe = true,
                                        }
                                        Mover{
                                            unit = data.to,
                                            angle = GetBetween(move.target, data.to, true),
                                            distance = 200,
                                            time = 0.5,
                                            high = 200,
                                        }
                                    end
                                }
                            end
                        end
                    )
                end
            )
            --落点特效
            local target = this.target
            local distance = GetBetween(this.unit, target)
            local time = distance / speed --撞击时间
            local area = this:get("area")
            local see = CreateFogModifierRadiusLoc(GetOwningPlayer(this.unit), FOG_OF_WAR_VISIBLE, target, area + 100, true)
            FogModifierStart(see)
            Wait(time + 1,
                function()
                    DestroyFogModifier(see)
                end
            )
            if time > 0.5 then
                local modles = {}
                local mod1, mod2 = "", ""
                if IsGod() or IsPlayerAlly(GetOwningPlayer(this.unit), SELFP) then
                    mod1 = "Doodads\\Cinematic\\GlowingRunes\\GlowingRunes2.mdl"
                    mod2 = "Doodads\\Cinematic\\GlowingRunes\\GlowingRunes0.mdl"
                end
                for i = 1, 18 do
                    modles[i] = CreateModle(mod1, MovePoint(target, {area - 50, 70 + 20 * i}))
                end
                local i = 1
                LoopRun(time / 18,
                    function()
                        if i == 19 then
                            EndLoop()
                            for i = 1, 18 do
                                RemoveUnit(modles[i])
                            end
                            return
                        end
                        local p = GetUnitLoc(modles[i])
                        RemoveUnit(modles[i])
                        modles[i] = CreateModle(mod2, p)
                        i = i + 1
                    end
                )
            end
        end,
    }
