    
    SELFP = GetLocalPlayer() --本地玩家
    SELF = GetPlayerId(SELFP) --本地玩家的ID
    
    require "mathLibrary.lua"
    require "stringLibrary.lua"
    require "tableLibrary.lua"
    
    --等待(计时器)
    Wait = function(r, func)
        local t = CreateTimer()
        TimerStart(t, r, false,
            function()
                DestroyTimer(t)
                func()
            end
        )
        return t, func
    end
    
    --循环(计时器)
    Loop = function(r, func)
        local t = CreateTimer()
        TimerStart(t, r, true, func)
        if r < 0.01 then
            Debug("<循环周期>" .. r)
        end
        return t, func
    end
    
    LoopRun = function(r, func)
        local t = CreateTimer()
        TimerStart(t, 0, false, 
            function()
                func()
                TimerStart(t, r, true, func)
            end
        )
        if r < 0.01 then
            Debug("<循环周期>" .. r)
        end
        return t, func
    end
    
    EndLoop = function()
        DestroyTimer(GetExpiredTimer())
    end
    
    --全局表
    local MarkTable = {}
    
    --不要往里面存nil!
    Mark = function(x, y, v)
        if x == nil then
            print("<ERROR>全局表索引x为空,请截图汇报!")
            print("y = " .. tostring(y))
            print("v = " .. tostring(v))
            return
        end
        if v ~= nil then --存入数据
            if not MarkTable[x] then --获取表主索引,不存在就创建
                MarkTable[x] = {}
            end
            if y == nil then
                print("<ERROR>全局表索引y为空,请截图汇报!")
                print("x = " .. tostring(x))
                print("v = " .. tostring(v))
                return
            end
            MarkTable[x][y] = v
        elseif y ~= nil then --获取数据
            if MarkTable[x] then
                return MarkTable[x][y]
            end
        else --清空主索引
            MarkTable[x] = nil
        end                
    end
    
    metaMark = function(x, y)
        if not MarkTable[x] then --获取表主索引,不存在就创建
            MarkTable[x] = {}
        end
        if not MarkTable[y] then --获取表主索引,不存在就创建
            MarkTable[y] = {}
        end
        setmetatable(MarkTable[x], {__index = MarkTable[y]})
    end
    
    --256进制转换
    get256s = function(a)
        local s1 = a/256/256/256%256
        local s2 = a/256/256%256
        local s3 = a/256%256
        local s4 = a%256
        return string.format("%s%s%s%s", string.char(s1), string.char(s2), string.char(s3), string.char(s4))
    end
    
    get256n = function(a)
        local n1 = string.byte(a, 1)
        local n2 = string.byte(a, 2)
        local n3 = string.byte(a, 3)
        local n4 = string.byte(a, 4)
        return n1*256*256*256+n2*256*256+n3*256+n4
    end
    
    --判断单位是否死亡
    IsUnitDead = function(u)
        return IsUnit(u, nil) or IsUnitType(u, UNIT_TYPE_DEAD)
    end

    IsUnitAlive = function(u)
        return not IsUnitDead(u)
    end
    
    --为单位添加技能
    Skill = function(u, abil, lv)
        local i = GetUnitAbilityLevel(u, abil)
        if lv == 0 then
            if i ~= 0 then
                UnitRemoveAbility(u, abil)
            end
        else
            if i == 0 then
                if UnitAddAbility(u, abil) then
                    UnitMakeAbilityPermanent(u, abil, true)
                    if lv ~= 1 then
                        SetUnitAbilityLevel(u, abil, lv)
                    end
                end
            elseif i ~= lv then
                SetUnitAbilityLevel(u, abil, lv)
            end
        end
    end
    
    --单位组迭代
    G2T = function(g)
        local t = {}
        local i = 0
        ForGroup(g,
            function()
                i = i + 1
                t[i] = GetEnumUnit()
            end
        )
        return t
    end
    
    enumGroup = function(t, i)
        i = i + 1
        local v = t[i]  
        if v then
            return i, v 
        else
            g = nil
        end  
    end  
    
    group = function(g)
        return enumGroup, G2T(g), 0
    end
    
    --获取当前游戏时间
    local timeTimer = CreateTimer()
    
    TimerStart(timeTimer, 999999, false, nil)
   
    GetTime = function()
        return TimerGetElapsed(timeTimer)
    end
    
    local gameTime = 0
    
    Loop(1, function()
        gameTime = gameTime + 1
    end)
    
    SetGameTime = function(t)
        gameTime = t
    end
    
    GetGameTime = function()
        if gameTime < 0 then
            return -gameTime, gameTime
        else
            return gameTime, gameTime
        end
    end
    
    TimeWord = function(t)
        local h = math.floor(t/3600)
        local m = math.floor((t-h*3600)/60)
        local s = math.floor(t-h*3600-m*60)
        if h == 0 then
            if m == 0 then
                return string.format("%02d", s)
            else
                return string.format("%02d:%02d", m, s)
            end
        else
            return string.format("%02d:%02d:%02d", h, m, s)
        end
    end
    
    GetTimeWord = function()
        return TimeWord(GetGameTime())        
    end
    
    --是否为在线玩家
    IsPlayer = function(p)
        if type(p) == "number" then
            return IsPlayer(Player(p))
        else
            return GetPlayerController(p) == MAP_CONTROL_USER and GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING
        end
    end
    
    IsUser = function(p)
        if type(p) == "number" then
            return p < 12 and p ~= 0 and p ~= 6
        else
            return(IsUser(GetPlayerId(p)))
        end
    end
    
    IsComputer = function(p)
        if type(p) == "number" then
            return IsComputer(Player(p))
        else
            return GetPlayerController(p) == MAP_CONTROL_COMPUTER
        end
    end
    
    IsCom = function(p)
        if type(p) == "number" then
            return IsCom(Player(p))
        else
            return p == Com[0] or p == Com[1]
        end
    end
    
    AI = {}
    
    IsAI = function(p)
        if type(p) == "number" then
            return AI[Player(p)]
        else
            return AI[p]
        end
    end
    
    --是否全知(OB或录像)
    IsGod = function()
        return not IsInGame or IsPlayerObserver(SELFP)
    end
    
    --整合漂浮文字
    Text = function(t)
        bj_lastCreatedTextTag = CreateTextTag()
        if bj_lastCreatedTextTag == nil then
            return
        end
        SetTextTagText(bj_lastCreatedTextTag, t.word or "没有定义漂浮文字内容", (t.size or 10) * 0.023 / 10)
        if t.unit then
            SetTextTagPos(bj_lastCreatedTextTag, GetUnitX(t.unit) + (t.x or 0), GetUnitY(t.unit) + (t.y or 0), t.z or 0)
        elseif t.x and t.y then
            SetTextTagPos(bj_lastCreatedTextTag, t.x, t.y, t.z or 0)
        elseif t.loc then
            SetTextTagPos(bj_lastCreatedTextTag, GetLocationX(t.loc) + (t.x or 0), GetLocationY(t.loc) + (t.y or 0), t.z or 0)
        end
        if t.color then
            SetTextTagColor(bj_lastCreatedTextTag, (t.color[1] or 100) * 2.55, (t.color[2] or 100) * 2.55, (t.color[3] or 100) * 2.55, (t.color[4] or 100) * 2.55)
        end
        if t.speed then
            SetTextTagVelocity(bj_lastCreatedTextTag, t.speed[1] * 0.071 * Cos(t.speed[2])/ 128, t.speed[1] * 0.071 * Sin(t.speed[2])/ 128)
        end
        if t.life then
            if t.life[1] then
                SetTextTagFadepoint( bj_lastCreatedTextTag, t.life[1] )
            end
            if t.life[2] then
                SetTextTagLifespan( bj_lastCreatedTextTag, t.life[2] )
            end
        end
        SetTextTagPermanent(bj_lastCreatedTextTag, false)
        if not IsGod() then
            if t.show then
                if not t.player and t.unit then
                    t.player = GetOwningPlayer(t.unit)
                end
                if t.player then
                    if t.show == "友方" then
                        if IsPlayerEnemy(t.player, SELFP) then
                            SetTextTagVisibility(bj_lastCreatedTextTag, false)
                        end
                    elseif t.show == "自己" then
                        if t.player ~= SELFP then
                            SetTextTagVisibility(bj_lastCreatedTextTag, false)
                        end
                    end
                end
            end
        end
        Mark("漂浮文字数据", bj_lastCreatedTextTag, t)
        return bj_lastCreatedTextTag
    end
    
    --获取坐标
    getXY = function(p)
        if type(p) == "table" then
            return p[1], p[2]
        else
            return GetWidgetX(p), GetWidgetY(p)
        end
    end
    
    GetXY = getXY
    
    --临时特效
    TempEffect = function(where, s)
        DestroyEffect(AddSpecialEffect(s, getXY(where)))
    end
    
    --刷新玩家的名字
    RefreshPlayerName = function(p)
        local i = GetPlayerId(p)
        local id = GetUnitPointValue(Hero[i])
        SetPlayerName(p, string.format("%s%s(%s)", Mark(p, "称号") or "", PlayerName[i], HeroName[id] or "没有英雄"))
    end
    
    PlayerNameHero = function(p, b, b2)
        local i
        if type(p) == "number" then
            i = GetPlayerId(Player(p))
        else
            i = GetPlayerId(p)
        end
        local id = GetUnitPointValue(Hero[i])
        if b then
            if b2 and not IsPlayer(p) then
                return string.format("%s%s(%s)|r", "|cff888888", PlayerName[i], HeroName[id] or "没有英雄")
            else
                return string.format("%s%s(%s)|r", Color[i], PlayerName[i], HeroName[id] or "没有英雄")
            end
        else
            return string.format("%s(%s)", PlayerName[i], HeroName[id] or "没有英雄")
        end
    end
    
    --让单位可以飞行
    FlyEnable = function(u)
        UnitAddAbility(u, |A000|)
        UnitRemoveAbility(u, |A000|)
    end
    
    --移动坐标
    MovePoint = function(p, to)
        local x, y = getXY(p)
        x = x + to[1] * Cos(to[2])
        y = y + to[1] * Sin(to[2])
        return {x, y}
    end
    
    MovePointSafe = function(p, to)
        local x, y = getXY(p)
        local l, a = to[1], to[2]
        local fl = math.max(50, l / 20)
        local fx, fy = fl * Cos(a), fl * Sin(a)
        x, y = x + l * Cos(a), y + l * Sin(a)
        while l > 0 do
            if GetTerrainCliffLevel(x, y) > 3 or IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) then
                l = l - fl
                x = x - fx
                y = y - fy
            else
                return {x, y}
            end
        end
        return getXY(p)
    end
    
    --语言包
    Lang = {}
    
    setmetatable(Lang, { __index =  --语言包添加默认值,如果索引不存在就返回索引本身
        function(_, k)
            return k
        end
    })
    
    --获取友方玩家(含自己)
    GetAllyUsers = function(p)
        local tid = GetPlayerTeam(p)
        if tid == 0 then
            return PA
        elseif tid == 1 then
            return PB
        else
            print("<获取友方玩家出错>" .. tid)
        end
    end
    
    --获取坐标间角度/距离
    GetBetween = function(a, b, c)
        local x1, y1 = getXY(a)
        local x2, y2 = getXY(b)
        if c then
            return Atan2(y2 - y1, x2 - x1)
        else
            local x = x1 - x2
            local y = y1 - y2
            return math.sqrt(x*x + y*y)
        end
    end
    
    --寻找范围内的单位
    do
        local gs = {}
        local i = 0
        local funcs = {}
        local e = Condition(
            function()
                funcs[i](GetFilterUnit())
            end
        )
        forRange = function(where, range, func)
            i = i + 1
            local g = gs[i]
            if g == nil then
                g = CreateGroup()
                gs[i] = g
            end
            local x, y = getXY(where)
            funcs[i] = func
            GroupEnumUnitsInRange(g, x, y, range, e)
            i = i - 1
        end
    end
    
    --寻找线段附近的单位
    forSeg = function(p1, p2, w, func)
        local x1, y1 = getXY(p1)
        local x2, y2 = getXY(p2)
        local A, B, C = y1 - y2, x2 - x1, (y2 - y1) * x1 + (x1 - x2) * y1    --直线公式 A*x + B*y + C = 0
        local x0, y0 = (x1 + x2) / 2, (y1 + y2) / 2 --获取线段中点
        local r = GetBetween(p1, p2) / 2 --获取线段半径
        --点到线段公式│AXo＋BYo＋C│／√（A2＋B2）
        local s = math.sqrt(A * A + B * B)
        forRange({x0, y0}, r,
            function(u)
                local x0, y0 = GetUnitX(u), GetUnitY(u)
                local d = math.abs(A*x0 + B*y0 + C) / s
                if d <= w then
                    func(u)
                end
            end
        )
    end
    
    
    --是否是英雄
    IsHero = function(u)
        return IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitType(u, UNIT_TYPE_SUMMONED)
    end
    
    --获取高度
    local toZPoint = {0, 0}
    
    getZ = function(where)
        toZPoint[1], toZPoint[2] = getXY(where)
        return GetLocationZ(toZPoint)
    end
    
    GetUnitZ = function(u)
        return getZ(u) + GetUnitFlyHeight(u)
    end
    
    SetUnitZ = function(u, z)
        SetUnitFlyHeight(u, z - getZ(u), 0)
    end
    
    GetZ = function(u)
        if type(u) == "table" then
            return u[3] or GetLocationZ(u)
        else
            return GetUnitZ(u)
        end
    end
    
    GetModleSize = function(u)
        local size = Mark(u, "模型缩放")
        if size then return size end
        size = getObj(slk.unit, GetUnitTypeId(u), "modelScale", 1)
        return tonumber(size)
    end
    
    SetUnitXY = function(u, p)
        local x, y = getXY(p)
        SetUnitX(u, x)
        SetUnitY(u, y)
    end
    
    --数据同步
    local syncgc = InitGameCache("Sync")
    local synctable = {}
    
    Sync = function(p, data, code)
        for x = 1, 100 do
            if not synctable[x] then
                synctable[x] = data
                local count = #data
                data.index = x
                if p == SELFP then
                    for y = 1, count do
                        StoreReal(syncgc, x, y, data[y])
                        SyncStoredReal(syncgc, x, y)
                    end
                    StoreReal(syncgc, x, 0, 1)
                    SyncStoredReal(syncgc, x, 0)
                end
                for y = 1, count do
                    StoreReal(syncgc, x, y, 0)
                    data[y] = nil
                end
                StoreReal(syncgc, x, 0, 0)
                local time = 0
                Loop(0.1,
                    function()
                        time = time + 0.1
                        if GetStoredReal(syncgc, x, 0) == 1 then
                            EndLoop()
                            data.ready = time
                            Debug("<数据同步成功>用时:" .. time)
                            for y = 1, count do
                                data[y] = GetStoredReal(syncgc, x, y)
                            end
                            synctable[x] = nil
                            if code then
                                code(data)
                            end
                        else
                            if time > 10 then
                                EndLoop()
                                print("<数据同步失败>超时:" .. x)
                            end
                        end
                    end
                )
                return data
            end
        end
        print("<数据同步失败>同时同步的数据过多")
        return data
    end
    
    --随机几率(%)
    Random = function(a)
        return a > GetRandomInt(0, 99)
    end
    
    --是否满血满蓝
    IsFullLife = function(u)
        return GetUnitState(u, UNIT_STATE_LIFE) == GetUnitState(u, UNIT_STATE_MAX_LIFE)
    end
    
    IsFullMana = function(u)
        return GetUnitState(u, UNIT_STATE_MANA) == GetUnitState(u, UNIT_STATE_MAX_MANA)
    end
    
    --单位是否是远程
    do
        local units = {}
        
        IsUnitRange = function(u)
            local tid = GetUnitTypeId(u)
            if units[tid] == nil then
                local unit = getObj(slk.unit, tid)
                units[tid] = unit.Missileart
            end
            return units[tid]
        end
    end
    
    luaDone()
