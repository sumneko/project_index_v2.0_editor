    
    FoodS = {[0] = 0, 0, 0, 0}
    Food = {}
    for i = 0, 11 do
        Food[i] = 0
    end
    
    AddFood = function(tid, food)
        FoodS[tid + 2] = FoodS[tid + 2] + food
        local f = math.floor(FoodS[tid + 2])
        FoodS[tid + 2] = FoodS[tid + 2] - f
        local ps
        if tid == 0 then
            ps = PA
        else
            ps = PB
        end
        for i = 1, 5 do
            local id = GetPlayerId(ps[i])
            Food[id] = Food[id] + f
            SetPlayerState(ps[i], PLAYER_STATE_RESOURCE_FOOD_USED, Food[id])
        end
    end
    
    AddPlayerFood = function(p, food)
        local id
        if type(p) == "number" then
            id = p
            p = Player(p)
        else
            id = GetPlayerId(p)
        end
        Food[id] = Food[id] + food
        SetPlayerState(p, PLAYER_STATE_RESOURCE_FOOD_USED, Food[id])
    end
    
    Event("游戏开始",
        function()
            Loop(1,
                function()
                    AddFood(0, FoodS[0])
                    AddFood(1, FoodS[1])
                end
            )
        end
    )
    
    --研发系统
    Research = {}
    
    local u1, u2 = gg_unit_e033_0007, gg_unit_e033_0008
    
    ShowUnit(u1, false)
    ShowUnit(u2, false)
    
    Event("创建英雄",
        function(data)
            local p = GetOwningPlayer(data.unit)
            local i = GetPlayerId(p)            
            if not Research[i] then
                local u0
                if GetPlayerTeam(p) == 0 then
                    u0 = u1
                else
                    u0 = u2
                end
                Research[i] = CreateUnit(p, GetUnitTypeId(u0), GetUnitX(u0), GetUnitY(u0), 270)
                UnitRemoveAbility(Research[i], |Amov|)
                if SELF ~= i then
                    SetUnitFlyHeight(Research[i], 5000, 0)
                end
                InitResearch(Research[i])
            end
        end
    )
    
    --注册研究项目
    Projects = {}
    
    InitProject = function(this)
        Projects[this.name] = this
        table.insert(Projects, this)
        if type(this.art) == "string" then
            this.disart = "ReplaceableTextures\\CommandButtonsDisabled\\DIS" .. this.art
            this.art = "ReplaceableTextures\\CommandButtons\\" .. this.art
        end
    end
    
    require "ResearchSkills.lua"
    
    --注册研究
    local icons = {|A19A|, |A19B|, |A19C|, |A19D|, |A19E|, |A19F|, |A19G|, |A19H|, |A19I|, |A19J|, |A19K|, |A19L|}
    local xy2i = function(x, y)
        return x * 3 + y - 3
    end
    local page = {} --记录当前的翻页
    local level = {} --记录当前可以研究的等级
    local freshPage
    
    GetResearchLevel = function(i)
        return level[i]
    end
    
    for i, id in ipairs(icons) do --建立反向表
        icons[id] = i
    end
    
    local trg
    local hasResearched = {} --用来记录已经研究过的科技
    
    InitResearch = function(u)
        local p = GetOwningPlayer(u)
        local id = GetPlayerId(p)
        local tid = GetPlayerTeam(p)
        local skills = {}
        hasResearched[u] = {}
        TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_SPELL_EFFECT)
        Projects[u] = skills
        for i, skill in ipairs(Projects) do
            skill = table.copy(skill)
            table.insert(skills, skill)
            skills[skill.name] = skill
            skill.hero = Hero[id]
            skill.player = p
            skill.team = tid
            for _, name in ipairs{"name", "art", "tip"} do
                if type(skill[name]) == "function" then
                    skill[name](skill)
                end
            end
        end
        for i, id in ipairs(icons) do
            UnitAddAbility(u, id)
        end
        --先设置翻页键
        
        --向上翻页
        local i = xy2i(4, 1)
        local ab = japi.EXGetUnitAbility(u, icons[i])
        japi.EXSetAbilityDataString(ab, 1, 204, "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedUp.blp") --图标
        japi.EXSetAbilityDataString(ab, 1, 215, "|cffffcc00向上翻|r") --标题
        japi.EXSetAbilityDataString(ab, 1, 218, "") --内容
        
        --中间的按钮隐藏掉暂时不用
        local i = xy2i(4, 2)
        SetPlayerAbilityAvailable(p, icons[i], false)
        
        --向下翻页
        local i = xy2i(4, 3)
        local ab = japi.EXGetUnitAbility(u, icons[i])
        japi.EXSetAbilityDataString(ab, 1, 204, "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedDown.blp") --图标
        japi.EXSetAbilityDataString(ab, 1, 215, "|cffffcc00向下翻|r") --标题
        japi.EXSetAbilityDataString(ab, 1, 218, "") --内容
        
        --记录当前页面(y坐标加成)
        page[u] = 1
        
        --记录当前可以研究的等级
        local t = table.new(0)
        level[u] = t
        level[id] = t
        t[0] = 1 --表示当前研发流程
        t[1] = 1 --表示在第X层还能研究几次
        
        freshPage(u)
    end
    
    local cost = {0, 0, 0, 100, 200, 300, 400, 500, 600, 700, 9999999}
    local lastLevel = table.new(-60) --上次提示的时间
    local tag = {}
    
    Loop(5,
        function()
            local time = GetTime()
            for i = 1, 10 do
                local id = GetPlayerId(P[i])
                if Hero[id] then
                    local level = level[id]
                    local n = level[0]
                    if Food[id] >= cost[n] and time - lastLevel[id] > 60 then
                        lastLevel[id] = time
                        printTo(P[i], "|cffffff00你已经积攒了足够的节操来进行新的研发!")
                        if SELFP == P[i] then
                            local x, y = GetXY(Research[id])
                            PingMinimapEx(x, y, 10, 255, 255, 0, false)
                            StartSound(gg_snd_SecretFound)
                        end
                        if not tag[id] then
                            tag[id] = Text{
                                unit = Research[id],
                                word = "你可以进行新的研发!",
                                size = 20,
                                x = -100,
                                show = "自己"
                            }
                        end
                    end
                end
            end
        end
    )
    
    freshPage = function(u)
        local p = GetOwningPlayer(u)
        if p == SELFP then --
        local id = GetPlayerId(p)
        local tid = GetPlayerTeam(p)
        local page = page[u]
        local skills = Projects[u]
        local level = level[u]
        local hasResearched = hasResearched[u]
        for x = 1, 3 do
            for y = 1, 3 do
                local i1 = xy2i(x, y) --图标索引
                local i2 = x + (y + page) * 3 - 6 --技能在表中的索引
                local skill = skills[i2]
                local thislevel = y + page - 1 --当前扫描到的研究等级
                if not skill then
                    break
                end
                local ab = japi.EXGetUnitAbility(u, icons[i1])
                if level[thislevel] > 0 then --可以研究的
                    if table.has(hasResearched, skill.name) then --已经研究过,图标不可点击+高亮
                        --if p == SELFP then
                            japi.EXSetAbilityDataString(ab, 1, 204, skill.art) --图标
                            japi.EXSetAbilityDataString(ab, 1, 215, string.format("|cffffcc00%s|r - [|cffffcc00%s|r]", skill.name, "已研发")) --标题
                            japi.EXSetAbilityDataString(ab, 1, 218, skill.tip) --内容
                        --end
                        --japi.EXSetAbilityDataReal(ab, 1, 105, 1000000) --间隔
                        --japi.EXSetAbilityState(ab, 1, 10000) --冷却
                    else --可以研究,图标可点击+高亮
                        --if p == SELFP then
                            japi.EXSetAbilityDataString(ab, 1, 204, skill.art) --图标
                            local cost = cost[thislevel]
                            if cost == 0 then
                                cost = "免费!"
                            end
                            japi.EXSetAbilityDataString(ab, 1, 215, string.format("|cffffcc00%s|r - [|cffffcc00%s|r]", skill.name, cost)) --标题
                            japi.EXSetAbilityDataString(ab, 1, 218, skill.tip) --内容
                        --end
                        --japi.EXSetAbilityState(ab, 1, 0) --冷却
                    end
                else --还不能研究的
                    if table.has(hasResearched, skill.name) then --已经研究过,图标不可点击+高亮
                        --if p == SELFP then
                            japi.EXSetAbilityDataString(ab, 1, 204, skill.art) --图标
                            japi.EXSetAbilityDataString(ab, 1, 215, string.format("|cffffcc00%s|r - [|cffffcc00%s|r]", skill.name, "已研发")) --标题
                            japi.EXSetAbilityDataString(ab, 1, 218, skill.tip) --内容
                        --end
                        --japi.EXSetAbilityDataReal(ab, 1, 105, 1000000) --间隔
                        --japi.EXSetAbilityState(ab, 1, 10000) --冷却
                    else --可以研究,图标不可点击+灰暗
                        --if p == SELFP then
                            japi.EXSetAbilityDataString(ab, 1, 204, skill.disart) --图标
                            local cost = cost[thislevel]
                            if cost == 0 then
                                cost = "免费!"
                            end
                            japi.EXSetAbilityDataString(ab, 1, 215, string.format("|cffffcc00%s|r - [|cffffcc00%s|r]", skill.name, cost)) --标题
                            japi.EXSetAbilityDataString(ab, 1, 218, skill.tip) --内容
                        --end
                        --japi.EXSetAbilityDataReal(ab, 1, 105, 1000000) --间隔
                        --japi.EXSetAbilityState(ab, 1, 10000) --冷却
                    end
                end   
            end
        end
        
        end --
        
        RefreshTips(u)
    end
    
    --响应玩家点击按钮
    local i2xy = function(n)
        local x, y
        n = n - 1
        y = n % 3 + 1
        x = math.floor(n / 3) + 1
        return x, y        
    end
    
    trg = CreateTrigger()
    TriggerAddCondition(trg, Condition(
        function()
            local u = GetTriggerUnit()
            local id = GetSpellAbilityId()
            local skills = Projects[u]
            local n = icons[id] --第几个技能
            local x, y = i2xy(n) --获取技能所在的坐标
            local thispage = page[u] --当前页数(y坐标加成)
            local si = x + (y + thispage - 2) * 3 --获取表中的位置
            local skill = skills[si]
            local p = GetOwningPlayer(u)
            local i = GetPlayerId(p)
            n = y + thispage - 1 --第几层技能
            if x == 4 then
                --翻页
                if y == 1 then
                    --向上翻页
                    if thispage > 1 then
                        page[u] = thispage - 1
                        freshPage(u) --刷新页面
                    end
                else
                    if thispage < #cost - 3 then
                        page[u] = thispage + 1
                        freshPage(u) --刷新页面
                    end
                end
            else
                IssueImmediateOrder(u, "stop")
                if Food[i] < cost[n] then
                    printTo(p, "|cffffcc00你的节操不足!|r")
                    if p == SELFP then
                        StartSound(gg_snd_Error)
                    end
                elseif table.has(hasResearched[u], skill.name) then
                    printTo(p, "|cffffcc00你已经研发过这个了!|r")
                    if p == SELFP then
                        StartSound(gg_snd_Error)
                    end
                elseif level[u][n] < 1 then
                    printTo(p, "|cffffcc00你还不能研发这一层!|r")
                    if p == SELFP then
                        StartSound(gg_snd_Error)
                    end
                else
                    table.insert(hasResearched[u], skill.name) --记录该升级已经应用
                    AddPlayerFood(p, - cost[n])
                    level[u][n] = level[u][n] - 1
                    if n == level[u][0] then
                        n = n + 1
                        level[u][0] = n
                        level[u][n] = level[u][n] + 1
                    end
                    freshPage(u) --刷新页面
                    if tag[i] then
                        DestroyTextTag(tag[i])
                        tag[i] = nil
                    end
                    --回调该升级
                    skill:code()
                end
            end
        end
    ))
    
