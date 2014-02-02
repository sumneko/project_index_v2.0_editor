    
    --初春的花环
    InitItem{
        name = "初春的花环",
        id = |I0BO|,
        skill = function(this)
            if this.event == "获得" then
                Recover(this.unit, 4)
            elseif this.event == "失去" then
                Recover(this.unit, -4)
            end
        end
    }
    
    --生命宝珠
    InitItem{
        name = "生命宝珠",
        id = |I0BP|,
        skill = function(this)
            if this.event == "获得" then
                MaxLife(this.unit, 300, true)
            elseif this.event == "失去" then
                MaxLife(this.unit, -300, true)
            end
        end
    }
    
    --魔能宝珠
    InitItem{
        name = "魔能宝珠",
        id = |I0BQ|,
        skill = function(this)
            if this.event == "获得" then
                MaxLife(this.unit, 225, true)
                MaxMana(this.unit, 150, true)
            elseif this.event == "失去" then
                MaxLife(this.unit, -225, true)
                MaxMana(this.unit, -150, true)
            end
        end
    }
    
    --守护指环
    InitItem{
        name = "守护指环",
        id = |I0BR|,
        skill = function(this)
            if this.event == "获得" then
                Def(this.unit, 10)
            elseif this.event == "失去" then
                Def(this.unit, -10)
            end
        end
    }
    
    --锁子甲
    InitItem{
        name = "锁子甲",
        id = |I0BS|,
        skill = function(this)
            if this.event == "获得" then
                Def(this.unit, 30)
            elseif this.event == "失去" then
                Def(this.unit, -30)
            end
        end
    }
    
    --防暴盾
    InitItem{
        name = "防暴盾",
        id = |I0BT|,
        skillOnly = {
            ["护盾格挡"] = function(this)
                if this.event == "获得" then
                    Mark(this.unit, this.skillname, Event("伤害减免",
                        function(damage)
                            if damage.to == this.unit and damage.attack then
                                damage.damage = damage.damage - 10
                            end
                        end
                    ))
                elseif this.event == "失去" then
                    Event("-伤害减免", Mark(this.unit, this.skillname))
                end
            end
        }
    }
    
    --生命甲
    InitItem{
        name = "生命甲",
        id = |I0BX|,
        skill = function(this)
            if this.event == "获得" then
                Recover(this.unit, 5)
                MaxLife(this.unit, 300, true)
                Def(this.unit, 20)
            elseif this.event == "失去" then
                Recover(this.unit, -5)
                MaxLife(this.unit, -300, true)
                Def(this.unit, -20)
            end
        end,
        complex = {"初春的花环", "生命宝珠", "守护指环", "守护指环"}
    }
    
    --天使甲
    InitItem{
        name = "天使铠",
        id = |I0C0|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 25)
                Recover(this.unit, 5)
                MaxLife(this.unit, 300, true)
                Def(this.unit, 20)
            elseif this.event == "失去" then
                Sai(this.unit, -25)
                Recover(this.unit, -5)
                MaxLife(this.unit, -300, true)
                Def(this.unit, -20)
            end
        end,
        skillOnly = {
            ["天使庇护"] = function(this)
                if this.event == "获得" then
                    local data = {unit = this.unit, recover = 0, timer = CreateTimer()}
                    Mark(this.unit, this.skillname, data)
                    local func = function()
                        local recover = (GetUnitState(data.unit, UNIT_STATE_MAX_LIFE) - GetUnitState(data.unit, UNIT_STATE_LIFE)) * 0.02
                        Recover(data.unit, recover - data.recover)
                        data.recover = recover
                    end
                    func()
                    TimerStart(data.timer, 1, true, func)
                elseif this.event == "失去" then
                    local data = Mark(this.unit, this.skillname)
                    DestroyTimer(data.timer)
                    Recover(data.unit, - data.recover)
                end
            end
        },
        complex = {"重型战斧", "生命甲"}
    }
    
    --警备员的防护服
    InitItem{
        name = "警备员的防护服",
        id = |I0BZ|,
        skill = function(this)
            if this.event == "获得" then
                Attack(this.unit, 10)
                Def(this.unit, 30)
                this.func = Event("伤害减免",
                    function(damage)
                        if damage.to == this.unit and damage.attack then
                            damage.damage = damage.damage - 5
                        end
                    end
                )
            elseif this.event == "失去" then
                Attack(this.unit, -10)
                Def(this.unit, -30)
                Event("-伤害减免", this.func)
            end
        end,
        skillOnly = {
            ["护盾格挡"] = false
        },
        complex = {"防暴盾", "锁子甲", "菜刀"}
    }
    
    --驱动铠
    InitItem{
        name = "驱动铠",
        id = |I0C6|,
        skill = function(this)
            if this.event == "获得" then
                Attack(this.unit, 45)
                Def(this.unit, 60)
                this.func = Event("伤害减免",
                    function(damage)
                        if damage.to == this.unit and damage.attack then
                            damage.damage = damage.damage - 10
                        end
                    end
                )
            elseif this.event == "失去" then
                Attack(this.unit, -45)
                Def(this.unit, -60)
                Event("-伤害减免", this.func)
            end
        end,
        skillOnly = {
            ["护盾格挡"] = false
        },
        complex = {"警备员的防护服", "锁子甲", "长枪"}
    }
    
