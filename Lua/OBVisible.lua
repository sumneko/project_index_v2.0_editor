    
    local g = {} --用来存放单位
    
    local code = function(u, v)
        if v == 0 then
            if IsUnitInvisible(u, PB[1]) then
                g[u] = 2
                toEvent("可见度", {unit = u, reason = false}) --单位变为不可见事件
            end
        elseif v == 1 then
            if IsUnitInvisible(u, PA[1]) then
                g[u] = 3
                toEvent("可见度", {unit = u, reason = false}) --单位变为不可见事件
            end
        elseif v == 2 then
            if IsUnitVisible(u, PB[1]) then
                g[u] = 0
                toEvent("可见度", {unit = u, reason = true}) --单位变为可见事件
            end
        elseif v == 3 then
            if IsUnitVisible(u, PA[1]) then
                g[u] = 1
                toEvent("可见度", {unit = u, reason = true}) --单位变为可见事件
            end
        end
    end
    
    visibleTimer = CreateTimer()
    TimerStart(visibleTimer, 0.03, true,
        function()
            for u, v in pairs(g) do
                code(u, v)                
            end
        end
    )
    
    --单位进入地图时添加进单位组
    Event("进入地图",
        function(data)
            local i = GetPlayerId(GetOwningPlayer(data.unit))
            if i < 12 and i ~= 0 and i ~= 6 and GetUnitAbilityLevel(data.unit, |Aloc|)==0 and not IsUnitType(data.unit, UNIT_TYPE_MECHANICAL) then --属于玩家的,不是马甲的,不是机械的
                local p = GetOwningPlayer(data.unit)
                Mark(data.unit, "变为可见的时间", 0)
                Mark(data.unit, "变为不可见的时间", -1)
                g[data.unit] = GetPlayerTeam(p)
                code(data.unit, g[data.unit])
            end
        end
    )
    
    --死亡的单位移除出单位组并删除特效
    Event("死亡",
        function(data)
            if not IsHero(data.unit) then
                g[data.unit] = nil
                DestroyEffect(Mark(data.unit, "视野特效"))
            end
        end
    )
    
    --重载视野外英雄可见性
    local GetHeight = GetUnitFlyHeight
    local SetHeight = SetUnitFlyHeight
    
    GetUnitFlyHeight = function(u)
        return Mark(u, "真实飞行高度") or GetHeight(u)
    end
    
    SetUnitFlyHeight = function(u, h)
        if Mark(u, "真实飞行高度") then
            Mark(u, "真实飞行高度", h)
        else
            SetHeight(u, h, 0)
        end
    end
    
    --动态古树类型/OB视角查看单位是否在敌方视野中
    Event("可见度",  
        function(data)
            if data.reason then --单位变为可见
                --Debug(GetUnitName(data.unit) .. ":可见")
                UnitRemoveType(data.unit, UNIT_TYPE_ANCIENT) --移除古树类型
                Mark(data.unit, "变为可见的时间", GetTime())
                if Mark(data.unit, "注册英雄") then
                    SetHeight(data.unit, Mark(data.unit, "真实飞行高度"), 0)
                    Mark(data.unit, "真实飞行高度", false)
                end
                DestroyEffect(Mark(data.unit, "视野特效"))
            else --单位变为不可见
                --Debug(GetUnitName(data.unit) .. ":不可见")
                UnitAddType(data.unit, UNIT_TYPE_ANCIENT) --添加古树类型
                Mark(data.unit, "变为不可见的时间", GetTime())
                if Mark(data.unit, "注册英雄") then
                    Mark(data.unit, "真实飞行高度", GetHeight(data.unit))
                    if IsUnitEnemy(data.unit, SELFP) and not Mark(data.unit, "大地图可见") then
                        SetHeight(data.unit, 10000, 0)
                    end
                end
                if IsGod() then
                    Mark(data.unit, "视野特效", AddSpecialEffectTarget("war3mapImported\\shockwavemissilepurple.mdx", data.unit, "chest"))
                else
                    Mark(data.unit, "视野特效", AddSpecialEffectTarget("", data.unit, "chest"))
                end
            end
        end
    )
    
    --敌方的侦查守卫显示特效
    Event("召唤",
        function(data)
            if GetUnitTypeId(data.unit) == |oeye| or GetUnitTypeId(data.unit) == |nwad| then
                if IsUnitEnemy(data.unit, SELFP) then
                    AddSpecialEffectTarget("war3mapImported\\wardmark_t2.mdx", data.unit, "origin")
                else
                    AddSpecialEffectTarget("", data.unit, "origin")
                end
            end
        end
    )
    
    SeeUnit = function(u, b)
        if b ~= false then
            Mark(u, "大地图可见", (Mark(u, "大地图可见") or 0) + 1)
            if Mark(u, "变为不可见的时间") > Mark(u, "变为可见的时间") then
                SetHeight(u, Mark(u, "真实飞行高度"), 0)
            end
        else
            local i = (Mark(u, "大地图可见") or 0) - 1
            if i == 0 then
                Mark(u, "大地图可见", false)
                if Mark(u, "变为不可见的时间") > Mark(u, "变为可见的时间") and IsUnitEnemy(u, SELFP) then
                    SetHeight(u, 10000, 0)
                end
            else
                Mark(u, "大地图可见", i)
            end
        end
    end
