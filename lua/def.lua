    
     GetUnitDefReduce = function(u)
        local def
        if type(u) == "number" then
            def = u
        else
            def = GetUnitState(u, ConvertUnitState(0x20))
        end
        if def == 0 then
            return 1
        elseif def > 0 then
            return 1 / (def*0.01 + 1) --这里的0.01由平衡常数定义
        else
            return 2 - math.pow(0.99, -def)
        end
    end
    
    Event("伤害前",
        function(damage)
            if damage.def then
                local x = GetUnitState(damage.to, ConvertUnitState(0x20))
                if x > 0 then
                    local def1 = (damage.def1 or 0) + (Mark(damage.from, "护甲穿透1") or 0)
                    local def2 = (damage.def2 or 0) + (Mark(damage.from, "护甲穿透2") or 0)
                    x = math.max(0, x - def1 - x * def2 * 0.01)
                end
                x = GetUnitDefReduce(x)
                damage.odamage = damage.odamage * x
                damage.damage = damage.damage * x
            end
        end
    )
    
    DefPenetrate = function(u, def1, def2)
        if def1 then
            Mark(u, "护甲穿透1", (Mark(u, "护甲穿透1") or 0) + def1)
        end
        if def2 then
            Mark(u, "护甲穿透2", (Mark(u, "护甲穿透2") or 0) + def2)
        end
    end
            
