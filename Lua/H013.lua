    
    HeroName[13] = "阿尔托莉亚"
    HeroMain[13] = "力量"
    HeroType[13] = |Ewrd|
    RDHeroType[13] = |h017|
    IllHeroType[13] = |E038|
    HeroTypePic[13] = "ReplaceableTextures\\CommandButtons\\BTNSaber.blp"
    HeroSize[13] = 1.2
    LearnSkillId = {|A1A1|, |A1A2|, |A1A3|, |A1A4|}
    
    --解放真名
    InitSkill{
        name = "解放真名",
        type = {"开关"},
        ani = "stand",
        art = {"BTNJFZM.blp", "BTNJFZM.blp", "BTNFWJJ.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = 75,
        area = 600,
        tip = "\
|cffff00cc主动:|r解放石中剑的真名,使你可以使用更加强大的技能,但是失去该技能的被动效果.如果你在风王结界状态下维持了至少%s秒的时间,你将对周围的单位造成伤害并|cffffcc00减速|r.\
|cffff00cc被动:|r风暴隐藏了你的武器,使你更加容易的击中敌人的要害,获得暴击率的提升.\
\
|cff00ffcc技能|r: 无目标\
|cff00ffcc伤害|r: 法术\n\
|cffffcc00造成伤害|r: %s(|cff1111ff+%d|r)\
|cffffcc00降低攻速|r: %s%%\
|cffffcc00降低移速|r: %s%%\
|cffffcc00减速持续|r: %s\
|cffffcc00暴击率|r: %s\n\
|cff888888风王结界爆发延迟1.5秒\n减速效果可以驱散\n2种技能共享冷却时间",
        untip = "\
重新使用风王结界隐藏你的武器,使你获得被动的暴击率提升,但是将不能使用强大的技能.",
        undata = {},
        researchtip = "风王结界爆发时将单位卷至你面前",
        data = {
            {12, 11, 10, 9}, --积攒时间1
            {80, 160, 240, 320}, --爆发伤害2
            function(ap) --爆发伤害加成3
                return ap * 1.2
            end,
            {30, 50, 70, 90}, --降低攻速4
            {20, 25, 30, 35}, --降低移速5
            {2, 3, 4, 5}, --持续时间6
            {5, 10, 15, 20} --暴击率7
        },
        events = {"获得技能", "升级技能", "发动技能", "关闭技能", "失去技能"},
        code = function(this)
            if this.event == "获得技能" then
                this._crit = this:get(7)
                Crit(this.unit, this._crit)
                local state = 0
                this._pasfunc = function()
                    state = 1
                    this.tipname = nil
                    DestroyEffect(this._effect)
                    this._effect = AddSpecialEffectTarget("Abilities\\Spells\\Other\\Tornado\\Tornado_Target.mdl", this.unit, "hand right")
                    local timer = Wait(this:get(1),
                        function()
                            state = 2
                            DestroyEffect(this._effect)
                            this._effect = AddSpecialEffectTarget("CycloneShield.mdx", this.unit, "hand right")
                        end
                    )
                    this._pasflush = function()
                        DestroyTimer(timer)
                        DestroyEffect(this._effect)
                        this._effect = nil
                        return state
                    end
                end
                this._pasfunc()
            elseif this.event == "升级技能" then
                local up = this:get(7) - this._crit
                this._crit = this:get(7)
                if not this.openflag then
                    Crit(this.unit, up)
                end
            elseif this.event == "发动技能" then
                local state = this._pasflush()
                this.tipname = "风王结界"
                this._effect = AddSpecialEffectTarget("war3mapImported\\shizhongjian.mdx", this.unit, "hand right")
                Crit(this.unit, - this._crit)
                if state == 2 then
                    --风王结界爆发
                    StartSound("sound\\H013_Q1.mp3", this.player)
                    
                    local modle = CreateModle("CycloneShield.mdx", this.unit, {z = 50, time = 2, size = 3})
                    local d = this:get(2) + this:get(3)
                    local as, ms = this:get(4), this:get(5)
                    local t = this:get(6)
                    local timer = Loop(0.1,
                        function()
                            SetUnitXY(modle, this.unit)
                        end
                    )
                    Wait(1.5,
                        function()
                            DestroyTimer(timer)
                            local loc
                            if this.research then
                                loc = MovePoint(this.unit, {150, GetUnitFacing(this.unit)})
                            end
                            forRange(this.unit, this:get("area"),
                                function(u)
                                    if EnemyFilter(this.player, u) then
                                        SkillEffect{
                                            from = this.unit,
                                            to = u,
                                            name = this.name,
                                            data = this,
                                            aoe = true,
                                            code = function(data)
                                                if loc then
                                                    Mover{
                                                        unit = data.to,
                                                        speed = 1000,
                                                        angle = GetBetween(data.to, loc, true),
                                                        distance = GetBetween(data.to, loc)
                                                    }
                                                end
                                                SlowUnit{
                                                    from = data.from,
                                                    to = data.to,
                                                    attack = as,
                                                    move = ms,
                                                    time = t,
                                                    aoe = true,
                                                }
                                                Damage(data.from, data.to, d, false, true, {aoe = true, damageReason = this.name})
                                            end
                                        }
                                    end
                                end
                            )
                        end
                    )
                end
            elseif this.event == "关闭技能" then
                this._pasfunc()
                Crit(this.unit, this._crit)
            elseif this.event == "失去技能" then
                DestroyEffect(this._effect)
                Crit(this.unit, - this._crit or 0)
            end
        end
    }
    
    --魔力放出/远离尘世的理想乡
    InitSkill{
        name = "魔力放出",
        tipname = "魔力放出",
        _tipname = "远离尘世的理想乡",
        type = {"主动"},
        ani = "morph",
        _ani = "spell four",
        art = {"BTNMLFC.blp"}, --左边是学习,右边是普通.不填右边视为左边
        _art = {"BTNLXX.blp"},
        cast = 0.1,
        mana = {120, 130, 140, 150},
        _mana = {150, 160, 170, 180},
        cool = 15,
        _cool = 30,
        dur = 10,
        _dur = {4.5, 5, 5.5, 6},
        tip = "\
放射出魔法构建铠甲,吸收受到的伤害.当铠甲存在时,你的攻击附带额外的法术伤害,数值正比于你的铠甲的剩余能量.\n\
|cff00ffcc技能|r: 无目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00铠甲能量|r: %s(|cff1111ff+%d|r)\
|cffffcc00额外伤害|r: %s%%",
        researchtip = "魔力放出:额外伤害会恢复你同等的生命值与法力值\n远离尘世的理想乡:激活时你溢出的生命值会增加生命值上限,持续直到下一次使用远离尘世的理想乡",
        data = {
            {150, 300, 450, 600}, --铠甲能量1
            function(ap)
                return ap * 2.5
            end,
            {9, 11, 13, 15} --伤害系数3
        },
        _tip = "\
获得极高的护甲,抗性与生命恢复速度.持续期间内你处于|cffffcc00霸体|r状态.\n\
|cff00ffcc技能|r: 无目标\n\
|cffffcc00护甲|r: %s\
|cffffcc00抗性|r: %s\
|cffffcc00生命恢复|r: %s(|cff1111ff+%d|r)\n\
|cff888888霸体状态下免疫晕眩,变羊,吹风等令你无法控制的负面效果",
        _data = {
            {100, 200, 300, 400}, --护甲1
            {75, 150, 225, 300}, --魔抗2
            {30, 50, 70, 90}, --生命恢复3
            function(ap)
                return ap * 0.5
            end
        },
        events = {"获得技能", "发动技能", "失去技能"},
        code = function(this)
            if this.event == "发动技能" then
                if this.tipname == "魔力放出" then
                    if this.flush1 then
                        TimerRestart(this._timer1)
                        return
                    end
                    local effect = AddSpecialEffectTarget("war3mapImported\\BigBlueOrbShield.mdx", this.unit, "chest")
                    local hp = this:get(1) + this:get(2)
                    local s = this:get(3) / 100
                    
                    local func1 = Event("伤害减免",
                        function(damage)
                            if damage.to == this.unit then
                                local d = math.min(damage.damage, hp)
                                hp = hp - d
                                damage.damage = damage.damage - d
                                if d == 0 then
                                    this.flush1()
                                end
                            end
                        end
                    )
                    
                    local func2 = Event("伤害效果",
                        function(damage)
                            if damage.attack and damage.from == this.unit then
                                local damage = Damage(damage.from, damage.to, hp * s, false, true, {damageReason = this.name})
                                if damage.damage > 0 and this.research then
                                    Heal(this.unit, this.unit, damage.damage)
                                    SetUnitState(this.unit, UNIT_STATE_MANA, damage.damage + GetUnitState(this.unit, UNIT_STATE_MANA))
                                end
                            end
                        end
                    )
                    
                    this._timer1 = Wait(this:get("dur"),
                        function()
                            if this.flush1 then
                                this.flush1()
                            end
                        end
                    )
                    
                    this.flush1 = function()
                        Event("-伤害减免", func1)
                        Event("-伤害效果", func2)
                        DestroyEffect(effect)
                        this.flush1 = nil
                    end
                elseif this.tipname == "远离尘世的理想乡" then
                    StartSound("sound\\H013_W2.mp3", this.player)
                    if this.flush2 then
                        TimerRestart(this._timer2)
                        return
                    end
                    local effect = AddSpecialEffectTarget("war3mapImported\\BigYellowOrbShield.mdx", this.unit, "chest")
                    local def, ant = this:get(1), this:get(2)
                    local hp = this:get(3) + this:get(4)
                    Def(this.unit, def)
                    Ant(this.unit, ant)
                    Recover(this.unit, hp)
                    
                    this._timer2 = Wait(this:get("dur"),
                        function()
                            if this.flush2 then
                                this.flush2()
                            end
                        end
                    )
                    
                    local func1 = Event("无法控制",
                        function(data)
                            if data.to == this.unit then
                                return true
                            end
                        end
                    )
                    
                    if this._hp > 0 then
                        MaxLife(this.unit, - this._hp)
                        this._hp = 0
                    end
                    
                    local func2
                    
                    if this.research then
                        func2 = Reload("SetUnitState",
                            function(u, state, v)
                                if u == this.unit and state == UNIT_STATE_LIFE then
                                    local hp = v
                                    local mhp = GetUnitState(u, UNIT_STATE_MAX_LIFE)
                                    local fhp = hp - mhp
                                    if fhp > 0 then
                                        fhp = math.ceil(fhp)
                                        this._hp = this._hp + fhp
                                        MaxLife(u, fhp)
                                    end
                                end
                                SetUnitState(u, state, v)
                            end
                        )
                    end
                    
                    this.flush2 = function()
                        DestroyEffect(effect)
                        Def(this.unit, - def)
                        Ant(this.unit, - ant)
                        Recover(this.unit, - hp)
                        Event("-无法控制", func1)
                        if func2 then
                            Reload("-SetUnitState", func2)
                            func2 = nil
                        end
                        this.flush2 = nil
                    end
                    
                    --仅在失去技能时运行
                    this.flush3 = function()
                        if this._hp > 0 then
                            MaxLife(this.unit, - this._hp)
                            this._hp = 0
                        end
                        if func2 then
                            Reload("-SetUnitState", func2)
                            func2 = nil
                        end
                    end
                end
            elseif this.event == "获得技能" then
                local func1 = Event("英雄技能回调",
                    function(data)
                        local that = data.skill
                        if that.unit == this.unit and that.name == "解放真名" and (that.event == "发动技能" or that.event == "关闭技能") then
                            this._change()
                        end
                    end
                )
                
                this._change = function()
                    this.tipname, this._tipname = this._tipname, this.tipname
                    this.art, this._art = this._art, this.art
                    this.ani, this._ani = this._ani, this.ani
                    this.mana, this._mana = this._mana, this.mana
                    this.cool, this._cool = this._cool, this.cool
                    this.dur, this._dur = this._dur, this.dur
                    this.tip, this._tip = this._tip, this.tip
                    this.data, this._data = this._data, this.data
                    SetSkillTip(this.unit, this.id)
                    SetLearnSkillTip(this.unit, this.id)
                end
                
                local that = findSkillData(this.unit, "解放真名")
                if that and that.openflag then
                    this._change()
                end
                
                this._hp = 0
                
                this._flush = function()
                    Event("-发动英雄技能后", func1)
                    if this.flush3 then
                        this.flush3()
                    end
                end
            elseif this.event == "失去技能" then
                if this._flush then
                    this._flush()
                end
            end            
        end
    }
    
    --直感/剑舞
    InitSkill{
        name = "直感",
        tipname = "直感",
        _tipname = "剑舞",
        type = {"主动"},
        ani = nil,
        _ani = "spell three",
        art = {"BTNZG.blp"}, --左边是学习,右边是普通.不填右边视为左边
        _art = {"BTNJW.blp"},
        mana = 50,
        _mana = nil,
        cool = 15,
        _cool = 15,
        dur = 5,
        _dur = nil,
        cast = 0,
        _cast = 0.01,
        time = 0.001,
        _time = 0.6,
        area = {1000, 1500, 2000, 2500},
        _area = 150,
        tip = "\
|cffff00cc主动:|r探知附近的威胁,暂时获得大范围的空中视野.\
|cffff00cc被动:|r阿尔托莉亚的直感能力已经达到可以扭曲未来的程度,有几率使受到的伤害减少.\n\
|cff00ffcc技能|r: 无目标\n\
|cffffcc00扭曲几率|r: %s%%\
|cffffcc00伤害减少|r: %s(|cff1111ff+%.2f|r)%%",
        researchtip = "直感:附近的敌方英雄离开视野后可以继续在大地图上看到,持续1秒.\n剑舞:第3剑附带攻击效果.",
        data = {
            {29, 36, 43, 50}, --扭曲几率1
            {15, 20, 25, 30}, --伤害减少2
            function(ap)
                return ap * 0.1
            end,
        },
        _tip = "\
依次斩出3剑,对前方一片区域内的单位造成伤害.第3剑会推动路径上的单位.\n\
|cff00ffcc技能|r: 无目标\n|cff00ffcc伤害|r: 物理\n\
|cffffcc00第1剑伤害|r: %s(|cffff1111+%d|r)\
|cffffcc00第2剑伤害|r: %s(|cffff1111+%d|r)\
|cffffcc00第3剑伤害|r: %s(|cffff1111+%d|r)\n\
|cff888888每斩出一剑后技能会进入%s秒的短暂冷却\n超过%s秒没有斩出下一剑技能将进入冷却\n第3剑的位移速度是移动速度的1.5倍可以穿越地形",
        _data = {
            {75, 125, 175, 225}, --第1剑 1 2
            function(ap, ad)
                return ad * 1.2
            end,
            {90, 150, 210, 270}, --第2剑 3 4
            function(ap, ad)
                return ad * 1.5
            end,
            {120, 200, 280, 360}, --第3剑 5 6
            function(ap, ad)
                return ad * 2
            end,
            0.4, --斩击间隔7
            3, --斩击超时8
        },
        events = {"获得技能", "发动技能", "失去技能", "停止施放"},
        code = function(this)
            if this.event == "发动技能" then
                if this.tipname == "直感" then
                    local effect = AddSpecialEffectTarget("DarkSummonSeal.mdx", this.unit, "origin")
                    local area = this:get("area")
                    local x, y = GetXY(this.unit)
                    local mr = CreateFogModifierRadius(this.player, FOG_OF_WAR_VISIBLE, x, y, area, true, false)
                    FogModifierStart(mr)
                    local dur = this:get("dur")
                    local time = 0
                    Loop(0.5,
                        function()
                            time = time + 0.5
                            DestroyFogModifier(mr)
                            if time < dur then
                                x, y = GetXY(this.unit)
                                mr = CreateFogModifierRadius(this.player, FOG_OF_WAR_VISIBLE, x, y, area, true, false)
                                FogModifierStart(mr)
                            else
                                EndLoop()
                                DestroyEffect(effect)
                            end
                        end
                    )
                    
                elseif this.tipname == "剑舞" then
                    --结束技能
                    this._func1 = function()
                        --技能进入冷却
                        if this._slash > 0 then
                            local ab = japi.EXGetUnitAbility(this.unit, this.id)
                            local cd = japi.EXGetAbilityState(ab, 1)
                            if cd > 0 then
                                UnitRemoveAbility(this.unit, this.id)
                                UnitAddAbility(this.unit, this.id)
                            end
                            local mcd = this:get("cool")
                            cd = this.targetcooltime - GetTime()
                            if cd > 0 then
                                Wait(0,
                                    function()
                                        SetSkillCool(this.unit, this.id, cd, mcd)
                                    end
                                )
                            end
                        end
                        --重置数据
                        this.ani = "spell three"
                        this.time = 0.6
                        this._slash = 0
                        --清理数据
                        if this._timer then
                            DestroyTimer(this._timer)
                            this._timer = nil
                        end
                    end
                    
                    --启动间隔
                    this._func2 = function()
                        --开始短暂间隔
                        this.freshcool = this:get(7)
                        --超时直接进入冷却
                        local timeout = this:get(8)
                        if not this._timer then
                            this._timer = CreateTimer()
                        end
                        TimerStart(this._timer, timeout, false, this._func1)
                    end
                    
                    this._func3 = function()
                        if this._slashtimer then
                            DestroyTimer(this._slashtimer)
                            this._slashtimer = nil
                        end
                        if this._slashmover then
                            this._slashmover.stop = true
                            this._slashmover = nil
                        end
                    end
                    
                    this._slash = this._slash + 1
                    local area = this:get("area")
                    if this._slash == 1 then
                        --第1剑
                        local d = this:get(1) + this:get(2)
                        this._slashtimer = Wait(0.3,
                            function()
                                this._slashtime = nil
                                local loc = MovePoint(this.unit, {area, GetUnitFacing(this.unit)})
                                forRange(loc, area,
                                    function(u)
                                        if EnemyFilter(this.player, u) then
                                            SkillEffect{
                                                from = this.unit,
                                                to = u,
                                                name = this.name,
                                                data = this,
                                                aoe = true,
                                                code = function(data)
                                                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", data.to, "chest"))
                                                    Damage(data.from, data.to, d, true, false, {aoe = true, damageReason = this.name})
                                                end
                                            }
                                        end
                                    end
                                )
                                TempEffect(loc, "Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile.mdl")
                                SetSoundPosition(gg_snd_MetalHeavyChopFlesh1, loc[1], loc[2], 0)
                                StartSound(gg_snd_MetalHeavyChopFlesh1)
                            end
                        )
                        
                        --激活短暂冷却
                        this._func2()
                        --为下一剑准备数据
                        this.ani = "spell two"
                        --记录冷却时间
                        this.targetcooltime = GetTime() + this:get("cool")
                    elseif this._slash == 2 then
                        --第2剑
                        local d = this:get(3) + this:get(4)
                        this._slashtimer = Wait(0.3,
                            function()
                                this._slashtimer = nil
                                local loc = MovePoint(this.unit, {area, GetUnitFacing(this.unit)})
                                forRange(loc, area,
                                    function(u)
                                        if EnemyFilter(this.player, u) then
                                            SkillEffect{
                                                from = this.unit,
                                                to = u,
                                                name = this.name,
                                                data = this,
                                                aoe = true,
                                                code = function(data)
                                                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", data.to, "chest"))
                                                    Damage(data.from, data.to, d, true, false, {aoe = true, damageReason = this.name})
                                                end
                                            }
                                        end
                                    end
                                )
                                TempEffect(loc, "Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile.mdl")
                                SetSoundPosition(gg_snd_MetalHeavyChopFlesh2, loc[1], loc[2], 0)
                                StartSound(gg_snd_MetalHeavyChopFlesh2)
                                
                            end
                        )
                        --激活短暂冷却
                        this._func2()
                        --为下一剑准备数据
                        this.ani = "spell one"
                        this.time = 1
                        SetSkillTip(this.unit, this.id)
                    elseif this._slash == 3 then
                        --第3剑
                        local d = this:get(5) + this:get(6)
                        local g = {} --保存推进单位组
                        this._slashmover = Mover(
                            {
                                unit = this.unit,
                                speed = GetUnitMoveSpeed(this.unit) * 1.5,
                                angle = GetUnitFacing(this.unit),
                                time = 0.5,
                            },
                            function(move)
                                if move.count % 5 == 1 then --每5个周期,即0.1秒判定一次
                                    local loc = MovePoint(move.unit, {area, move.angle})
                                    for u, t in pairs(g) do
                                        SetUnitXY(u, MovePoint(loc, t))
                                    end
                                    forRange(loc, area,
                                        function(u)
                                            if not g[u] and EnemyFilter(this.player, u) then
                                                g[u] = { --结构为 距离,角度
                                                    GetBetween(loc, u),
                                                    GetBetween(loc, u, true)
                                                }
                                            end
                                        end
                                    )
                                end
                            end,
                            function(move)
                                this._slashmover = nil
                                local loc = MovePoint(this.unit, {area, GetUnitFacing(this.unit)})
                                forRange(loc, area,
                                    function(u)
                                        if EnemyFilter(this.player, u) then
                                            SkillEffect{
                                                from = this.unit,
                                                to = u,
                                                name = this.name,
                                                data = this,
                                                aoe = true,
                                                code = function(data)
                                                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", data.to, "chest"))
                                                    Damage(data.from, data.to, d, true, false, {aoe = true, damageReason = this.name, attack = this.research})
                                                end
                                            }
                                        end
                                    end
                                )
                                TempEffect(loc, "Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile.mdl")
                                SetSoundPosition(gg_snd_MetalHeavyChopFlesh3, loc[1], loc[2], 0)
                                StartSound(gg_snd_MetalHeavyChopFlesh3)
                            end
                        )
                        --结束技能
                        this._func1()
                    end
                end
            elseif this.event == "获得技能" then
                local func1 = Event("伤害减免",
                    function(damage)
                        if damage.to == this.unit and this.tipname == "直感" then
                            if Random(this:get(1)) then
                                damage.damage = damage.damage - damage.odamage * (this:get(2) + this:get(3)) / 100
                                DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdl", this.unit, "chest"))
                            end
                        end
                    end
                )
                
                local func2 = Event("英雄技能回调",
                    function(data)
                        local that = data.skill
                        if that.unit == this.unit and that.name == "解放真名" and (that.event == "发动技能" or that.event == "关闭技能") then
                            if that.event == "关闭技能" then
                                if this._func1 then
                                    this._func1()
                                end
                            end
                            this._change()
                        end
                    end
                )
                
                local func3 = Event("可见度",
                    function(data)
                        if this.research and not data.reason and this.tipname == "直感" and IsHero(data.unit) and
                        IsUnitEnemy(data.unit, this.player) and GetBetween(this.unit, data.unit) < this:get("area") then
                            SeeUnit(data.unit)
                            Wait(1,
                                function()
                                    SeeUnit(data.unit, false)
                                end
                            )
                        end
                    end
                )
                
                this._change = function()
                    this.tipname, this._tipname = this._tipname, this.tipname
                    this.art, this._art = this._art, this.art
                    this.ani, this._ani = this._ani, this.ani
                    this.cast, this._cast = this._cast, this.cast
                    this.time, this._time = this._time, this.time
                    this.mana, this._mana = this._mana, this.mana
                    this.cool, this._cool = this._cool, this.cool
                    this.area, this._area = this._area, this.area
                    this.dur, this._dur = this._dur, this.dur
                    this.tip, this._tip = this._tip, this.tip
                    this.data, this._data = this._data, this.data
                    SetSkillTip(this.unit, this.id)
                    SetLearnSkillTip(this.unit, this.id)
                end
                
                local that = findSkillData(this.unit, "解放真名")
                if that and that.openflag then
                    this._change()
                end
                
                this._slash = 0 --斩击次数
                
                this.flush = function()
                    Event("-伤害减免", func1)
                    Event("-英雄技能回调", func2)
                    Event("-可见度", func3)
                    if this.tipname == "剑舞" then
                        this._func1()
                    end
                end
            elseif this.event == "失去技能" then
                if this.flush then
                    this.flush()
                end
            elseif this.event == "停止施放" then
                if this._func3 then
                    this._func3()
                end
            end
        end
    }
    
    --风王铁槌/誓约胜利之剑
    InitSkill{
        name = "风王铁槌",
        tipname = "风王铁槌",
        _tipname = "誓约胜利之剑",
        type = {"开关", 2},
        ani = "spell three",
        _ani = "spell channel one",
        art = {"BTNFWZC.blp", "BTNFWZC.blp", "BTNFWZC2.blp"},
        _art = {"BTNSYSLZJ.blp", "BTNSYSLZJ.blp", "BTNSYSLZJ2.blp"},
        cast = 0.1,
        _cast = 0,
        time = 1,
        _time = 7,
        mana = {150, 200, 250},
        _mana = {200, 400, 600},
        cool = 15,
        _cool = 45,
        area = 300,
        _area = 350,
        rng = 1500, 
        _rng = 1800,
        dur = 1.5,
        _dur = 5,
        tip = "\
利用风王结界将压缩的风暴释放,对一条直线上的单位造成伤害并将他们向两边推开.使用后再次激活该技能将跟随风暴前进,但是技能冷却时间变为30秒.\n\
|cff00ffcc技能|r: 点目标\
|cff00ffcc伤害|r: 法术\n\
|cffffcc00造成伤害|r: %s(|cff1111ff+%d|r)\n\
|cff888888风暴飞行速度为%s\n再次激活技能的限制时间为%s秒\n跟随速度为风王铁槌的2倍",
        researchtip = {
            "风王铁槌的施法距离翻倍",
            "移除誓约胜利之剑的冷却时间,但是无法提前施放",
            "刷新其他技能的冷却时间",
        },
        data = {
            {200, 400, 600}, --伤害 1 2
            function(ap)
                return ap * 2.5
            end,
            1000, --速度3
            1.5, --限制时间4
        },
        _tip = "\
经过一段时间的能量积蓄后,对一条直线上的单位造成惊人的伤害,积蓄时间越长伤害越高.\n\
|cff00ffcc技能|r: 点目标\
|cff00ffcc伤害|r: 法术\n\
|cffffcc00最小积蓄时间|r: %s\
|cffffcc00最小伤害|r: %s(|cff1111ff+%d|r)\
|cffffcc00最大积蓄时间|r: %s\
|cffffcc00最大伤害|r: %s(|cff1111ff+%d|r)\n\
|cff888888通过再次激活该技能来提前施放\n伤害在2秒内分8次造成",
        _data = {
            2, --最小时间1
            {200, 400, 600}, --最小伤害 2 3
            function(ap)
                return ap * 2.5
            end,
            5, --最大时间4
            {600, 1200, 1800}, --最大伤害 5 6
            function(ap)
                return ap * 7.5
            end,
        },
        events = {"发动技能", "关闭技能", "获得技能", "失去技能", "停止施放", "研发"},
        code = function(this)
            if this.event == "发动技能" then
                if this.research[3] then
                    for i = 1, 3 do
                        local t = findSkillData(this.unit, i)
                        if t and t.targetcooltime then
                            t.targetcooltime = 0
                        end
                        SetSkillCool(this.unit, i, 0)
                    end
                end
                if this.tipname == "风王铁槌" then
                    local angle = GetBetween(this.unit, this.target, true)
                    local speed = this:get(3)
                    local distance = this:get("rng")
                    local g = {}
                    local d = this:get(1) + this:get(2)
                    local area = this:get("area")
                    local mod = {}
                    for i = 1, 8 do
                        mod[i] = CreateModle("Abilities\\Spells\\Other\\Tornado\\TornadoElementalSmall.mdl", MovePoint(this.unit, {area / 2, angle + 45 * i}), {size = 0.5})
                    end
                    
                    StartSound("sound\\H013_R1.mp3", this.player)
                    
                    local mover = Mover(
                        {
                            from = this.unit,
                            modle = "Abilities\\Spells\\NightElf\\Cyclone\\CycloneTarget.mdl",
                            size = 1.5,
                            speed = speed,
                            angle = angle,
                            distance = distance,
                        },
                        function(move)
                            angle = angle + 15
                            for i = 1, 8 do
                                SetUnitXY(mod[i], MovePoint(move.unit, {area / 2, angle + 45 * i}))
                            end                            
                            if move.count % 5 == 0 then --0.1秒判定一次
                                forRange(move.unit, area,
                                    function(u)
                                        if not g[u] and EnemyFilter(this.player, u) then
                                            g[u] = true
                                            Damage(move.from, u, d, false, true, {aoe = true, damageReason = this.name})
                                            local a = GetBetween(move.unit, u, true) --中心到单位的角度
                                            local dis = GetBetween(move.unit, u) --中心到单位的距离
                                            local angle = move.angle
                                            local pa = math.A2A(a, angle) --夹角
                                            local pd = Sin(pa) * dis
                                            if math.A2A(a, angle + 90) < math.A2A(a, angle - 90) then
                                                a = angle + 90
                                            else
                                                a = angle - 90
                                            end
                                            Mover{
                                                unit = u,
                                                speed = 500,
                                                angle = a,
                                                distance = area - pd
                                            }
                                        end
                                    end
                                )
                            end
                        end,
                        nil,
                        function(move)
                            for i = 1, 8 do
                                KillUnit(mod[i])
                                RemoveUnit(mod[i])
                            end
                        end
                    )
                    
                    this.flush1 = function()
                        Wait(0.01,
                            function()
                                SetUnitAnimation(this.unit, "spell channel")
                            end
                        )
                        SetUnitFacing(this.unit, GetBetween(this.unit, mover.unit, true))
                        local effect = AddSpecialEffectTarget("BladeShockwave.mdl", this.unit, "chest")
                        Mover(
                            {   
                                unit = this.unit,
                                speed = speed * 2,
                                target = mover.unit
                            },
                            nil,
                            nil,
                            function(move)
                                DestroyEffect(effect)
                            end
                        )
                        this.freshcool = 30
                    end
                elseif this.tipname == "誓约胜利之剑" then                    
                    local effect = AddSpecialEffect("war3mapImported\\ex light.mdx", GetXY(this.unit))
                    local min = this:get(1)
                    if this.research[2] then
                        min = 5
                        this.freshcool = 0
                    end
                    SetSkillCool(this.unit, this.id, min, min) --激活2秒冷却(作为最小间隔)
                    
                    local sound = StartSound("sound\\H013_R2.mp3", this.player)
                    Wait(1.5,
                        function()
                            StopSound(sound, true, false)
                        end
                    )
                    
                    Wait(0,
                        function()
                            local ab = japi.EXGetUnitAbility(this.unit, this.id)
                            japi.EXSetAbilityDataReal(ab, 1, 108, 2) --手动关闭时会施法2秒
                        end
                    )
                    
                    local angle = GetBetween(this.unit, this.target, true)
                    
                    --预创建2个闪电效果
                    local l1 = Lightning{
                        from = this.unit,
                        name = 'LN04',
                        check = false,
                        x1 = 0,
                        y1 = 0,
                        z1 = 0,
                        x2 = 0,
                        y2 = 0,
                        z2 = 0,
                        color = {1, 1, 0, 0},
                        cut = false
                    }
                    
                    --第2个闪电效果延迟0.25秒创建以保证流动纹路不同
                    local l2 = Lightning{
                        from = this.unit,
                        name = 'LN05',
                        check = false,
                        x1 = 0,
                        y1 = 0,
                        z1 = 0,
                        x2 = 0,
                        y2 = 0,
                        z2 = 0,
                        color = {1, 1, 1, 0},
                        cut = false
                    }
                    
                    local d1 = this:get(2) + this:get(3)
                    local d2 = this:get(5) + this:get(6)
                    local t1 = this:get(1)
                    local t2 = this:get(4)
                    local area = this:get("area")
                    
                    local opentime = this.spellflag
                    
                    this.flush2 = function()
                        Wait(0.01,
                            function()
                                SetUnitAnimation(this.unit, "spell channel two")
                            end
                        )
                        local loc = GetUnitLoc(this.unit)
                        
                        local sound = StartSound("sound\\H013_R2.mp3", this.player)
                        SetSoundPlayPosition(sound, 1500)
                        
                        local t = GetTime() - opentime
                        local s = (t - t1) / (t2 - t1)
                        local d = d1 + (d2 - d1) * s
                        d = d / 8
                        
                        local x1, y1, z1 = loc[1], loc[2], GetZ(loc) + 200
                        local target = MovePoint(loc, {this:get("rng"), angle})
                        local x2, y2, z2 = target[1], target[2], z1
                        
                        local targetmod = CreateModle("Abilities\\Spells\\Demon\\ReviveDemon\\ReviveDemon.mdl", target, {time = 2, angle = angle, size = 2, z = z2})
                        
                        local mods = {}
                        ForLoop(0.2, 1, 3,
                            function(count)
                                if count == 1 then
                                    mods[4] = CreateUnitAtLoc(this.player, |e00K|, loc, angle)
                                end
                                mods[count] = CreateUnitAtLoc(this.player, |e034|, loc, angle)
                            end
                        )
                        
                        Wait(3,
                            function()
                                for i = 1, 4 do
                                    KillUnit(mods[count])
                                end
                            end
                        )
                        
                        l1.x1, l1.y1, l1.z1 = x1, y1, z1
                        l1.cut = true
                        l2.x1, l2.y1, l2.z1 = x1, y1, z1
                        ForLoop(0.05, 1, 40,
                            function(i)
                                local a = 1
                                if i < 11 then
                                    a = i * 0.1
                                elseif i > 29 then
                                    a = (40 - i) * 0.1
                                end
                                l1.color[4] = a
                                l1.x2, l1.y2, l1.z2 = x2, y2, z2
                                ChangeLightning(l1)
                                l2.color[4] = a
                                l2.x2, l2.y2, l2.z2 = l1.x2, l1.y2, l1.z2
                                ChangeLightning(l2)
                                if i % 5 == 0 then
                                    forSeg(loc, {l1.x2, l1.y2}, area,
                                        function(u)
                                            if EnemyFilter(this.player, u) then
                                                SkillEffect{
                                                    from = this.unit,
                                                    to = u,
                                                    name = this.name,
                                                    data = this,
                                                    aoe = true,
                                                    code = function(data)
                                                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\StaffOfPurification\\PurificationTarget.mdl", data.to, "origin"))
                                                        Damage(data.from, data.to, d, false, true, {aoe = true, damageReason = this.name})
                                                    end
                                                }
                                            end
                                        end
                                    )
                                end
                                if i == 40 then
                                    this.flush3()
                                end
                            end
                        )
                    end
                    
                    this.flush3 = function()
                        DestroyEffect(effect)
                        if l1 then
                            DestroyLightning(l1.l)
                        end
                        if l2 then
                            DestroyLightning(l2.l)
                        end
                        l1 = nil
                        l2 = nil
                    end
                end
            elseif this.event == "关闭技能" then
                if this.tipname == "风王铁槌" then
                    if this.closereason == "手动关闭" then
                        --玩家主动关闭技能
                        this.flush1()
                    end
                elseif this.tipname == "誓约胜利之剑" then
                    if this.closereason == "持续时间" or this.closereason == "手动关闭" then
                        this.flush2()
                    else
                        UnitRemoveAbility(this.unit, this.id)
                        UnitAddAbility(this.unit, this.id)
                        this.flush3()
                    end
                end
            elseif this.event == "停止施放" then
                if this.openflag and this.tipname == "誓约胜利之剑" then
                    Wait(0,
                        function()
                            this:closeskill()
                        end
                    )
                end
            elseif this.event == "获得技能" then
                this._change = function()
                    this.tipname, this._tipname = this._tipname, this.tipname
                    this.art, this._art = this._art, this.art
                    this.ani, this._ani = this._ani, this.ani
                    this.cast, this._cast = this._cast, this.cast
                    this.time, this._time = this._time, this.time
                    this.mana, this._mana = this._mana, this.mana
                    this.cool, this._cool = this._cool, this.cool
                    this.area, this._area = this._area, this.area
                    this.dur, this._dur = this._dur, this.dur
                    this.rng, this._rng = this._rng, this.rng
                    this.tip, this._tip = this._tip, this.tip
                    this.data, this._data = this._data, this.data
                    SetSkillTip(this.unit, this.id)
                    SetLearnSkillTip(this.unit, this.id)
                end
                
                local that = findSkillData(this.unit, "解放真名")
                if that and that.openflag then
                    this._change()
                end
                
                local func1 = Event("英雄技能回调",
                    function(data)
                        local that = data.skill
                        if that.unit == this.unit and that.name == "解放真名" and (that.event == "发动技能" or that.event == "关闭技能") then
                            Wait(0,
                                function()
                                    this._change()
                                end
                            )
                            if this.openflag and this.tipname == "风王铁槌" then
                                this:closeskill()
                            end
                        end
                    end
                )
                
                this.flush = function()
                    Event("-发动英雄技能后", func1)
                end
            elseif this.event == "失去技能" then
                if this.flush then
                    this.flush()
                end
            elseif this.event == "研发" then
                if this.lastResearch == 1 then
                    if this.tipname == "风王铁槌" then
                        this.rng = this.rng * 2
                        SetSkillTip(this.unit, this.id)
                        SetLearnSkillTip(this.unit, this.id)
                    else
                        this._rng = this._rng * 2
                    end
                end
            end
        end
    }
