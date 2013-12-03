    
    HeroName[11] = "御坂20001"
    HeroMain[11] = "智力"
    HeroType[11] = |Hjai|
    RDHeroType[11] = |h00U|
    HeroTypePic[11] = "ReplaceableTextures\\CommandButtons\\BTNlo.blp"
    HeroSize[11] = 1.1
    LearnSkillId = {|A19N|, |A19O|, |A19P|, |A19Q|}

    
    --范围电击
    InitSkill{
        name = "范围电击",
        type = {"主动", 2, 3},
        ani = "spell",
        art = {"BTNMonsoon.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {100, 110, 120, 130},
        cool = 15,
        rng = 800,
        area = 150,
        dur = {1, 1.5, 2, 2.5},
        cast = 0.3,
        tip = "\
释放一道闪电击中目标区域,对附近的单位造成伤害并|cffffcc00麻痹|r.\n\
|cff00ffcc技能|r: 点目标\
|cff00ffcc伤害|r: 法术\n\
|cffffcc00伤害|r: %s(|cff0000ff+%d|r)\n\
|cff888888闪电被截断则在截断处生效|r",
        researchtip = "被闪电贯穿的单位也受到同样效果,闪电宽度为200",
        data = {
            {60, 120, 180, 240}, --伤害1
            function(ap, ad) --伤害加成2
                return ap * 1
            end,
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                --技能效果
                local d = this:get(1) + this:get(2)
                local t = this:get("dur")
                local g = {}
                local se = function(u)
                    if g[u] then return end
                    g[u] = true
                    SkillEffect{
                        from = this.unit,
                        to = u,
                        name = this.name,
                        data = this,
                        aoe = true,
                        code = function(data)
                            --麻痹
                            BenumbUnit{
                                from = data.from,
                                to = data.to,
                                time = t,
                                aoe = true,
                            }
                            --伤害
                            Damage(this.unit, u, d, false, true, {aoe = true, damageReason = this.name})
                        end
                    }
                end
                --先创建闪电效果
                local l = Lightning{
                    from = this.unit,
                    name = 'CLPB',
                    check = true,
                    x1 = GetUnitX(this.unit),
                    y1 = GetUnitY(this.unit),
                    z1 = GetUnitZ(this.unit) + 75,
                    x2 = GetLocationX(this.target),
                    y2 = GetLocationY(this.target),
                    z2 = GetLocationZ(this.target) + 75,
                    cut = true,
                    time = 0.5
                }
                local target = {l.x2, l.y2}
                TempEffect(target, "Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl")
                forRange(target, this:get("area"),
                    function(u)
                        if EnemyFilter(this.player, u) then
                            se(u)
                        end
                    end
                )
                if this.research then
                    forSeg(this.unit, target, 200,
                        function(u)
                            if EnemyFilter(this.player, u) then
                                se(u)
                            end
                        end
                    )
                end
            end
        end
    }
    
    --静电力场
    InitSkill{
        name = "静电力场",
        type = {"开关"},
        ani = "stand",
        art = {"BTNFeedBack.blp", "BTNFeedBack.blp", "BTNWispSplode.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = 150,
        dur = 60,
        area = 600,
        tip = "\
产生大范围的静电力场,降低附近单位的移动速度并麻痹初次受到影响的单位.受到静电力场作用的单位将会承受额外伤害.\n\
|cff00ffcc技能|r: 无目标\
|cff00ffcc伤害|r: 法术\n\
|cffffcc00移速降低|r: %s\
|cffffcc00麻痹时间|r: %s\
|cffffcc00额外伤害|r: %s(|cff0000ff+%d|r)\n\
|cff888888可以提前关闭\n单次受到的伤害大于20点才会触发额外伤害\n该技能的冷却时间等同于开启的时间",
        researchtip = "单位被麻痹时受到伤害,数值相当于额外伤害的5倍",
        data = {
            {50, 75, 100, 125}, --移速降低1
            {0.5, 0.75, 1, 1.25}, --麻痹时间2
            {10, 20, 30, 40}, --额外伤害3
            function(ap) --额外伤害加成4
                return ap * 0.2
            end
        },
        events = {"发动技能", "关闭技能"},
        code = function(this)
            if this.event == "发动技能" then
                local area = this:get("area")
                this.opentime = GetTime()
                this.units = {}
                this.timer = Loop(0.25,
                    function()
                        local t = this:get(2)
                        local ms = this:get(1)
                        local g = {}
                        forRange(this.unit, area,
                            function(u)
                                if EnemyFilter(this.player, u) then
                                    if this.units[u] == nil then
                                        --表示是初次受到影响
                                        SkillEffect{
                                            name = this.name .. "(麻痹)",
                                            from = this.unit,
                                            to = u,
                                            data = this,
                                            aoe = true,
                                            code = function(data)
                                                --麻痹
                                                BenumbUnit{
                                                    from = data.from,
                                                    to = data.to,
                                                    time = t,
                                                    aoe = true,
                                                }
                                                --伤害
                                                if this.research then
                                                    Damage(data.from, data.to, 5 * (this:get(3) + this:get(4)), false, true, {aoe = true, damageReason = this.name})
                                                end
                                            end
                                        }
                                        this.units[u] = 0
                                    end
                                    if ms > this.units[u] then
                                        MoveSpeed(u, this.units[u] - ms)
                                        this.units[u] = ms
                                    end
                                    g[u] = true
                                end
                            end
                        )
                        --移除离开区域单位的负面效果
                        for u, ms in pairs(this.units) do
                            if not g[u] then
                                MoveSpeed(u, ms)
                                this.units[u] = 0
                            end
                        end
                    end
                )
                --额外伤害
                this.skillfunc = Event("伤害效果",
                    function(damage)
                        if damage.damageReason ~= this.name and damage.damage > 20 and this.units[damage.to] and this.units[damage.to] > 0 then
                            Damage(this.unit, damage.to, this:get(3) + this:get(4), false, true, {aoe = true, damageReason = this.name})
                        end
                    end
                )
            elseif this.event == "关闭技能" then
                for u, ms in pairs(this.units) do
                    MoveSpeed(u, ms)
                end
                DestroyTimer(this.timer)
                Event("-伤害效果", this.skillfunc)
                this.freshcool = GetTime() - this.opentime
            end
        end
    }
    
    --风之钝器-散裂
    InitSkill{
        name = "风之钝器-散裂",
        type = {"被动"},
        art = {"BTNBash.blp"},
        area = 500,
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
                                                time = time
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
                            if dis > 200 then
                                a = a + (1 - (dis - 200) / (600 - 200)) * 0.5
                            elseif dis < 600 then
                                a = a + 0.5
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
    
