    
    --表中是否有指定值
    table.has = function(t, v)
        if type(t) ~= "table" then return false end
        for _,tv in pairs(t) do
            if tv == v then
                return true
            elseif type(tv) == "table" and table.has(tv, v) then
                return true
            end
        end
        return false
    end
    
    --从表中移除值
    table.remove2 = function(t, v)
        for i, f in ipairs(t) do
            if f == v then
                table.remove(t, i) --把函数从表中移除
                return i
            end
        end
    end
    
    --从表中获取极值
    table.getone = function(t, func)
        local v1
        for _, v in pairs(t) do
            if v1 then
                if not func(v1, v) then
                    v1 = v
                end
            else
                if v then
                    v1 = v
                else
                    return
                end
            end
        end
        return v1
    end
    
    --复制表
    table.copy = function(t, b, tt)
        local nt = {}
        if b == true then
            --完全复制
            local tt = tt or {}
            for k, v in pairs(t) do
                if type(v) == "table" and not tt[v] then
                    tt[v] = true
                    nt[k] = table.copy(v, true, tt)
                else
                    nt[k] = v
                end
            end
        elseif b == false then
            --不完全复制
            for k, v in pairs(t) do
                nt[k] = v
            end
        else
            --继承
            setmetatable(nt, {__index = t})
        end
        return nt
    end
    
    --创建有默认值的表
    table.new = function(v)
        local nt = {}
        setmetatable(nt, {__index = function()
            return v
        end})
        return nt
    end
    
