    
    --分割字符串
    string.split = function(str, tos)
        local x = 1
        local strl = string.len(str)
        local tosl = string.len(tos)
        local strs = {}
        for y = 1, strl do
            if string.sub(str, y, y+tosl-1) == tos then
                table.insert(strs, string.sub(str, x, y-1))
                x = y + tosl
            end
        end
        if strl >= x then
            table.insert(strs, string.sub(str, x, strl))
        end
        return strs
    end
    
    --连接字符串
    string.concat = function(t, cs)
        cs = cs or ""
        rs = ""
        for _,s in ipairs(t) do
            if rs == "" then
                rs = rs .. s
            else
                rs = rs .. cs .. s
            end
        end
        return rs
    end
    
    string.concat = table.concat --我2了

