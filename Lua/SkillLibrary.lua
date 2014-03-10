    --过滤器
    EnemyFilter = function(p1, u2, t)
        if IsUnitDead(u2) then
            return false
        elseif t and t["别人"] and GetOwningPlayer(u2) == p1 then
            return false
        elseif not (t and t["马甲"]) and GetUnitAbilityLevel(u2, |Aloc|) == 1 then
            return false
        elseif not (t and t["友军"]) and IsUnitAlly(u2, p1) then
            return false
        elseif not (t and t["魔免"]) and IsUnitType(u2, UNIT_TYPE_MAGIC_IMMUNE) then
            return false
        elseif not (t and t["无敌"]) and GetUnitAbilityLevel(u2, |Avul|) == 1 then
            return false
        elseif not (t and t["建筑"]) and IsUnitType(u2, UNIT_TYPE_STRUCTURE) then
            return false
        elseif t and t["英雄"] and not IsHeroUnitId(u2) then
            return false
        end
        return true
    end
    
    --寻找技能  单位,位置/名称/ID
    findSkillData = function(u, i)
        local t = Mark(u, "技能")
        if t then
            return t[i]
        end
    end
    
    --技能效果    
    SkillEffect = function(data)
        if toEvent("技能效果", data) then return end
        if toEvent("抵挡", data) then return end
        data:code()        
    end
    
    --通用马甲
    local Dummy = CreateUnitAtLoc(Player(15), |e01B|, MH.temp, 0)
    
    --自定义技能
    DummySkill = function(data)
        UnitAddAbility(Dummy, data.skill)
        if data.x then
            SetUnitX(Dummy, data.x)
        end
        if data.y then
            SetUnitY(Dummy, data.y)
        end
        if data.point then
            if type(data.point) == "table" then
                SetUnitX(Dummy, data.point[1])
                SetUnitY(Dummy, data.point[2])
            else
                SetUnitX(Dummy, GetWidgetX(data.point))
                SetUnitY(Dummy, GetWidgetY(data.point))
            end
        end
        if type(data.target) == "nil" then
            IssueImmediateOrder(Dummy, data.order)
        elseif type(data.target) == "table" then
            IssuePointOrderLoc(Dummy, data.order, data.target)
        else
            IssueTargetOrder(Dummy, data.order, data.target)
        end
    end
    
    --单位是否可以使用物品
    CanUseItem = function(u)
        return not toEvent("是否无法使用物品", {unit = u})
    end
    
    --击晕单位   单位,时间,来源
    UnitAddAbility(Dummy, |A143|)
    
    StunUnit = function(data)
        if toEvent("debuff", "晕眩", "无法施法", "无法控制", data) then return end
        if IssueTargetOrder(Dummy, "thunderbolt", data.to) then
            Mark(data.to, "晕眩计数", (Mark(data.to, "晕眩计数") or 0) + 1)
            local count = Mark(data.to, "debuff驱散计数")
            Wait(data.time,
                function()
                    if count == Mark(data.to, "debuff驱散计数") then
                        Mark(data.to, "晕眩计数", (Mark(data.to, "晕眩计数") or 0) - 1)
                        if Mark(data.to, "晕眩计数") == 0 then
                            UnitRemoveAbility(data.to, |BPSE|)
                            toEvent("晕眩结束", data)
                        end
                    end
                end
            )
        end
    end
    
    Event("晕眩", "晕眩结束",
        function(data)
            if data.event == "晕眩" then
                if IsUnitType(data.to, UNIT_TYPE_HERO) and IsUnitAlive(data.to) then
                    local p = GetOwningPlayer(data.to)
                    local i =GetPlayerId(p)
                    if data.to == Hero[i] then
                        --晃动镜头,创建滤镜
                        if p == SELFP then
                            CameraSetSourceNoiseEx(100.00, 1000.00, false)
                            CinematicFilterGenericBJ( 0.20, BLEND_MODE_ADDITIVE, "ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp", 100, 100, 100, 0.00, 100.00, 100.00, 100.00, 50.00 )
                        end
                        Wait(0.2,
                            function()
                                if p == SELFP then
                                    CameraSetSourceNoise(0, 0)
                                    SetCineFilterDuration(0)
                                end
                            end
                        )
                    end
                end
            elseif data.event == "晕眩结束" then
                if IsUnitType(data.to, UNIT_TYPE_HERO) then
                    local p = GetOwningPlayer(data.to)
                    local i =GetPlayerId(p)
                    if data.to == Hero[i] then
                        if p == SELFP then
                            CinematicFilterGenericBJ( 0.20, BLEND_MODE_ADDITIVE, "ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp", 100, 100, 100, 50.00, 100.00, 100.00, 100.00, 100.00 )
                        end
                    end
                end
            end
        end
    )
    
    Event("驱散",
        function(this)
            if this.debuff then
                UnitRemoveAbility(this.to, |BPSE|)
            end
        end
    )
    
    Event("是否无法使用物品",
        function(this)
            return GetUnitAbilityLevel(this.unit, |BPSE|) == 1
        end
    )
    
    --减速单位
    UnitAddAbility(Dummy, |A14A|)
    
    SlowUnit = function(data)
        if toEvent("debuff", "减速", data) then return end
        local skill = japi.EXGetUnitAbility(Dummy, |A14A|)
        japi.EXSetAbilityDataReal(skill, 1, 109, (data.attack or 0)*0.01) --攻击速度
        japi.EXSetAbilityDataReal(skill, 1, 108, (data.move or 0)*0.01) --移动速度
        japi.EXSetAbilityDataReal(skill, 1, 102, data.time or 1) --持续时间
        japi.EXSetAbilityDataReal(skill, 1, 103, data.time or 1) --持续时间
        IssueTargetOrder(Dummy, "slow", data.to)
    end
    
    Event("驱散",
        function(this)
            if this.debuff then
                UnitRemoveAbility(this.to, |B02R|)
            end
        end
    )
    
    --末日
    UnitAddAbility(Dummy, |A14P|)
    
    DoomUnit = function(data)
        if toEvent("debuff", "末日", "无法施法", data) then return end
        local skill = japi.EXGetUnitAbility(Dummy, |A14P|)
        japi.EXSetAbilityDataReal(skill, 1, 102, data.time or 1) --持续时间
        japi.EXSetAbilityDataReal(skill, 1, 103, data.time or 1) --持续时间
        IssueTargetOrder(Dummy, "doom", data.to)
    end
    
    Event("驱散",
        function(this)
            if this.debuff then
                UnitRemoveAbility(this.to, |BNdo|)
            end
        end
    )
    
    Event("是否无法使用物品",
        function(this)
            return GetUnitAbilityLevel(this.unit, |BNdo|) == 1
        end
    )
    
    --中毒
    PoisonUnit = function(data)
        if toEvent("debuff", "中毒", data) then return end
        data.flashdamage = data.damage / data.time
        data.dot = true
        local that = Mark(data.to, "中毒")
        if that then
            if data.damage > that.damage then
                data.timer = that.timer
                Mark(data.to, "中毒", data)
            end
        else
            UnitAddAbility(data.to, |A14U|)
            data.timer = Loop(1,
                function()
                    local data = Mark(data.to, "中毒")
                    if data then
                        Damage(data.from, data.to, data.flashdamage, false, true, data)
                        data.damage = data.damage - data.flashdamage
                        if data.damage < 0.001 or IsUnitDead(data.to) then
                            EndLoop()
                            Mark(data.to, "中毒", false)
                            UnitRemoveAbility(data.to, |A14U|)
                            UnitRemoveAbility(data.to, |B06A|)
                        end
                    else
                        EndLoop()
                    end
                end
            )
            Mark(data.to, "中毒", data)
        end
    end
    
    Event("驱散", "死亡",
        function(this)
            local that
            if this.event == "驱散" then
                if this.debuff then
                    that = Mark(this.to, "中毒")
                end
            elseif this.event == "死亡" then
                that = Mark(this.unit, "中毒")
            end
            if that then
                PauseTimer(that.timer)
                DestroyTimer(that.timer)
                UnitRemoveAbility(that.to, |A14U|)
                UnitRemoveAbility(that.to, |B06A|)
                Mark(that.to, "中毒", false)
            end
        end
    )
    
    --致盲
    BlindUnit = function(data)
        if toEvent("debuff", "致盲", data) then return end
        local that = Mark(data.to, "致盲")
        if that then
            TimerStart(that.timer, data.time, false,
                function()
                    DestroyTimer(GetExpiredTimer())
                    that.func()
                end
            )
            Mark(data.to, "致盲", data)
        else
            UnitAddAbility(data.to, |A14V|)
            data.timer, data.func = Wait(data.time,
                function()
                    local data = Mark(data.to, "致盲")
                    if data then
                        Mark(data.to, "致盲", false)
                        UnitRemoveAbility(data.to, |A14V|)
                        UnitRemoveAbility(data.to, |B06B|)
                    end
                end
            )
            Mark(data.to, "致盲", data)
        end
    end
    
    Event("死亡", "驱散", "伤害无效",
        function(this)
            local that
            if this.event == "死亡" then
                that = Mark(this.unit, "致盲")
            elseif this.event == "驱散" then
                if this.debuff then
                    that = Mark(this.to, "致盲")
                end
            elseif this.event == "伤害无效" then
                if this.attack then
                    that = Mark(this.from, "致盲")
                end
            end
            if that then
                if this.event == "伤害无效" then
                    if GetRandomInt(0, 99) < that.miss then
                        this.dodgReason = "未击中"
                        return true
                    end
                else
                    DestroyTimer(that.timer)
                    UnitRemoveAbility(that.to, |A14V|)
                    UnitRemoveAbility(that.to, |B06B|)
                    Mark(that.to, "致盲", false)
                end
            end
        end
    )
    
    --麻痹单位
    UnitAddAbility(Dummy, |A15Z|)
    
    BenumbUnit = function(data)
        if toEvent("debuff", "麻痹", data) then return end
        local skill = japi.EXGetUnitAbility(Dummy, |A15Z|)
        japi.EXSetAbilityDataReal(skill, 1, 102, data.time or 1) --持续时间
        japi.EXSetAbilityDataReal(skill, 1, 103, data.time or 1) --持续时间
        IssueTargetOrder(Dummy, "drunkenhaze", data.to)
    end
    
    Event("驱散",
        function(this)
            if this.debuff then
                UnitRemoveAbility(this.to, |B01P|)
            end
        end
    )
    
    --吹起单位
    UnitAddAbility(Dummy, |A18K|)
    
    BlowUnit = function(data)
        if data.good then
            if toEvent("buff", "吹风", "无法施法", "无法控制", data) then return end
        else
            if toEvent("debuff", "吹风", "无法施法", "无法控制", data) then return end
        end
        local skill = japi.EXGetUnitAbility(Dummy, |A18K|)
        japi.EXSetAbilityDataReal(skill, 1, 102, data.time or 1) --持续时间
        japi.EXSetAbilityDataReal(skill, 1, 103, data.time or 1) --持续时间
        if IssueTargetOrder(Dummy, "cyclone", data.to) then
            UnitAddAbility(data.to, |Avul|)
            Wait(data.time or 1,
                function()
                    UnitRemoveAbility(data.to, |Avul|)
                end
            )
        end
    end
    
    Event("驱散",
        function(this)
            UnitRemoveAbility(this.to, |Bcyc|)
        end
    )
    
    Event("是否无法使用物品",
        function(this)
            return GetUnitAbilityLevel(this.unit, |Bcyc|) == 1
        end
    )
    
    --变羊单位
    UnitAddAbility(Dummy, |A18L|)
    
    HexUnit = function(data)
        if toEvent("debuff", "变羊", "无法施法", "无法控制", data) then return end
        local skill = japi.EXGetUnitAbility(Dummy, |A18L|)
        japi.EXSetAbilityDataReal(skill, 1, 102, data.time or 1) --持续时间
        japi.EXSetAbilityDataReal(skill, 1, 103, data.time or 1) --持续时间
        IssueTargetOrder(Dummy, "polymorph", data.to)
    end
    
    Event("驱散",
        function(this)
            UnitRemoveAbility(this.to, |Bply|)
        end
    )
    
    Event("是否无法使用物品",
        function(this)
            return GetUnitAbilityLevel(this.unit, |Bply|) == 1
        end
    )
    
    --燃烧单位
    FireUnit = function(data)
        if toEvent("debuff", "燃烧", data) then return end
        local time = math.floor(data.time)
        local flashdamage = data.damage / (time + 1)
        local timed = -1
        data.dot = true
        local e = AddSpecialEffectTarget("Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeDamageTarget.mdl", data.to, "origin")
        LoopRun(1,
            function()
                Damage(data.from, data.to, flashdamage, false, true, data)
                timed = timed + 1
                if timed >= time then
                    EndLoop()
                    DestroyEffect(e)
                end
            end
        )
    end
    
    --驱散计数
    Event("驱散",
        function(this)
            if this.buff then
                Mark(this.to, "buff驱散计数", (Mark(this.to, "buff驱散计数") or 0) + 1)
            elseif this.debuff then
                Mark(this.to, "debuff驱散计数", (Mark(this.to, "debuff驱散计数") or 0) + 1)
            end
        end
    )
    
    --驱散
    CleanUnit = function(this)
        toEvent("驱散", this)
    end
    
    --改变缩放
    ChangeSize = function(u, s)
        local sz = GetModleSize(u)
        local rs = sz + s
        SetUnitScale(u, rs, rs, rs)
        Mark(u, "模型缩放", rs)
    end
    
    --设置技能冷却    第三个个参数选填,不填为默认冷却
    SetSkillCool = function(u, id, c, maxc)
        local t = findSkillData(u, id)
        local data = japi.EXGetUnitAbility(u, id) or japi.EXGetUnitAbility(u, t.id)
        if not data then return end
        local lv = GetUnitAbilityLevel(u, id)
        if not c then
            if t then
                c = t:get("cool")
            else
                c = japi.EXGetAbilityDataReal(data, lv, 105)
            end
        end
        if maxc then
            local cc = japi.EXGetAbilityDataReal(data, lv, 105)
            japi.EXSetAbilityDataReal(data, lv, 105, maxc)
        end
        japi.EXSetAbilityState(data, 1, c)
        if maxc then
            japi.EXSetAbilityDataReal(data, lv, 105, cc)
        end
        return c
    end
    
    --增加攻击速度
    UnitAddAbility(Dummy, |A14H|)
    
    AttackSpeed = function(u, a)
        a = a * 0.01 + (Mark(u, "额外攻击速度") or 0)
        Mark(u, "额外攻击速度", a)
        local ab = japi.EXGetUnitAbility(Dummy, |A14H|)
        japi.EXSetAbilityDataReal(ab, 2, 108, a)
        if UnitAddAbility(u, |A14H|) then
            UnitMakeAbilityPermanent(u, true, |A14H|)
        else
            SetUnitAbilityLevel(u, |A14H|, 1)
        end
        SetUnitAbilityLevel(u, |A14H|, 2)
    end
    
    --增加移动速度
    MoveSpeed = function(u, m)
        local m = m + (Mark(u, "额外移动速度") or 0)
        Mark(u, "额外移动速度", m)
        SetUnitMoveSpeed(u, m + GetUnitDefaultMoveSpeed(u))
    end
    
    --允许攻击
    EnableAttack = function(u, b)
        if b == false then
            if UnitAddAbility(u, |Abun|) then
                UnitMakeAbilityPermanent(u, true, |Abun|)
            end
            Mark(u, "禁止攻击", (Mark(u, "禁止攻击") or 0) + 1)
        else
            Mark(u, "禁止攻击", (Mark(u, "禁止攻击") or 0) - 1)
            if Mark(u, "禁止攻击") == 0 then
                UnitRemoveAbility(u, |Abun|)
            end
        end
    end
    
    --缴械单位
    DisarmUnit = function(data)
        if toEvent("debuff", "缴械", data) then return end
        local t = Mark(data.to, "缴械")
        if not t then
            t = {
                timer = CreateTimer(),
                targettime = 0,
                func = function()
                    DestroyTimer(t.timer)
                    Mark(data.to, "缴械", false)
                    EnableAttack(data.to)
                    DestroyEffect(t.effect)
                end,
                effect = AddSpecialEffectTarget("Abilities\\Spells\\Other\\TalkToMe\\TalkToMe.mdl", data.to, "overhead")
            }
            Mark(data.to, "缴械", t)
            EnableAttack(data.to, false)
        end
        local target = data.time + GetTime()
        if target > t.targettime then
            TimerStart(t.timer, data.time, false, t.func)
        end
    end
    
    Event("驱散",
        function(this)
            if this.debuff then
                local that = Mark(this.to, "缴械")
                if that then
                    that.func()
                end
            end
        end
    )
    
    --沉默单位
    UnitAddAbility(Dummy, |A19W|)
    
    SilentUnit = function(data)
        if toEvent("debuff", "沉默", "无法施法", data) then return end
        local skill = japi.EXGetUnitAbility(Dummy, |A19W|)
        japi.EXSetAbilityDataReal(skill, 1, 111, 0)
        japi.EXSetAbilityDataReal(skill, 1, 102, data.time or 1) --持续时间
        japi.EXSetAbilityDataReal(skill, 1, 103, data.time or 1) --持续时间
        IssueTargetOrder(Dummy, "soulburn", data.to)
    end
    
    Event("驱散",
        function(this)
            UnitRemoveAbility(this.to, |BNsi|)
        end
    )
    
    --束缚单位
    BoundUnit = function(data)
        if toEvent("debuff", "束缚", data) then return end
        local t = Mark(data.to, "束缚")
        if not t then
            t = {
                timer = CreateTimer(),
                targettime = 0,
                func = function()
                    DestroyTimer(t.timer)
                    Mark(data.to, "束缚", false)
                    MoveSpeed(data.to, 10000)
                    DestroyEffect(t.effect)
                end,
                effect = AddSpecialEffectTarget("Abilities\\Spells\\Orc\\Ensnare\\ensnareTarget.mdl", data.to, "origin")
            }
            Mark(data.to, "束缚", t)
            MoveSpeed(data.to, -10000)
        end
        local target = data.time + GetTime()
        if target > t.targettime then
            TimerStart(t.timer, data.time, false, t.func)
        end
    end
    
    Event("驱散",
        function(this)
            if this.debuff then
                local that = Mark(this.to, "束缚")
                if that then
                    that.func()
                end
            end
        end
    )
    
    --冻结单位
    local Freeze = {
        name = "冻结",
        add = function(this, u)
            local hp, mp = GetRecover(u)
            SetUnitTimeScale(u, 0)
            Recover(u, - hp, - mp)
            
            this.units[u] = {
                timescale = 1, --动画播放速度
                hp = hp, --回血速度
                mp = mp, --回蓝速度
                damages = {}, --伤害栈
                heals = {}, --治疗栈
            }
            
            this.count = this.count + 1
            if this.count == 1 then
                this.func1 = Event("伤害无效",
                    function(damage)
                        local data = this.units[damage.to]
                        if data then
                            table.insert(data.damages, damage)
                            dodgeReason = this.name
                            return true
                        end
                    end
                )
                
                this.func2 = Event("治疗无效",
                    function(heal)
                        local data = this.units[heal.to]
                        if data then
                            table.insert(data.heals, heal)
                            dodgeReason = this.name
                            return true
                        end
                    end
                )
                
                this.func3 = Reload("Recover",
                    function(u, hp, mp)
                        local data = this.units[u]
                        if data then
                            data.hp = data.hp + (hp or 0)
                            data.mp = data.mp + (mp or 0)
                        else
                            Recover(u, hp, mp)
                        end
                    end
                )
                
                this.func4 = Reload("SetUnitTimeScale",
                    function(u, r)
                        local data = this.units[u]
                        if data then
                            data.timescale = r
                        else
                            SetUnitTimeScale(u, r)
                        end
                    end
                )
            end
        end,
        remove = function(this, u)
            local data = this.units[u]
            
            this.units[u] = nil
            SetUnitTimeScale(u, data.timescale)
            Recover(u, data.hp, data.mp)
            
            this:callback(data, u) --开始回溯生命与法力
            
            this.count = this.count - 1
            if this.count == 0 then
                --释放Reload节省资源
                Event("-伤害无效", func1)
                Event("-治疗无效", func2)
                Reload("-Recover", func3)
                Reload("-SetUnitTimeScale", func4)
            end
        end,
        callback = function(this, data, u)
        
            local hp = GetUnitState(u, UNIT_STATE_LIFE)
            local mhp = GetUnitState(u, UNIT_STATE_MAX_LIFE)
            local mp = GetUnitState(u, UNIT_STATE_MANA)
            local mmp = GetUnitState(u, UNIT_STATE_MAX_MANA)
                        
            --开始回溯
            MaxLife(u, 50000, true) --增加血量上限,维持当前血量
            MaxMana(u, 50000, true) --增加法力上限,维持当前法力
            local func = Reload("GetUnitState",
                function(who, s)
                    if who == u then
                        if s == UNIT_STATE_MAX_LIFE then
                            return mhp
                        elseif s == UNIT_STATE_LIFE then
                            return hp
                        elseif s == UNIT_STATE_MAX_MANA then
                            return mmp
                        elseif s == UNIT_STATE_MANA then
                            return mp
                        end
                    end
                    return GetUnitState(who, s)
                end
            )
            
            for _, heal in ipairs(data.heals) do
                local heal = Heal(heal.from, heal.to, heal.sheal, heal)
                --Debug(("<冻结>回溯治疗:%.3f"):format(heal.heal))
            end
            
            for _, damage in ipairs(data.damages) do
                local damage = Damage(damage.from, damage.to, damage.sdamage, damage.def, damage.ant, damage)
                if damage.result == "死亡" then
                    break
                end
                --Debug(("<冻结>回溯伤害:%.3f"):format(damage.damage))
            end
            MaxLife(u, -50000, true)
            MaxMana(u, -50000, true)
            Reload("-GetUnitState", func)
        end,
        units = {},
        count = 0
    }
    
    FreezeUnit = function(data)
        if toEvent("debuff", "冻结", "无法施法", "无法控制", data) then return end
        StunUnit(data) --直接回调击晕
        local this = Mark(data.to, "冻结")
        if not this then
            this = {
                unit = data.to,
                effect = AddSpecialEffectTarget("war3mapImported\\falsepromise.mdx", data.to, "chest"),
                timer = CreateTimer(),
                func1 = function()
                    DestroyEffect(this.effect)
                    DestroyTimer(this.timer)
                    Mark(this.unit, "冻结", false)
                    Freeze:remove(this.unit)
                end,
                func2 = function(t)
                    TimerStart(this.timer, t, false, this.func1)
                end
            }
            Mark(data.to, "冻结", this)
            Freeze:add(this.unit)
        end
        this.func2(data.time)
    end
    
    Event("驱散",
        function(data)
            if data.debuff then
                local this = Mark(data.to, "冻结")
                if this then
                    this.func1()
                end
            end
        end
    )
    
    --幻象
    for i = 1, 5 do
        ---[[
        for y = 1, 6 do
            SetPlayerAbilityAvailable(PA[i], TrueSkillId["技能"][0][y], false)
            
            SetPlayerAbilityAvailable(PB[i], TrueSkillId["技能"][0][y], false)
        end
        --]]
    end
    
    IsUnitIllusion = function(u)
        return Mark(u, "幻象")
    end
    
    IllusionUnit = function(data)
        local p = GetOwningPlayer(data.from)
        local ut = GetUnitTypeId(data.to)
        if IsHeroUnitId(ut) then
            ut = IllHeroType[GetUnitPointValue(data.to)]
        end
        local u = CreateUnitAtLoc(p, ut, GetUnitLoc(data.to), GetUnitFacing(data.to))
        Mark(u, "幻象", true)
        
        --英雄
        if IsHeroUnitId(ut) then
            local id = GetUnitPointValue(u) --获取英雄的编号
            UnitAddType(u, UNIT_TYPE_SUMMONED)
            
            Mark(u, "模型缩放", HeroSize[id])
            SetUnitScale(u, HeroSize[id], HeroSize[id], HeroSize[id])
            
            --处理技能
            local lv = GetHeroLevel(data.to)
            if lv > 1 then
                SetHeroLevel(u, lv, false)
            end
            local skills = Mark(data.to, "技能")
            Mark(u, "技能", {}) --保存英雄的技能
            Mark(u, "空余图标", 6) --英雄的空余图标为6
            for i = 1, 4 do
                local t = skills[i]
                if t then
                    AddSkill(u, t.name, nil, true)
                end
            end
            for i = 1, 4 do
                local t = skills[i]
                if t then
                    SetPlayerAbilityAvailable(p, TrueSkillId["学习"][0][i], true)
                    for i = 1, t.lv do
                        SelectHeroSkill(u, TrueSkillId["学习"][0][i])
                    end
                    SetPlayerAbilityAvailable(p, TrueSkillId["学习"][0][i], false)
                end
            end
            for i = 5, 6 do
                local t = skills[i]
                if t and not findSkillData(u, t.name) then
                    AddSkill(u, t.name)
                end
            end
            for i = 1, math.max(GetUnitAbilityLevel(u, |A00J|), GetUnitAbilityLevel(u, |A0L0|)) do
                SelectHeroSkill(u, |A00J|)
                SelectHeroSkill(u, |A0L0|)
            end
            
            --处理物品
            UnitRemoveAbility(u, |AInv|)
            UnitAddAbility(u, |A1AE|)
            for i = 0, 5 do
                local it = UnitItemInSlot(data.to, i)
                if it then
                    local item = Mark(it, "数据")
                    AddItem(u, item.name)
                end
            end
            
            --处理属性
            local str1, agi1, int1 = GetHeroStr(data.to, false), GetHeroAgi(data.to, false), GetHeroInt(data.to, false)
            local str2, agi2, int2 = GetHeroStr(data.to, true) - str1, GetHeroAgi(data.to, true) - agi1, GetHeroInt(data.to, true) - int1
            local str3, agi3, int3 = GetHeroStr(u, false), GetHeroAgi(u, false), GetHeroInt(u, false)
            local str4, agi4, int4 = GetHeroStr(u, true) - str1, GetHeroAgi(u, true) - agi1, GetHeroInt(u, true) - int1
            SetHeroStr(u, str1)
            SetHeroAgi(u, agi1)
            SetHeroInt(u, int1)
            Sai(u, str2 - str4, agi2 - agi4, int2 - int4)
        end
        
        --最终处理
        MaxLife(u, GetUnitState(data.to, UNIT_STATE_MAX_LIFE) - GetUnitState(data.to, UNIT_STATE_MAX_LIFE))
        MaxMana(u, GetUnitState(data.to, UNIT_STATE_MAX_MANA) - GetUnitState(data.to, UNIT_STATE_MAX_MANA))
        SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(data.to, UNIT_STATE_LIFE))
        SetUnitState(u, UNIT_STATE_MANA, GetUnitState(data.to, UNIT_STATE_MANA))
        
        Attack(u, GetUnitState(data.to, UNIT_STATE_ADD_ATTACK) - GetUnitState(u, UNIT_STATE_ADD_ATTACK))
        Def(u, GetUnitState(data.to, UNIT_STATE_DEFENCE) - GetUnitState(u, UNIT_STATE_DEFENCE))
        
        SetUnitColor(u, ConvertPlayerColor(GetPlayerId(p)))
        if IsUnitAlly(u, SELFP) then
            SetUnitVertexColor(u, 0, 0, 255, 255)
        end
        UnitApplyTimedLife(u, 'BTLF', data.time)
        
        Mark(u, "幻象攻击", data.attack or 0)
        Mark(u, "幻象伤害", data.damage or 0)
        
        return u
    end
    
    Event("伤害前",
        function(damage)
            if damage.from then
                local attack = Mark(damage.from, "幻象攻击")
                if attack then
                    attack = attack * 0.01
                    damage.sdamage = damage.sdamage * attack
                    damage.odamage = damage.odamage * attack
                    damage.damage = damage.damage * attack
                end
            end
            local attack = Mark(damage.to, "幻象伤害")
            if attack then
                attack = attack * 0.01
                damage.sdamage = damage.sdamage * attack
                damage.odamage = damage.odamage * attack
                damage.damage = damage.damage * attack
            end
        end
    )
    
    Event("死亡",
        function(data)
            if IsUnitIllusion(data.unit) then
                local skills = Mark(data.unit, "技能")
                if skills then
                    for i = 1, 6 do
                        RemoveSkill(data.unit, i)
                    end
                    for i = 0, 5 do
                        local it = UnitItemInSlot(data.unit, i)
                        RemoveItem(it)
                    end
                end
                ShowUnit(data.unit, false)
            end
        end
    )
        
    --无敌
    EnableGod = function(u, b)
        if b == false then
            Mark(u, "无敌", (Mark(u, "无敌") or 0) - 1 )
            if Mark(u, "无敌") == 0 then
                UnitRemoveAbility(u, |Avul|)
            end
        else
            if UnitAddAbility(u, |Avul|) then
                UnitMakeAbilityPermanent(u, true, |Avul|)
            end
            Mark(u, "无敌", (Mark(u, "无敌") or 0) + 1 )
        end
    end
    
    --播放3D音效
    Sound = function(where, sound)
        SetSoundVolumeBJ(sound, 100 - 0.03*GetBetween(where, GetCameraTargetPositionLoc()))
        StartSound(sound)
    end
    
    --暴击率/暴击系数
    Crit = function(u, a, b)
        if a then
            Mark(u, "暴击率", (Mark(u, "暴击率") or 0) + a)
        end
        if b then
            Mark(u, "暴击系数", (Mark(u, "暴击系数") or 0) + b)
        end
    end
    
    --立即刷新技能说明
    RefreshTips = function(u)
        if not UnitAddAbility(u, |A14N|) then
            UnitRemoveAbility(u, |A14N|)
        end
    end    
    
    --增加攻击距离
    AttackRange = function(u, r)
        local rng = GetUnitState(u, ConvertUnitState(0x16)) + r
        SetUnitState(u, ConvertUnitState(0x16), rng)
    end
    
    --增加攻击力
    UnitAddAbility(Dummy, |A17T|)
    
    Attack = function(u, a)
        a = (Mark(u, "附加攻击") or 0) + a
        Mark(u, "附加攻击", a)
        local ab = japi.EXGetUnitAbility(Dummy, |A17T|)
        japi.EXSetAbilityDataReal(ab, 2, 108, a)
        if UnitAddAbility(u, |A17T|) then
            UnitMakeAbilityPermanent(u, true, |A17T|)
        else
            SetUnitAbilityLevel(u, |A17T|, 1)
        end
        SetUnitAbilityLevel(u, |A17T|, 2)
        RefreshHeroSkills(u)
        RefreshTips(u)
    end
    
    --增加护甲
    UnitAddAbility(Dummy, |A18G|)
    
    Def = function(u, a)
        a = (Mark(u, "附加护甲") or 0) + a
        Mark(u, "附加护甲", a)
        local ab = japi.EXGetUnitAbility(Dummy, |A18G|)
        japi.EXSetAbilityDataReal(ab, 2, 108, a)
        if UnitAddAbility(u, |A18G|) then
            UnitMakeAbilityPermanent(u, true, |A18G|)
        else
            SetUnitAbilityLevel(u, |A18G|, 1)
        end
        SetUnitAbilityLevel(u, |A18G|, 2)
    end
    
    --增加最大生命值
    MaxLife = function(u, hp, b)
        UnitAddAbility(u, |A0P1|)
        local skill = japi.EXGetUnitAbility(u, |A0P1|)
        japi.EXSetAbilityDataReal(skill, 2, 108, -hp)
        SetUnitAbilityLevel(u, |A0P1|, 2)
        if b then
            b = GetUnitState(u, UNIT_STATE_LIFE)
        end
        UnitRemoveAbility(u, |A0P1|)
        if b then
            SetUnitState(u, UNIT_STATE_LIFE, b)
        end
    end
    
    --增加最大法力值
    MaxMana = function(u, mp, b)
        UnitAddAbility(u, |A18I|)
        local skill = japi.EXGetUnitAbility(u, |A18I|)
        japi.EXSetAbilityDataReal(skill, 2, 108, -mp)
        SetUnitAbilityLevel(u, |A18I|, 2)
        if b then
            b = GetUnitState(u, UNIT_STATE_MANA)
        end
        UnitRemoveAbility(u, |A18I|)
        if b then
            SetUnitState(u, UNIT_STATE_MANA, b)
        end
    end
    
    --增加属性
    UnitAddAbility(Dummy, |A188|)
    
    Sai = function(u, s, a, i)
        s, a, i = s or 0, a or 0, i or 0
        local as = (Mark(u, "附加力量") or 0) + s
        local aa = (Mark(u, "附加敏捷") or 0) + a
        local ai = (Mark(u, "附加智力") or 0) + i
        Mark(u, "附加力量", as)
        Mark(u, "附加敏捷", aa)
        Mark(u, "附加智力", ai)
        local ab = japi.EXGetUnitAbility(Dummy, |A188|)
        japi.EXSetAbilityDataReal(ab, 2, 110, as) --力量
        japi.EXSetAbilityDataReal(ab, 2, 108, aa) --敏捷
        japi.EXSetAbilityDataReal(ab, 2, 109, ai) --智力
        if UnitAddAbility(u, |A188|) then
            UnitMakeAbilityPermanent(u, true, |A188|)
        else
            SetUnitAbilityLevel(u, |A188|, 1)
        end
        SetUnitAbilityLevel(u, |A188|, 2)
        --发起附加属性变化事件
        toEvent("附加属性变化", {unit = u, str = s, agi = a, int = i})
        --刷新技能说明
        RefreshHeroSkills(u)
        RefreshTips(u)
    end
    
    --关闭小地图图标
    SetAltMinimapIcon("null_16_16.blp")
    
    MinimapIcon = function(u, b)
        if b then
            Mark(u, "小地图图标", (Mark(u, "小地图图标") or 0) - 1)
        else
            Mark(u, "小地图图标", (Mark(u, "小地图图标") or 0) + 1)
        end
        if Mark(u, "小地图图标") == 0 then
            UnitSetUsesAltIcon(u, false)
        else
            UnitSetUsesAltIcon(u, true)
        end
    end
    
    --创建模型
    CreateModle = function(mod, p, data)
        data = data or {}
        if type(p) ~= "table" then
            p = GetUnitLoc(p)
        end
        local u = CreateUnitAtLoc(Player(15), |e030|, p, data.angle or 0)
        if data.size then
            SetUnitScale(u, data.size, data.size, data.size)
        end
        local e = AddSpecialEffectTarget(mod, u, "origin")
        Mark(u, "绑定特效", e)
        Mark(u, "立即删除", data.remove)
        if data.time then
            UnitApplyTimedLife(u, 'BTLF', data.time)
        end
        if data.z then
            SetUnitFlyHeight(u, data.z, 0)
        end
        return u
    end
    
    Event("死亡",
        function(data)
            if GetUnitTypeId(data.unit) == |e030| then
                local e = Mark(data.unit, "绑定特效")
                if Mark(data.unit, "立即删除") then
                    RemoveUnit(data.unit)
                end
                if e then
                    DestroyEffect(e)
                end
            end
        end
    )
    
    --复制英雄技能
    DummyHeroSkill = function(u, u2, that, newname)
        local this = findSkillData(u, newname or that.name)
        local flag
        if this then
            flag = true
        else
            this = table.copy(SkillTable[that.sid], true)
            if not Mark(u, "技能") then
                Mark(u, "技能", {})
            end
            Mark(u, "技能")[newname or that.name] = this
        end
        this.name = newname or that.name
        this.lv = that.lv
        this.unit = u
        this.target = u2
        if not flag then
            if this.events["获得技能"] then
                this.event = "获得技能"
                this:code()
            end
            if this.events["升级技能"] then
                if this.lv > 1 then
                    for i = 1, this.lv - 1 do
                        this.event = "升级技能"
                        this:code()
                    end
                end
            end
        end
        this.spellflag = GetTime()
        this.event = that.event
        if this.event == "发动技能" then
            this.usecount = this.usecount + 1
            local count = this.usecount
            if this.type[1] == "开关" and this.dur then
                Wait(this:get("dur"),
                    function()
                        if count == this.usecount then
                            this.openflag = false
                        end
                    end
                )
            end
            Wait((this:get("cast") or 0.01) + (this:get("time") or 0),
                function()
                    if count == this.usecount then
                        this.spellflag = false
                    end
                end
            )
        elseif this.event == "停止施放" then
            this.stopcount = 1 + this.stopcount
            this.spellflag = false
        elseif this.event == "关闭技能" then
            this.openflag = false
        end
        this:code()
    end
