
    local IsPath = function(x, y, b)
        return IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY)
        and IsTerrainPathable(x - 32, y, PATHING_TYPE_WALKABILITY)
        and IsTerrainPathable(x + 32, y, PATHING_TYPE_WALKABILITY)
        and IsTerrainPathable(x, y - 32, PATHING_TYPE_WALKABILITY)
        and IsTerrainPathable(x, y + 32, PATHING_TYPE_WALKABILITY)
        or GetTerrainCliffLevel(x, y) > 4
    end

    local MoverDebug = function(u)
        if IsPath(GetXY(u)) then
            local a = GetRandomInt(1, 4) * 90
            local d = 0
            for i = 0, 400 do
                a = a + 90
                if i % 4 == 0 then
                    d = d + 32
                end
                local p = MovePoint(u, {d, a})
                if not IsPath(GetXY(p)) then
                    SetUnitXY(u, p)
                    return
                end
            end
            Debug("<MoverDebug>没有找到可通行的位置:" .. GetUnitName(u))
        end
    end
    
    --偏转移动
    MoveXYZ = function(u, x, y, z, move, target)
        local b = true
        ux = GetUnitX(u)
        uy = GetUnitY(u)
        nx = (x or 0) + ux
        ny = (y or 0) + uy
        if not target then
            if IsTerrainPathable(nx, uy, PATHING_TYPE_FLYABILITY) then
                nx = ux
                b = false
            end
            if IsTerrainPathable(ux, ny, PATHING_TYPE_FLYABILITY) then
                ny = uy
                b = false
            end
        end
        if move then
            SetUnitPosition(u, nx, ny)
        else
            SetUnitX(u, nx)
            SetUnitY(u, ny)
        end
        if z then
            SetUnitFlyHeight(u, GetUnitFlyHeight(u)+z, 0)
        end
        return b, nx, ny
    end
    
    --重定义目标
    local newTarget = function(move, u)
        move.target = u
        if toEvent("弹道即将命中", move) then
            move.angle = GetBetween(move.unit, move.target, true) --重定义角度
            --重定义每周期移动距离
            move.x = Cos(move.angle) * move.speed
            move.y = Sin(move.angle) * move.speed
            move.target = nil --取消目标以免变为追踪性弹道
            return true
        end
        move.target = nil
    end
    
    --移动数据, 每周期运行函数, 结束后运行函数
    Mover = function(move, func, func2, func3)
        
        --排除一些异常参数
        if move.unit and GetUnitMoveSpeed(move.unit) == 0 then return end
        
        if not move.distance and move.target then
            move.distance = GetBetween(move.unit or move.from, move.target)
        end
        
        --计算速度
        if move.distance and move.time then
            move.speed = move.distance / move.time
        end
        
        if move.speed then
            if not move.angle then
                if move.unit then
                    move.angle = GetUnitFacing(move.unit)
                elseif move.target then
                    move.angle = GetBetween(move.from, move.target, true)
                elseif type(move.from) ~= "table" then
                    move.angle = GetUnitFacing(move.from)
                else
                    move.angle = 0
                end
            end
            move.x = Cos(move.angle) * move.speed
            move.y = Sin(move.angle) * move.speed
        else
            move.x = move.x or 0
            move.y = move.y or 0
            move.angle = Atan2(move.y, move.x)
            move.speed = (move.x * move.x + move.y * move.y) ^ 0.5
        end
        
        --创建模型
        if not move.unit and move.modle then
            local x, y = GetXY(move.source or move.from)
            move.unit = CreateUnit(Player(15), |e031|, x, y, move.angle)
            move.modle = AddSpecialEffectTarget(move.modle, move.unit, "origin")
            KillUnit(move.unit)
            --模型大小
            if not move.z then
                move.z = 0
            end
            if move.size then
                SetUnitScale(move.unit, move.size, move.size, move.size)
            else
                move.size = 1
            end
            if move.modle then
                move.fz = 100
            else
                move.fz = 0
            end
            SetUnitFlyHeight(move.unit, move.fz * move.size + move.z, 0)

        end
        
        --允许单位飞行
        FlyEnable(move.unit)
        
        move.distance = move.distance or (move.time or 0) * move.speed
        move.flash = math.max(0.01, move.flash or 0.02) --刷新周期默认为0.02,不低于0.01
        move.x = move.x * move.flash
        move.y = move.y * move.flash
        move.speed = move.speed * move.flash
        move.moved = 0
        move.originz = 0
        move.pause = 0
        move.nz = 0
        move.timed = 0
        move.time = move.time or 9999999
        
        --是否允许移动
        if not move.canmove then
            MoveSpeed(move.unit, -10000)
        end
        
        --是否允许转身
        if not move.canturn then
            SetUnitTurnSpeed(move.unit, 0)
        end
        
        --是否关闭碰撞
        if not move.path then
            SetUnitPathing(move.unit, false)
            Mark(move.unit, "无碰撞", (Mark(move.unit, "无碰撞") or 0) + 1)
        end
        
        --移动结束后还原一些数据
        local End = function(b)
            if not move.canmove then
                MoveSpeed(move.unit, 10000)
            end
            if not move.canturn then
                SetUnitTurnSpeed(move.unit, 1)
            end
            if not move.path then
                Mark(move.unit, "无碰撞", (Mark(move.unit, "无碰撞") or 0) - 1)
                if Mark(move.unit, "无碰撞") == 0 then
                    SetUnitPathing(move.unit, true)
                end
            end
            if move.originz then
                SetUnitFlyHeight(move.unit, GetUnitFlyHeight(move.unit) - move.originz, 0)
            end
            if move.modle then
                DestroyEffect(move.modle)
                Wait(5,
                    function()
                        RemoveUnit(move.unit)
                    end
                )
            end
            move.finish = b
            if b and func2 then
                func2(move)
            end
            if func3 then
                func3(move)
            end
            Mark(move.unit, "移动器", false)
            if IsHero(move.unit) then
                MoverDebug(move.unit)
            end
        end
        
        Mark(move.unit, "移动器", move)
        
        --周期
        move.count = 0
        Loop(move.flash,
            function()
                if move.stop then
                    EndLoop()
                    End(false)
                    return
                end
                if move.pause > 0 then
                    move.pause = move.pause - move.flash
                else
                    move.count = move.count + 1
                    if move.target then
                        move.distance = GetBetween(move.unit, move.target)
                        move.angle = GetBetween(move.unit, move.target, true)
                        move.x = move.speed * Cos(move.angle)
                        move.y = move.speed * Sin(move.angle)
                        SetUnitFacing(move.unit, move.angle)
                    else
                        move.distance = move.distance - move.speed
                    end
                    if move.high and move.high ~= 0 then
                        move.step = move.moved / (move.moved + move.distance)
                        move.nz = 4 * move.high * move.step * (1 - move.step)
                    end
                    _, move.nx, move.ny = MoveXYZ(move.unit, move.x, move.y, move.nz - move.originz, move.move, move.target)
                    move.originz = move.nz
                    move.timed = move.timed + move.flash
                    move.moved = move.moved + move.speed
                    if func then
                        func(move)
                    end
                    if move.distance < move.speed * 1.5 or move.timed >= move.time then
                        EndLoop()
                        End(true)
                    end
                end
            end
        )
        
        --重定义目标
        move.newTarget = newTarget
        
        return move
    end
    
    MoverEx = function(move, func, func2, func3)
        move.x = move.x or 0
        move.y = move.y or 0
        move.z = move.z or 0
        if move.source then
            if type(move.source) == "table" then
                move.x = move.source[1] + move.x
                move.y = move.source[2] + move.y
                move.z = (move.source[3] or GetLocationZ(move.source)) + move.z
            else
                move.x = GetWidgetX(move.source) + move.x
                move.y = GetWidgetY(move.source) + move.y
                move.z = (GetUnitZ(move.source) or GetLocationZ{move.x, move.y}) + move.z
            end
        elseif move.from then
            if type(move.from) == "table" then
                move.x = move.from[1] + move.x
                move.y = move.from[2] + move.y
                move.z = (move.from[3] or GetLocationZ(move.from)) + move.z
            else
                move.x = GetWidgetX(move.from) + move.x
                move.y = GetWidgetY(move.from) + move.y
                move.z = (GetUnitZ(move.from) or GetLocationZ{move.x, move.y}) + move.z
            end
        end
        
        --创建马甲单位
        move.unit = CreateUnit(Player(15), |e031|, move.x, move.y, GetBetween({move.x, move.y}, move.target, true))
        --SetUnitPathing(move.unit ,false)
        --UnitAddAbility(move.unit, |Aloc|)
        KillUnit(move.unit)
        
        --缩放
        move.size = move.size or 1
        SetUnitScale(move.unit, move.size, move.size, move.size)
        
        --设置高度
        SetUnitZ(move.unit, 100 * move.size + move.z)
        
        --绑定特效
        move.effect = AddSpecialEffectTarget(move.modle, move.unit, "origin")
        
        --移动周期
        move.flash = math.max(0.01, move.flash or 0.02) --刷新周期默认为0.02,不低于0.01
        move.speed = move.speed * move.flash
        
        --初始化一些数据
        move.moved = 0
        move.pause = 0
        move.tz = move.tz or 0
        move.step = 0
        move.oz = 0
        move.cz2 = 0
        move.count = 0
        move.z1 = move.z
        
        --结束时运行
        local End = function(b)
            if func2 and b then
                func2(move)
            end
            SetUnitLookAt(move.unit, "head", move.unit, (move.cx or 0) * 100, (move.cy or 0) * 100, 0)
            DestroyEffect(move.effect)
            Wait(5,
                function()
                    RemoveUnit(move.unit)
                end
            )
            Mark(move.unit, "移动器", false)
        end
        
        Mark(move.unit, "移动器", move)
        
        --移动循环
        Loop(move.flash,
            function()
                if move.stop then
                    EndLoop()
                    End(false)
                    return
                end
                if move.pause > 0 then
                    move.pause = move.pause - move.flash
                else
                    move.distance = GetBetween(move.unit, move.target)
                    move.angle = GetBetween(move.unit, move.target, true)
                    move.cx = move.speed * Cos(move.angle)
                    move.cy = move.speed * Sin(move.angle)
                    
                    move.x = move.x + move.cx
                    move.y = move.y + move.cy
                   
                    SetUnitX(move.unit, move.x)
                    SetUnitY(move.unit, move.y)
                    
                    SetUnitFacing(move.unit, move.angle)
                    
                    if move.distance < move.speed * 1.5 then
                        if not toEvent("弹道即将命中", move) then
                            EndLoop()
                            End(true)
                        end
                    else
                        
                        move.cz = (GetZ(move.target) + move.tz - move.z1) * move.speed / move.distance
                        move.z1 = move.z1 + move.cz
                        
                        if move.high and move.high ~= 0 then
                            move.step = move.moved / (move.distance + move.moved)
                            move.nz = 4 * move.high * move.step * (1 - move.step)
                            move.cz2 = move.nz - move.oz
                            move.oz = move.nz
                        end
                        
                        move.z = move.z + move.cz + move.cz2
                        SetUnitZ(move.unit, move.z + 100 * move.size)

                        SetUnitLookAt(move.unit, "head", move.unit, move.cx * 100, move.cy * 100, (move.cz + move.cz2) * 100)
                        
                        move.moved = move.moved + move.speed
                        
                        if func then
                            func(move)
                        end
                        
                        move.count = move.count + 1
                    end
                end
            end
        )
        
        return move        
    end
    
    luaDone()
