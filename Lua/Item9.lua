    
    --风之鞭
    InitItem{
        name = "风之鞭",
        id = |I0CU|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 3, 15, 3)
                this.data = {}
                this.data.func = Event("伤害效果", "死亡",
                    function(data)
                        if data.event == "伤害效果" then
                            if data.from == this.unit and data.attack then
                                SetUnitState(this.unit, UNIT_STATE_MANA, 3 + GetUnitState(this.unit, UNIT_STATE_MANA))
                            end
                        elseif data.event == "死亡" then
                            if data.killer == this.unit then
                                SetUnitState(this.unit, UNIT_STATE_MANA, 5 + GetUnitState(this.unit, UNIT_STATE_MANA))
                            end
                        end
                    end
                )
            elseif this.event == "失去" then
                Sai(this.unit, -3, -15, -3)
                Event("-伤害效果", "-死亡", this.data.func)
            end
        end,
        use = function(this)
            Hooker{
                from = this.unit,
                modle = {"Abilities\\Spells\\Other\\Tornado\\TornadoElementalSmall.mdl", "Abilities\\Spells\\Other\\Tornado\\Tornado_Target.mdl"},
                size = {0.35, 1},
                --lookat = {-100, 0, 10000},
                z = 50,
                speed = 500,
                angle = GetBetween(this.unit, this.target, true),
                distance = 1000,
                range = 150,
                tow = 500,
                filter = function(data, u)
                    return u
                end
            }
        end,
        complex = {"皮鞭", "敏捷之靴"}
    }
    
    --风魔之弦
    InitItem{
        name = "风魔之弦",
        id = |I0CV|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 3, 40, 3)
                this.data = {}
                this.data.func = Event("伤害效果", "死亡",
                    function(data)
                        if data.event == "伤害效果" then
                            if data.from == this.unit and data.attack then
                                SetUnitState(this.unit, UNIT_STATE_MANA, 3 + GetUnitState(this.unit, UNIT_STATE_MANA))
                            end
                        elseif data.event == "死亡" then
                            if data.killer == this.unit then
                                SetUnitState(this.unit, UNIT_STATE_MANA, 5 + GetUnitState(this.unit, UNIT_STATE_MANA))
                            end
                        end
                    end
                )
            elseif this.event == "失去" then
                Sai(this.unit, -3, -40, -3)
                Event("-伤害效果", "-死亡", this.data.func)
            end
        end,
        skillOnly = {
            ["风暴来袭"] = function(this)
                if this.event == "获得" then
                    Mark(this.unit, this.skillname, Event("伤害效果",
                        function(damage)
                            if damage.from == this.unit and damage.weapon then
                                if Random(33) then
                                    Wait(0.2,
                                        function()
                                            if GetUnitTypeId(this.unit) == 0 then return end
                                            local ob = getObj(slk.unit, GetUnitTypeId(this.unit))
                                            local t = tonumber(ob.dmgpt1 or 0.1)
                                            SetUnitAnimation(this.unit, "attack")
                                            Wait(t,
                                                function()
                                                    if GetUnitTypeId(this.unit) == 0 then return end
                                                    StartWeaponAttack(this.unit, damage.to)
                                                end
                                            )
                                        end
                                    )
                                end
                            end
                        end
                    ))
                elseif this.event == "失去" then
                    Event("-伤害效果", Mark(this.unit, this.skillname))
                end
            end
        },
        use = function(this)
            Hooker{
                from = this.unit,
                modle = {"Abilities\\Spells\\Other\\Tornado\\TornadoElementalSmall.mdl", "Abilities\\Spells\\Other\\Tornado\\Tornado_Target.mdl"},
                size = {0.35, 1},
                --lookat = {-100, 0, 10000},
                z = 50,
                speed = 500,
                angle = GetBetween(this.unit, this.target, true),
                distance = 1500,
                range = 150,
                tow = 500,
                filter = function(data, u)
                    return u
                end
            }
        end,
        complex = {"风之鞭", "莺歌弓"}
    }
    
