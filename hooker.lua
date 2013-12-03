    
    Hooker = function(this)
        --modle = {钩头模型路径, 钩身模型路径}
        --size = {钩头缩放, 钩身缩放}
        --lookat = {模型朝向}
        --source = 起点
        --from = 发起者
        --x = 起点修正x
        --y = 起点修正y
        --z = 起点修正z
        --angle = 钩子角度
        --speed = 钩子速度
        --distance = 最大距离
        --range = 判定范围
        --back = 钩子返回时是否有判定
        --filter = 判定函数
        --start = 钩子开始时的回调函数
        --hit = 钩子命中时的回调函数
        --finish = 钩子结束时的回调函数
        --run = 挣脱判定范围
        --tow = 甩勾范围
        
        local x, y = GetXY(this.source or this.from)
        if this.x then
            x = x + this.x
        end
        if this.y then
            y = y + this.y
        end
        z = this.z or 0
        --创建钩头
        this.unit = CreateUnit(Player(15), |e031|, x, y, this.angle)
        local fz1, fz2
        if this.size then
            SetUnitScale(this.unit, this.size[1], this.size[1], this.size[1])
            fz1 = 100 * this.size[1] + z
            fz2 = 100 * this.size[2] + z
        else
            fz1 = z
            fz2 = z
        end
        SetUnitFlyHeight(this.unit, fz1, 0)
        if this.lookat then
            local l = GetBetween({0, 0}, this.lookat)
            local a = GetBetween({0, 0}, this.lookat, true)
            local np = MovePoint({0, 0}, {l, a + this.angle})
            this.lookat[1] = np[1]
            this.lookat[2] = np[2]
            SetUnitLookAt(this.unit, "head", this.unit, this.lookat[1], this.lookat[2], this.lookat[3])
        end
        KillUnit(this.unit)
        this.effect = AddSpecialEffectTarget(this.modle[1], this.unit, "origin")
        
        if this.start then
            this:start()
        end
        
        --钩头开始移动
        local flash = 0.02 --移动周期
        local mo = 10
        local count = 0
        local dised = 0
        local isback
        local step = this.speed * flash
        local backunit = this.from
        Loop(flash,
            function()
                count = count + 1
                if this.gomove() then
                    EndLoop()
                    if this.to then
                        MoveSpeed(this.to, 10000)
                    end
                    DestroyEffect(this.effect)
                    RemoveUnit(this.unit)
                    this.goahead()
                    if this.finish then
                        this:finish()
                    end
                    return
                end
                
                if count % mo == 0 then
                    if this.to == nil and (not isback or this.back) then
                        forRange(this.unit, this.range,
                            function(u)
                                if u ~= this.from and IsUnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_GIANT) and GetUnitAbilityLevel(u, |Avul|) == 0 then
                                    this.to = this:filter(u)
                                end
                            end
                        )
                        --钩中
                        if this.to then
                            Debug("<钩子>击中单位:" .. GetUnitName(this.to))
                            MoveSpeed(this.to, -10000)
                            if this.hit then
                                this:hit()
                            end
                            if not isback then
                                isback = true
                            end
                        end
                    end
                    
                    this.goahead()
                end
            end
        )
        
        --甩勾
        this.tow = this.tow or 0
        local towed = 0
        local lastback = GetUnitLoc(backunit)
        
        --用来判定甩勾
        this.gotow = function()
            if backunit == lastback then return end -- 说明钩身已经断裂
            local d = GetBetween(this.unit, backunit)
            towed = towed + d - dised
            dised = d
            if towed > this.tow then --钩身断裂
                backunit = lastback
            else
                lastback = GetUnitLoc(backunit)
            end
        end
        
        this.run = this.run or this.range
        
        --钩头前进
        this.gomove = function()
            if this.to then
                local r = GetBetween(this.to, this.unit)
                if r > this.run then
                    MoveSpeed(this.to, 10000) --钩子被挣脱
                    this.to = false
                else
                    SetUnitXY(this.to, this.unit) --把被钩中的单位移动到钩头的位置
                end
            end
            if isback then
                this.angle = GetBetween(this.unit, backunit, true)
                MoveXYZ(this.unit, step * Cos(this.angle), step * Sin(this.angle))
                dised = dised - step
                this.gotow()
                return dised < step
            else
                MoveXYZ(this.unit, step * Cos(this.angle), step * Sin(this.angle))
                dised = dised + step
                this.gotow()
                if dised >= this.distance then
                    isback = true
                end
            end
        end
        
        --钩身
        
        --创建钩身的函数
        local dummy = function(where)
            local x, y = GetXY(where)
            local u = CreateUnit(Player(15), |e031|, x, y, 0)
            KillUnit(u)
            if this.size then
                SetUnitScale(u, this.size[2], this.size[2], this.size[2])
            end
            SetUnitFlyHeight(u, fz2, 0)
            local e = AddSpecialEffectTarget(this.modle[2], u, "origin")
            return u, e
        end
        
        local units = {} --记录钩身
        local effects = {}
        local len = this.speed * flash * mo --每节钩子之间的距离
        
        --刷新钩身
        this.goahead = function()
            local num = math.floor(dised / len) --钩身的数量
            local a = GetBetween(this.unit, backunit, true) --角度
            for i = 1, num do
                local loc = MovePoint(this.unit, {len * i, a})
                if units[i] then
                    SetUnitXY(units[i], loc)
                else
                    units[i], effects[i] = dummy(loc)
                end
            end
            for i = num + 1, #units do
                DestroyEffect(effects[i])
                RemoveUnit(units[i])
                units[i] = nil
            end
        end
    end
    
