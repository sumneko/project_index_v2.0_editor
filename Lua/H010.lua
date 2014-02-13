    
    HeroName[10] = "前方之风"
    HeroMain[10] = "敏捷"
    HeroType[10] = |Oshd|
    RDHeroType[10] = |h01C|
    HeroTypePic[10] = "ReplaceableTextures\\CommandButtons\\BTNQianFang.blp"
    HeroSize[10] = 1.2
    LearnSkillId = {|A17P|, |A17Q|, |A17R|, |A17S|}
    
    --风之钝器-锤击
    InitSkill{
        name = "风之钝器-锤击",
        type = {"主动", 1, 3},
        ani = "spell one",
        art = {"BTNStormBolt.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {140, 155, 170, 185},
        cool = {18, 17, 16, 15},
        rng = 525,
        cast = 0.3,
        area = 300,
        targs = GetTargs("地面,空中,敌人,有机生物"),
        tip = "\
使用神之右席特有术式,创造出风之钝器精准的命中敌方目标造成伤害并|cffffcc00击晕|r.风之钝器之后爆裂,对附近的单位造成一半的伤害并|cffffcc00减速|r.\n\
|cff00ffcc技能|r: 单位目标\
|cff00ffcc伤害|r: 物理\n\
|cffffcc00持续时间|r: %s\
|cffffcc00伤害|r: %s(|cffff00ff+%d|r)\
|cffffcc00降低移速|r: %s%%\n\
|cff888888弹道飞行速度为%s",
        researchtip = "对附近单位造成全额的伤害",
        data = {
            {1.4, 1.6, 1.8, 2}, --持续时间1
            {75, 150, 225, 300}, --伤害2
            function(ap, ad) --伤害加成3
                return ad * 0.5 + ap * 0.5
            end,
            {60, 70, 80, 90}, --降低移速4
            1000, --弹道飞行速度5
        },
        events = {"发动技能"},
        code = function(this)
            local d = this:get(2) + this:get(3)
            local t = this:get(1)
            local ms = this:get(4)
            local area = this:get("area")
            local dd = 0.5
            if this.research then
                dd = 1
            end
            if this.event == "发动技能" then
                 MoverEx({
                        modle = "Abilities\\Spells\\Human\\StormBolt\\StormBoltMissile.mdl",
                        size = 2,
                        z = 100,
                        tz = 100,
                        from = this.unit,
                        target = this.target,
                        speed = this:get(5),
                    }, nil,
                    function(move)
                        if IsUnitAlive(move.target) then
                            SkillEffect{
                                name = this.name,
                                from = move.from,
                                to = move.target,
                                data = this,
                                code = function(data)
                                    StunUnit{
                                        from = data.from,
                                        to = data.to,
                                        time = t
                                    }
                                    Damage(data.from, data.to, d, true, false, {damageReason = this.name})
                                end
                            }
                        end
                        local p = GetOwningPlayer(move.from)
                        forRange(move.target, area,
                            function(u)
                                if u ~= this.target and EnemyFilter(p, u) then
                                    SkillEffect{
                                        name = this.name .. "(爆裂效果)",
                                        from = move.from,
                                        to = u,
                                        data = this,
                                        aoe = true,
                                        code = function(data)
                                            SlowUnit{
                                                from = data.from,
                                                to = data.to,
                                                time = t,
                                                aoe = true,
                                                move = ms
                                            }
                                            Damage(data.from, data.to, d * dd, true, false, {aoe = true, damageReason = this.name})
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
    
    --冰箭风暴
    InitSkill{
        name = "冰箭风暴",
        type = {"主动", 2, 3},
        ani = "spell",
        art = {"BTNBlizzard.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = 125,
        cool = 10,
        time = 6,
        rng = 700,
        dur = 6,
        area = 400,
        tip = "\
前方使空气中的水汽凝结成冰,对范围内的随机位置进行冰箭打击,造成伤害并|cffffcc00减速|r.若被冰箭连续击中则减速效果将叠加.\n\
|cffffcc00需要持续施法\
|cff00ffcc技能|r: 点目标\
|cff00ffcc伤害|r: 法术\n\
|cffffcc00冰箭间隔|r: %s\
|cffffcc00冰箭影响范围|r: %s\
|cffffcc00伤害|r: %s(|cffff00ff+%d|r)\
|cffffcc00降低攻速与移速|r: %s%%\
|cffffcc00叠加减速|r: %s%%\
|cffffcc00减速持续时间|r: %s\n\
|cff888888技能发动后立即出现第一支冰箭\n冰箭落地需要%s秒时间\n可对建筑造成伤害",
        researchtip = "冰箭落下的间隔与总持续时间减半",
        data = {
            0.5, --间隔1
            225, --冰箭影响范围2
            {40, 70, 100, 130}, --伤害3
            function(ap, ad) --伤害加成4
                return ap * 0.25 + ad * 0.25
            end,
            {35, 40, 45, 50}, --初始减速5
            {10, 12, 14, 16}, --叠加减速6
            3, --减速持续时间7
            0.7, --落地时间8
        },
        events = {"发动技能", "停止施放", "研发"},
        code = function(this)
            if this.event == "发动技能" then
                local a1 = this:get("area")
                local a2 = a1 * 0.5
                local a3 = this:get(2)
                local t = this:get(7)
                local g = {}
                local p = GetOwningPlayer(this.unit)
                this.timer = LoopRun(this:get(1),
                    function()
                        local loc = MovePoint(this.target, {GetRandomInt(0, a1), GetRandomInt(0, 360)})
                        local unit = CreateModle("Abilities\\Spells\\Human\\Blizzard\\BlizzardTarget.mdl", loc, {size = 3, time = 5})
                        local p = GetOwningPlayer(this.unit)
                        local d = this:get(3) + this:get(4)
                        local s1 = this:get(5)
                        local s2 = this:get(6)
                        local time = this:get(7)
                        Wait(this:get(8),
                            function()
                                DestroyEffect(AddSpecialEffectLoc("Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl", loc))
                                forRange(loc, a3,
                                    function(u)
                                        if EnemyFilter(p, u, {["建筑"] = true}) then
                                            SkillEffect{
                                                name = this.name,
                                                from = this.unit,
                                                to = u,
                                                data = this,
                                                aoe = true,
                                                code = function(data)
                                                    if not IsUnitType(data.to, UNIT_TYPE_STRUCTURE) then
                                                        if g[data.to] then
                                                            g[data.to] = g[data.to] + s2
                                                        else
                                                            g[data.to] = s1
                                                        end
                                                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdl", data.to, "origin"))
                                                        SlowUnit{
                                                            from = data.from,
                                                            to = data.to,
                                                            attack = g[data.to],
                                                            speed = g[data.to],
                                                            time = t,
                                                            aoe = true
                                                        }
                                                    end
                                                    Damage(data.from, data.to, d, false, true, {aoe = true, damageReason = this.name})
                                                end
                                            }
                                        end
                                    end
                                )
                            end
                        )
                    end
                )
            elseif this.event == "停止施放" then
                DestroyTimer(this.timer)
            elseif this.event == "研发" then
                this.time = 3
                this.data[1] = 0.25
            end
        end
    }
    
    --风之钝器-散裂
    InitSkill{
        name = "风之钝器-散裂",
        type = {"被动"},
        art = {"BTNBash.blp"},
        area = 400,
        tip = "\
前方之风的攻击有几率产生弹射,对附近的其他单位也造成同样的伤害.在击中减速或晕眩的单位时,该几率将增加.\n\
|cff00ffcc技能|r: 武器效果\
|cff00ffcc伤害|r: 物理\n\
|cffffcc00弹射几率|r: %s%%\
|cffffcc00几率增加|r: %s%%\n\
|cff888888弹射攻击带有攻击效果与武器效果\n可以击中魔免单位或建筑单位",
        researchtip = "可以重复弹射同一个单位",
        data = {
            {45, 53, 59, 63}, --弹射几率1
            {13, 14, 15, 16}, --增幅几率2
        },
        count = 0,
        events = {"获得技能", "失去技能"},
        code = function(this)
            if this.event == "获得技能" then
                this.skillfunc = Event("伤害效果",
                    function(damage)
                        if damage.from == this.unit and (damage.weapon or damage.damageReason == this.name) then
                            local dg = damage.damagedGroup or {}
                            if not this.research then
                                dg[damage.to] = true
                            end
                            local a = this:get(1)
                            if GetUnitAbilityLevel(damage.to, |BPSE|) == 1 or GetUnitAbilityLevel(damage.to, |B02R|) == 1 then
                                a = a + this:get(2)
                            end
                            if Random(a) then
                                local p = GetOwningPlayer(damage.from)
                                local g = {}
                                forRange(damage.to, this:get("area"),
                                    function(u)
                                        if u ~= damage.to and not dg[u] and EnemyFilter(p, u, {["魔免"] = true, ["建筑"] = true}) then
                                            table.insert(g, u)
                                        end
                                    end
                                )
                                local count = #g
                                local target
                                if count > 0 then
                                    target = g[GetRandomInt(1, count)]
                                else
                                    return
                                end
                                local moved = damage.mover or {}
                                local u1 = getObj(slk.unit, GetUnitTypeId(damage.from))
                                local u2 = getObj(slk.unit, GetUnitTypeId(target))
                                local move = {
                                    modle = moved.modle or Mark(damage.from, "弹道模型") or u1.Missileart or "Abilities\\Spells\\Human\\StormBolt\\StormBoltMissile.mdl",
                                    from = damage.to,
                                    target = target,
                                    z = GetUnitZ(damage.to) + (getObj(slk.unit, GetUnitTypeId(damage.to)).impactZ or 0) * GetModleSize(damage.to),
                                    tz = (u2.impactZ or 0) * GetModleSize(target),
                                    high = moved.high or GetBetween(damage.to, target) * (u1.Missilearc or 0),
                                    size = moved.size or GetModleSize(damage.from),
                                    speed = moved.speed or u1.Missilespeed or 100,
                                    attack = true,
                                    code = function(move)
                                        Damage(move.from, move.target, damage.sdamage, true, false, {damageReason = this.name, attack = true, damagedGroup = dg})
                                    end
                                }
                                MoverEx(move, nil, move.code)
                                move.from = damage.from
                            end
                        end
                    end
                )
            elseif this.event == "失去技能" then
                Event("-伤害效果", this.skillfunc)
            end
        end
    }
    
    --天罚术式
    InitSkill{
        name = "天罚术式",
        type = {"主动"},
        ani = "spell slam",
        art = {"BTNPurge.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {150, 200, 250},
        area = 900,
        cool = 300,
        tip = "\
|cff00ccff主动|r: 降下天罚,立即|cffffcc00击晕|r附近单位并造成伤害.取决于对方的威胁程度,最多可以造成3倍的效果.\
|cff00ccff被动|r: 敌方单位对你造成伤害或技能影响时将被|cffffcc00晕眩|r,不会连续触发.受到的伤害累计达到当前生命值的10%%后,此技能冷却加速10%%.\n\
|cff00ffcc技能|r: 无目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00天罚伤害|r: %s(|cffff00ff+%d|r)\
|cffffcc00天罚晕眩|r: %s\
|cffffcc00被动晕眩|r: %s\
|cffffcc00被动间隔|r: %s\n\
|cff888888弹道速度为%s\n只影响视野内的单位",
        researchtip = {
            "天罚至少造成2倍的效果",
            "被动击晕会附带天罚的基础伤害",
            "天罚可以击中全地图视野内的敌人"
        },
        data = {
            {125, 175, 225}, --天罚伤害1
            function(ap, ad) --天罚伤害加成2
                return ap * 0.5 + ad * 0.5
            end,
            {0.75, 1, 1.25}, --天罚晕眩时间3
            0.5, --被动晕眩时间4
            {8, 7, 6}, --被动触发间隔5
            2000, --弹道速度6
        },
        events = {"获得技能", "发动技能", "失去技能"},
        code = function(this)
            if this.event == "获得技能" then
                this.md = 0
                this.units = {}
                this.skillspell = function(unit, time, damage, word, aoe)
                    local speed = this:get(6)
                    Mover({
                            modle = "Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl",
                            speed = speed,
                            from = this.unit,
                            target = unit,
                        }, nil,
                        function(move)
                            SkillEffect{
                                name = this.name,
                                from = move.from,
                                to = move.target,
                                data = this,
                                aoe = aoe,
                                code = function(data)
                                    if IsUnitAlive(move.target) then
                                        if time then
                                            StunUnit{
                                                from = data.from,
                                                to = data.to,
                                                time = time,
                                                aoe = true
                                            }
                                        end
                                        if damage then
                                            Damage(data.from, data.to, damage, false, true, {aoe = aoe, damageReason = this.name})
                                        end
                                        if word then
                                            Text{
                                                word = word,
                                                size = 16,
                                                unit = data.to,
                                                color = {100, 0, 100},
                                                life = {4, 5},
                                                speed = {30, 270},
                                                x = -50,
                                                y = -50,
                                            }
                                        end
                                    end
                                end
                            }
                        end
                    )
                end
                this.skillfunc = function(u)
                    local p = GetOwningPlayer(this.unit)
                    if IsUnitVisible(u, p) and EnemyFilter(p, u) then
                        local time = GetTime()
                        if (this.units[u] or 0) < time then
                            if this.research and this.research[2] then
                                this.skillspell(u, this:get(4), this:get(1) + this:get(2))
                            else
                                this.skillspell(u, this:get(4))
                            end
                            this.units[u] = time + this:get(5)
                        end
                    end
                end
                this.skillfunc2 = Event("伤害效果", "技能效果",
                    function(data)
                        if data.to ~= this.unit then return end
                        if data.event == "伤害效果" then
                            local damage = data
                            --加速冷却
                            this.md = this.md + damage.damage
                            local hp = GetUnitState(this.unit, UNIT_STATE_LIFE) * 0.1
                            while this.md >= hp do
                                this.md = this.md - hp
                                local ab = japi.EXGetUnitAbility(this.unit, this.id)
                                local cd = japi.EXGetAbilityState(ab, 1)
                                if cd > 0 then
                                    japi.EXSetAbilityState(ab, 1, cd * 0.9)
                                end
                            end
                            --天罚
                            this.skillfunc(damage.from)
                        elseif data.event == "技能效果" then
                            --天罚
                            this.skillfunc(data.from)
                        end
                    end
                )
            elseif this.event == "发动技能" then
                DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\Unsummon\\UnsummonTarget.mdl", this.unit, "origin"))
                local p = GetOwningPlayer(this.unit)
                local d = this:get(1) + this:get(2) --基础伤害
                local t = this:get(3) --基础晕眩时间
                local area = this:get("area")
                if this.research and this.research[3] then
                    area = 20000
                end
                forRange(this.unit, area,
                    function(u)
                        if IsUnitVisible(u, p) and EnemyFilter(p, u) then
                            local a = 1 --系数
                            --评估距离(200范围内为0.5,600范围外为0)
                            local dis = GetBetween(this.unit, u)
                            if dis < 200 then
                                a = a + 0.5
                            elseif dis < 600 then
                                a = a + (1 - (dis - 200) / (600 - 200)) * 0.5
                            end
                            --评估对方的面向角度(小于30°即为0.5, 大于90°为0)
                            local angle = GetBetween(u, this.unit, true) --对方到自己的角度
                            local face = GetUnitFacing(u)
                            local a1 = math.A2A(angle, face) --求出夹角
                            if a1 < 30 then
                                a = a + 0.5
                            elseif a1 < 90 then
                                a = a + (1 - (a1 - 30) / (90 - 30)) * 0.5
                            end
                            --评估你的面向角度(小于45°即为0.5, 大于135°为0)
                            local face2 = GetUnitFacing(this.unit)
                            local a2 = math.A2A(angle, face2)
                            if a2 < 45 then
                                a = a + 0.5
                            elseif a2 < 135 then
                                a = a + (1 - (a2 - 45) / (135 - 45)) * 0.5
                            end
                            --评估双方的生命值(对方的生命值为你的2倍以上为0.5,不足你的一半为0)
                            local a3 = GetUnitState(u, UNIT_STATE_LIFE) / GetUnitState(this.unit, UNIT_STATE_LIFE)
                            if a3 > 2 then
                                a = a + 0.5
                            elseif a3 > 0.5 then
                                a = a + ((a3 - 0.5) / (2 - 0.5)) * 0.5
                            end
                            --研发1
                            if a < 2 and this.research and this.research[1] then
                                a = 2
                            end
                            --终于可以造成伤害了
                            this.skillspell(u, t * a, d * a, string.format("×%.2f", a) , true)
                        end
                    end
                )
            elseif this.event == "失去技能" then
                Event("-伤害效果", "-技能效果", this.skillfunc2)
            end
        end
    }
    
