    
    HeroName[8] = "御坂美琴"
    HeroMain[8] = "智力"
    HeroType[8] = |Hkal|
    RDHeroType[8] = |h01P|
    HeroTypePic[8] = "ReplaceableTextures\\CommandButtons\\BTNMeiQin.blp"
    HeroSize[8] = 1.3
    LearnSkillId = {|A17H|, |A17I|, |A17J|, |A17K|}
    
    --闪电攻击
    Event("远程攻击弹道", "伤害后",
        function(move)
            if GetUnitTypeId(move.from) == HeroType[8] then
                if move.event == "远程攻击弹道" then
                    local l = Lightning{
                        from = move.from,
                        name = 'CHIM',
                        check = true,
                        x1 = move.x + GetUnitX(move.from),
                        y1 = move.y + GetUnitY(move.from),
                        z1 = move.z + GetUnitZ(move.from),
                        x2 = GetUnitX(move.target),
                        y2 = GetUnitY(move.target),
                        z2 = GetUnitZ(move.target) + move.tz,
                        time = 0.25,
                        cut = true,
                    }
                elseif move.event == "伤害后" then
                    if move.weapon then
                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\ChimaeraLightningMissile\\ChimaeraLightningMissile.mdl", move.to, "chest"))
                    end
                end
            end
        end
    )
    
    --超电磁炮
    InitSkill{
        name = "超电磁炮",
        type = {"主动", 2}, --点目标
        ani = "spell",
        art = {"BTNdiancipao2.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {120, 140, 160, 180},
        cool = 20,
        rng = {1700, 1800, 1900, 2000},
        cast = 0,
        time = 0.8,
        area = 150,
        tip = "\
|cff00ccff主动|r: 将一枚游戏代币灌注强大的电磁力以三倍音速射出,对一条直线上的敌人造成伤害并|cffffcc00击晕|r.\
|cff00ccff被动|r: 技能造成伤害时加速技能冷却\n\
|cff00ffcc技能|r: 点目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00造成伤害|r: %s(|cff0000ff+%d|r)\
|cffffcc00晕眩时间|r: %s\
|cffffcc00施法延迟|r: %s\
|cffffcc00加速冷却|r: %s%%\n\
|cff888888施法延迟中技能已经进入冷却\n弹道飞行速度为%s\n必须要接到硬币才能发动\n可对建筑造成伤害",
        researchtip = "即使技能施放失败,只要捡回硬币就可以刷新技能冷却并回复一半的法力",
        data = {
            {70, 140, 210, 280}, --伤害1
            function(ap, ad, data) --伤害加成2
                return ap * (0.5 + 0.1 * data.lv) --AP加成0.6/0.7/0.8/0.9
            end,
            {0.9, 1.1, 1.3, 1.5}, --晕眩时间3
            0.6, --施法延迟4
            {1, 1.5, 2, 2.5}, --加速冷却5
            2000, --飞行速度6
        },
        events = {"获得技能", "失去技能", "发动技能"},
        code = function(this)
            if this.event == "获得技能" then
                this.skillfunc = Event("伤害效果",
                    function(damage)
                        if not damage.weapon and not damage.item then
                            if this.unit == damage.from then
                                local x = this:get(5) * 0.01
                                local time = GetTime()
                                for y = 1, 6 do
                                    local that = findSkillData(this.unit, y)
                                    if that then
                                        if that.targetcooltime and that.targetcooltime > time then
                                            that.targetcooltime = that.targetcooltime - (that.targetcooltime - time) * x
                                            local ab = japi.EXGetUnitAbility(this.unit, that.id)
                                            local cd = japi.EXGetAbilityState(ab, 1)
                                            if cd > 0 and cd < 600 then
                                                japi.EXSetAbilityState(ab, 1, math.max(that.targetcooltime - time, 0))
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                )
            elseif this.event == "失去技能" then
                Event("-伤害效果", this.skillfunc)
            elseif this.event == "发动技能" then
                --抛硬币  考虑了一下物理引擎地图内不是很常用,所以就先不统一函数了
                SetUnitTimeScale(this.unit, 0.65)
                local move = {}
                move.angle = GetBetween(this.unit, this.target, true)
                move.x = GetUnitX(this.unit) + 35 * Cos(move.angle)
                move.y = GetUnitY(this.unit) + 35 * Sin(move.angle)
                move.z = GetUnitZ(this.unit) + 100 * GetModleSize(this.unit)
                move.modle = "Abilities\\Weapons\\ProcMissile\\ProcMissile.mdl"
                move.unit = CreateUnit(Player(15), |e030|, move.x, move.y, move.angle)
                SetUnitZ(move.unit, move.z)
                move.effect = AddSpecialEffectTarget(move.modle, move.unit, "origin")
                move.size = 0.5
                SetUnitScale(move.unit, move.size, move.size, move.size)
                move.time = this:get(4) / 2
                move.high = 500
                move.flash = 0.02
                move.speed = move.high * move.flash / move.time
                move.g = - move.speed / move.time * move.flash
                
                local getbackflag
                
                Loop(move.flash,
                    function()
                        if getbackflag and GetBetween(move.unit, this.unit) < 100 then
                            EndLoop()
                            DestroyEffect(move.effect)
                            RemoveUnit(move.unit)
                            local ab = japi.EXGetUnitAbility(this.unit, this.id)
                            japi.EXSetAbilityState(ab, 1, 0)
                            SetUnitState(this.unit, UNIT_STATE_MANA, this:get("mana") * 0.5 + GetUnitState(this.unit, UNIT_STATE_MANA))
                            return
                        end
                        if move.stop then
                            EndLoop()
                            return
                        end
                        if move.z > getZ(move.unit) then
                            move.z = move.z + move.speed
                            move.speed = move.speed + move.g
                            SetUnitZ(move.unit, move.z)
                        else
                            --落地
                            if not move:code() then
                                EndLoop()
                                move:End()
                            end
                        end
                    end
                )
                
                move.End = function(move)
                    Wait(3,
                        function()
                            DestroyEffect(move.effect)
                            RemoveUnit(move.unit)
                        end
                    )
                end
                
                move.code = function(move)
                    move.speed = -move.speed * 0.6
                    move.z = getZ(move.unit) + 1
                    return move.speed > 8
                end
                
                Wait(this:get(4),
                    function()
                        SetUnitTimeScale(this.unit, 1)
                        if this.spellflag then
                            move.stop = true
                            local area = this:get("area")
                            local p = GetOwningPlayer(this.unit)
                            local time = this:get(3)
                            local d = this:get(1) + this:get(2)
                            local x, y, z = GetUnitX(this.unit), GetUnitY(this.unit), GetUnitZ(move.unit)
                            local l1 = AddLightningEx("LN00", false, x, y, z, x, y, z)
                            SetLightningColor(l1, 1, 0, 0, 1)
                            local l2 = AddLightningEx("LN01", false, x, y, z, x, y, z)
                            SetLightningColor(l2, 0.5, 1, 0, 1)
                            Mover({
                                    modle = "shishi.mdl",
                                    from = this.unit,
                                    z = GetUnitZ(move.unit) - GetUnitZ(this.unit),
                                    speed = this:get(6),
                                    angle = move.angle,
                                    distance = this:get("rng"),
                                    aoe = true,
                                    g = {}
                                },
                                function(move2)
                                    local x1, y1, z1 = GetUnitX(move2.unit), GetUnitY(move2.unit), z
                                    SetUnitX(move.unit, x1)
                                    SetUnitY(move.unit, y1)
                                    MoveLightningEx(l1, false, x, y, z, x1, y1, z1)
                                    MoveLightningEx(l2, false, x, y, z, x1, y1, z1)
                                    if move2.count % 5 == 0 then
                                        forRange(move.unit, area,
                                            function(u)
                                                if not move2.g[u] then
                                                    move2.g[u] = true
                                                    if EnemyFilter(p, u, {["建筑"] = true}) then
                                                        SkillEffect{
                                                            name = this.name,
                                                            from = move2.from,
                                                            to = u,
                                                            data = this,
                                                            aoe = true,
                                                            filter = "建筑",
                                                            code = function(data)
                                                                if not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                                                                    StunUnit{
                                                                        from = data.from,
                                                                        to = data.to,
                                                                        time = time,
                                                                        aoe = true
                                                                    }
                                                                    Mover{
                                                                        unit = data.to,
                                                                        angle = move.angle,
                                                                        distance = 200,
                                                                        time = time,
                                                                        high = 200,
                                                                    }
                                                                end
                                                                DestroyEffect(AddSpecialEffectTarget("war3mapImported\\ChainLightning_Impact_Chest.mdx", data.to, "chest"))
                                                                Damage(data.from, data.to, d, false, true, {aoe = true, damageReason = this.name})
                                                            end
                                                        }
                                                    end
                                                end
                                            end
                                        )
                                    end
                                end,nil,
                                function(move2)
                                    RemoveUnit(move.unit)
                                    RemoveUnit(move2.unit)
                                    DestroyEffect(move.effect)
                                    local i = 1
                                    Loop(0.02,
                                        function()
                                            i = i - 0.01
                                            SetLightningColor(l1, 1, 0, 0, i)
                                            SetLightningColor(l2, 0.5, 1, 0, i)
                                            if i < 0.01 then
                                                EndLoop()
                                                DestroyLightning(l1)
                                                DestroyLightning(l2)
                                            end
                                        end
                                    )
                                end
                            )
                        elseif this.research then
                            getbackflag = true
                        end
                    end
                )
            end
        end
    }
    
    --静电超载
    InitSkill{
        name = "静电超载",
        type = {"主动", 2}, --点目标
        ani = "stand",
        art = {"BTNJDCZ.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {120, 100, 80, 60},
        cool = 15,
        rng = {400, 475, 550, 625},
        cast = 0,
        time = 0,
        area = 175,
        dur = {30, 40, 50, 60},
        tip = "\
|cff00ccff主动|r: 将自己包裹在雷电,利用磁力向前突进.静电能量会增加伤害.\
|cff00ccff被动|r: 每次使用英雄技能获得一个静电能量,在你进行攻击时静电能量也会自由攻击附近的敌人.\n\
|cff00ffcc技能|r: 点目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00突进伤害|r: %s(|cff0000ff+%d|r)\
|cffffcc00静电能量加成|r: %s%%\
|cffffcc00静电能量伤害|r: %s(|cffff0000+%d|r)\n\
|cff888888突进速度为%s\n静电能量的攻击范围为%s,弹道速度为%s\n静电能量的攻击可以触发攻击效果",
        researchtip = "静电能量的攻击范围变为2倍",
        data = {
            {30, 60, 90, 120}, --伤害1
            function(ap) --伤害加成2
                return ap * 0.5 --AP加成0.5
            end,
            25, --加成3
            {10, 20, 30, 40}, --静电能量伤害4
            function(ap, ad) --静电伤害加成5
                return ad * 0.3
            end,
            1500, --突进速度6
            400, --攻击范围7
            700, --弹道速度8
        },
        events = {"失去技能", "获得技能", "发动技能"},
        code = function(this)
            if this.event == "失去技能" then
                Event("-发动英雄技能", "-死亡", "-伤害效果", this.skillfunc)
            elseif this.event == "获得技能" then
                this.units = {} --用于存放静电
                
                this.skillfunc = Event("发动英雄技能", "死亡", "伤害效果",
                    function(data)
                        if data.event == "发动英雄技能" then
                            if this.unit == data.unit then
                                --获得静电
                                local r = GetRandomReal(50, 150) --环绕半径
                                local s = -GetRandomReal(60, 120) * 0.02 --环绕速度(顺时针)
                                local a = GetRandomReal(0, 360) --当前所在角度
                                local u = CreateModle("Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl", MovePoint(this.unit, {r, a}), {size = 1, time = this:get("dur")})
                                Mark(u, "攻击伤害", this:get(4) + this:get(5))
                                SetUnitFlyHeight(u, GetUnitFlyHeight(this.unit) + 75, 0)
                                table.insert(this.units, u)
                                Loop(0.02,
                                    function()
                                        if IsUnitAlive(u) then
                                            a = a + s
                                            SetUnitXY(u, MovePoint(this.unit, {r, a}))
                                            SetUnitFlyHeight(u, GetUnitFlyHeight(this.unit) + 75, 0)
                                        else
                                            table.remove2(this.units, u)
                                            RemoveUnit(u)
                                            EndLoop()
                                        end
                                    end
                                )
                            end
                        elseif data.event == "死亡" then
                            if this.unit == data.unit then
                                for _, u in ipairs(this.units) do
                                    KillUnit(u)
                                end
                            end
                        elseif data.event == "伤害效果" then
                            if data.weapon then
                                if this.unit == data.from then
                                    local area = this:get(7)
                                    if this.research then
                                        area = area * 2
                                    end
                                    local speed = this:get(8)
                                    local p = GetOwningPlayer(this.unit)
                                    for _, u in ipairs(this.units) do
                                        if IsUnitAlive(u) then
                                            local d = Mark(u, "攻击伤害")
                                            local g = {}
                                            forRange(u, area,
                                                function(u2)
                                                    if EnemyFilter(p, u2, {["建筑"] = true}) then
                                                        table.insert(g, u2)
                                                    end
                                                end
                                            )
                                            local count = #g
                                            if count > 0 then
                                                local i = GetRandomInt(1, count)
                                                local move = MoverEx({
                                                    modle = "Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl",
                                                    from = this.unit,
                                                    source = u,
                                                    target = g[i],
                                                    tz = GetModleSize(g[i]) * 75,
                                                    size = 0.75,
                                                    speed = speed,
                                                    attack = true,
                                                    aoe = true,
                                                    },nil,
                                                    function(move)
                                                        Damage(move.source, move.target, d, false, true, {attack = true, aoe = true, damageReason = this.name})
                                                    end
                                                )
                                                move.from = this.unit
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                )
            elseif this.event == "发动技能" then
                --特效部分
                DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Orc\\LightningShield\\LightningShieldTarget.mdl", this.unit, "origin"))
                local e1 = AddSpecialEffectTarget("war3mapImported\\thunderstorm_groundeffect.mdx", this.unit, "origin")
                local e2 = AddSpecialEffectTarget("Abilities\\Weapons\\Bolt\\BoltImpact.mdl", this.unit, "chest")
                local x, y, z = GetUnitX(this.unit), GetUnitY(this.unit), GetUnitZ(this.unit)
                local l = AddLightningEx("FORK", true, x, y, z, x, y, z)
                SetUnitVertexColor(this.unit, 100, 100, 100, 100)
                --数据部分
                local up = 1 + this:get(3) * #this.units * 0.01
                local dis = this:get("rng")
                local d = this:get(1) + this:get(2) * up
                local area = this:get("area")
                local p = GetOwningPlayer(this.unit)                
                Mover({
                    unit = this.unit,
                    speed = this:get(6),
                    angle = GetBetween(this.unit, this.target, true),
                    distance = dis,
                    aoe = true,
                    g = {}
                    },
                    function(move)
                        if move.count %5 == 0 then
                            forRange(this.unit, area,
                                function(u)
                                    if not move.g[u] then
                                        move.g[u] = true
                                        if EnemyFilter(p, u) then
                                            SkillEffect{
                                                name = this.name,
                                                from = this.unit,
                                                to = u,
                                                data = this,
                                                aoe = true,
                                                code = function(data)
                                                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Orc\\LightningBolt\\LightningBoltMissile.mdl", data.to, "origin"))
                                                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\ChimaeraLightningMissile\\ChimaeraLightningMissile.mdl", data.to, "origin"))
                                                    Damage(data.from, data.to, d, false, true, {aoe = true, damageReason = this.name})
                                                end
                                            }
                                        end
                                    end
                                end
                            )
                            --特效部分
                            TempEffect(move.unit, "Abilities\\Weapons\\Bolt\\BoltImpact.mdl")
                            MoveLightningEx(l, false, x, y, z, GetUnitX(move.unit), GetUnitY(move.unit), GetUnitZ(move.unit))
                        end
                    end,
                    function(move)
                        SetUnitVertexColor(move.unit, 255, 255, 255, 255)
                        DestroyLightning(l)
                        DestroyEffect(e1)
                        DestroyEffect(e2)
                    end
                )
            end
        end
    }
    
    --雷击之枪
    InitSkill{
        name = "雷击之枪",
        type = {"开关", 2}, --点目标
        ani = "attack slam",
        art = {"BTNManaFlare.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = 50,
        flashmana = 0,
        cool = 10,
        rng = 1500,
        cast = 0.3,
        time = 10,
        area = 125,
        dur = 10,
        tip = "\
|cff00ccff主动|r: 发射一道巨大的雷电横贯战场,造成持续递增的伤害.\
|cff00ccff被动|r: 御坂美琴的普通攻击可以立即对贯穿的敌人造成伤害.\n\
|cff00ffcc技能|r: 点目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00每秒消耗|r: %d\
|cffffcc00雷电伤害|r: %s(|cff0000ff+%d|r)\
|cffffcc00每秒加成|r: %s%%\
|cffffcc00普通攻击的贯穿伤害|r: %s(|cffff0000+%d|r)\n\
|cff888888引导可以提前关闭\n引导期间不能攻击与施法\n引导期间转身速度降低为%s°\n被动效果不再对你正在攻击的单位造成伤害",
        researchtip = "雷电只对英雄造成伤害,伤害提升50%",
        data = {
            function(ap, ad, data) --每秒消耗1
                return data.flashmana
            end,
            {10, 20, 30, 40}, --伤害2
            function(ap) --伤害加成3
                return ap * 0.4 --AP加成0.4
            end,
            20, --加成4
            {10, 20, 30, 40}, --贯穿伤害伤害5
            function(ap, ad) --贯穿伤害加成6
                return ad * 1
            end,
            30, --转身速度7
        },
        events = {"获得技能", "失去技能", "发动技能"},
        code = function(this)
            if this.event == "获得技能" then
                this.timer = LoopRun(1,
                    function()
                        this.flashmana = GetUnitState(this.unit, UNIT_STATE_MANA) * 0.05 + this.lv * 10
                        SetSkillTip(this.unit, this.y)
                    end
                )
                this.skillfunc = Event("远程攻击弹道", "发动英雄技能", "无法施法",
                    function(move)
                        if move.event == "远程攻击弹道" then
                            if this.unit == move.from then
                                local p = GetOwningPlayer(this.unit)
                                local d = this:get(5) + this:get(6)
                                forSeg(this.unit, move.target, this:get("area"),
                                    function(u)
                                        if u ~= move.target and EnemyFilter(p, u, {["建筑"] = true}) then
                                            DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\ChimaeraLightningMissile\\ChimaeraLightningMissile.mdl", u, "chest"))
                                            Damage(this.unit, u, d, false, true, {aoe = true, damageReason = this.name})
                                        end
                                    end
                                )
                            end
                        elseif move.event == "发动英雄技能" then
                            if this.unit == move.from then
                                if this.openflag then
                                    this:closeskill()
                                end
                            end
                        elseif move.event == "无法施法" then
                            if this.unit == move.to then
                                if this.openflag then
                                    this:closeskill()
                                end
                            end
                        end
                    end
                )
            elseif this.event == "失去技能" then
                DestroyTimer(this.timer)
                Event("-远程攻击弹道", "-发动英雄技能", "-无法施法", this.skillfunc)
            elseif this.event == "发动技能" then
                EnableAttack(this.unit, false)
                local dis = this:get("rng")
                local face = GetBetween(this.unit, this.target, true)
                SetUnitFacing(this.unit, face)
                local x1, y1, z1 = GetUnitX(this.unit), GetUnitY(this.unit), GetUnitZ(this.unit)
                local x2, y2 = getXY(MovePoint(this.unit, {dis, face}))
                local z2 = getZ({x1, y1})
                local l, l1 = Lightning{ --蓝色粗线
                    name = "LN00",
                    check = false,
                    x1 = x1,
                    y1 = y1,
                    z1 = z1 + 80,
                    x2 = x2,
                    y2 = y2,
                    z2 = z2 + 80,
                    cut = true,
                    color = {0, 0, 1, 0.5}
                }
                z1, x2, y2, z2 = l.z1, l.x2, l.y2, l.z2
                local l2 = AddLightningEx("LN01", false, x1, y1, z1, x2, y2, z2) --红色细线
                SetLightningColor(l2, 1, 0, 0, 0.5)
                local l3 = AddLightningEx("CLPB", false, x1, y1, z1 + 20, x2, y2, z2 + 20) --闪电主
                local l4 = AddLightningEx("CLSB", false, x1, y1, z1 + 10, x2, y2, z2 + 10) --闪电次
                local l5 = AddLightningEx("FORK", false, x1, y1, z1 - 10, x2, y2, z2 - 10) --闪电次
                local l6 = AddLightningEx("CHIM", false, x1, y1, z1 - 20, x2, y2, z2 - 20) --闪电次
                local l7 = AddLightningEx("HWPB", false, x1, y1, z1, x2, y2, z2) --闪电次
                
                local order
                local orderAngle = face
                local trg = CreateTrigger()
                local p = GetOwningPlayer(this.unit)
                TriggerRegisterUnitEvent(trg, this.unit, EVENT_UNIT_ISSUED_POINT_ORDER)
                TriggerRegisterUnitEvent(trg, this.unit, EVENT_UNIT_ISSUED_TARGET_ORDER)
                TriggerAddCondition(trg, Condition(
                    function()
                        local id = GetIssuedOrderId()
                        if id == 851973 then --晕眩指令
                            this:closeskill()
                        else
                            order = GetOrderTarget() or GetOrderPointLoc()
                            orderAngle = GetBetween(this.unit, order, true)
                            Wait(0, 
                                function()
                                    IssueImmediateOrder(this.unit, "stop")
                                end
                            )
                        end
                    end
                ))
                local flashAngle = this:get(7) * 0.05 --每个周期的最大转向
                local count = 0
                local area = this:get("area")
                local up = 1
                Loop(0.05,
                    function()
                        local mana = this.flashmana * 0.05
                        if IsUnitAlive(this.unit) and GetUnitState(this.unit, UNIT_STATE_MANA) > mana and this.openflag then
                            SetUnitState(this.unit, UNIT_STATE_MANA, GetUnitState(this.unit, UNIT_STATE_MANA) - mana)
                            local a = math.A2A(face, orderAngle) --夹角
                            if a > flashAngle then
                                local f1 = face + flashAngle
                                local f2 = face - flashAngle
                                if math.A2A(f1, orderAngle) < math.A2A(f2, orderAngle) then
                                    face = f1
                                else
                                    face = f2
                                end
                                
                            else
                                face = orderAngle
                            end
                            SetUnitFacing(this.unit, face)
                            x1, y1, z1 = GetUnitX(this.unit), GetUnitY(this.unit), GetUnitZ(this.unit)
                            local np = MovePoint(this.unit, {dis, face})
                            x2, y2 = getXY(np)
                            z2 = getZ({x1, y1})
                            l, l1 = ChangeLightning{
                                l = l1,
                                check = false,
                                x1 = x1,
                                y1 = y1,
                                z1 = z1 + 80,
                                x2 = x2,
                                y2 = y2,
                                z2 = z2 + 80,
                                cut = true
                            }
                            z1, x2, y2, z2 = l.z1, l.x2, l.y2, l.z2
                            MoveLightningEx(l2, false, x1, y1, z1, x2, y2, z2)
                            MoveLightningEx(l3, false, x1, y1, z1 + 20, x2, y2, z2 + 20)
                            MoveLightningEx(l4, false, x1, y1, z1 + 10, x2, y2, z2 + 10)
                            MoveLightningEx(l5, false, x1, y1, z1 - 10, x2, y2, z2 - 10)
                            MoveLightningEx(l6, false, x1, y1, z1 - 20, x2, y2, z2 - 20)
                            MoveLightningEx(l7, false, x1, y1, z1, x2, y2, z2)
                            np = {l.x2, l.y2}
                            if count % 2 == 0 then --每0.1秒创建一个特效
                                TempEffect(np, "Abilities\\Weapons\\Bolt\\BoltImpact.mdl")
                                if count % 10 == 0 then --每0.5秒造成一次伤害
                                    up = up + 0.005 * this:get(4)
                                    local d = (this:get(2) + this:get(3)) * 0.5 * up
                                    if this.research then
                                        d = d * 1.5
                                    end
                                    forSeg(this.unit, np, area,
                                        function(u)
                                            if (not this.research or IsHero(u)) and EnemyFilter(p, u) then
                                                SkillEffect{
                                                    name = this.name,
                                                    from = this.unit,
                                                    to = u,
                                                    data = this,
                                                    aoe = true,
                                                    code = function(data)
                                                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\ChimaeraLightningMissile\\ChimaeraLightningMissile.mdl", data.to, "chest"))
                                                        Damage(data.from, data.to, d, false, true, {aoe = true, damageReason = this.name})
                                                    end
                                                }
                                            end
                                        end
                                    )
                                end
                            end
                            count = count + 1
                        else
                            EndLoop()
                            this:closeskill() --手动关闭技能
                            DestroyLightning(l1)
                            DestroyLightning(l2)
                            DestroyLightning(l3)
                            DestroyLightning(l4)
                            DestroyLightning(l5)
                            DestroyLightning(l6)
                            DestroyLightning(l7)
                            DestroyTrigger(trg)
                            EnableAttack(this.unit, true)
                        end
                    end
                )
            end
        end
    }
    
    --审判之光
    InitSkill{
        name = "审判之光",
        type = {"主动"},
        ani = "stand",
        art = {"BTNZZDLL.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {200, 350, 500},
        cool = 120,
        cast = 0,
        time = 4,
        area = 360,
        dur = 4,
        tip = "\
御坂美琴积聚雷电,在身边随机位置落下小落雷.2秒后你当前屏幕中央位置将开始积聚一道巨型落雷,技能引导完毕时这道落雷将审判区域内的一切罪恶.\n\
|cffffcc00需要持续施法\n\n|cff00ffcc技能|r: 无目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00落雷伤害|r: %s(|cff0000ff+%d|r)\
|cffffcc00落雷出现范围|r: %s\
|cffffcc00落雷影响范围|r: %s\
|cffffcc00最大审判伤害|r: %s(|cff0000ff+%d|r)\n\
|cff888888引导期间获得全图视野\n审判区域中心%s范围内造成全额伤害,越靠近边缘伤害越少,最少造成%s%%伤害\n可对建筑造成伤害",
        researchtip = {
            "审判总是造成全额伤害",
            "落雷在3秒后开始积聚",
            "技能发动后立即以你自身为中心进行审判.取代之前的效果",
        },
        data = {
            {50, 100, 150}, --落雷伤害1
            function(ap) --落雷伤害加成2
                return ap * 0.5
            end,
            600, --落雷出现范围3
            200, --落雷影响范围4
            {250, 500, 750}, --审判伤害5
            function(ap) --审判伤害加成6
                return ap * 4
            end,
            60, --全伤害范围7
            50, --最少伤害8
        },
        events = {"发动技能", "施放结束", "停止施放"},
        code = function(this)
            if this.event == "发动技能" then
                StartSound(gg_snd_MonsoonLightningHit)
                local p = GetOwningPlayer(this.unit)
                this.fm = CreateFogModifierRect(p, FOG_OF_WAR_VISIBLE, bj_mapInitialPlayableArea, true, false)
                FogModifierStart(this.fm)
                local area1 = this:get(3)
                local area2 = this:get(4)
                local d = this:get(1) + this:get(2)
                local count = 0
                local maxcount = 10
                if this.research and this.research[2] then
                    maxcount = 15
                end
                this.timer = Loop(0.2,
                    function()
                        --创建小闪电
                        local where = MovePoint(this.unit, {area1, GetRandomReal(0, 360)})
                        local x, y = getXY(where)
                        local ln = AddLightningEx("FORK", true, x, y, 2000, x, y, 0)
                        local effect = AddSpecialEffectLoc("war3mapImported\\thunderstorm_groundeffect.mdx", where)
                        Wait(0.7,
                            function()
                                DestroyEffect(effect)
                                DestroyLightning(ln)
                            end
                        )
                        forRange(where, area2,
                            function(u)
                                if EnemyFilter(p, u, {["建筑"] = true}) then
                                    SkillEffect{
                                        name = this.name,
                                        from = this.unit,
                                        to = u,
                                        data = this,
                                        aoe = true,
                                        code = function(data)
                                            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Orc\\LightningBolt\\LightningBoltMissile.mdl", data.to, "origin"))
                                            Damage(data.from, data.to, d, false, true, {aoe = true, damageReason = this.name})
                                        end
                                    }
                                end
                            end
                        )
                        count = count + 1
                        --开始同步数据
                        if count == maxcount then
                            local x, y = GetCameraTargetPositionX(), GetCameraTargetPositionY()
                            this.sync = Sync(p, {x, y})
                            if p == SELFP then
                                this.effect = AddSpecialEffect("war3mapImported\\calldown_4.mdx", x, y)
                            else
                                this.effect = AddSpecialEffect("", 0, 0)
                            end
                        end
                    end
                )
                if this.research and this.research[3] then
                    this.event = "施放结束"
                    this:code()
                    IssueImmediateOrder(this.unit, "stop")
                end
            elseif this.event == "施放结束" then
                local x, y
                if this.research and this.research[3] then
                    x, y = GetUnitX(this.unit), GetUnitY(this.unit)
                elseif this.sync.ready then
                    x, y = this.sync[1], this.sync[2]
                else
                    print("<审判之光>镜头同步失败")
                    x, y = GetUnitX(this.unit), GetUnitY(this.unit)
                end
                StartSound(gg_snd_ThunderClapCaster)
                local points = {}
                for i = 1, 6 do
                    points[i] = MovePoint({x, y}, {240, 60 * i})
                end
                points[7] = {x, y}
                local units = {}
                local p = GetOwningPlayer(this.unit)
                local l1 = {}
                local l2 = {}
                for i = 1, 7 do
                    units[i] = CreateUnitAtLoc(p, |e02Q|, points[i], 0)
                    SetUnitTimeScale(units[i], 0.7)
                    SetUnitAnimation(units[i], "birth")
                    local x, y = getXY(points[i])
                    l1[i] = AddLightningEx("CHIM", true, x, y, 2000, x, y ,0)
                    l2[i] = AddLightningEx("FORK", true, x, y, 2000, x, y ,0)
                end
                Wait(0.6,
                    function()
                        for i = 1, 7 do
                            RemoveUnit(units[i])
                        end
                    end
                )
                Wait(1,
                    function()
                        for i = 1, 7 do
                            DestroyLightning(l1[i])
                            DestroyLightning(l2[i])
                        end
                    end
                )
                local count = 0
                local d = (this:get(5) + this:get(6)) / 3
                local aa = this:get(7)
                if this.research and this.research[1] then
                    aa = 9999999
                end
                local ld = this:get(8) * d * 0.01
                local area = this:get("area")
                Loop(0.2,
                    function()
                        count = count + 1
                        if count == 3 then
                            EndLoop()
                        end
                        forRange(points[7], area,
                            function(u)
                                if EnemyFilter(p, u, {["建筑"] = true}) then
                                    local dd
                                    local l = GetBetween(points[7], u)
                                    if l > aa then
                                        l = l - aa
                                        dd = d - (d - ld) * l / (area - aa)
                                    else
                                        dd = d
                                    end
                                    SkillEffect{
                                        name = this.name,
                                        from = this.unit,
                                        to = u,
                                        data = this,
                                        aoe = true,
                                        code = function(data)
                                            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl", data.to, "origin"))
                                            Damage(data.from, data.to, dd, false, true, {aoe = true, damageReason = this.name})
                                        end
                                    }
                                end
                            end
                        )
                    end
                )
            elseif this.event == "停止施放" then
                DestroyTimer(this.timer)
                DestroyEffect(this.effect)
                Wait(1,
                    function()
                        DestroyFogModifier(this.fm)
                    end
                )
            end
        end
    }
