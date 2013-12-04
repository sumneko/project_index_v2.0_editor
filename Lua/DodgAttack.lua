    
    Event("伤害无效",
        function(damage)
            if damage.attack then
                if toEvent("计算闪躲", damage) then
                    damage.dodgReason = "闪躲"
                    return true
                end
            end
        end
    )
    
    Event("伤害无效后",
        function(damage)
            if damage.attack then
                if damage.dodgReason == "闪躲" then
                    Text{
                        unit = damage.to,
                        word = "闪躲",
                        size = 12,
                        x = -20,
                        z = 50,
                        color = {100, 0, 0},
                        speed = {120, 90},
                        life = {2, 3},
                    }
                elseif damage.dodgReason == "未击中" then
                    Text{
                        unit = damage.from,
                        word = "未击中",
                        size = 12,
                        x = -25,
                        z = 50,
                        color = {100, 0, 0},
                        speed = {120, 90},
                        life = {2, 3},
                    }
                end
            end
        end
    )
    
    luaDone()
