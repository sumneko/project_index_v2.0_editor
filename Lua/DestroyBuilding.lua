    
    local win
    
    Event("死亡",
        function(data)
            if IsUnitType(data.unit, UNIT_TYPE_STRUCTURE) then
                local p = GetOwningPlayer(data.unit)
                if IsCom(p) then
                    local gold = GetUnitPointValue(data.unit)
                    local word
                    local ps
                    local p2
                    if GetPlayerTeam(p) == 0 then
                        ps = PB
                        p2 = Com[1]
                    else
                        ps = PA
                        p2 = Com[0]
                    end
                    local i1 = GetPlayerId(p)
                    local i2 = GetPlayerId(p2)
                    if data.killer then
                        local p3 = GetOwningPlayer(data.killer)
                        local i3 = GetPlayerId(p3)
                        if IsPlayerAlly(p, p3) then
                            gold = gold / 3
                            word = string.format("%s%s|r 反补了一座建筑, %s%s|r 的玩家获得 |cffffcc00%d|r !", Color[i3], PlayerName[i3], Color[i2], PlayerName[i2], gold)
                        elseif IsCom(p3) then
                            word = string.format("%s%s|r 摧毁了 %s%s|r 的一座建筑, 玩家获得 |cffffcc00%d|r !", Color[i3], PlayerName[i3], Color[i1], PlayerName[i1], gold)
                        elseif IsUser(p3) then
                            gold = gold * 4 / 5
                            word = string.format("%s%s|r 摧毁了一座建筑, %s%s|r 的玩家获得 |cffffcc00%d|r !", Color[i3], PlayerName[i3], Color[i2], PlayerName[i2], gold)
                        else
                            word = string.format("野怪 莫名其妙的摧毁了 %s%s|r 的一座建筑, %s%s|r 的玩家获得 |cffffcc00%d|r !", Color[i1], PlayerName[i1], Color[i2], PlayerName[i2], gold)
                        end
                        
                    else
                        word = string.format("%s%s|r 的违章建筑被城管取缔了, %s%s|r 的玩家获得 |cffffcc00%d|r !", Color[i1], PlayerName[i1], Color[i2], PlayerName[i2], gold)
                    end
                    print(word)
                    for i = 1, 5 do
                        GetGold(ps[i], gold)
                    end
                    if not win then
                        local id = GetUnitTypeId(data.unit)
                        if id == |h00P| then
                            print("|cffffcc00罗马正教胜利!|r")
                            win = 1
                        elseif id == |hcas| then
                            print("|cffffcc00学园都市胜利!|r")
                            win = 0
                        end
                    end
                end
            end
        end
    )
    
