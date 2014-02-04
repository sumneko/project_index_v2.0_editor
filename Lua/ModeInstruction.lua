    
    local trg = CreateTrigger()
    
    ModeInstructionFlush = function()
        DestroyTrigger(trg)
    end
    
    local modes
    local modeword = {}
    
    TriggerRegisterPlayerChatEvent(trg, FirstPlayer, "-", false)
    TriggerAddCondition(trg, Condition(
        function()
            local w = GetEventPlayerChatString()
            w = w:gsub("[^%w%.]", ""):upper()
            while #w > 1 do
                local s = w:sub(1, 2)
                if modes[s] and not table.has(GameMode, s) then
                    table.insert(GameMode, s)
                    table.insert(modeword, ("|cffffcc00%s|r(|cffff1111%s|r)"):format(modes[s].name, s))
                    w = w:sub(3)
                    w = modes[s].code(w) or w
                else
                    w = w:sub(2)
                end
            end
            if #modeword > 0 then
                print(table.concat(modeword, "/"))
                RefreshGamemode()
            end
        end
    ))
    
    modes = {
        SP = {
            name = "洗牌模式",
            code = function()
                local f1 = {}
                local f2 = {}
                
                --将所有玩家加入玩家组
                for i = 1, 10 do
                    if IsPlayer(P[i]) then
                        table.insert(f1, P[i])
                    else
                        table.insert(f2, P[i])
                    end
                end
                
                --拉一个随机玩家出来
                local getRandom = function()
                    local f
                    local w
                    if #f1 > 0 then
                        f = f1
                        w = "提取玩家"
                    else
                        f = f2
                        w = "提取电脑"
                    end
                    local i = GetRandomInt(1, #f)
                    local p = f[i]
                    table.remove(f, i)
                    return p
                end
                
                --进行重组
                for i = 1, 5 do
                    if GetRandomInt(1, 2) == 1 then
                        PA[i], PB[i] = getRandom(), getRandom()
                    else
                        PB[i], PA[i] = getRandom(), getRandom()
                    end
                    P[i] = PA[i]
                    P[i+5] = PB[i]
                end
                
                --刷新
                RefreshAlliance()
                CreateBoard()
                
                toEvent("洗牌后", {})
            end
        },
    }
    
