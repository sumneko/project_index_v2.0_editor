    
    HeroName[4] = "一方通行"
    HeroMain[4] = "智力"
    HeroType[4] = |Udre|
    RDHeroType[4] = |h01F|
    HeroTypePic[4] = "ReplaceableTextures\\CommandButtons\\BTNYiFang.blp"
    HeroSize[4] = 1.3
    LearnSkillId = {|A14W|, |A14X|, |A14Y|, |A14Z|}
    
    --矢量加速
    InitSkill{
        name = "矢量加速",
        type = {"主动", 2, 3}, --点目标,图标可见+目标选取图像
        ani = "spell",
        art = {"BTNWindWalkOn.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {90, 120, 150, 180},
        cool = {18, 17, 16, 15},
        rng = {600, 700, 800, 900},
        cast = 0.1,
        dur = 3,
        area = 300,
        tip = "\
一方通行改变脚下的矢量,高速冲向目标区域.到达目标区域后,一方通行将操纵地面的矢量使周围的敌人|cffffcc00减速|r并造成伤害.\n\
|cff00ffcc技能|r: 点目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00造成伤害|r: %s(|cff0000ff+%d|r)\
|cffffcc00降低移动速度|r: %s%%\n\
|cff888888冲刺速度为%s\n到达目标区域后延迟%s秒发动区域效果\n减速效果可以驱散",
        researchtip = "一方在冲刺过程中无敌,施法距离提升50%",
        data = {
            {40, 80, 120, 160}, --伤害1
            function(ap) --伤害加成2
                return ap * 0.5 --AP加成为0.5
            end,
            {50, 60, 70, 80}, --降低移动速度3
            1500, --冲刺速度4
            0.25, --效果延迟5
        },
        events = {"发动技能", "研发"},
        code = function(this)
            if this.event == "发动技能" then
                local e1 = AddSpecialEffectTarget("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", this.unit, "hand left")
                local e2 = AddSpecialEffectTarget("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", this.unit, "hand right")
                local flag
                if this.research then
                    flag = true
                    EnableGod(this.unit)
                end
                --冲刺效果
                Mover({
                        unit = this.unit,
                        speed = this:get(4),
                        angle = GetBetween(this.unit, this.target, true),
                        target = this.target,
                    },nil,
                    function(move)
                        SetUnitAnimation(move.unit, "spell slam")
                        DestroyEffect(e1)
                        DestroyEffect(e2)
                        TempEffect(move.target, "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl")
                        local p1 = GetOwningPlayer(move.unit)
                        Wait(this:get(5),
                            function()
                                if flag then
                                    EnableGod(this.unit, false)
                                end
                                local m = this:get(3)
                                local t = this:get("dur")
                                local d = this:get(1) + this:get(2)
                                forRange(move.target, this:get("area"),
                                    function(u2)
                                        if EnemyFilter(p1, u2) then
                                            SkillEffect{
                                                name = this.name,
                                                from = this.unit,
                                                to = u2,
                                                data = this,
                                                aoe = true,
                                                code = function(data)
                                                    SlowUnit{
                                                        from = data.from,
                                                        to = data.to,
                                                        move = m,
                                                        time = t,
                                                        aoe = true
                                                    }
                                                    Damage(data.from, data.to, d, false, true, {aoe = true, damageReason = this.name})
                                                end
                                            }
                                        end
                                    end
                                )
                                --创建特效
                                local ub = CreateUbersplatBJ(move.target, "THND", 100, 100, 100, 0, false, false )
                                SetUbersplatRenderAlways(ub, true )
                                local count = 0
                                local modle = "Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl"
                                local n = 1 + this.lv
                                local a = 360 / n
                                local a2 = 360 / (6 + n * 2 )
                                local area = this:get("area")
                                local area2 = area / 10
                                Loop(0.05,
                                    function()
                                        for i = 1, n do
                                            TempEffect(MovePoint(move.target, {area - count * area2, a * i + count * a2}), modle)
                                        end
                                        
                                        count = count + 1
                                        if count == 10 then
                                            EndLoop()
                                        end
                                    end
                                )
                            end
                        )
                    end
                )
            elseif this.event == "研发" then
                this.rng[1] = this.rng[1] + 300
                this.rng[2] = this.rng[2] + 350
                this.rng[3] = this.rng[3] + 400
                this.rng[4] = this.rng[4] + 450
            end
        end,
    }
    
    --矢量转换
    InitSkill{
        name = "矢量转换",
        type = {"主动", 2, 3}, --点目标,图标可见+目标选取图像
        ani = "attack alternate -1",
        art = {"BTNAttackGround.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {120, 160, 200, 240},
        cool = {20, 18, 16, 14},
        rng = 800,
        cast = 0.1,
        dur = 0.75,
        area = 200,
        tip = "\
一方通行改变周围的重力矢量,使附近单位坠向目标区域,对区域内的敌方单位造成伤害并短暂|cffffcc00击晕|r.\n\
|cff00ffcc技能|r: 点目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00最大数量|r: %s\
|cffffcc00每个单位造成伤害|r: %s(|cff0000ff+%d|r)\n\
|cff888888如果周围%s范围内没有单位则丢出石块,但伤害与晕眩时间减半\n可以丢队友\n每个单位只能被投掷一次\n坠落时间为%s,坠落间隔为%s\n坠落点与指定点有最大%s的误差",
        researchtip = "石块也可以造成全额的伤害与晕眩时间",
        data = {
            {1, 2, 3, 4}, --单位数量1
            60, --伤害2
            function(ap) --伤害加成3
                return ap * 0.25 --AP加成为0.25
            end,
            225, --抓取范围4
            1, --坠落时间5
            0.5, --坠落间隔6
            100, --最大误差7
        },
        events = {"发动技能"},
        code = function(this)
            local count = this:get(1)
            local r = this:get(4)
            local p1 = GetOwningPlayer(this.unit)
            local t = this:get(5)
            local tr = this:get(7)
            local area = this:get("area")
            local d = this:get(2) + this:get(3)
            local dur = this:get("dur")
            local gg = {}
            LoopRun(this:get(6),
                function()
                    --寻找最近单位
                    local g = {}
                    forRange(this.unit, r,
                        function(u2)
                            if EnemyFilter(p1, u2, {["友军"] = true}) and this.unit ~= u2 and not table.has(gg, u2) then
                                table.insert(g, u2)
                            end
                        end
                    )
                    local move = {
                        target = MovePoint(this.target, {GetRandomInt(0, tr), GetRandomInt(1, 360)}),
                        time = t,
                        high = 500,
                        data = {},
                    }
                    --跳跃
                    local moveStart = function()
                        Mover(move, nil,
                            function(move)
                                TempEffect(move.target, "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl")
                                forRange(move.target, area,
                                    function(u2)
                                        if EnemyFilter(p1, u2) then
                                            SkillEffect{
                                                name = "矢量转换(坠落效果)",
                                                from = move.from,
                                                to = u2,
                                                data = this,
                                                code = function(data)
                                                    StunUnit{
                                                        from = data.from,
                                                        to = data.to,
                                                        time = move.data.dur,
                                                        aoe = true
                                                    }
                                                    Damage(data.from, data.to, move.data.damage, false, true, {aoe = true, damageReason = this.name})
                                                end
                                            }
                                        end
                                    end
                                )
                            end
                        )
                    end
                    if #g == 0 then
                        move.modle = "Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl"
                        move.from = this.unit
                        move.size = 1.5
                        if this.research then
                            move.data.damage = d
                            move.data.dur = dur
                        else
                            move.data.damage = d / 2
                            move.data.dur = dur / 2
                        end
                        moveStart()
                    else
                        move.unit = table.getone(g,
                            function(u1, u2)
                                return GetBetween(this.unit, u1) < GetBetween(this.unit, u2)
                            end
                        )
                        table.insert(gg, move.unit)
                        SkillEffect{
                            name = this.name,
                            from = this.unit,
                            to = move.unit,
                            data = this,
                            aoe = true,
                            filter = "友军,别人",
                            code = function(data)
                                table.insert(gg, data.to)
                                move.from = data.from
                                move.unit = data.to
                                move.data.damage = d
                                move.data.dur = dur
                                moveStart()
                            end
                        }
                    end
                    --结束
                    count = count - 1
                    if count == 0 then
                        EndLoop()
                    end
                end
            )
        end
    }
    
    --矢量偏转
    InitSkill{
        name = "矢量偏转",
        type = {"主动"},
        ani = "morph",
        art = {"BTNNeutralManaShield.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {50, 75, 100, 125},
        cool = 20,
        dur = {7, 8, 9, 10},
        area = 1000,
        tip = "\
一方通行开启项圈电源,偏转之后受到的伤害,负面状态,弹道或技能效果.\n\
|cff00ffcc技能|r: 无目标\n\
|cffffcc00偏转次数|r: %s\n\
|cff888888只能偏转给视野范围内的敌方单位\n非英雄非建筑单位来源或持续性效果%s次算1次\
立即偏转伤害与负面效果/重置弹道目标/偏转技能效果时一方自己发射一个速度为%s的弹道,弹道命中后附加该技能效果",
        researchtip = "开启反射后的第1秒内不计算偏转次数",
        data = {
            {1, 2, 3, 4}, --偏转次数1
            3, --非英雄单位的折算2
            500, --弹道3
        },
        events = {"获得技能", "失去技能", "发动技能"},
        code = function(this)
            if this.event == "获得技能" then
                this.opentime = 0
                this.close = function(this, unit, aoe, dot)
                    if this.research and GetTime() - this.lastopentime < 1 then
                        return
                    end
                    if dot or (not IsHeroUnitId(GetUnitTypeId(unit)) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)) then
                        this.opencount = this.opencount - 1
                    else
                        this.opencount = this.opencount - this:get(2)
                    end
                    if this.opencount <= 0 then
                        this.open = false
                        this.opentime = 0
                        DestroyEffect(this.effect)
                        this.effect = nil
                    end
                end
                
                this.skillfunc = Event("弹道即将命中", "debuff", "伤害转移", "技能效果",
                    function(move)
                        local unit
                        if move.good then return end --如果是正面效果的弹道或技能效果就跳过
                        if move.event == "弹道即将命中" then
                            unit = move.target
                        else
                            unit = move.to
                        end
                        local this = findSkillData(unit, this.name)
                        if not this then return end
                        if this.open then
                            --寻找附近的单位
                            local g = {}
                            local p1 = GetOwningPlayer(unit)
                            local filter = nil
                            if move.attack then
                                filter = {["魔免"] = true, ["建筑"] = true}
                            elseif move.filter then
                                filter = {}
                                for _, v in ipairs(string.split(move.filter, ",")) do
                                    filter[v] = true
                                end
                            end
                            forRange(unit, this:get("area"),
                                function(u2)
                                    if EnemyFilter(p1, u2, filter) and IsUnitVisible(u2, p1) then
                                        table.insert(g, u2)
                                    end
                                end
                            )
                            local n = #g
                            if move.event == "弹道即将命中" then
                                this:close(move.from, move.aoe)
                                if n == 0 then
                                    move.stop = true
                                else
                                    move.from = this.unit
                                    move.target = g[GetRandomInt(1, n)]
                                end
                                return true --取消命中
                            else
                                local time = GetTime()
                                if this.lasttime ~= time then
                                    this:close(move.from, move.aoe , move.dot)
                                    if n == 0 then
                                        return true --取消伤害/效果
                                    else
                                        this.lastunit = g[GetRandomInt(1, n)]
                                    end
                                end
                                if move.changed then --已经转移过的就不再转移,以免死循环
                                    return true
                                end
                                this.lasttime = time
                                move.from = this.unit
                                move.to = this.lastunit
                                if move.event == "技能效果" then
                                    MoverEx({
                                        modle = "war3mapImported\\soulmissile.mdl",
                                        size = 1,
                                        z = 100,
                                        tz = 100,
                                        high = 300,
                                        from = this.unit,
                                        target = this.lastunit,
                                        speed = this:get(3),
                                        filter = move.filter,
                                    }, nil,
                                    function()
                                        move:code()
                                    end)
                                    return true
                                else
                                    move.changed = this.name
                                    move.delay = 0
                                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl", move.to, "overhead"))
                                end
                            end
                        end
                    end
                )
            elseif this.event == "发动技能" then
                this.open = true
                this.opentime = GetTime()
                this.opencount = this:get(1) * this:get(2)
                this.lastopentime = this.spellflag
                local opentime = this.opentime
                if not this.effect then
                    this.effect = AddSpecialEffectTarget("war3mapImported\\WaterArmor.mdx", this.unit, "origin")
                end
                Wait(this:get("dur"),
                    function()
                        if this.opentime == opentime then
                            this.open = false
                            DestroyEffect(this.effect)
                            this.effect = nil
                        end
                    end
                )
            elseif this.event == "失去技能" then
                Event("-弹道即将命中", "-debuff", "-伤害转移", "-技能效果", this.skillfunc)
            end
        end
    }
    
    --全力模式
    InitSkill{
        name = "全力模式",
        type = {"开关"},
        art = {"BTNPurge.blp", "BTNPurge.blp", "BTNCancel.blp"}, --第三个参数为关闭
        mana = 100,
        cool = 60,
        dur = 30,
        area = 200,
        tip = "\
不明的能量聚集在一方身边,使得一方可以同时攻击3个单位并获得移动速度与|cffffcc00冷却缩减|r加成.\
全力模式结束时一方将释放出期间聚集的能量,携带沿途的敌方单位向前方冲击并造成毁灭性的伤害.\n\
|cff00ffcc技能|r: 开关\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00每秒消耗|r: %s\n|cffffcc00移动速度|r: %s\n|cffffcc00冷却缩减|r: %s%%\n|cffffcc00冲击距离|r: %s\n|cffffcc00冲击伤害|r: %s(|cff0000ff+%d|r)\n\
|cff888888技能关闭后开始冷却\n关闭技能时移除负面效果\n冲击速度为%s|r",
        researchtip = {
            "全力模式下的一方可以同时攻击附近所有单位.取代同时攻击3个单位",
            "开启全力模式后可以立即聚集10秒的冲击距离与冲击伤害",
            "冷却时间减少为10秒",
        },
        untip = "\
已聚集 |cffffcc00%d|r 的冲击距离与 |cffffcc00%d|r 的冲击伤害",
        data = {
            {20, 35, 50}, --每秒法力消耗1
            {30, 45, 60}, --移动速度加成2
            {10, 15, 20}, --冷却缩减3
            50, --冲击距离4
            {20, 35, 50}, --冲击伤害5
            function(ap, ad) --冲击伤害加成6
                return ap * 0.15 --AP加成0.15
            end,
            1000, --冲击速度7
        },
        undata = {0, 0},
        bufftip = "该单位的攻击速度与移动速度大幅提升",
        events = {"发动技能", "关闭技能"},
        code = function(this)
            if this.event == "发动技能" then
                           
                --开启技能的效果
                AddUnitAnimationProperties(this.unit, "alternate", true)
                local s = "blackwing.mdl"
                if GetRandomInt(1, 5) == 1 then
                    s = "war3mapImported\\AvengingWrath_State_Chest.mdx"
                end
                this.effect = AddSpecialEffectTarget(s, this.unit, "chest")
                this.ms = this:get(2)
                this.cd = this:get(3)
                MoveSpeed(this.unit, this.ms)
                SetCoolDown(this.unit, this.cd)
                
                --同时攻击3个单位
                Mark(this.unit, "弹道模型", "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl")
                
                this.skillfunc = Event("远程攻击弹道",
                    function(move)
                        if move.from == this.unit and this.openflag then
                            local p1 = GetOwningPlayer(move.from)
                            local t = {}
                            forRange(move.from, GetUnitState(move.from, ConvertUnitState(0x16)),
                                function(u2)
                                    if move.target ~= u2 and EnemyFilter(p1, u2, {["魔免"] = true, ["建筑"] = true}) then
                                        table.insert(t, u2)
                                    end
                                end
                            )
                            if this.research and this.research[1] then
                                for i, u in ipairs(t) do
                                    local move = table.copy(move)
                                    move.target = u
                                    MoverEx(move, nil, move.code)
                                end
                            else
                                for i = 1, 2 do
                                    local n = #t
                                    if n ~= 0 then
                                        local x = GetRandomInt(1, n)
                                        local move = table.copy(move)
                                        move.target = t[x]
                                        MoverEx(move, nil, move.code)
                                        table.remove(t, x)
                                    else
                                        break
                                    end
                                end
                            end
                        end
                    end
                )
                
                --持续效果
                local fCost = this:get(1) * 0.05
                local fDis = this:get(4) * 0.05
                local fDam = (this:get(5) + this:get(6)) * 0.05
                if this.research and this.research[2] then
                    this.undata[1] = this.undata[1] + fDis * 10 / 0.05
                    this.undata[2] = this.undata[2] + fDam * 10 / 0.05
                end
                Loop(0.05,
                    function()
                        if this.openflag then
                            local mp = GetUnitState(this.unit, UNIT_STATE_MANA) - fCost
                            SetUnitState(this.unit, UNIT_STATE_MANA, mp)
                            if mp <= 0 then
                                this:closeskill()
                            else
                                this.data[1] = this.data[1] + fDis
                                this.data[2] = this.data[2] + fDam
                                SetSkillTip(this.unit, this.y) --刷新技能说明
                                RefreshTips(this.unit)
                            end
                        else
                            EndLoop()
                        end
                    end
                )
            elseif this.event == "关闭技能" then
                local Dis = this.undata[1]
                local Dam = this.undata[2]
                this.undata[1] = 0
                this.undata[2] = 0
                
                AddUnitAnimationProperties(this.unit, "alternate", false)
                
                Mark(this.unit, "弹道模型", false)
                Event("-远程攻击弹道", this.skillfunc)
                
                this.freshcool = this:get("cool")
                if this.research and this.research[2] then
                    this.freshcool = this.freshcool / 6
                end
                
                MoveSpeed(this.unit, - this.ms)
                SetCoolDown(this.unit, - this.cd)
                
                if IsUnitAlive(this.unit) then --单位存活
                    CleanUnit{
                        from = this.unit,
                        to = this.unit,
                        debuff = true
                    }
                    --进行冲击
                    local area = this:get("area")
                    local face = GetUnitFacing(this.unit)
                    local uu = {}
                    for i = 0, 10 do
                        uu[i] = CreateModle("Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl", MovePoint(this.unit, {area - area / 5 * i, face + 90}), {angle = face})
                        SetUnitFlyHeight(uu[i], 75, 0)
                        SetUnitScale(uu[i], 3, 3, 3)
                    end
                    Mover({
                        from = this.unit,
                        unit = this.unit,
                        speed = this:get(7),
                        angle = face,
                        distance = Dis,
                        high = 100,
                        data = {damage = Dam, g = {}, p1 = GetOwningPlayer(this.unit), g2 = {}},
                        },
                        function(move)
                            if move.count % 5 == 0 then
                                forRange(move.unit, area,
                                    function(u2)
                                        if EnemyFilter(move.data.p1, u2) and not table.has(move.data.g2, u2) then
                                            table.insert(move.data.g2, u2)
                                            SkillEffect{
                                                name = this.name,
                                                from = move.from,
                                                to = u2,
                                                data = this,
                                                aoe = true,
                                                code = function(data)
                                                    table.insert(move.data.g, data.to)
                                                    Damage(data.from, data.to, move.data.damage, false, true, {aoe = true, damageReason = this.name})
                                                end
                                            }
                                        end
                                    end
                                )
                            end
                            for _, u in ipairs(move.data.g) do
                                SetUnitX(u, move.nx)
                                SetUnitY(u, move.ny)
                            end
                            for i = 0, 10 do
                                SetUnitXY(uu[i], MovePoint({move.nx, move.ny}, {area - area / 5 * i, face + 90}))
                            end
                        end,
                        nil,
                        function(move)
                            DestroyEffect(this.effect)
                            for i = 0, 10 do
                                RemoveUnit(uu[i])
                            end
                        end
                    )
                else
                    DestroyEffect(this.effect)
                end              
            end
        end
    }
    
