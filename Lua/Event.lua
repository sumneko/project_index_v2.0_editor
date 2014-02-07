    
    local Events = {}
    
    --注册事件
    
    local Event2 = function(event, func)
        local b = true
        if string.sub(event, 1, 1) == "-" then
            event = string.sub(event, 2)
            b = false
        end
        if not Events[event] then --获取事件组,如果不存在就创建
            Events[event] = {} 
        end
        local t = Events[event]
        if b then
            table.insert(t, func) --把函数添加到表
        else
            table.remove2(t, func)
        end
    end
    
    Event = function(...)
        local arg = {...}
        local count = #arg
        local func = arg[count]
        for i = 1, count-1 do
            Event2(arg[i], func)
        end
        return func
    end
    
    --发起事件
    
    local toEvent2 = function(event, data)
        local t = Events[event]
        if t then
            data.event = event
            for _,func in ipairs(t) do
                if func(data) then
                    return true --被触发的函数如果返回true,则跳过之后的函数
                end
            end
        end
    end
    
    toEvent = function(...)
        local arg = {...}
        local count = #arg
        local data = arg[count]
        for i = 1, count-1 do
            if toEvent2(arg[i], data) then
                return true --触发的事件如果返回true,则跳过之后的触发
            end
        end
    end
    
    --一些事件常量
    
    --死亡事件
    Event("伤害结算后",
        function(damage)
            if IsUnitDead(damage.to) then
                toEvent("死亡", {unit = damage.to, killer = damage.from, data = damage})
            end
        end
    )
    
    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_DEATH)
    TriggerAddCondition(trg, Condition(
        function()
            if not eventDeadFlag then
                toEvent("死亡", {unit = GetTriggerUnit(), killer = GetKillingUnit()})
            end
        end
    ))
    
    --杀死单位也触发死亡收事件
    KillUnit = function(u)
        if u then
            jass.KillUnit(u)
            toEvent("死亡", {unit = u})
        end
    end
    
    --删除单位事件
    do
        local units = {}
        
        RemoveUnit = function(u)
            if u then
                toEvent("删除单位", {unit = u})
                jass.RemoveUnit(u)
            end
        end
        
        Event("死亡",
            function(data)
                if IsHero(data.unit) then return end
                if GetUnitTypeId(data.unit) == 0 then return end
                local t = tonumber(getObj(slk.unit, GetUnitTypeId(data.unit), "death", 3))
                if t > 1000 then return end
                units[data.unit] = CreateTimer()
                TimerStart(units[data.unit], t, false,
                    function()
                        RemoveUnit(data.unit)
                    end
                )
            end
        )
        
        Event("删除单位",
            function(data)
                local timer = units[data.unit]
                if timer then
                    DestroyTimer(timer)
                    units[data.unit] = nil
                end
            end
        )
    end
    
    --进入地图事件
    do
        CreateUnit = function(p, i, x, y, f)
            local u = jass.CreateUnit(p, i, x, y, f)
            if u == nil then
                print(string.format("<ERROR>没有成功创建单位:(%s,%s,%s,%s,%s)", p, i, x, y, f))
                return
            end
            toEvent("进入地图", {unit = u})
            return u
        end
    end
    
    --技能事件
    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_CAST)
    TriggerAddCondition(trg, Condition(
        function()
            toEvent("准备施放", {unit = GetTriggerUnit(), skill = GetSpellAbilityId()})
        end
    ))
    
    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_CHANNEL)
    TriggerAddCondition(trg, Condition(
        function()
            toEvent("开始施放", {unit = GetTriggerUnit(), skill = GetSpellAbilityId()})
        end
    ))
    
    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trg, Condition(
        function()
            toEvent("发动技能", {unit = GetTriggerUnit(), skill = GetSpellAbilityId()})
        end
    ))
    
    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trg, Condition(
        function()
            toEvent("施放结束", {unit = GetTriggerUnit(), skill = GetSpellAbilityId()})
        end
    ))
    
    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerAddCondition(trg, Condition(
        function()
            toEvent("停止施放", {unit = GetTriggerUnit(), skill = GetSpellAbilityId()})
        end
    ))
    
    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_HERO_SKILL)
    TriggerAddCondition(trg, Condition(
        function()
            toEvent("学习技能", {unit = GetTriggerUnit(), skill = GetLearnedSkill()})
        end
    ))
    
    --攻击事件
    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_ATTACKED)
    TriggerAddCondition(trg, Condition(
        function()
            toEvent("攻击", {from = GetAttacker(), to = GetTriggerUnit()})
        end
    ))
    
    --召唤事件
    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SUMMON)
    TriggerAddCondition(trg, Condition(
        function()
            toEvent("召唤", {unit = GetTriggerUnit(), from = GetSummoningUnit()})
        end
    ))
    
    --英雄复活事件
    trg = CreateTrigger()
    TriggerAddCondition(trg, Condition(
        function()
            if IsUnitAlive(GetTriggerUnit()) then
                toEvent("复活", {unit = GetTriggerUnit()})
            end
        end
    ))
    
    InitHeroRevive = function(u)
        --TriggerRegisterUnitStateEvent(trg, u, UNIT_STATE_LIFE, GREATER_THAN, 0.1) --单位生命值变为大于0.1时认为复活
    end
    
    --英雄升级事件
    local herolevel = table.new(1)
    
    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_HERO_LEVEL)
    TriggerAddCondition(trg, Condition(
        function()
            local u = GetTriggerUnit()
            for i = herolevel[u] + 1, GetHeroLevel(u) do
                herolevel[u] = herolevel[u] + 1
                toEvent("英雄升级", {unit = u})
                if IsHero(u) then
                    toEvent("升级", {unit = u})
                end
            end
        end
    ))
    
    Event("删除单位",
        function(data)
            herolevel[data.unit] = nil
        end
    )
    
    --发布指令事件
    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_ISSUED_ORDER)
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
    TriggerAddCondition(trg, Condition(
        function()
            local u = GetTriggerUnit()
            local event = GetTriggerEventId()
            local id = GetIssuedOrderId()
            if event == EVENT_PLAYER_UNIT_ISSUED_ORDER then
                toEvent("无目标指令", {unit = u, id = id})
            elseif event == EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER then
                toEvent("物体目标指令", {unit = u, id = id})
            elseif event == EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER then
                toEvent("点目标指令", {unit = u, id = id})
            end
        end
    ))
    
