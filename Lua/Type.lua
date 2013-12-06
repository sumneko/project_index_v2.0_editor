    
    --type location = {0, 0}

    DefineStartLocationLoc = function(a, b)
        DefineStartLocation(a, b[1], b[2])
    end
    
    GetStartLocationLoc = function(i)
        local loc = jass.GetStartLocationLoc(i)
        local p = {GetLocationX(loc), GetLocationY(loc)}
        RemoveLocation(loc)
        return p
    end
    
    GroupEnumUnitsInRangeOfLoc = function(g, loc, r, f)
        GroupEnumUnitsInRange(g, loc[1], loc[2], r, f)
    end
    
    GroupEnumUnitsInRangeOfLocCounted = function(g, loc, r, f, c)
        GroupEnumUnitsInRangeCounted(g, loc[1], loc[2], r, f, c)
    end
    
    GroupPointOrderLoc = function(g, o, loc)
        return GroupPointOrder(g, o, loc[1], loc[2])
    end
    
    GroupPointOrderByIdLoc = function(g, i, loc)
        return GroupPointOrderById(g, i, loc[1], loc[2])
    end
    
    RectFromLoc = function(l1, l2)
        return Rect(l1[1], l1[2], l2[1], l2[2])
    end
    
    SetRectFromLoc = function(r, l1, l2)
        SetRect(r, l1[1], l1[2], l2[1], l2[2])
    end
    
    MoveRectToLoc = function(r, loc)
        MoveRectTo(r, loc[1], loc[2])
    end
    
    RegionAddCellAtLoc = function(r, l)
        RegionAddCell(r, l[1], l[2])
    end
    
    RegionClearCellAtLoc = function(r, l)
        RegionClearCell(r, l[1], l[2])
    end
    
    Location = function(x, y)
        return {x, y}
    end
    
    RemoveLocation = function(loc)
        loc = nil
    end
    
    MoveLocation = function(loc, x, y)
        loc[1] = x
        loc[2] = y
    end
    
    GetLocationX = function(loc)
        return loc[1]
    end
    
    GetLocationY = function(loc)
        return loc[2]
    end
    
    local locZ = jass.Location(0, 0)
    
    GetLocationZ = function(loc)
        jass.MoveLocation(locZ, loc[1], loc[2])
        return jass.GetLocationZ(locZ)
    end
    
    IsLocationInRegion = function(r, loc)
        return IsPointInRegion(r, loc[1], loc[2])
    end
    
    GetOrderPointLoc = function()
        return {GetOrderPointX(), GetOrderPointY()}
    end
    
    GetSpellTargetLoc = function()
        return {GetSpellTargetX(), GetSpellTargetY()}
    end
    
    CreateUnitAtLoc = function(p, i, l, f)
        return CreateUnit(p, i, l[1], l[2], f)
    end
    
    CreateUnitAtLocByName = function(p, n, l, f)
        return CreateUnitByName(p, n, l[1], l[2], f)
    end
    
    SetUnitPositionLoc = function(u, l)
        SetUnitPosition(u, l[1], l[2])
    end
    
    ReviveHeroLoc = function(u, l, b)
        return ReviveHero(u, l[1], l[2], b)
    end
    
    GetUnitLoc = function(u)
        return {GetUnitX(u), GetUnitY(u)}
    end
    
    GetUnitRallyPoint = function(u)
        local loc = jass.GetUnitRallyPoint(u)
        local p = {jass.GetLocationX(loc), jass.GetLocationY(loc)}
        RemoveLocation(loc)
        return p
    end
    
    IsUnitInRangeLoc = function(u, l ,d)
        return IsUnitInRangeXY(u, l[1], l[2], d)
    end
    
    IssuePointOrderLoc = function(u, o, l)
        return IssuePointOrder(u, o, l[1], l[2])
    end
    
    IssuePointOrderByIdLoc = function(u, i, l)
        return IssuePointOrderById(u, i, l[1], l[2])
    end
    
    IsLocationVisibleToPlayer = function(l, p)
        return IsVisibleToPlayer(l[1], l[2], p)
    end
    
    IsLocationFoggedToPlayer = function(l, p)
        return IsFoggedToPlayer(l[1], l[2], p)
    end
    
    IsLocationMaskedToPlayer = function(l, p)
        return IsMaskedToPlayer(l[1], l[2], p)
    end
    
    SetFogStateRadiusLoc = function(p, s, l, r, b)
        SetFogStateRadius(p, s, l[1], l[2], r, b)
    end
    
    CreateFogModifierRadiusLoc = function(p, s, l, r, b1, b2)
        return CreateFogModifierRadius(p, s, l[1], l[2], r, b1, b2)
    end
    
    CameraSetupGetDestPositionLoc = function(c)
        return {CameraSetupGetDestPositionX(c), CameraSetupGetDestPositionY(c)}
    end
    
    GetCameraTargetPositionLoc = function()
        return {GetCameraTargetPositionX(), GetCameraTargetPositionY()}
    end
    
    GetCameraEyePositionLoc = function()
        return {GetCameraEyePositionX(), GetCameraEyePositionY()}
    end
    
    AddSpecialEffectLoc = function(s, l)
        return AddSpecialEffect(s, l[1], l[2])
    end
    
    AddSpellEffectLoc = function(s, t, l)
        return AddSpellEffect(s, t, l[1], l[2])
    end
    
    AddSpellEffectByIdLoc = function(i, t, l)
        return AddSpellEffectById(i, t, l[1], l[2])
    end
    
    SetBlightLoc = function(p, l, r, b)
        SetBlight(p, l[1], l[2], r, b)
    end
    
    --JAPI
    GetUnitState = japi.GetUnitState
    
    SetUnitState = japi.SetUnitState
    
    UNIT_STATE_BASE_ATTACK = ConvertUnitState(0x12)
    
    UNIT_STATE_ADD_ATTACK = ConvertUnitState(0x13)
    
    UNIT_STATE_MIN_ATTACK = ConvertUnitState(0x14)
    
    UNIT_STATE_MAX_ATTACK = ConvertUnitState(0x15)
    
    UNIT_STATE_ATTACK_RANGE = ConvertUnitState(0x16)
    
    UNIT_STATE_DEFENCE = ConvertUnitState(0x20)
    
    --修改
    
    --数学相关
    Sin = function(deg)
        return math.sin(math.rad(deg))
    end
    
    SinBJ = Sin
    
    Cos = function(deg)
        return math.cos(math.rad(deg))
    end
    
    CosBJ = Cos
    
    Tan = function(deg)
        return math.tan(math.rad(deg))
    end
    
    TanBJ = Tan
    
    Asin = function(deg)
        return math.deg(math.asin(deg))
    end
    
    AsinBJ = Asin
    
    Acos = function(deg)
        return math.deg(math.acos(deg))
    end
    
    AcosBJ = Acos
    
    Atan = function(deg)
        return math.deg(math.atan(deg))
    end
    
    AtanBJ = Atan
    
    Atan2 = function(y, x)
        return math.deg(math.atan2(y, x))
    end
    
    Atan2BJ = Atan2
    
    bj_DEGTORAD = 1
    bj_RADTODEG = 1
    
    SquareRoot = math.sqrt
    
    --重载计时器
    do        
        local timers = {} --计时器队列
        local top = 0 --队列顶部
        local truetimer = jass.CreateTimer() --真计时器,用于计算队列顶部计时器的到期情况
        local lasttime = 0 --上一次计时器到期的时间
        local lasttimer --上一次到期的计时器
        local timered = false
        
        --刷新核心计时器   
        local freshTimer
        local timerFunc
        
        freshTimer = function()
            local timer = timers[top] --提取顶部的计时器
            local time = timer.at - GetTime() --计算顶部的计时器还有多久才到期
            timered = nil
            jass.TimerStart(truetimer, time, false, timerFunc)
        end
        
        timerFunc = function(time)
            local timer = timers[top] --提取顶部的计时器
            if time == nil then --由核心计时器到期发起的事件
                time = timer.at
            end
            if timer.at == time then --如果顶部计时器的到期时间等于当前时间
                timer.state = "到期" --将该计时器的状态更改为到期
                lasttime = timer.at --记录上一次计时器到期的时间
                timered = lasttime --表示当前时间就是lasttime
                lasttimer = timer --记录上一次到期的计时器
                timers[top] = nil --将计时器从顶部移除
                top = top - 1
                if timer.func then --运行计时器到期的函数
                    timer.func()
                end
                if timer.state == "到期" then --状态没有进行更改
                    if timer.loop then --如果是循环计时器
                        TimerStart(timer, timer.time, timer.loop, timer.func)
                    else
                        timer.state = "空闲"
                    end    
                end
                timerFunc(time) --递归
            else
                freshTimer() --刷新计时器
            end
        end
        
        --获取当前游戏时间        
        GetTime = function()
            return timered or lasttime + jass.TimerGetElapsed(truetimer)
        end
        
        --创建计时器
        CreateTimer = function()
            return {
                time = 0, --计时器周期
                loop = false, --是否循环
                func = nil, --计时器到期时运行的函数
                start = 0, --计时器启动时间
                at = 0, --计时器预期的结束时间
                state = "空闲", --计时器状态
            }
        end
        
        --放一个计时器在队列底部
        do
            local timer = CreateTimer()
            timers[1] = timer
            top = 1
            timer.time = 999999
            timer.loop = false
            timer.func = nil
            timer.start = 0
            timer.at = 999999
            timer.state = "运行"
            freshTimer() --刷新计时器
        end            
        
        --启动计时器
        TimerStart = function(timer, r, b, func)
            PauseTimer(timer)
            timer.time = math.max(0, r)
            timer.loop = b
            timer.func = func
            timer.start = GetTime()
            timer.at = timer.start + r
            timer.state = "运行"
            top = top + 1 --计时器计数+1
            for i = top - 1, 1, -1 do --从顶部开始向下检查
                local at = timers[i].at --当前计时器的到期时间
                if at > timer.at then --到期时间大的放在下面
                    table.insert(timers, i + 1, timer)
                    if i + 1 == top then --如果比顶部的计时器还要小
                        freshTimer() --刷新真计时器
                    end
                    break
                end
            end
        end
        
        --暂停计时器
        PauseTimer = function(timer)
            if timer.state == "运行" then
                timer.state = "空闲"
                for i = top, 1, -1 do
                    local that = timers[i]
                    if that == timer then
                        top = top - 1
                        table.remove(timers, i)
                        if i == top + 1 then --如果计时器之前就是位于队列顶部
                            freshTimer() --刷新真计时器
                        end
                        break
                    end
                end
            elseif timer.state == "到期" then
                timer.state = "空闲"
            end
        end
        
        --删除计时器
        DestroyTimer = function(timer)
            PauseTimer(timer)
            timer.state = "删除"
        end
        
        --获取到期计时器
        GetExpiredTimer = function()
            return lasttimer --上一次到期的计时器
        end
        
        TimerGetElapsed = function(timer)
            return GetTime() - timer.start
        end
        
        TimerGetRemaining = function(timer)
            return timer.at - GetTime()
        end
        
        TimerGetTimeout = function(timer)
            return timer.time
        end
        
        TimerRestart = function(timer)
            TimerStart(timer, timer.time, timer.loop, timer.func)
        end
        
        ResumeTimer = TimerRestart
        
        --立即运行计时器
        ExcuteTimer = function(timer)
            PauseTimer(timer)
            timer.at = GetTime()
            top = top + 1
            timers[top] = timer --把计时器放在队列顶部
            timerFunc()
        end
    end
    
    --创建闪电效果
    AddLightningEx = function(name, b, x1, y1, z1, x2, y2, z2)
        local l = jass.AddLightningEx(name, false, x1, y1, z1, x2, y2, z2)
        if b and not IsVisibleToPlayer(x1, y1, SELFP) and not IsVisibleToPlayer(x2, y2, SELFP) then
            SetLightningColor(l, 1, 1, 1, 0)
        end
        return l
    end
    
    --自定义默认值
    Or = function(a, b, c)
        if a == b then
            return c
        end
        return a
    end
    
    --重置技能冷却
    do
        UnitResetCooldown = function(u)
            local skills = Mark(u, "技能")
            if skills then
                for _, this in pairs(skills) do
                    local ab = japi.EXGetUnitAbility(this.unit, this.id)
                    local cd = japi.EXGetAbilityState(ab, 1)
                    if cd > 0 and cd < 3600 then
                        japi.EXSetAbilityState(ab, 1, 0)
                    end
                end
            else
                jass.UnitResetCooldown(u)
            end
        end
    end
    
    --获得经验值
    AddHeroXP = function(u, xp, b, r)
        local data = {unit = u, xp = xp, oxp = xp, reason = r or "杀敌"}
        toEvent("获得经验", data)
        jass.AddHeroXP(data.unit, data.xp, b)
    end
