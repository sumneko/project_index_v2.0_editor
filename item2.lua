    
    --呱太
    InitItem{
        name = "呱太",
        id = |I0AV|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 1, 1, 1)
            elseif this.event == "失去" then
                Sai(this.unit, -1, -1, -1)
            end
        end
    }
    
    --稀有呱太
    InitItem{
        name = "稀有呱太",
        id = |I0AW|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 3, 3, 3)
            elseif this.event == "失去" then
                Sai(this.unit, -3, -3, -3)
            end
        end,
        skillOnly = {
            ["值得珍藏"] = function(this)
                if this.event == "获得" then
                    Mark(this.unit, this.skillname, Event("伤害加成",
                        function(damage)
                            if damage.attack and damage.from == this.unit and not IsUser(GetOwningPlayer(damage.to)) then
                                if IsUnitRange(damage.from) then
                                    damage.damage = damage.damage + 0.2 * damage.odamage
                                else
                                    damage.damage = damage.damage + 0.3 * damage.odamage
                                end
                            end
                        end
                    ))
                elseif this.event == "失去" then
                    Event("-伤害加成", Mark(this.unit, this.skillname))
                end                
            end
        },
        complex = {"呱太", "呱太", "呱太"}
    }
    
    --力量手套
    InitItem{
        name = "力量手套",
        id = |I0AX|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 6)
            elseif this.event == "失去" then
                Sai(this.unit, -6)
            end
        end
    }
    
    --力量之锤
    InitItem{
        name = "力量之锤",
        id = |I0AY|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 12)
            elseif this.event == "失去" then
                Sai(this.unit, -12)
            end
        end
    }
    
    --重型战斧
    InitItem{
        name = "重型战斧",
        id = |I0AZ|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 24)
            elseif this.event == "失去" then
                Sai(this.unit, -24)
            end
        end
    }
    
    --敏捷指环
    InitItem{
        name = "敏捷指环",
        id = |I0B0|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 0, 6)
            elseif this.event == "失去" then
                Sai(this.unit, 0, -6)
            end
        end
    }
    
    --敏捷之靴
    InitItem{
        name = "敏捷之靴",
        id = |I0B1|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 0, 12)
            elseif this.event == "失去" then
                Sai(this.unit, 0, -12)
            end
        end
    }
    
    --莺歌弓
    InitItem{
        name = "莺歌弓",
        id = |I0B2|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 0, 24)
            elseif this.event == "失去" then
                Sai(this.unit, 0, -24)
            end
        end
    }
    
    --智力斗篷
    InitItem{
        name = "智力斗篷",
        id = |I0B3|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 0, 0, 6)
            elseif this.event == "失去" then
                Sai(this.unit, 0, 0, -6)
            end
        end
    }
    
    --智力挂饰
    InitItem{
        name = "智力挂饰",
        id = |I0B4|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 0, 0, 12)
            elseif this.event == "失去" then
                Sai(this.unit, 0, 0, -12)
            end
        end
    }
    
    --大魔法师的秘典
    InitItem{
        name = "大魔法师的秘典",
        id = |I0B5|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 0, 0, 24)
            elseif this.event == "失去" then
                Sai(this.unit, 0, 0, -24)
            end
        end
    }
    
    --能量增幅器
    InitItem{
        name = "能量增幅器",
        id = |I0C4|,
        skill = function(this)
            if this.event == "获得" then
                Sai(this.unit, 10, 10, 10)
            elseif this.event == "失去" then
                Sai(this.unit, -10, -10, -10)
            end
        end
    }
