    
    local BoardIndex = {
        --列
        ["名字"] = 0,
        ["战绩"] = 1,
        ["补刀"] = 2,
        ["资源"] = 4,
        ["称号"] = 3,
        ["物品"] = {5, 6, 7, 8, 9, 10},
        ["技能"] = {11, 12, 13, 14},
        --以下为OB界面
        ["打野"] = 15,
        ["拆房"] = 16,
        ["战损"] = 17,
        ["复仇"] = 18,
        ["伤害输出"] = 19,
        ["伤害承受"] = 20,
        
        --行
        ["标题"] = 0,
    }
    
    Wait(0,
        function()
            CreateBoard()                
        end
    )
    
    CreateBoard = function()
        if Board then
            DestroyMultiboard(Board.this) --如果已经有多面板存在,就删除掉
        end
        
        Board = {}
        
        Board.this = CreateMultiboard() --创建多面板
        MultiboardSuppressDisplay(false) --关闭多面板隐藏
        MultiboardDisplay(Board.this, true) --对所有玩家显示该多面板
        
        --每个玩家在第几行
        BoardIndex.players = {}
        BoardIndex["反向"] = {[0] = "标题"}
        local x = 1
        BoardIndex[0] = x --学园都市
        BoardIndex["反向"][x] = 0
        x = x + 1
        for i = 1, 5 do
            local p = P[i]
            if IsPlayer(p) or IsAI(p) then
                local id = GetPlayerId(p)
                BoardIndex[id] = x
                BoardIndex["反向"][x] = id
                table.insert(BoardIndex.players, x)
                x = x + 1
            end
        end
        BoardIndex[6] = x --罗马正教
        BoardIndex["反向"][x] = 6
        x = x + 1
        for i = 6, 10 do
            local p = P[i]
            if IsPlayer(p) or IsAI(p) then
                local id = GetPlayerId(p)
                BoardIndex[id] = x
                BoardIndex["反向"][x] = id
                table.insert(BoardIndex.players, x)
                x = x + 1
            end
        end
        
        --设置标题与宽度
        MultiboardSetColumnCount(Board.this, 20 + 1) --设置列数
        MultiboardSetRowCount(Board.this, x + 2) --设置行数
        local this
            x = x - 1
            --名字
            Board["名字"] = {}
            for j = 0, x do
                this = MultiboardGetItem(Board.this, j, BoardIndex["名字"])
                local i = BoardIndex["反向"][j]
                Board["名字"][i] = this
                MultiboardSetItemStyle(this, true, true)
                MultiboardSetItemWidth(this, 0.08)
                if i ~= "标题" and i ~= 0 and i ~= 6 then
                    MultiboardSetItemValue(this, PlayerNameHero(i, true))
                    MultiboardSetItemIcon(this, HeroTypePic[GetUnitPointValue(Hero[i])])
                end
                if i == 0 or i == 6 then
                    MultiboardSetItemStyle(this, true, false)
                end
            end
            MultiboardSetItemStyle(Board["名字"]["标题"], false, false)
            MultiboardSetItemValue(Board["名字"][0], string.format("%s%s|r", Color[0], PlayerName[0]))
            MultiboardSetItemValue(Board["名字"][6], string.format("%s%s|r", Color[6], PlayerName[6]))
            
            Event("创建英雄",
                function(data)
                    local p = GetOwningPlayer(data.unit)
                    local i = GetPlayerId(p)
                    local this = Board["名字"][i]
                    MultiboardSetItemValue(this, PlayerNameHero(i, true, true))
                    MultiboardSetItemIcon(this, HeroTypePic[GetUnitPointValue(Hero[i])])
                end
            )
            
            Event("玩家退出",
                function(data)
                    local i = GetPlayerId(data.player)
                    local this = Board["名字"][i]
                    MultiboardSetItemValue(this, PlayerNameHero(i, true, true))
                    MultiboardSetItemIcon(this, HeroTypePic[GetUnitPointValue(Hero[i])])
                end
            )
            
            --战绩
            Board["战绩"] = {}
            for j = 0, x do
                this = MultiboardGetItem(Board.this, j, BoardIndex["战绩"])
                local i = BoardIndex["反向"][j]
                Board["战绩"][i] = this
                MultiboardSetItemStyle(this, true, false)
                MultiboardSetItemWidth(this, 0.04)
                if i ~= "标题" then
                    MultiboardSetItemValue(this, string.format("|cff0000ff%d|r || |cffff0000%d|r || |cff00ff00%d|r", KillData[i]["击杀"], KillData[i]["死亡"], KillData[i]["助攻"]))
                end
            end
            MultiboardSetItemValue(Board["战绩"]["标题"], string.format("|cffffff00%s(|cff0000ff%s|r || |cffff0000%s|r || |cff00ff00%s|r)", Lang["战绩"], "K", "D", "A"))
            
            --补刀
            Board["补刀"] = {}
            for j = 0, x do
                this = MultiboardGetItem(Board.this, j, BoardIndex["补刀"])
                local i = BoardIndex["反向"][j]
                Board["补刀"][i] = this
                MultiboardSetItemStyle(this, true, false)
                MultiboardSetItemWidth(this, 0.03)
                if i ~= "标题" and i ~= 0 and i ~= 6 then
                    if IsPlayerAlly(Player(i), SELFP) then
                        MultiboardSetItemValue(this, string.format("|cffffff00%d|r || |cff888888%d|r", KillData[i]["正补"], KillData[i]["反补"]))
                    else
                        MultiboardSetItemStyle(this, false, false)
                    end
                end
                if i == 0 or i == 6 then
                    MultiboardSetItemStyle(this, false, false)
                end
            end
            MultiboardSetItemValue(Board["补刀"]["标题"], "|cffffff00补刀|r")
            
            --资源
            Board["资源"] = {}
            for j = 0,x do
                this = MultiboardGetItem(Board.this, j, BoardIndex["资源"])
                local i = BoardIndex["反向"][j]
                Board["资源"][i] = this
                MultiboardSetItemStyle(this, true, false)
                MultiboardSetItemWidth(this, 0.04)
                if i ~= "标题" and i ~= 0 and i ~= 6 then
                    if IsPlayerAlly(Player(i), SELFP) then
                        MultiboardSetItemValue(this, string.format("|cffffff00%d|r || |cff00ff00%d|r", GetPlayerState(Player(i), PLAYER_STATE_RESOURCE_GOLD), GetPlayerState(Player(i), PLAYER_STATE_RESOURCE_LUMBER)))
                    else
                        MultiboardSetItemStyle(this, false, false)
                    end
                end
                if i == 0 or i == 6 then
                    MultiboardSetItemStyle(this, false, false)
                end
            end
            MultiboardSetItemValue(Board["资源"]["标题"], "|cffffff00资源|r")
            
            --称号
            Board["称号"] = {}
            for j = 0,x do
                this = MultiboardGetItem(Board.this, j, BoardIndex["称号"])
                local i = BoardIndex["反向"][j]
                Board["称号"][i] = this
                MultiboardSetItemStyle(this, true, false)
                MultiboardSetItemWidth(this, 0.03)
                if i ~= "标题" and i ~= 0 and i ~= 6 then
                    MultiboardSetItemValue(this, Mark(Player(i), "称号") or "")
                end
                if i == 0 or i == 6 then
                    MultiboardSetItemStyle(this, false, false)
                end
            end
            MultiboardSetItemValue(Board["称号"]["标题"], "|cffffff00称号|r")
            
            --物品
            Board["物品"] = {}
            for j = 0,x do
                local i = BoardIndex["反向"][j]
                Board["物品"][i] = {}
                for k = 1,6 do
                    this = MultiboardGetItem(Board.this, j, BoardIndex["物品"][k])
                    Board["物品"][i][k] = this
                    MultiboardSetItemStyle(this, false, true)
                    MultiboardSetItemWidth(this, 0.01)
                    if i ~= "标题" and i ~= 0 and i ~= 6 then
                        if IsPlayerAlly(Player(i), SELFP) then
                            MultiboardSetItemIcon(this, "ReplaceableTextures\\CommandButtons\\BTNblack.blp")
                        else
                            MultiboardSetItemStyle(this, false, false)
                        end
                    end
                    if i == 0 or i == 6 then
                        MultiboardSetItemStyle(this, false, false)
                    end
                    if i == "标题" then
                        MultiboardSetItemStyle(this, true, false)
                    end
                end
            end
            MultiboardSetItemValue(Board["物品"]["标题"][3], "|cffffff00物|r")
            MultiboardSetItemValue(Board["物品"]["标题"][4], "|cffffff00品|r")
            
            do
                local x = 1
                Loop(0.2,
                    function()
                        x = x + 1
                        if x == 12 then
                            x = 1
                        end
                        local hero = Hero[x]
                        if hero then
                            for y = 0, 5 do
                                local this = Board["物品"][x][y + 1]
                                local it = UnitItemInSlot(hero, y)
                                if it then
                                    MultiboardSetItemIcon(this, Mark(it, "数据").art)
                                else
                                    MultiboardSetItemIcon(this, "ReplaceableTextures\\CommandButtons\\BTNblack.blp")
                                end
                            end
                        end
                    end
                )
            end
            
            --技能
            require "LoadSkills.lua"
            
            Board["技能"] = {}
            for j = 0,x do
                local i = BoardIndex["反向"][j]
                Board["技能"][i] = {}
                for k = 1,4 do
                    this = MultiboardGetItem(Board.this, j, BoardIndex["技能"][k])
                    Board["技能"][i][k] = this
                    MultiboardSetItemStyle(this, true, true)
                    MultiboardSetItemWidth(this, 0.02)
                    if i ~= "标题" and i ~= 0 and i ~= 6 then
                        if IsPlayerAlly(Player(i), SELFP) then
                            local t = GetHeroSkill(Hero[i], k)
                            if t then
                                MultiboardSetItemValue(this, GetUnitAbilityLevel(Hero[i], t.id))
                            else
                                MultiboardSetItemValue(this, 0)
                            end
                            MultiboardSetItemIcon(this, GetSkillIcon(GetHeroSkill(Hero[i], k)))
                        else
                            MultiboardSetItemStyle(this, false, false)
                        end
                    end
                    if i == 0 or i == 6 then
                        MultiboardSetItemStyle(this, false, false)
                    end
                    if i == "标题" then
                        MultiboardSetItemStyle(this, true, false)
                    end
                end
            end
            MultiboardSetItemValue(Board["技能"]["标题"][2], "|cffffff00技|r")
            MultiboardSetItemValue(Board["技能"]["标题"][3], "|cffffff00能|r")
            
            Event("获得技能", "升级技能",
                function(data)
                    local u = data.unit
                    local this = data.abil
                    local x = GetPlayerId(this.player)
                    local y = this.y
                    MultiboardSetItemIcon(Board["技能"][x][y], GetSkillIcon(this))
                    MultiboardSetItemValue(Board["技能"][x][y], this.lv)
                end
            )
            
            Event("创建英雄",
                function(data)
                    local u = data.unit
                    local skills = Mark(u, "技能")
                    local x = GetPlayerId(GetOwningPlayer(u))
                    for y = 1, 4 do
                        local this = skills[y]
                        MultiboardSetItemIcon(Board["技能"][x][y], "ReplaceableTextures\\CommandButtonsDisabled\\DIS" .. this.art[1])
                    end
                end
            )
            
        --以下为OB界面
            
            --打野
            Board["打野"] = {}
            for j = 0,x do
                this = MultiboardGetItem(Board.this, j, BoardIndex["打野"])
                local i = BoardIndex["反向"][j]
                Board["打野"][i] = this
                MultiboardSetItemStyle(this, true, false)
                if IsGod() or Debug then
                    MultiboardSetItemWidth(this, 0.02)
                else
                    MultiboardSetItemWidth(this, 0.00)
                end
                if i ~= "标题" and i ~= 0 and i ~= 6 then
                    if IsPlayerAlly(Player(i), SELFP) then
                        MultiboardSetItemValue(this, string.format("|cffffff00%d|r", KillData[i]["打野"]))
                    else
                        MultiboardSetItemStyle(this, false, false)
                    end
                end
                if i == 0 or i == 6 then
                    MultiboardSetItemStyle(this, false, false)
                end
            end
            MultiboardSetItemValue(Board["打野"]["标题"], "|cffffff00打野|r")
            
            --拆房
            Board["拆房"] = {}
            for j = 0,x do
                this = MultiboardGetItem(Board.this, j, BoardIndex["拆房"])
                local i = BoardIndex["反向"][j]
                Board["拆房"][i] = this
                MultiboardSetItemStyle(this, true, false)
                if IsGod() or Debug then
                    MultiboardSetItemWidth(this, 0.02)
                else
                    MultiboardSetItemWidth(this, 0.00)
                end
                if i ~= "标题" and i ~= 0 and i ~= 6 then
                    if IsPlayerAlly(Player(i), SELFP) then
                        MultiboardSetItemValue(this, string.format("|cffffff00%d|r", KillData[i]["拆房"]))
                    else
                        MultiboardSetItemStyle(this, false, false)
                    end
                end
                if i == 0 or i == 6 then
                    MultiboardSetItemStyle(this, false, false)
                end
            end
            MultiboardSetItemValue(Board["拆房"]["标题"], "|cffffff00拆房|r")
            
            --战损
            Board["战损"] = {}
            for j = 0,x do
                this = MultiboardGetItem(Board.this, j, BoardIndex["战损"])
                local i = BoardIndex["反向"][j]
                Board["战损"][i] = this
                MultiboardSetItemStyle(this, true, false)
                if IsGod() or Debug then
                    MultiboardSetItemWidth(this, 0.04)
                else
                    MultiboardSetItemWidth(this, 0.00)
                end
                if i ~= "标题" and i ~= 0 and i ~= 6 then
                    if IsPlayerAlly(Player(i), SELFP) then
                        MultiboardSetItemValue(this, string.format("|cffffff00%d|r || |cffff0000%s|r", Mark(Player(i), "死亡损失") or 0, TimeWord(Mark(Player(i), "死亡时间") or 0)))
                    else
                        MultiboardSetItemStyle(this, false, false)
                    end
                end
                if i == 0 or i == 6 then
                    MultiboardSetItemStyle(this, false, false)
                end
            end
            MultiboardSetItemValue(Board["战损"]["标题"], "|cffffff00战损|r")
            
            --复仇
            Board["复仇"] = {}
            for j = 0,x do
                this = MultiboardGetItem(Board.this, j, BoardIndex["复仇"])
                local i = BoardIndex["反向"][j]
                Board["复仇"][i] = this
                MultiboardSetItemStyle(this, true, false)
                if IsGod() or Debug then
                    MultiboardSetItemWidth(this, 0.04)
                else
                    MultiboardSetItemWidth(this, 0.00)
                end
                if i ~= "标题" and i ~= 0 and i ~= 6 then
                    if IsPlayerAlly(Player(i), SELFP) then
                        local pn = ""
                        if Mark(Player(i), "复仇") then
                            if Mark(Player(i), "复仇生效") then
                                pn = PlayerNameHero(Mark(Player(i), "复仇"), true)
                            else
                                pn = "|cff888888" .. PlayerNameHero(Mark(Player(i), "复仇")) .. "|r"
                            end
                        end
                        MultiboardSetItemValue(this, pn)
                    else
                        MultiboardSetItemStyle(this, false, false)
                    end
                end
                if i == 0 or i == 6 then
                    MultiboardSetItemStyle(this, false, false)
                end
            end
            MultiboardSetItemValue(Board["复仇"]["标题"], "|cffffff00复仇|r")
            
            --伤害输出            
            Board["伤害输出"] = {}
            for j = 0,x do
                this = MultiboardGetItem(Board.this, j, BoardIndex["伤害输出"])
                local i = BoardIndex["反向"][j]
                Board["伤害输出"][i] = this
                MultiboardSetItemStyle(this, true, false)
                if IsGod() or Debug then
                    MultiboardSetItemWidth(this, 0.04)
                else
                    MultiboardSetItemWidth(this, 0.00)
                end
                if i ~= "标题" and i ~= 0 and i ~= 6 then
                    if IsPlayerAlly(Player(i), SELFP) then
                        MultiboardSetItemValue(this, string.format("%d(%d)", DamageStat[i][1], DamageStat[i][2]))
                    else
                        MultiboardSetItemStyle(this, false, false)
                    end
                end
                if i == 0 or i == 6 then
                    MultiboardSetItemStyle(this, false, false)
                end
            end
            MultiboardSetItemValue(Board["伤害输出"]["标题"], "|cffffff00伤害输出|r")
            
            --伤害承受
            Board["伤害承受"] = {}
            for j = 0,x do
                this = MultiboardGetItem(Board.this, j, BoardIndex["伤害承受"])
                local i = BoardIndex["反向"][j]
                Board["伤害承受"][i] = this
                MultiboardSetItemStyle(this, true, false)
                if IsGod() or Debug then
                    MultiboardSetItemWidth(this, 0.04)
                else
                    MultiboardSetItemWidth(this, 0.00)
                end
                if i ~= "标题" and i ~= 0 and i ~= 6 then
                    if IsPlayerAlly(Player(i), SELFP) then
                        MultiboardSetItemValue(this, string.format("%d(%d)", DamageStat[i][3], DamageStat[i][4]))
                    else
                        MultiboardSetItemStyle(this, false, false)
                    end
                end
                if i == 0 or i == 6 then
                    MultiboardSetItemStyle(this, false, false)
                end
            end
            MultiboardSetItemValue(Board["伤害承受"]["标题"], "|cffffff00伤害承受|r")
            
            --空行
            for y = 0, 21 do
                this = MultiboardGetItem(Board.this, x+1, y)
                MultiboardSetItemStyle(this, false, false)
                MultiboardSetItemWidth(this, 0)
            end
            
        --游戏模式
            this = MultiboardGetItem(Board.this, x + 2, 0)
            Board["游戏模式"] = this
            MultiboardSetItemStyle(this, true, false)
            MultiboardSetItemWidth(this, 1)
            
            RefreshGamemode = function()
                MultiboardSetItemValue(this, string.format("游戏模式:|cffffff00%s|r", string.concat(GameMode, " ")))
            end
            
            RefreshGamemode()
            
        --最小化多面板
        MultiboardMinimize(Board.this, true)
        
        --设置标题颜色
        MultiboardSetTitleTextColor(Board.this, 255, 255, 255, 255)
        MultiboardSetTitleText(Board.this, "|cffffff00加载中...|r")
    end
    
    --获取复活文字(多面板标题)
    local GetReviveWord = function(tid)
        local ps
        if tid == 0 then
            ps = PA
        elseif tid == 1 then
            ps = PB
        end
        local t = {}
        for _, p in ipairs(ps) do
            local tt = Mark(p, "复活时间")
            if tt and tt > 0 then
                local i = GetPlayerId(p)
                table.insert(t, Color[i] .. tt .. "|r")
            end
        end
        local s = string.concat(t, " || ")
        if s == "" then
            return s
        else
            return "[ " .. s .. " ]"
        end
    end
    
    --每秒刷新面板数据
    Loop(1,
        function()
            if not Board then return end
            --刷新资源数据
            for i = 1, 10 do
                local id = GetPlayerId(P[i])
                if Board["资源"][id] then
                    MultiboardSetItemValue(Board["资源"][id], string.format("|cffffff00%d|r || |cff00ff00%d|r", GetPlayerState(Player(id), PLAYER_STATE_RESOURCE_GOLD), GetPlayerState(Player(id), PLAYER_STATE_RESOURCE_LUMBER)))
                end
            end
            --刷新标题
            MultiboardSetTitleText(Board.this, string.format("%s|cffff0000学院都市|r(|cffffff00%d|r) |cffffff00VS|r (|cffffff00%d|r)|cff00ff00罗马正教|r%s    |cff0000ff%d|r || |cffff0000%d|r || |cff00ff00%d|r    -    |cffffff00%d|r || |cff888888%d|r",
            GetReviveWord(0), KillData[0]["击杀"], KillData[6]["击杀"], GetReviveWord(1), KillData[SELF]["击杀"], KillData[SELF]["死亡"], KillData[SELF]["助攻"],
            KillData[SELF]["正补"], KillData[SELF]["反补"]))
        end
    )
    
    luaDone()
