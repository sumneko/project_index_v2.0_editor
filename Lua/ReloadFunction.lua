    
    local reload = {}
    
    Reload = function(name, func)
        if name:sub(1, 1) == "-" then
            name = name:sub(2)
            local funcs = reload[name]
            for i = 2, #funcs do
                local f = funcs[i]
                if f == func then
                    table.remove(funcs, i)
                    break
                end
            end
            if #funcs == 1 then
                _G[name] = funcs[1]
                reload[name] = nil
            end
        else
            local funcs = reload[name]
            if not funcs then
                funcs = {
                    _G[name],
                    index = 0,
                    code = function(...)
                        local i = math.max(1, #funcs - funcs.index)
                        funcs.index = funcs.index + 1
                        local returns = {funcs[i](...)}
                        funcs.index = funcs.index - 1
                        return unpack(returns)
                    end
                }
                reload[name] = funcs
                _G[name] = funcs.code
            end
            table.insert(funcs, func)
            return func
        end
    end
    
    
    
