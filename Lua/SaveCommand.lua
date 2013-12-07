    
    local trg = CreateTrigger()
    local heroes = {}
    
    Event("创建英雄",
        function(data)
            TriggerRegisterUnitEvent(trg, data.unit, EVENT_UNIT_ISSUED_ORDER)
            TriggerRegisterUnitEvent(trg, data.unit, EVENT_UNIT_ISSUED_POINT_ORDER)
            TriggerRegisterUnitEvent(trg, data.unit, EVENT_UNIT_ISSUED_TARGET_ORDER)
            table.insert(heroes, data.unit)
        end
    )
    
    local stop = OrderId("stop")
    local attack = OrderId("attack")
    local smart = OrderId("smart")
    local move = OrderId("move")
    local patrol = OrderId("patrol")
    local hold = OrderId("holdposition")
    
    local last = {}
    local lasttype = {}
    local lasttarget = {}
    
    TriggerAddCondition(trg, Condition(
        function()
            local hero = GetTriggerUnit()
            local order = GetIssuedOrderId()
            if order == attack or order == smart or order == move or order == patrol or order == hold then
                last[hero] = order
                if order == hold then
                    lasttype[hero] = "nil"
                else
                    local target = GetOrderTarget()
                    if target then
                        lasttarget[hero] = target
                        lasttype[hero] = "target"
                    else
                        target = GetOrderPointLoc()
                        lasttarget[hero] = target
                        lasttype[hero] = "loc"
                    end
                end
            end
        end
    ))
    
    Loop(0.1,
        function()
            for _, hero in ipairs(heroes) do
                if GetUnitCurrentOrder(hero) == 0 then
                    last[hero] = nil
                end
            end
        end
    )
    
    Event("停止施放",
        function(data)
            local hero = data.unit
            if last[hero] then
                if lasttype[hero] == "nil" then
                    IssueImmediateOrderById(hero, last[hero])
                elseif lasttype[hero] == "target" then
                    if IsUnitVisible(lasttarget[hero], GetOwningPlayer(hero)) then
                        IssueTargetOrderById(hero, last[hero], lasttarget[hero])
                    end
                else
                    IssuePointOrderByIdLoc(hero, last[hero], lasttarget[hero])
                end
            end
        end
    )
    
