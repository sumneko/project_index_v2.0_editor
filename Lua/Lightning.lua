    Lightning = function(l)
        l.length = GetBetween({l.x1, l.y1}, {l.x2, l.y2})
        if l.cut then
            toEvent("截断光束", l)
        end
        l.l = AddLightningEx(l.name, l.check, l.x1, l.y1, l.z1, l.x2, l.y2, l.z2)
        if l.time then
            Wait(l.time,
                function()
                    DestroyLightning(l.l)
                end
            )
        end
        if l.color then
            SetLightningColor(l.l, l.color[1], l.color[2], l.color[3], l.color[4])
        end
        return l, l.l
    end
    
    ChangeLightning = function(l)
        l.length = GetBetween({l.x1, l.y1}, {l.x2, l.y2})
        if l.cut then
            toEvent("截断光束", l)
        end
        MoveLightningEx(l.l, l.check, l.x1, l.y1, l.z1, l.x2, l.y2, l.z2)
        if l.color then
            SetLightningColor(l.l, l.color[1], l.color[2], l.color[3], l.color[4])
        end
        return l, l.l
    end
    
