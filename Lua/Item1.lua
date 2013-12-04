    
    --菜刀
    InitItem{
        name = "菜刀",
        id = |I0AM|,
        skill = function(this)
            if this.event == "获得" then
                Attack(this.unit, 10)
            elseif this.event == "失去" then
                Attack(this.unit, -10)
            end
        end
    }
    
    --大斧
    InitItem{
        name = "大斧",
        id = |I0AN|,
        skill = function(this)
            if this.event == "获得" then
                Attack(this.unit, 20)
            elseif this.event == "失去" then
                Attack(this.unit, -20)
            end
        end
    }
    
    --长枪
    InitItem{
        name = "长枪",
        id = |I0AO|,
        skill = function(this)
            if this.event == "获得" then
                Attack(this.unit, 40)
            elseif this.event == "失去" then
                Attack(this.unit, -40)
            end
        end
    }
    
    --太刀
    InitItem{
        name = "太刀",
        id = |I0AQ|,
        skill = function(this)
            if this.event == "获得" then
                Attack(this.unit, 30)
            elseif this.event == "失去" then
                Attack(this.unit, -30)
            end
        end,
        skillOnly = {
            ["气刃斩"] = function(this)
                if this.event == "获得" then
                    Crit(this.unit, 20)
                elseif this.event == "失去" then
                    Crit(this.unit, -20)
                end
            end
        },
        complex = {"菜刀", "大斧"}
    }
    
    --七天七刀
    InitItem{
        name = "七天七刀",
        id = |I0AS|,
        skill = function(this)
            if this.event == "获得" then
                Attack(this.unit, 70)
                Crit(this.unit, 10)
            elseif this.event == "失去" then
                Attack(this.unit, -70)
                Crit(this.unit, -10)
            end
        end,
        skillOnly = {
            ["气刃斩"] = false,
            ["气刃斩·终式"] = function(this)
                if this.event == "获得" then
                    Crit(this.unit, nil, 50)
                elseif this.event == "失去" then
                    Crit(this.unit, nil, -50)
                end
            end
        },
        complex = {"太刀", "长枪"}
    }
    
    --吸血鬼指环
    InitItem{
        name = "吸血鬼指环",
        id = |I0AP|,
        skill = function(this)
            if this.event == "获得" then
                AttackStealLife(this.unit, 8, 4)
            elseif this.event == "失去" then
                AttackStealLife(this.unit, -8, -4)
            end
        end
    }
    
    --吸血鬼之触
    InitItem{
        name = "吸血鬼之触",
        id = |I0AT|,
        skill = function(this)
            if this.event == "获得" then
                Attack(this.unit, 20)
                AttackStealLife(this.unit, 10, 5)
            elseif this.event == "失去" then
                Attack(this.unit, -20)
                AttackStealLife(this.unit, -10, -5)
            end
        end,
        complex = {"吸血鬼指环", "大斧"}
    }
    
    --锐眼之石
    InitItem{
        name = "锐眼之石",
        id = |I0BU|,
        skillOnly = {
            ["观察之眼"] = function(this)
                if this.event == "获得" then
                    DefPenetrate(this.unit, 15)
                elseif this.event == "失去" then
                    DefPenetrate(this.unit, -15)
                end
            end
        }
    }
    
    --魔眼之石
    InitItem{
        name = "魔眼之石",
        id = |I0BW|,
        skillOnly = {
            ["观察之眼"] = false,
            ["黄金之眼"] = function(this)
                if this.event == "获得" then
                    DefPenetrate(this.unit, 15)
                elseif this.event == "失去" then
                    DefPenetrate(this.unit, -15)
                end
            end
        },
        complex = {"锐眼之石"}
    }
    
    --天丛云剑   
    InitItem{
        name = "天丛云剑",
        id = |I0BV|,
        skill = function(this)
            if this.event == "获得" then
                Attack(this.unit, 30)
                AttackSpeed(this.unit, 30)
            elseif this.event == "失去" then
                Attack(this.unit, -30)
                AttackSpeed(this.unit, -30)
            end
        end,
        skillOnly = {
            ["气刃斩"] = false,
            ["观察之眼"] = false,
            ["黄金之眼"] = false,
            ["削铁如泥"] = function(this)
                if this.event == "获得" then
                    local data = {unit = this.unit, player = GetOwningPlayer(this.unit), buffs = {}}
                    Mark(this.unit, this.skillname, data)
                    data.func = Event("伤害效果",
                        function(damage)
                            if damage.attack and damage.from == data.unit and EnemyFilter(data.player, damage.to, {["魔免"] = true}) then
                                local buff = data.buffs[damage.to]
                                if not buff then
                                    buff = {
                                        unit = damage.to,
                                        def = 0,
                                        timer = CreateTimer()
                                    }
                                    data.buffs[damage.to] = buff
                                end
                                if buff.def < 25 then
                                    buff.def = buff.def + 5
                                    Def(buff.unit, -5)
                                end
                                buff.func = function()
                                    Def(buff.unit, buff.def)
                                    DestroyTimer(buff.timer)
                                    data.buffs[buff.unit] = nil
                                end
                                TimerStart(buff.timer, 5, false, buff.func)
                                DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\OrbCorruption\\OrbCorruptionSpecialArt.mdl", damage.to, "chest"))
                            end
                        end
                    )
                elseif this.event == "失去" then
                    local data = Mark(this.unit, this.skillname)
                    for _, buff in pairs(data.buffs) do
                        buff.func()
                    end
                    Event("-伤害效果", data.func)
                end
            end
        },
        complex = {"太刀", "魔眼之石", "加速手套", "加速手套"}
    }

