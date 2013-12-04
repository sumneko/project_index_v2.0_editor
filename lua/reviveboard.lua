    
    Wait(0, function()
        --创建排行榜
        local LB = CreateLeaderboard()
        LeaderboardSetItemStyle(LB, true, true, false, false)
        for i = 0, 11 do
            PlayerSetLeaderboard(Player(i), LB)
        end
        LeaderboardDisplay(LB, true)
        
        LoopRun(0.5, function()
            --设置排行榜标题
            local w = "时间  " .. GetTimeWord()
            
            local t = Mark(SELFP, "复活时间")
            if t and t > 0 then
                w = w .. "\n复活  " .. TimeWord(t)
            end
            LeaderboardSetLabel(LB, w)
                
        end)
    end)
    
    luaDone()
