
    --统计杀敌/死亡/助攻
    KillData = {}
    
    for i = 0, 15 do
        KillData[i] = {
            ["击杀"] = 0,
            ["死亡"] = 0,
            ["助攻"] = 0,
            ["正补"] = 0,
            ["反补"] = 0,
            ["打野"] = 0,
            ["拆房"] = 0,
        }
    end
    
    Event("击杀结算",
        function(data)
            local p1 = GetOwningPlayer(data.u1)
            local p2 = GetOwningPlayer(data.u2)
            local i1 = GetPlayerId(p1)
            local i2 = GetPlayerId(p2)
            local ci1 = GetPlayerId(Com[GetPlayerTeam(p1)])
            local ci2 = GetPlayerId(Com[GetPlayerTeam(p2)])
            if IsUnitEnemy(data.u2, p1) then
                KillData[i1]["击杀"] = KillData[i1]["击杀"] + 1
                if i1 ~= ci1 and i1 < 12 then
                    KillData[ci1]["击杀"] = KillData[ci1]["击杀"] + 1
                end
                for _, p in ipairs(data.assist) do
                    local i = GetPlayerId(p)
                    KillData[i]["助攻"] = KillData[i]["助攻"] + 1
                    KillData[ci1]["助攻"] = KillData[ci1]["助攻"] + 1
                end
            end
            KillData[i2]["死亡"] = KillData[i2]["死亡"] + 1
            KillData[ci2]["死亡"] = KillData[ci2]["死亡"] + 1
            
            --刷新多面板数据
            for i = 0, 11 do
                if Board["战绩"][i] then
                    MultiboardSetItemValue(Board["战绩"][i], string.format("|cff0000ff%d|r || |cffff0000%d|r || |cff00ff00%d|r", KillData[i]["击杀"], KillData[i]["死亡"], KillData[i]["助攻"]))
                end
            end
        end
    )
    
    Event("正补", "反补",
        function(data)
            local p1 = GetOwningPlayer(data.u1)
            local p2 = GetOwningPlayer(data.u2)
            local i1 = GetPlayerId(p1)
            local i2 = GetPlayerId(p2)
            if data.event == "正补" then
                if p2 == Player(12) then
                    KillData[i1]["打野"] = KillData[i1]["打野"] + 1
                else
                    if IsUnitType(data.u2, UNIT_TYPE_STRUCTURE) then
                        KillData[i1]["拆房"] = KillData[i1]["拆房"] + 1
                    else
                        KillData[i1]["正补"] = KillData[i1]["正补"] + 1
                    end
                end
            elseif data.event == "反补" then
                KillData[i1]["反补"] = KillData[i1]["反补"] + 1
            end
            MultiboardSetItemValue(Board["补刀"][i1], string.format("|cffffff00%d|r || |cff888888%d|r", KillData[i1]["正补"], KillData[i1]["反补"]))
        end
    )
            

    luaDone()
