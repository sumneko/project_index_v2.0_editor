    
    KillHero = function(u1, u2)
        local p1 = GetOwningPlayer(u1)
        local p2 = GetOwningPlayer(u2)
        local gold = Kill.Gold
        local wood = Kill.Wood
        local kill = {u1 = u1, u2 = u2, gold = gold, wood = wood, assist = {}, nk = 0, nd = 0}
        
        toEvent("阵亡", kill)
        
        if not u1 or u1 == u2 then --自杀
            toEvent("自杀", kill)
            
        elseif IsPlayerAlly(u2, p1) then
            toEvent("队友击杀", kill)
        
        elseif GetPlayerId(p1) > 11 then --被野怪杀
            toEvent("野怪击杀", kill)
            
        else
            
            toEvent("敌方击杀", kill)
            
            if p1 == Com[0] or p1 == Com[1] then --被小兵杀
                toEvent("小兵击杀", kill)
            else
                kill.u1 = Hero[GetPlayerId(p1)]
                toEvent("玩家击杀", kill)
            end
        end
        
        toEvent("击杀结算", kill)
    end
    
    Event("自杀",
        function(data)
            local p2 = GetOwningPlayer(data.u2)
            local i = GetPlayerId(p2)
            local id = GetUnitPointValue(data.u2)
            print(string.format("%s%s(%s)|r %s", Color[i], PlayerName[i], HeroName[id], Lang["自爆了 ! ! !"]))
        end
    )
    
    Event("队友击杀",
        function(data)
            local u1 = data.u1
            local u2 = data.u2
            local p1 = GetOwningPlayer(u1)
            local p2 = GetOwningPlayer(u2)
            local i1 = GetPlayerId(p1)
            local i2 = GetPlayerId(p2)
            local id2 = GetUnitPointValue(u2)
--%颜色%玩家名(%英雄名) %被队友 %颜色%玩家名 %反补了 ! ! !
            print(string.format("%s%s(%s)|r %s %s%s|r %s",
            Color[i2], PlayerName[i2], HeroName[id2], Lang["被队友"], Color[i1], PlayerName[i1], Lang["反补了 ! ! !"]))
        end
    )
    
    Event("野怪击杀",
        function(data)
            local u1 = data.u1
            local u2 = data.u2
            local p2 = GetOwningPlayer(u2)
            local i = GetPlayerId(p2)
            local id = GetUnitPointValue(u2)
            if GetUnitTypeId(u1) == |nctl| then --Y叔
                print(string.format("%s%s(%s)|r %s", Color[i], PlayerName[i], HeroName[id], Lang["被Y叔杀死了 ! ! !"]))
            elseif GetUnitTypeId(u1) == |Etyr| then --黑白子
                print(string.format("%s%s(%s)|r %s", Color[i], PlayerName[i], HeroName[id], Lang["被黑白子杀死了 ! ! !"]))
            else
                print(string.format("%s%s(%s)|r %s", Color[i], PlayerName[i], HeroName[id], Lang["被野怪打死了 ! ! !"]))
            end
        end
    )
    
    Event("敌方击杀",
        function(data)
            local p1 = GetOwningPlayer(data.u1)
            local p2 = GetOwningPlayer(data.u2)
            local i1 = GetPlayerId(p1)
            local i2 = GetPlayerId(p2)
            local time = GetTime()

            --寻找助攻玩家
            local ps
            local tid = GetPlayerTeam(p1)
            if tid == 0 then
                ps = PA
            elseif tid == 1 then
                ps = PB
            else
                print("<查找助攻玩家时出错>0x0000")
                return
            end
            for i = 1, 5 do
                local i3 = GetPlayerId(ps[i])
                if time - DamageTime[i3][i2] < Kill.AssistTime then --当前时间-上一次造成伤害的时间 < 判定时间
                    table.insert(data.assist, ps[i])
                elseif time - HelpTime[i3][i1] < Kill.AssistTime then --当前时间-上一次进行帮助的时间 < 判定时间
                    table.insert(data.assist, ps[i])
                end
            end
            
            --计算奖励
            
            --终结连杀
            data.nk = Kill[i2]["连杀"]
            Kill[i2]["连杀"] = 0
            if data.nk > 0 then
                data.gold = data.gold + Kill.GoldK[data.nk]
                data.wood = data.wood + Kill.WoodK[data.nk]
            end
            
            data.nd = Kill[i2]["连死"]
            Kill[i2]["连死"] = math.min(10, data.nd + 1)
            if data.nd > 0 then
                data.gold = data.gold * Kill.GoldP[data.nd]
                data.wood = data.wood * Kill.GoldP[data.nd]
            end
            
        end
    )
    
    --一血奖励
    local firstBlood
    
    firstBlood = Event("敌方击杀",
        function(data)
            Event("-敌方击杀", firstBlood) --移除当前函数
            data.gold = data.gold + Kill.GoldF
            data.wood = data.wood + Kill.WoodF
        end
    )
    
    --分经验
    Event("敌方击杀",
        function(data)
            local u1 = data.u1
            local u2 = data.u2
            local lv = GetUnitLevel(u2)
            local data = {}
            data.u2 = u2
            data.expm = 5*lv*lv + 45*lv + 50 --产生的总经验
            
            --寻找附近的英雄
            local p1 = GetOwningPlayer(u1)
            local ps = GetAllyUsers(p1)
            data.expg = {}
            for i = 1, 5 do
                local u = Hero[i]
                if table.has(data.assist, u) or (IsUnitAlive(u) and DistanceBetweenPoints(GetUnitLoc(u), GetUnitLoc(u2)) < 1200) then
                    table.insert(data.expg, u)
                end
            end
            
            --计算经验
            local count = #data.expg
            if count == 0 then return end
            
            for _,p in ipairs(data.expg) do
                local i = GetPlayerId(p)
                data.u1 = Hero[i]
                data.exp = data.expm / count
                data.expo = data.exp
                AddHeroXP(u1, data.exp, true)
            end
        end
    )
    
    Event("小兵击杀",
        function(data)
            local count = #data.assist
            if count == 0 then --没有助攻
            
                data.gold = data.gold + Kill.GoldM --没有助攻而被小兵杀死将被惩罚
                local p1 = GetOwningPlayer(data.u1)
                local p2 = GetOwningPlayer(data.u2)
                local i1 = GetPlayerId(p1)
                local i2 = GetPlayerId(p2)
                local id2 = GetUnitPointValue(data.u2)
                local ps = GetAllyUsers(p1) --击杀者一方的每个玩家获得20%的报酬
                local gold = data.gold/5
                local wood = data.wood/5
                for _, p in ipairs(ps) do
                    GetGold(p, gold, wood)
                end
                
                local nk = Kill[i2]["连杀"]
--%颜色%学园都市|r %推倒了 %颜色%玩家名(%英雄名)|r % %且没有玩家助攻 , %友方玩家平分 |cffffff00%金钱|r / cff00ff00%木材|r ! ! !
                print(string.format("%s%s|r %s %s%s(%s)|r %s %s , %s |cffffff00%d|r / |cff00ff00%d|r ! ! !",
                Color[i1], PlayerName[i1], Kill["杀敌1"][data.nk], Color[i2], PlayerName[i2], HeroName[id2], Kill["杀敌2"][data.nk],
                Lang["且没有玩家助攻"], Lang["友方玩家平分"], data.gold, data.wood))
                
            elseif count == 1 then --有1个助攻,视为该玩家的人头
            
                local p = data.assist[1] --取出该玩家
                data.u1 = Hero[GetPlayerId(p)] --将击杀者重置为该玩家的英雄
                toEvent("玩家击杀", data) --发起玩家击杀事件
                return true --返回true以跳过之后的触发
                
            else --多个玩家助攻,由助攻的玩家平分
                local p1 = GetOwningPlayer(data.u1)
                local p2 = GetOwningPlayer(data.u2)
                local i1 = GetPlayerId(p1)
                local i2 = GetPlayerId(p2)
                local id2 = GetUnitPointValue(data.u2)
                local word = {}
                
                data.assist.gold = Skill.AssistGold[count] * data.gold
                data.assist.wood = Skill.AssistGold[count] * data.wood
                for _, p in ipairs(data.assist) do --大家分赃
                    GetGold(p, data.assist.gold, data.assist.wood)
                    local i = GetPlayerId(p)
                    table.insert(word, PlayerNameHero(p, true))
                end
                
--%颜色%学园都市|r %推倒了 %颜色%玩家名(%英雄名)|r % , [%助攻表] %s平分 |cffffff00%金钱|r / |cff00ff00%木材|r ! ! !
                print(string.format("%s%s|r %s %s%s(%s)|r %s , [%s] %s |cffffff00%d|r / |cff00ff00%d|r ! ! !",
                Color[i1], PlayerName[i1], Kill["杀敌1"][data.nk],
                Color[i2], PlayerName[i2], HeroName[id2], Kill["杀敌2"][data.nk],
                table.concat(word, "/"), Lang["平分"], data.gold, data.wood))
            end
        end
    )
            
    Event("玩家击杀",
        function(data)
            local p1 = GetOwningPlayer(data.u1)
            local p2 = GetOwningPlayer(data.u2)
            local i1 = GetPlayerId(p1)
            local i2 = GetPlayerId(p2)
            local id1 = GetUnitPointValue(data.u1)
            local id2 = GetUnitPointValue(data.u2)
            local lv1 = GetUnitLevel(data.u1)
            local lv2 = GetUnitLevel(data.u2)
            local lv0 = math.max(0, lv2-lv1) --等级差
            
            --增加连杀
            local nk = math.min(Kill[i1]["连杀"] + 1, 10)
            Kill[i1]["连杀"] = nk
            if nk > 2 then
--%颜色%英雄名|r %连杀文字
                print(string.format("%s%s|r %s", Color[i1], HeroName[id1], Kill["连杀文字"][nk]))
            end
            
            --移除连死
            local nd = Kill[i1]["连死"]
            Kill[i1]["连死"] = 0
            
            --计算快速连杀
            local time = GetTime()
            local qk = Kill[i1]["快速连杀"] + 1
            local id = GetUnitPointValue(data.u1)
            if time - Kill[i1]["快速连杀时间"] < Kill.QkillTime then
                Kill[i1]["快速连杀"] = qk
                if qk > 1 then
--%颜色%英雄名|r %连杀文字
                    print(string.format("%s%s|r %s"), Color[i1], HeroName[id], Kill["快速连杀文字"][qk])
                end
            else
                Kill[i1]["快速连杀"] = 0
            end
            Kill[i1]["快速连杀时间"] = time
            
            --计算复仇
            Mark(p2, "复仇", p1)
            Mark(p2, "复仇生效", false)
            local bi = Board["复仇"][id2]
            if bi then
                MultiboardSetItemValue(bi, string.format("|cff888888%s|r", PlayerNameHero(p1)))
                Wait(15,
                    function()
                        MultiboardSetItemValue(bi, PlayerNameHero(p1, true))
                        Mark(p2, "复仇生效", true)
                    end
                )
            end
                
            --计算奖励
            --等级差
            data.gold = data.gold + Kill.GoldLv[lv0]
            data.wood = data.wood + Kill.WoodLv[lv0]
            
            --崛起
            data.gold = data.gold + Kill.GoldD[nd]
            data.wood = data.wood + Kill.WoodD[nd]
            
            --复仇
            if Mark(p1, "复仇") == p2 and Mark(p1, "复仇生效") then
                data.gold = data.gold + Kill.GoldR
                data.wood = data.wood + Kill.WoodR
                Mark(p1, "复仇", p1)
                Mark(p1, "复仇生效", false)
                local bi = Board["复仇"][id2]
                if bi then
                    MultiboardSetItemValue(bi, "")
                end
            end
            
            --寻找助攻
            table.remove2(data.assist, p1) --从助攻表中移除击杀者
            
            local count = #data.assist
            local word = {}
            
--%颜色%玩家名(%英雄名)|r %推倒了 %颜色%玩家名(%英雄名)|r % , %获得了 |cffffff00%金钱|r / |cff00ff00%木材|r ! ! !
            print(string.format("%s%s(%s)|r %s %s%s(%s)|r %s , %s |cffffff00%d|r / |cff00ff00%d|r ! ! !",
            Color[i1], PlayerName[i1], HeroName[id1], Kill["杀敌1"][data.nk],
            Color[i2], PlayerName[i2], HeroName[id2], Kill["杀敌2"][data.nk],
            Lang["获得了"], data.gold, data.wood))
            
            if count > 0 then --有助攻者
                
                data.assist.gold = Kill.AssistGold[count] * data.gold
                data.assist.wood = Kill.AssistGold[count] * data.wood
                for _, p in ipairs(data.assist) do --大家分赃
                    GetGold(p, data.assist.gold, data.assist.wood)
                    local i = GetPlayerId(p)
                    table.insert(word, PlayerNameHero(p, true))
                end
                --%助攻 [%助攻表]
                print(string.format("%s [%s]", Lang["助攻:"], string.concat(word, "/")))
            end
            
            --拿钱
            GetGold(p1, data.gold, data.wood, u2)
            
        end
    )
    
    Kill = {
        ["杀敌1"] = {[0] = "推倒了", "推倒了", "推倒了", "推倒了", "推倒了", "推倒了", "推倒了", "推倒了", "推倒了", "推倒了", "推倒了"},
        
        ["杀敌2"] = {[0] = "", "", "", "", "", "", "", "", "", "", ""},
        
        ["连杀文字"] = {"", "", "已经三人斩 ! ! !", "已经四人斩 ! ! !", "已经五人斩 ! ! !", "已经六人斩 ! ! !",
        "已经七人斩 ! ! !", "已经八人斩 ! ! !", "已经九人斩 ! ! !", "已经十人斩 ! ! !"},
        
        Gold = 300, --基础杀敌奖励
        
        Wood = 50, --基础杀敌木材
        
        GoldLv = {[0] = 0, 50, 125, 225, 350, 500, 650, 800, 950, 1100, 1250, 1250, 1250, 1250, 1250, 1250, 1250, 1250, 1250, 1250, 1250}, --等级差奖励
        
        WoodLv = {[0] = 0, 10, 25, 45, 70, 100, 130, 160, 190, 220, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250}, --等级差木材
        
        GoldK = {[0] = 0, 50, 175, 300, 400, 500, 575, 650, 700, 750, 800}, --终结连杀奖励
        
        WoodK = {[0] = 0, 10, 35, 60, 80, 100, 115, 130, 140, 150, 160}, --终结连杀木材
        
        GoldD = {[0] = 0, 50, 175, 300, 400, 500, 575, 650, 700, 750, 800}, --崛起奖励
        
        WoodD = {[0] = 0, 10, 35, 60, 80, 100, 115, 130, 140, 150, 160}, --崛起木材
        
        GoldF = 200, --一血奖励
        
        WoodF = 40, --一血木材
        
        GoldR = 100, --复仇奖励
        
        WoodR = 20, --复仇木材
        
        GoldM = 750, --被小兵杀死没有助攻时额外获得的金钱
        
        GoldP = {1, 0.8, 0.65, 0.55, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25}, --连死后的奖励惩罚
        
        AssistTime = 15, --助攻判定时间
        
        AssistGold = {0.4, 0.25, 0.2, 0.175}, --每个助攻者可以获得的金钱比例(按照击杀者者计算)
        
        Exp = {1.2, 1.4, 1.6, 1.8, 2, 2.25, 2.5, 2.75, 3, 3.5, 4, 4.5, 5, 5, 5, 5, 5, 5, 5, 5}, --根据等级差计算获得的经验倍率
        
        QkillTime = 15, --快速连杀判定事件
        
        ["快速连杀文字"] = {"", "完成了一次双杀 ! ! !", "完成了一次三杀 ! ! !", "完成了一次四杀 ! ! !", "完成了一次五杀 ! ! !"},
    }
    
    for i = 1, 10 do
        local id = GetPlayerId(P[i])
        Kill[id] = {["连杀"] = 0, ["连死"] = 0, ["快速连杀"] = 0, ["快速连杀时间"] = 0}
    end
    
    luaDone()
