    
    --lua引擎预设slk    
    getObj = function(t, id, name, d)
        local u = t[id2string(id)]
        if u then
            if name then
                local u = u[name]
                if u then
                    return u
                end
            else
                return u
            end
        end
        return d
    end

