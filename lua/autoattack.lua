
    local stop = OrderId("stop")
    local attack = OrderId("attack")
    local smart = OrderId("smart")
    local move = OrderId("move")
    
    local mark

    local StopAttack = function(u, b)
        if b then
            UnitAddType(u, UNIT_TYPE_PEON)
            SetUnitAcquireRange(u, GetUnitState(u, ConvertUnitState(0x16)))
            mark = true
            IssuePointOrderById(u, move, GetUnitX(u), GetUnitY(u))
            IssueImmediateOrderById(u, stop)
            mark = false
        else
            UnitRemoveType(u, UNIT_TYPE_PEON)
            SetUnitAcquireRange(u, math.max(GetUnitState(u, ConvertUnitState(0x16)), 800))
        end
    end
    
    local oldIssueImmediateOrder = IssueImmediateOrder
    local orderflag
    
    IssueImmediateOrder = function(u, o)
        orderflag = true
        local r = oldIssueImmediateOrder(u, o)
        orderflag = false
        return r
    end
    
    local trg = CreateTrigger()
    TriggerAddCondition(trg, Condition(
        function()
            if mark or orderflag then return end
            local s = GetIssuedOrderId()
            if s == stop then
                StopAttack(GetTriggerUnit(), true)
            elseif s == attack or s == smart or s == move then
                StopAttack(GetTriggerUnit(), false)
            end
        end
    ))
    
    Event("创建英雄",
        function(this)
            StopAttack(this.unit, true)
            TriggerRegisterUnitEvent(trg, this.unit, EVENT_UNIT_ISSUED_ORDER)
            TriggerRegisterUnitEvent(trg, this.unit, EVENT_UNIT_ISSUED_POINT_ORDER)
            TriggerRegisterUnitEvent(trg, this.unit, EVENT_UNIT_ISSUED_TARGET_ORDER)
        end
    )
    
    
    
