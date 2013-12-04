    
    --设置玩家名字
    SetPlayerName(Player(13), "学园都市")
    SetPlayerName(Player(14), "罗马正教")
    for i = 0, 11 do
        PlayerName[i] = GetPlayerName(Player(i))
    end
    PlayerName[0] = "学园都市"
    PlayerName[6] = "罗马正教"
    
    --清点在线玩家
    PlayerCount = {}
    
    PlayerCount[0] = 0
    PlayerCount[1] = 0
    
    for i = 1, 5 do
        if IsPlayer(PA[i]) then
            PlayerCount[0] = PlayerCount[0] + 1
        end
        if IsPlayer(PB[i]) then
            PlayerCount[1] = PlayerCount[1] + 1
        end
    end
    
    --设置无玩家的名字
    for i = 1, 5 do
        if not IsPlayer(i) then
            SetPlayerName(Player(i), "玩家 " .. i)
        end
    end
    for i = 7, 11 do
        if not IsPlayer(i) then
            SetPlayerName(Player(i), "玩家 " .. (i-1))
        end
    end
    
    --设置OB玩家的名字
    if IsPlayerObserver(PA[0]) then
        SetPlayerName(PA[0], "斯芬克斯(" .. GetPlayerName(PA[0]) .. ")")
    else
        SetPlayerName(PA[0], "学园都市")
    end
    if IsPlayerObserver(PB[0]) then
        SetPlayerName(PB[0], "奥莱尔斯(" .. GetPlayerName(PB[0]) .. ")")
    else
        SetPlayerName(PB[0], "罗马正教")
    end
    
    --清点非玩家数量
    ComCount = 0
    
    for i = 1, 10 do
        if IsComputer(P[i]) then
            ComCount = ComCount + 1
        end
    end
    
    luaDone()
