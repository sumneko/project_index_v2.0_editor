
    local trg = CreateTrigger()
    for i = 0, 11 do
        TriggerRegisterPlayerEventLeave(trg, Player(i))
    end
    TriggerAddCondition(trg, Condition(function()
        local p = GetTriggerPlayer()
        local i = GetPlayerId(p)
        if IsUser(p) then
            print(string.format("%s |cffff0000%s|r", PlayerNameHero(p, true), Lang["离开了游戏!"]))
            local ps = GetAllyUsers(p)
            for i = 1, 5 do
                SetPlayerAlliance(p, ps[i], ALLIANCE_SHARED_CONTROL, true)
            end
        else
            print(string.format("|cffffcc00%s|r %s |cffff0000%s|r", Lang["裁判"], PlayerName[i], Lang["离开了游戏!"]))
        end
        toEvent("玩家退出", {player = p})
    end))
    
