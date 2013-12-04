    
    --工资
    local t = CreateTimer()
    local gold = {}
    local wage = table.new(2)
    local wages = table.new(0) --剩余工资
    
    gold[0] = 0
    gold[1] = 0
    
    StartGetGold = function(b)
        if b then
            TimerStart(t, 1, true,
                function()
                    gold[2] = 0
                    if gold[0] > 0 and PlayerCount[0] > 0 then
                        gold[2] = math.floor(gold[0]/PlayerCount[0])
                        gold[0] = gold[0] - gold[2]*PlayerCount[0]
                    end
                    gold[3] = 0
                    if gold[1] > 0 and PlayerCount[1] > 0 then
                        gold[3] = math.floor(gold[1]/PlayerCount[1])
                        gold[1] = gold[1] - gold[3]*PlayerCount[1]
                    end
                    for i = 1, 10 do
                        local tid = GetPlayerTeam(P[i])
                        local id = GetPlayerId(P[i])
                        local wage = wage[id] + wages[id] --工资+剩余工资
                        local g = math.floor(wage) --取整
                        wages[id] = wage - g --零头存在剩余工资里
                        if IsPlayer(P[i]) or IsComputer(P[i]) then
                            SetPlayerState(P[i], PLAYER_STATE_RESOURCE_GOLD, g + gold[tid+2] + GetPlayerState(P[i], PLAYER_STATE_RESOURCE_GOLD))
                            --SetPlayerState(P[i], PLAYER_STATE_GOLD_GATHERED, g + gold[tid+2] + GetPlayerState(P[i], PLAYER_STATE_GOLD_GATHERED))
                        else
                            gold[tid] = gold[tid] + g + GetPlayerState(P[i], PLAYER_STATE_RESOURCE_GOLD)
                            SetPlayerState(P[i], PLAYER_STATE_RESOURCE_GOLD, 0)
                        end
                        
                    end
                end
            )
        else
            PauseTimer(t)
        end
    end
    
    --涨工资
    Wage = function(p, g)
        if type(p) ~= "number" then
            p = GetPlayerId(p)
        end
        if g then
            wage[p] = wage[p] + g
        end
        return wage[p]
    end
    
    --直接获得金钱
    
    GetGold = function(p, gold, wood, u)
        --先取整
        gold = math.floor(gold or 0)
        wood = math.floor(wood or 0)
        
        SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, gold+GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD))
        SetPlayerState(p, PLAYER_STATE_GOLD_GATHERED, gold+GetPlayerState(p, PLAYER_STATE_GOLD_GATHERED))
        SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, wood+GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER))
        SetPlayerState(p, PLAYER_STATE_LUMBER_GATHERED, wood+GetPlayerState(p, PLAYER_STATE_LUMBER_GATHERED))
        if gold <= 0 then return end
        
        local i = GetPlayerId(p)
        
        if u == nil or IsGod() then --如果没有传递单位数据,或者为全知界面,钱就创建在英雄头上
            u = Hero[i]
        end
        
        if IsPlayerAlly(p, SELFP) and u then
            TempEffect(u, "UI\\Feedback\\GoldCredit\\GoldCredit.mdl")
        else
            TempEffect(u, "")
        end
        
        Text{
            word = "+" .. gold,
            size = 10,
            unit = u,
            x = -25,
            z = 50,
            player = p,
            speed = {58, 90},
            life = {2, 3},
            color = {100, 100, 0},
            show = "自己",
        }
    end
    
    luaDone()
    
