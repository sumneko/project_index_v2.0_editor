    
    --注册小兵类型
    ArmyType = {}
    
    ArmyType[0] = {} --学园都市
    ArmyType[1] = {} --罗马正教
    
    ArmyType[0][0] = {} --学园都市左路
    ArmyType[0][0][0] = |hfoo| --学园都市左路近战
    ArmyType[0][0][1] = |earc| --学园都市左路远程
    ArmyType[0][0][2] = |hkni| --学园都市左路攻城
    
    ArmyType[0][1] = {} --学园都市中路
    ArmyType[0][1][0] = |hfoo| --学园都市中路近战
    ArmyType[0][1][1] = |earc| --学园都市中路远程
    ArmyType[0][1][2] = |hkni| --学园都市中路攻城
    
    ArmyType[0][2] = {} --学园都市右路
    ArmyType[0][2][0] = |hfoo| --学园都市右路近战
    ArmyType[0][2][1] = |earc| --学园都市右路远程
    ArmyType[0][2][2] = |hkni| --学园都市中路攻城
    
    ArmyType[1][0] = {} --罗马正教左路
    ArmyType[1][0][0] = |h00F| --罗马正教左路近战
    ArmyType[1][0][1] = |e00N| --罗马正教左路远程
    ArmyType[1][0][2] = |h00G| --罗马正教左路攻城
    
    ArmyType[1][1] = {} --罗马正教中路
    ArmyType[1][1][0] = |h00F| --罗马正教中路近战
    ArmyType[1][1][1] = |e00N| --罗马正教中路远程
    ArmyType[1][1][2] = |h00G| --罗马正教中路攻城
    
    ArmyType[1][2] = {} --罗马正教右路
    ArmyType[1][2][0] = |h00F| --罗马正教右路近战
    ArmyType[1][2][1] = |e00N| --罗马正教右路远程
    ArmyType[1][2][2] = |h00G| --罗马正教右路攻城
    
    --路径点
    ArmyPoint = {}
    
    ArmyPoint[0] = {} --学园都市路径点
    ArmyPoint[1] = {} --罗马正教路径点
    
    ArmyPoint[0][0] = {} --学园都市左路
    ArmyPoint[0][0][0] = GetRectCenter(gg_rct_CollageLeft) --学园都市左路出兵点
    ArmyPoint[0][0][1] = GetRectCenter(gg_rct_TurnLeft) --学园都市左路进攻点
    ArmyPoint[0][0][2] = GetRectCenter(gg_rct_RomeBase) --学园都市左路进攻点
    
    ArmyPoint[0][1] = {} --学园都市中路
    ArmyPoint[0][1][0] = GetRectCenter(gg_rct_CollageMid) --学园都市中路出兵点
    ArmyPoint[0][1][1] = GetRectCenter(gg_rct_RomeBase) --学园都市中路进攻点
    
    ArmyPoint[0][2] = {} --学园都市右路
    ArmyPoint[0][2][0] = GetRectCenter(gg_rct_CollageRight) --学园都市右路出兵点
    ArmyPoint[0][2][1] = GetRectCenter(gg_rct_TurnRight) --学园都市右路进攻点
    ArmyPoint[0][2][2] = GetRectCenter(gg_rct_RomeBase) --学园都市左路进攻点
    
    ArmyPoint[1][0] = {} --罗马正教左路
    ArmyPoint[1][0][0] = GetRectCenter(gg_rct_RomeLeft) --罗马正教左路出兵点
    ArmyPoint[1][0][1] = GetRectCenter(gg_rct_TurnLeft) --罗马正教左路进攻点
    ArmyPoint[1][0][2] = GetRectCenter(gg_rct_CollageBase) --学园都市左路进攻点
    
    ArmyPoint[1][1] = {} --罗马正教中路
    ArmyPoint[1][1][0] = GetRectCenter(gg_rct_RomeMid) --罗马正教中路出兵点
    ArmyPoint[1][1][1] = GetRectCenter(gg_rct_CollageBase) --罗马正教中路进攻点
    
    ArmyPoint[1][2] = {} --罗马正教右路
    ArmyPoint[1][2][0] = GetRectCenter(gg_rct_RomeRight) --罗马正教右路出兵点
    ArmyPoint[1][2][1] = GetRectCenter(gg_rct_TurnRight) --罗马正教右路进攻点
    ArmyPoint[1][2][2] = GetRectCenter(gg_rct_CollageBase) --学园都市左路进攻点
    
    ArmyShareVision = function(id, u) --小兵给玩家共享视野
        --do return end
        if id == 0 then
            for i = 1, 5 do
                UnitShareVision(u, PA[i], true)
            end
        else
            for i = 1, 5 do
                UnitShareVision(u, PB[i], true)
            end
        end
    end
    
    local trg = CreateTrigger()
    local trg2 = CreateTrigger()
    local ArmyTimer
    
    StartArmy = function(b) --开始出兵
        if b then
            toEvent("游戏开始", {})
            local count = 0
            ArmyTimer = LoopRun(30,
                function()
                    local a = math.floor(GetGameTime()/1200) + 3 --近战兵数量,每20分钟增加一个
                    local b = math.floor(GetGameTime()/1800) + 1 --远程兵数量,每30分钟增加一个
                    local c = math.floor(GetGameTime()/3600) + 1 --攻城兵数量,每60分钟增加一个
                    count = count + 1
                    if count == 4 then --每4波兵刷一次攻城兵
                        count = 0
                    else
                        c = 0
                    end
                    
                    LoopRun(0.75,
                        function()
                            if a > 0 then
                                a = a - 1
                                for x = 0, 1 do
                                    for y = 0, 2 do
                                        local p1 = ArmyPoint[x][y][0]
                                        local p2 = ArmyPoint[x][y][1]
                                        local face = AngleBetweenPoints(p1, p2)
                                        local u = CreateUnitAtLoc(Com[x], ArmyType[x][y][0], p1, face)
                                        Mark(u, "分路", y)
                                        Mark(u, "目标", 1)
                                        IssuePointOrderLoc(u, "attack", p2)
                                        ArmyShareVision(x, u)
                                        TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_ISSUED_ORDER)
                                        TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_ISSUED_TARGET_ORDER)
                                        TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_ISSUED_POINT_ORDER)
                                        toEvent("刷兵", {unit = u, team = x})
                                    end
                                end
                            elseif b > 0 then
                                b = b - 1
                                for x = 0, 1 do
                                    for y = 0, 2 do
                                        local p1 = ArmyPoint[x][y][0]
                                        local p2 = ArmyPoint[x][y][1]
                                        local face = AngleBetweenPoints(p1, p2)
                                        local u = CreateUnitAtLoc(Com[x], ArmyType[x][y][1], p1, face)
                                        Mark(u, "分路", y)
                                        Mark(u, "目标", 1)
                                        IssuePointOrderLoc(u, "attack", p2)
                                        ArmyShareVision(x, u)
                                        TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_ISSUED_ORDER)
                                        TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_ISSUED_TARGET_ORDER)
                                        TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_ISSUED_POINT_ORDER)
                                        toEvent("刷兵", {unit = u, team = x})
                                    end
                                end
                            elseif c > 0 then
                                c = c - 1
                                for x = 0, 1 do
                                    for y = 0, 2 do
                                        local p1 = ArmyPoint[x][y][0]
                                        local p2 = ArmyPoint[x][y][1]
                                        local face = AngleBetweenPoints(p1, p2)
                                        local u = CreateUnitAtLoc(Com[x], ArmyType[x][y][2], p1, face)
                                        Mark(u, "分路", y)
                                        Mark(u, "目标", 1)
                                        Mark(u, "攻城", true)
                                        IssuePointOrderLoc(u, "attack", p2)
                                        ArmyShareVision(x, u)
                                        TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_ISSUED_ORDER)
                                        TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_ISSUED_TARGET_ORDER)
                                        TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_ISSUED_POINT_ORDER)
                                        TriggerRegisterUnitEvent(trg2, u, EVENT_UNIT_ACQUIRED_TARGET)
                                        toEvent("刷兵", {unit = u, team = x})
                                    end
                                end
                            else
                                EndLoop()
                            end
                        end
                    )
                end
            )
            require "ArmyUpgrade.lua"
        elseif ArmyTimer then
            DestroyTimer(ArmyTimer)
        end
    end
    
    --小兵被发布停止命令后重新进攻
    TriggerAddCondition(trg, Condition(
        function()
            if OrderId2String(GetIssuedOrderId()) ~= "stop" and GetIssuedOrderId() ~= 851973 then return end
            local u = GetTriggerUnit()
            Wait(2,
                function()
                    if GetUnitCurrentOrder(u) == 0 then
                        local u2 = Mark(u, "专注攻击目标")
                        if u2 then
                            IssueTargetOrder(u, "attack", u2)
                        else
                            local p = GetOwningPlayer(u)
                            local x = GetPlayerTeam(p)
                            local y = Mark(u, "分路")
                            local z = Mark(u, "目标")
                            local point = ArmyPoint[x][y][z]
                            if point then
                                IssuePointOrderLoc(u, "attack", point)
                            else
                                Debug("<重新攻击>没有找到攻击目标")
                            end
                        end
                    end
                end
            )
        end
    ))            
    
    --转弯点转弯
    do
        local trg = CreateTrigger()
        TriggerRegisterEnterRectSimple(trg, gg_rct_TurnLeft)
        TriggerRegisterEnterRectSimple(trg, gg_rct_TurnRight)
        TriggerAddCondition(trg, Condition(
            function()
                local u = GetTriggerUnit()
                local p = GetOwningPlayer(u)
                local x
                if p == Com[0] then x = 0 end
                if p == Com[1] then x = 1 end
                if x then
                    local y = Mark(u, "分路") 
                    if y and y ~= 1 then --不是中路
                        local z = 1+Mark(u, "目标")
                        if z < 3 then --防止单位离开区域又重新进入区域
                            Mark(u, "目标", z)
                            local point = ArmyPoint[x][y][z]
                            if point then
                                IssuePointOrderLoc(u, "attack", point)
                            else
                                Debug("<转向点>没有找到攻击目标" )
                            end
                        end
                    end
                end
            end
        ))
    end
    
    --攻城单位添加到攻击建筑表中
    local AddUnit = function(u1, u2)
        local t = Mark(u2, "攻城组")
        if not t then
            t = {}
            Mark(u2, "攻城组", t)
        end
        table.insert(t, u1)
        Mark(u1, "专注攻击目标", u2)
    end
    
    --攻城单位优先攻击建筑
    TriggerAddCondition(trg2, Condition(
        function()
            local u1 = GetTriggerUnit()
            local u2 = GetEventTargetUnit()
            if IsUnitType(u2, UNIT_TYPE_STRUCTURE) then --建筑
                IssueTargetOrder(u1, "attack", u2)
                AddUnit(u1, u2)
            end
        end
    ))
    
    --建筑物死亡时施放攻城组
    Event("死亡",
        function(data)
            local u1 = data.unit
            if IsUnitType(u1, UNIT_TYPE_STRUCTURE) then --建筑
                local t = Mark(u1, "攻城组")
                if t then
                    for _,u2 in ipairs(t) do
                        if Mark(u2, "攻城") then --攻城单位
                            local p = GetOwningPlayer(u2)
                            local x = GetPlayerTeam(p)
                            local y = Mark(u2, "分路")
                            local z = Mark(u2, "目标")
                            local point = ArmyPoint[x][y][z]
                            if point then
                                IssuePointOrderLoc(u2, "attack", point)
                            else
                                Debug("<释放攻城组>没有找到攻击目标" )
                            end
                            Mark(u2, "专注攻击目标", false)
                        end
                    end
                end
            end
        end
    )
    
    require "ProtectHero.lua"
    
