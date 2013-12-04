
    Event("复活",
        function(data)
            local u = data.unit
            local p = GetOwningPlayer(u)
            if p == SELFP then
                ClearSelection()
                SelectUnit(u, true)
                PanCameraToTimed(GetUnitX(u), GetUnitY(u), 0.5)
            end
            Wait(0,
                function()
                    SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MAX_MANA))
                end
            )
        end
    )
    
    Event("阵亡",
        function(data)
            local p = GetOwningPlayer(data.u2)
            local i = GetPlayerId(p)
            local lv = GetUnitLevel(data.u2)
            local t = lv * 4 + 10 --复活时间
            local g = lv * 25 + 100 --死亡损失
            local data = {unit = data.u2, player = p, time = t, otime = t, gold = g, ogold = g}
            toEvent("阵亡损失", data)
            t = data.time
            g = data.gold
            SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) - g)
            Mark(p, "死亡损失", Mark(p, "死亡损失") or 0 + g)
            
            Mark(p, "死亡时间", Mark(p, "死亡时间") or 0 + t)
            Mark(p, "复活时间", t)
            
            MultiboardSetItemValue(Board["战损"][i], string.format("|cffffff00%d|r || |cffff0000%s|r", Mark(Player(i), "死亡损失"), TimeWord(Mark(Player(i), "死亡时间"))))
            
            Loop(1,
                function()
                    t = t - 1
                    Mark(p, "复活时间", t)
                    MultiboardSetItemValue(Board["名字"][i], string.format("%s|cffff0000(%d)|r", PlayerNameHero(i, true, true), t))
                    if t == 0 or IsUnitAlive(Hero[i]) then
                        Mark(p, "复活时间", 0)
                        if IsUnitDead(Hero[i]) then
                            ReviveHeroLoc(Hero[i], StartPoint[GetPlayerTeam(p)], true)
                            SetUnitState(Hero[i], UNIT_STATE_LIFE, 999999)
                            toEvent("复活", {unit = Hero[i]})
                        end
                        MultiboardSetItemValue(Board["名字"][i], PlayerNameHero(i, true, true))
                        EndLoop()
                    end
                end
            )
        end
    )
    
    luaDone()
    
