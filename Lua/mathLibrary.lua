    
    --取近似值
    math.near = function(r)
        local nr = math.floor(r)
        if r - nr < 0.01 then
            return nr
        end
        nr = math.ceil(r)
        if nr - r < 0.01 then
            return nr
        end
        return r
    end
    
    math.A2A = function(r1, r2)
        local r = r1 - r2
        r = r%360
        if r > 180 then
            return 360 - r
        elseif r < -180 then
            return 360 + r
        elseif r < 0 then
            return - r
        end
        return r
    end
    
