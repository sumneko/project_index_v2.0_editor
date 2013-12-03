
    local gameStartTimer = CreateTimer()
    local gameReadyTimer = CreateTimer()
    
    StartGameIn = function(t)
        --设置游戏时间
        SetGameTime(-t)
        TimerStart(gameStartTimer, t, false, GameStart)
        TimerStart(gameReadyTimer, t-10, false, GameReady)
    end
    
    GameReady = function()
        --播放号角声
        StartSound(gg_snd_TheHornOfCenarius)
    end
    
    GameStart = function()
        --设置游戏时间
        SetGameTime(0)
        
        --设置昼夜时间为6:00并使昼夜时间开始流动
        SetTimeOfDay(6)
        SuspendTimeOfDay(false)
        
        DayTime = "白天"
        
        Loop(240,
            function()
                if DayTime == "白天" then
                    toEvent("进入夜晚", {})
                    last = "夜晚"
                else
                    toEvent("进入白天", {})
                    last = "白天"
                end
            end
        )
        
        --开始发工资
        require "GetGold.lua"
        StartGetGold(true)
        
        --开始出兵
        require "InitArmy.lua"
        StartArmy(true)
        
        --开始刷野
        StartCreep(true)
        
    end

