    
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
        MD = {
            name = "启用主机MOD",
            code = function()
                local texts = {}
                if SELFP == FirstPlayer then
                    local mods = {}
                    for i = 1, 100 do
                        local suc, mod = pcall(old.require, "MoeUshio\\PI2\\Mod" .. i .. ".lua")
                        if suc then
                            table.insert(mods, mod)
                        end
                    end
                    
                    for i, mod in ipairs(mods) do
                        table.insert(texts, mod.name)
                        table.insert(texts, mod.ver)
                        table.insert(texts, mod.author)
                        table.insert(texts, mod.tip)
                        table.insert(texts, mod.script)
                    end
                end
                local chars = table.concat(texts, "><") or ""
                local text = [[
Mod大小 |cffffcc00% 6s|r 字节        压缩后大小 |cffffcc00% 6s|r 字节
经过时间 |cffffcc00% 6.2f|r 秒            已传输 |cffffcc00% 6s|r 字节
传输进度 |cffffcc00% 6.2f|r%%            传输速度 |cffffcc00% 5.2f|r 字节/秒

文本传输器版本 |cffffcc00%s|r           文本压缩器版本 |cffffcc00%s|r

%s
]]
                upload.start{
                    player = FirstPlayer,
                    text = chars,
                    ready = function(data)
                        if data.len == 0 then
                            print("没有检测到任何有效的Mod!")
                            return true
                        end
                        local id = |A1AG|
                        UnitAddAbility(gg_unit_h000_0024, id)
                        UnitAddAbility(gg_unit_h000_0025, id)
                        print("提示:你可以在泉水处查看Mod传输进度")
                    end,
                    past = function(data)
                        local ab = japi.EXGetUnitAbility(gg_unit_h000_0024, |A1AG|)
                        local text = text:format(
                            data.len, data.size,
                            data.pasttime, data.pastbyte,
                            math.min(100, data.pastbyte / math.max(1, data.size) * 100), data.speed,
                            upload.ver, upload.zipver,
                            ""
                        )
                        japi.EXSetAbilityDataString(ab, 1, 218, text)
                        RefreshTips(gg_unit_h000_0024)
                    end,
                    finish = function(data)
                        local texts = string.split(data.text, "><")
                        local names = {}
                        local vers = {}
                        local authors = {}
                        local tips = {}
                        local scripts = {}
                        for i, text in ipairs(texts) do
                            if i % 5 == 1 then
                                table.insert(names, text)
                            elseif i % 5 == 2 then
                                table.insert(vers, text)
                            elseif i % 5 == 3 then
                                table.insert(authors, text)
                            elseif i % 5 == 4 then
                                table.insert(tips, text)
                            else
                                table.insert(scripts, text)
                            end
                        end
                        local modtips = {}
                        local modtip = [[
Mod名称:|cffffcc00%s|r[%s]
Mod作者:|cffffcc00%s|r
%s
]]
                        for i = 1, #names do
                            print(("已加载Mod:|cffffcc00%s|r[%s]"):format(names[i], vers[i]))
                            loadstring(scripts[i])()
                            table.insert(modtips, modtip:format(names[i], vers[i], authors[i], tips[i]))
                        end
                        local ab = japi.EXGetUnitAbility(gg_unit_h000_0024, |A1AG|)
                        local text = text:format(
                            data.len, data.size,
                            data.pasttime, data.pastbyte,
                            math.min(100, data.pastbyte / math.max(1, data.size) * 100), data.speed,
                            upload.ver, upload.zipver,
                            "====================================\n\n" .. table.concat(modtips, "\n\n")
                        )
                        japi.EXSetAbilityDataString(ab, 1, 218, text)
                        RefreshTips(gg_unit_h000_0024)
                    end
                }
            end
        }
    }
    
