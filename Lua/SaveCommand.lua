    
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
            if order == attack or order == move or order == patrol or order == hold then
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
                    last[hero] = false
                end
            end
        end
    )
    
    RecommandHero = function(hero)
        local last = last[hero]
        SetUnitTimeScale(hero, 1)
        if last == nil then
            return
        elseif last == false then
            QueueUnitAnimation(hero, "stand")
        else
            if lasttype[hero] == "nil" then
                IssueImmediateOrderById(hero, last)
            elseif lasttype[hero] == "target" then
                local target = lasttarget[hero]
                local p = GetOwningPlayer(hero)
                if IsUnitVisible(target, p) then
                    IssueTargetOrderById(hero, last, target)
                elseif last == attack and IsUnitType(target, UNIT_TYPE_STRUCTURE) then
                    UnitShareVision(target, p, true)
                    IssueTargetOrderById(hero, last, lasttarget[hero])
                    UnitShareVision(target, p, false)
                end
            else
                IssuePointOrderByIdLoc(hero, last, lasttarget[hero])
            end
        end
    end
    
    Event("停止施放",
        function(data)
            local hero = data.unit
            if not IsHero(hero) then
                return
            end
            Wait(0,
                function()
                    if GetUnitCurrentOrder(hero) == 0 and IsUnitAlive(hero) then
                        RecommandHero(hero)
                    end
                end
            )
        end
    )
    
