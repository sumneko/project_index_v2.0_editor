    
    CPRect = {} --预设的野怪判定位置
    
    CPRect[1] = gg_rct_Cp1
    CPRect[2] = gg_rct_Cp2
    CPRect[3] = gg_rct_Cp3
    CPRect[4] = gg_rct_Cp4
    CPRect[5] = gg_rct_Cp5
    CPRect[6] = gg_rct_Cp6
    CPRect[7] = gg_rct_Cp7
    CPRect[8] = gg_rct_Cp8
    CPRect[9] = gg_rct_Cp9
    CPRect[10] = gg_rct_Cp10
    CPRect[11] = gg_rct_Cp11
    CPRect[12] = gg_rct_Cp12
    
    CPPoint = {} --刷野点
    
    for i, r in ipairs(CPRect) do
        CPPoint[i] = GetRectCenter(r)
    end
    
    CPType = {} --野怪类型
    
    for i, r in ipairs(CPRect) do
        CPType[i] = {}
        local g = CreateGroup()
        CPType[i][0] = 0
        GroupEnumUnitsInRect(g, r, nil)
        for x, u in group(g) do
            CPType[i][x] = GetUnitTypeId(u)
            RemoveUnit(u)
        end
        DestroyGroup(g)
    end
    
    local CreepTimer
    local trg = CreateTrigger()
    
    StartCreep = function(b)
        if b then
            CreepTimer = Loop(15,
                function()
                    local g = CreateGroup()
                    for i, r in ipairs(CPRect) do
                        local count = 0
                        GroupEnumUnitsInRect(g, r, Condition(
                            function()
                                local u = GetFilterUnit()
                                if IsUnitAlive(u) then
                                    count = count + 1
                                end
                            end
                        ))
                        if count == 0 then
                            CPType[i][0] = CPType[i][0] + 1
                            if CPType[i][0] == 2 then --连续2次没有单位才会刷野怪
                                CPType[i][0] = 0
                                for x, t in ipairs(CPType[i]) do
                                    local u = CreateUnitAtLoc(Player(12), t, CPPoint[i], 270)
                                    SetUnitAcquireRange(u, 128) --野怪主动攻击范围为128
                                    if t ~= |nfrl| and t ~= |ngz1| then --不是那2个4级怪就加古树类型(小兵不能攻击)
                                        UnitAddType(u, UNIT_TYPE_ANCIENT)
                                    end
                                    
                                    TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_ISSUED_POINT_ORDER) --添加单位发布点目标事件
                                end
                            end
                        else
                            CPType[i][0] = 0
                        end
                    end
                    DestroyGroup(g)
                end
            )
        elseif CreepTimer then
            DestroyTimer(CreepTimer)
        end
    end
    
    TriggerAddCondition(trg, Condition(
        function()
            if GetIssuedOrderId() == OrderId("move") then --发布的是 移动 指令
                local u = GetTriggerUnit()
                if DistanceBetweenPoints(GetUnitLoc(GetTriggerUnit()), GetOrderPointLoc()) > 600 then --超出范围后返回
                    SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_MAX_LIFE))
                end
            end
        end
    ))
    
    luaDone()
