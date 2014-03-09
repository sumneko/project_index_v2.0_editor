    
    HeroName[14] = "时崎狂三"
    HeroMain[14] = "敏捷"
    HeroType[14] = |Harf|
    RDHeroType[14] = |h017|
    HeroTypePic[14] = "ReplaceableTextures\\CommandButtons\\BTNSaber.blp"
    HeroSize[14] = 1.2
    LearnSkillId = {|A1A5|, |A1A6|, |A1A7|, |A1A8|}
    
    --吞噬时间
    InitSkill{
        name = "吞噬时间",
        type = {"开关"},
        ani = "stand",
        art = {"BTNFeedBack.blp", "BTNFeedBack.blp", "BTNWispSplode.blp"}, --左边是学习,右边是普通.不填右边视为左边
        tip = [[
|cffff00cc开启:|r
攻击时以消耗自身时间为代价,夺取对方的时间.
|cffff00cc被动:|r
杀死单位将获得永久的生命值上限提升.

|cff00ffcc技能|r: 无目标
|cff00ffcc伤害|r: 混合

|cffffcc00消耗生命|r: |cffff1111%d|r(自身当前生命值的%s%%)
|cffffcc00吸取生命|r: %s%%(对方当前生命值的百分比)
|cffffcc00生命上限提升(英雄)|r: %s(|cff1111ff+%d|r)
|cffffcc00生命上限提升(非英雄)|r: %s

|cffffcc00此技能已经为你提升的生命值上限|r: %s

|cff888888视为对自己造成伤害]],
        researchtip = "单位被麻痹时受到伤害,数值相当于额外伤害的5倍",
        data = {
            0, --消耗生命1
            10, --消耗百分比2
            {10, 12, 14, 16}, --对方生命百分比3
            {10, 15, 20, 25}, --生命上限(英雄)4
            function(ap) --生命上限(英雄)加成5
                return ap * 0.2
            end,
            {2, 3, 4, 5}, --生命提升(非英雄)6
            0, --已经提升的上限7
        },
        events = {"获得技能", "失去技能", "发动技能", "关闭技能"},
        code = function(this)
            if this.event == "发动技能" then
                Mark(this.unit, "弹道模型", "a13_hong.mdx")
                
                local func1 = Event("攻击出手",
                    function(damage)
                        if damage.from == this.unit then
                            local d = GetUnitState(this.unit, UNIT_STATE_LIFE) * this:get(2) * 0.01
                            Damage(this.unit, this.unit, d, true, true, {damageReason = this.name})
                            
                            local x = this:get(3)
                            
                            table.insert(damage.attackfuncs,
                                function(damage)
                                    SkillEffect{
                                        name = this.name,
                                        data = this,
                                        from = damage.from,
                                        to = damage.to,
                                        code = function(data)
                                            local d = GetUnitState(data.to, UNIT_STATE_LIFE) * x * 0.01
                                            local damage = Damage(data.from, data.to, d, true, true, {damageReason = this.name})
                                            
                                            local hp = damage.damage
                                            
                                            if hp > 0 then
                                                MoverEx(
                                                    {
                                                        from = damage.from,
                                                        source = damage.to,
                                                        target = MovePoint(damage.to, {GetRandomInt(100, 200), GetRandomInt(1, 360)}),
                                                        good = true,
                                                        modle = "a13_hong.mdx",
                                                        size = 1,
                                                        speed = GetRandomInt(200, 300),
                                                        z = 50,
                                                        tz = 0,
                                                        high = 150,
                                                    },
                                                    nil,
                                                    nil,
                                                    function(move)
                                                        move.func2 = function(move)
                                                            if IsUnitAlive(move.target) then
                                                                Heal(move.target, move.target, hp, {healReason = this.name})
                                                            end
                                                        end
                                                        
                                                        move.target = move.from
                                                        move.speed = 300
                                                        move.z = 0
                                                        move.tz = 50
                                                        move.func3 = nil
                                                        
                                                        move.initstep() --重置移动器计算
                                                        
                                                        return true --阻止移动器结束
                                                        
                                                    end
                                                )
                                            end
                                        end
                                    }
                                    
                                end
                            )
                        end
                    end
                )
                
                this.flush = function()
                    Mark(this.unit, "弹道模型", false)
                    Event("-攻击出手", func1)
                end
            elseif this.event == "关闭技能" then
                this.flush()
            elseif this.event == "获得技能" then
                local t = Loop(0.2,
                    function()
                        this.data[1] = GetUnitState(this.unit, UNIT_STATE_LIFE) * this:get(2) * 0.01
                        SetSkillTip(this.unit, this.id)
                    end
                )
                
                local func1 = Event("死亡",
                    function(data)
                        if data.killer == this.unit then
                            local hp
                            if IsHero(data.unit) then
                                hp = this:get(4) + this:get(5)
                            else
                                hp = this:get(6)
                            end
                            hp = math.floor(hp)
                            MoverEx(
                                {
                                    from = this.unit,
                                    source = data.unit,
                                    target = this.unit,
                                    good = true,
                                    modle = "a13_hong.mdx",
                                    size = 2,
                                    speed = 500,
                                    z = 50,
                                    tz = 100,
                                    high = 150,
                                },
                                nil,
                                function(move)
                                    if IsUnitAlive(move.target) then
                                        MaxLife(move.target, hp, true)
                                        this.data[7] = this.data[7] + hp
                                    end
                                end
                            )
                        end
                    end
                )
                
                this.loseflush = function()
                    DestroyTimer(t)
                    Event("-死亡", func1)
                end
            elseif this.event == "失去技能" then
                this.loseflush()
            end
        end
    }
    
    --Alef Bet Dalet
    InitSkill{
        name = "Alef Bet Dalet",
        type = {"主动", 1},
        _type = {"主动"},
        art = {"BTNFeedBack.blp"},
        _art = {"BTNWispSplode.blp"}, --左边是学习,右边是普通.不填右边视为左边
        targs = GetTargs("地面,空中,有机生物"),
        mana = {75, 100, 125, 150},
        time = 2.2,
        cool = 30,
        area = 1000,
        tip = [[
|cffff1111%d 生命值|r%s

|cffff00cc对友方:|r
发射一之弹,加快其行动速度.
|cffff00cc对敌方:|r
发射二之弹,减慢其行动速度.

|cffff00cc再次激活:|r
发射四之弹,令其时间倒流,其生命值,法力值与位置回溯到之前的状态

|cff00ffcc技能|r: 单位目标
|cff00ffcc伤害|r: 混合

|cffffcc00加速(攻击速度与移动速度)|r: %s  %s
|cffffcc00减速(攻击速度与移动速度)|r: %s  %s
|cffffcc00持续时间|r: %s(|cff11ff11+%.2f|r)

|cff888888施法延迟%s秒,施放失败冷却时间将变为3秒
速度变化会随着时间推移而逐渐消失
弹道速度为%s
视为对自己造成伤害]],
        researchtip = "单位被麻痹时受到伤害,数值相当于额外伤害的5倍",
        data = {
            0, --生命值消耗1
            "", --预留2
            {150, 175, 200, 225}, --攻速增加3
            "", --移速增加4
            {75, 100, 125, 150}, --攻速降低5
            "", --移速降低6
            {4, 5, 6, 7}, --持续时间7
            0, --持续时间加成8
            1.8, --施法延迟9
            2000, --弹道速度10
        },
        events = {"发动技能", "停止施放", "获得技能", "失去技能"},
        code = function(this)
            if this.event == "发动技能" then
                local target = this.type[2] and this.target or this._lasttarget
                
                if this.unit == target then
                    SetUnitAnimation(this.unit, "spell one")
                else
                    SetUnitAnimation(this.unit, "spell two")
                end
                
                local func1, func2
                
                func1 = function(enemy)
                    --一之弹/二之弹
                    this._targetcooltime = this.targetcooltime
                    
                    local hp = GetUnitState(this.unit, UNIT_STATE_LIFE) * 20 * 0.01
                    local t = this:get(7) + hp * 0.01
                    
                    Damage(this.unit, this.unit, hp, true, true, {damageReason = this.name})
                    
                    local as, ms
                    if enemy then
                        as, ms = - math.floor(this:get(5)), - math.floor(this:get(5))
                    else
                        as, ms = math.floor(this:get(3)), math.floor(this:get(3))
                    end
                    
                    AttackSpeed(target, as)
                    MoveSpeed(target, ms)
                    
                    local fas, fms = math.ceil(as / t), math.ceil(ms / t)
                    local count = math.ceil(t / 0.02)
                    
                    MoverEx{
                        from = this.unit,
                        target = target,
                        speed = this:get(10),
                        z = 100,
                        tz = 100,
                        good = not enemy,
                        modle = "a13_hong.mdx",
                        func2 = function(move)
                            if move.target and IsUnitAlive(move.target) then
                                SkillEffect{
                                    name = enemy and "二之弹" or "一之弹",
                                    data = this,
                                    from = move.from,
                                    to = move.target,
                                    code = function(data)
                                        local stack = {}
                                        local dummy = CreateUnit(Player(15), |h02D|, GetUnitX(data.to), GetUnitY(data.to), 270)
                                        
                                        SetUnitScale(dummy, 0.5, 0.5, 0.5)
                                        local ts = 1066 / count
                                        SetUnitTimeScale(dummy, ts)
                                        
                                        SetSkillCool(this.unit, this.id, 0)
                                        this.art, this._art = this._art, this.art
                                        this.type, this._type = this._type, this.type
                                        SetSkillTip(this.unit, this.id)
                                        this._lasttarget = data.to
                                        
                                        this._lastdata = {
                                            unit = data.to,
                                            dummy = dummy,
                                            stack = stack,
                                            as = as,
                                            ms = ms,
                                            ts = ts
                                        }
                                        
                                        local data2 = this._lastdata
                                        
                                        data2.timer = ForLoop(0.02, count,
                                            function(count)
                                                if count % 50 == 0 then
                                                    AttackSpeed(data.to, - fas)
                                                    MoveSpeed(data.to, - fms)
                                                    as, ms = as - fas, ms - fms
                                                    data2.as, data2.ms = as, ms
                                                end
                                                local data2 = GetUnitLoc(data.to)
                                                data2[3], data2[4], data2[5] = GetUnitState(data.to, UNIT_STATE_LIFE), GetUnitState(data.to, UNIT_STATE_MANA), GetUnitFlyHeight(data.to)
                                                table.insert(stack, data2)
                                                
                                                SetUnitXY(dummy, data2)
                                                SetUnitFlyHeight(dummy, data2[5], 0)
                                                if IsUnitVisible(data.to, SELFP) then
                                                    SetUnitScale(dummy, 0.5, 0.5, 0.5)
                                                else
                                                    SetUnitScale(dummy, 0, 0, 0)
                                                end
                                            end,
                                            function(count)
                                                AttackSpeed(data.to, - as)
                                                MoveSpeed(data.to, - ms)
                                                RemoveUnit(dummy)
                                                this._lastdata = nil
                                                func2()
                                            end
                                        )
                                    end
                                }
                                
                            end
                        end
                    }
                end
                
                func2 = function(use)
                    --四之弹
                    if not this._lasttarget then return end
                    this._lasttarget = nil
                    SetSkillCool(this.unit, this.id, 0)
                    Wait(0,
                        function()
                            SetSkillCool(this.unit, this.id, this._targetcooltime - GetTime(), this:get("cool"))
                        end
                    )
                    this.art, this._art = this._art, this.art
                    this.type, this._type = this._type, this.type
                    SetSkillTip(this.unit, this.id)
                    
                    if not use then
                        --阻止正在施法中的四之弹
                        UnitRemoveAbility(this.unit, this.id)
                        UnitAddAbility(this.unit, this.id)
                        
                    else
                        MoverEx{
                            from = this.unit,
                            target = target,
                            speed = this:get(10),
                            z = 100,
                            tz = 100,
                            good = not enemy,
                            modle = "a13_hong.mdx",
                            func2 = function(move)
                                if move.target and IsUnitAlive(move.target) then
                                    SkillEffect{
                                        name = "四之弹",
                                        data = this,
                                        from = move.from,
                                        to = move.target,
                                        code = function(data2)
                                            local data = this._lastdata
                                            if data then
                                                this._lastdata = nil
                                                if data.unit == data2.to then
                                                    SetUnitTimeScale(data.dummy, - 2 * data.ts)
                                                    DestroyTimer(data.timer)
                                                    AttackSpeed(data.unit, - data.as)
                                                    MoveSpeed(data.unit, - data.ms - 10000)
                                                    local func1 = Event("伤害无效",
                                                        function(damage)
                                                            if damage.to == data.unit then
                                                                damage.dodgReason = this.name
                                                                return true
                                                            end
                                                        end
                                                    )
                                                    local func2 = Event("治疗无效",
                                                        function(damage)
                                                            if damage.to == data.unit then
                                                                damage.dodgReason = this.name
                                                                return true
                                                            end
                                                        end
                                                    )
                                                    local high = GetUnitFlyHeight(data.unit)
                                                    local lasthigh = 0
                                                    Loop(0.01,
                                                        function()
                                                            local top = #data.stack
                                                            if top == 1 or IsUnitDead(data.unit) then
                                                                EndLoop()
                                                                MoveSpeed(data.unit, 10000)
                                                                SetUnitFlyHeight(data.unit, GetUnitFlyHeight(data.unit) - lasthigh + high, 0)
                                                                Event("-伤害无效", func1)
                                                                Event("-治疗无效", func2)
                                                                RemoveUnit(data.dummy)
                                                            end
                                                            SetUnitXY(data.unit, data.stack[top])
                                                            SetUnitXY(data.dummy, data.stack[top])
                                                            
                                                            SetUnitState(data.unit, UNIT_STATE_LIFE, data.stack[top][3])
                                                            SetUnitState(data.unit, UNIT_STATE_MANA, data.stack[top][4])
                                                            
                                                            lasthigh = data.stack[top][5]
                                                            SetUnitFlyHeight(data.unit, lasthigh, 0)
                                                            SetUnitFlyHeight(data.dummy, lasthigh, 0)
                                                            data.stack[top] = nil
                                                        end
                                                    )
                                                end
                                            end
                                        end
                                    }
                                    
                                end
                            end
                        }
                    end
                end
                
                local suc
                
                local ti = Wait(this:get(9),
                    function()
                        this._func(1)
                    end
                )
                
                this._func = function(t)
                    if t == 1 then
                        suc = true
                        if this._lasttarget then
                            func2(true)
                        else
                            func1(IsUnitEnemy(target, this.player))
                        end
                        
                    elseif t == 2 and not suc then
                        DestroyTimer(ti)
                        UnitRemoveAbility(this.unit, this.id)
                        UnitAddAbility(this.unit, this.id)
                        SetSkillCool(this.unit, this.id, 3, 3)
                    end
                end
            elseif this.event == "停止施放" then
                this._func(2)
            elseif this.event == "获得技能" then
                local t = Loop(0.2,
                    function()
                        local hp = GetUnitState(this.unit, UNIT_STATE_LIFE) * 20 * 0.01
                        this.data[1] = hp
                        this.data[8] = hp * 0.01
                        SetSkillTip(this.unit, this.id)
                    end
                )
                
                this.flush = function()
                    DestroyTimer(t)
                end
            elseif this.event == "失去技能" then
                this.flush()
            end
        end
    }
    
    --Zayin Chet
    InitSkill{
        name = "Zayin Chet",
        type = {"主动", 3},
        ani = "stand",
        art = {"BTNFeedBack.blp", "BTNFeedBack.blp", "BTNWispSplode.blp"}, --左边是学习,右边是普通.不填右边视为左边
        targs = GetTargs("地面,空中,有机生物"),
        rng = 1200,
        area = 225,
        cool = {30, 25, 20, 15},
        time = 2.2,
        tip = [[
|cffff1111%d 生命值|r%s

|cffff00cc对自己:|r
发射八之弹,分裂出自己的分身.
|cffff00cc对地面或其他单位:|r
发射七之弹,将一条直线上的单位|cffffcc00冻结|r.如果是敌方单位还会造成伤害.

|cff00ffcc技能|r: 点或单位目标
|cff00ffcc伤害|r: 混合

|cffffcc00分身攻击|r: %s%%
|cffffcc00分身承受伤害|r: %s%%
|cffffcc00分身持续时间|r: %s(|cff11ff11+%d|r)

|cffffcc00造成伤害|r: %s(|cff1111ff+%d|r)
|cffffcc00冻结时间|r: %s

|cff888888施法延迟%s秒,施放失败冷却时间将变为5秒
弹道速度为%s
视为对自己造成伤害
处于冻结状态的单位失去生命与法力恢复,受到的伤害或治疗被延后]],
        researchtip = "单位被麻痹时受到伤害,数值相当于额外伤害的5倍",
        data = {
            0, --消耗自己生命值1
            "", --预留2
            25, --分身攻击3
            200, --分身承受伤害4
            {30, 40, 50, 60}, --分身持续时间5
            0, --分身持续时间加成6
            {150, 300, 450, 600}, --造成伤害7
            function(ap) --伤害加成8
                return ap * 4 --AP * 4
            end,
            {2.5, 3, 3.5, 4}, --冻结时间9
            1.8, --施法延迟10
            2000, --弹道速度11
        },
        events = {"获得技能", "失去技能", "发动技能", "停止施放"},
        code = function(this)
            if this.event == "发动技能" then
                local target = this.target
                local hp = GetUnitState(this.unit, UNIT_STATE_LIFE) * 50 * 0.01
                Damage(this.unit, this.unit, hp, true, true, {damageReason = this.name})
                
                if this.unit == target then
                    SetUnitAnimation(this.unit, "spell one")
                else
                    SetUnitAnimation(this.unit, "spell two")
                    if type(target) ~= "table" then
                        target = GetUnitLoc(target)
                    end
                end
                
                local area = this:get("area")
                local ftime = this:get(9)
                local d = this:get(7) + this:get(8)
                
                local attack = this:get(3)
                local damage = this:get(4)
                local itime = this:get(5) + hp * 0.05
                
                local func1 = function()
                    if type(target) == "table" then
                        --七之弹
                        Mover{
                            modle = "a13_hong.mdx",
                            from = this.unit,
                            target = MovePoint(this.unit, {this:get("rng"), GetBetween(this.unit, target, true)}),
                            speed = this:get(11),
                            z = 100,
                            func1 = function(move)
                                if move.count % 5 == 0 then
                                    --每0.1秒判定一次,间隔200
                                    forRange(move.unit, area,
                                        function(u)
                                            if EnemyFilter(this.player, u, {["友军"] = true, ["别人"] = true}) then
                                                SkillEffect{
                                                    name = this.name,
                                                    data = "七之弹",
                                                    from = move.from,
                                                    to = u,
                                                    area = true,
                                                    good = IsUnitEnemy(u, this.player),
                                                    code = function(data)
                                                        FreezeUnit{
                                                            from = data.from,
                                                            to = data.to,
                                                            time = ftime
                                                        }
                                                        
                                                        if IsUnitEnemy(data.to, GetOwningPlayer(data.from)) then
                                                            Damage(data.from, data.to, d, true, true, {damageReason = "七之弹", aoe = true})
                                                        end
                                                    end
                                                }
                                                
                                            end
                                        end
                                    )
                                end
                            end
                        }
                    else
                        --八之弹
                        local dummy = IllusionUnit{
                            from = this.unit,
                            to = this.unit,
                            attack = attack,
                            damage = damage,
                            time = itime
                        }
                        
                        if dummy then
                            local a = GetUnitFacing(this.unit) - 90
                            local loc = GetUnitLoc(this.unit)
                            ForLoop(0.02, 10,
                                function(i)
                                    SetUnitVertexColor(dummy, 255, 255, 255, i * 25.5)
                                    local loc = MovePoint(loc, {20 * i, a})
                                    SetUnitXY(dummy, loc)
                                end
                            )
                        end
                        
                    end
                end                
                
                local suc
                
                local ti = Wait(this:get(10),
                    function()
                        this._func(1)
                    end
                )
                
                this._func = function(t)
                    if t == 1 then
                        suc = true
                        
                        func1()
                    elseif t == 2 and not suc then
                        DestroyTimer(ti)
                        UnitRemoveAbility(this.unit, this.id)
                        UnitAddAbility(this.unit, this.id)
                        SetSkillCool(this.unit, this.id, 3, 3)
                    end
                end
            elseif this.event == "停止施放" then
                this._func(2)
            elseif this.event == "获得技能" then
                local t = Loop(0.2,
                    function()
                        local hp = GetUnitState(this.unit, UNIT_STATE_LIFE) * 50 * 0.01
                        this.data[1] = hp
                        this.data[6] = hp * 0.05
                        SetSkillTip(this.unit, this.id)
                    end
                )
                
                this.flush = function()
                    DestroyTimer(t)
                end
            elseif this.event == "失去技能" then
                this.flush()
            end
        end
    }
    
    --吞噬时间
    InitSkill{
        name = "吞噬时间4",
        type = {"开关"},
        ani = "stand",
        art = {"BTNFeedBack.blp", "BTNFeedBack.blp", "BTNWispSplode.blp"}, --左边是学习,右边是普通.不填右边视为左边
        tip = [[]],
        researchtip = {
            "单位被麻痹时受到伤害,数值相当于额外伤害的5倍",
            "",
            "",
        },
        data = {
        },
        events = {"获得技能", "失去技能", "发动技能", "关闭技能"},
        code = function(this)
        end
    }
    
