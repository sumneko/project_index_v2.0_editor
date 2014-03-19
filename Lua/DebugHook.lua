    
    do
        local old = japi.EXGetAbilityState
        
        japi.EXGetAbilityState = function(ab, st)
            local cd = old(ab, st)
            if cd < 0 then
                print("<Debug>获取到的技能冷却小于0:" .. GetHandleId(ab) .. ":" .. cd)
                cd = 0
                japi.EXSetAbilityState(ab, st, cd)
            end
            return cd
        end
    end
    
    do
        local old = japi.EXSetAbilityState
        
        japi.EXSetAbilityState = function(ab, st, cd)
            if cd < 0 then
                print("<Debug>设置的技能冷却小于0:" .. GetHandleId(ab) .. ":" .. cd)
                cd = 0
            end
            return old(ab, st, cd)
        end
    end

