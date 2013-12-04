    
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
    TimerStart(visibleTimer, 0.05, true,
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
    
    --动态古树类型/OB视角查看单位是否在敌方视野中
    Event("可见度",  
        function(data)
            if data.reason then --单位变为可见
                Debug(GetUnitName(data.unit) .. ":可见")
                UnitRemoveType(data.unit, UNIT_TYPE_ANCIENT) --移除古树类型
                Mark(data.unit, "变为可见的时间", GetTime())
                DestroyEffect(Mark(data.unit, "视野特效"))
            else --单位变为不可见
                Debug(GetUnitName(data.unit) .. ":不可见")
                UnitAddType(data.unit, UNIT_TYPE_ANCIENT) --添加古树类型
                Mark(data.unit, "变为不可见的时间", GetTime())
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
    
    luaDone()
