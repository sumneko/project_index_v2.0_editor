    
    do return end
    
    Event("伤害后", 
        function(damage)
            Debug("[" .. GetUnitName(damage.from) .. " → " .. GetUnitName(damage.to) .. "][" .. damage.odamage .. " → " .. damage.damage .. "]")
        end
    )
    
    luaDone()
