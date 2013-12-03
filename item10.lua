    
    --当麻面包
    InitItem{
        name = "当麻面包",
        id = |I0CW|,
        use = function(this)
            if this.isitemtarget then
                this.target = this.unit
            end
            local data = Mark(this.target, this.name)
            if not data then
                data = {unit = this.target, timer = CreateTimer(), time = GetTime()}
                Mark(this.target, this.name, data)
                data.func = function()
                    Mark(this.target, this.name, false)
                    Recover(data.unit, -20)
                    DestroyEffect(data.effect)
                    DestroyTimer(data.timer)
                    Event("-伤害后", data.func2)
                end
                Recover(this.target, 20)
                data.effect = AddSpecialEffectTarget("Abilities\\Spells\\Other\\ANrm\\ANrmTarget.mdl", data.unit, "origin")
                data.func2 = Event("伤害后",
                    function(damage)
                        if damage.to == data.unit and damage.from and IsUser(GetOwningPlayer(damage.from)) then
                            if not damage.dot or damage.damage > 20 then 
                                data.func()
                            end
                        end
                    end
                )
            end
            data.time = data.time + 10
            
            TimerStart(data.timer, data.time - GetTime(), false, data.func)
        end,
        stack = 10
    }
    
    --运动饮料
    InitItem{
        name = "运动饮料",
        id = |I0CX|,
        use = function(this)
            if this.isitemtarget then
                this.target = this.unit
            end
            local data = Mark(this.target, this.name)
            if not data then
                data = {unit = this.target, timer = CreateTimer(), time = GetTime()}
                Mark(this.target, this.name, data)
                data.func = function()
                    Mark(this.target, this.name, false)
                    Recover(data.unit, 0, -5)
                    DestroyEffect(data.effect)
                    DestroyTimer(data.timer)
                    Event("-伤害后", data.func2)
                end
                Recover(this.target, 0, 5)
                data.effect = AddSpecialEffectTarget("Abilities\\Spells\\Other\\ANrl\\ANrlTarget.mdl", data.unit, "origin")
                data.func2 = Event("伤害后",
                    function(damage)
                        if damage.to == data.unit and damage.from and IsUser(GetOwningPlayer(damage.from)) then
                            if not damage.dot or damage.damage > 20 then 
                                data.func()
                            end
                        end
                    end
                )
            end
            data.time = data.time + 30
            
            TimerStart(data.timer, data.time - GetTime(), false, data.func)
        end,
        stack = 10
    }
    
