    
    local trg = CreateTrigger()
    
    ModeInstructionFlush = function()
        DestroyTrigger(trg)
        trg = nil
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
                    if IsPlayer(P[i]) or IsComputer(P[i]) then
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
                    else
                        f = f2
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
        AR = {
            name = "全体随机",
            code = function()
                for i = 1, 10 do
                    BanPlayerHeroType(P[i])
                end
                StartGameIn(90)
                Wait(2,
                    function()
                        ModeInstructionFlush()
                        local ps = {}
                        for i = 1, 10 do
                            if IsPlayer(P[i]) then
                                table.insert(ps, P[i])
                            end
                        end
                        Loop(0.5,
                            function()
                                if #ps == 0 then
                                    EndLoop()
                                else
                                    SelectRandomHero(ps[1])
                                    table.remove(ps, 1)
                                end
                            end
                        )
                    end
                )
            end,
        },
        MH = {
            name = "复选模式",
            code = function()
            end
        },
        RC = {
            name = "急速冷却",
            code = function()
                for _, this in pairs(SkillTable) do
                    if type(this) == "table" then
                        this.cool = 0
                        if this._cool then
                            this._cool = 0
                        end
                    end
                end
            end
        },
        UM = {
            name = "无限法力",
            code = function()
                for _, this in pairs(SkillTable) do
                    if type(this) == "table" then
                        this.mana = 0
                        if this._mana then
                            this._mana = 0
                        end
                    end
                end
            end
        },
        
    }
    
