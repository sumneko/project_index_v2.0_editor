
    local xy2i = function(x, y)
        return x + y * 4 - 4
    end
    
    shopAction = function()
        local u = GetTriggerUnit()
        local id = GetSpellAbilityId()
        local name = GetShopItemName(u, id)
        local first = string.sub(name, 1, 1)
        if first == "#" then
            --页面
            OpenShopPage(u, name)
        elseif first == "$" then
            --付费
            local err = BuyItem(u, string.sub(name, 2))
            local p = GetOwningPlayer(u)
            if err then
                printTo(p, 15, "|cffffcc00" .. err .. "|r")
                if SELFP == p then
                    StartSound(gg_snd_Error)
                end
            else
                if SELFP == p then
                    StartSound(gg_snd_ReceiveGold)
                end
                OpenShopPage(u, GetCurrentShopPage(u)) --购买成功,返回上一层
            end
        elseif first == "@" then
            local name = string.sub(name, 2)
            if name == "查看背包" then
                local items = table.new(false) --创建一个默认为false的表
                local hero = Hero[GetPlayerId(GetOwningPlayer(u))]
                
                items[xy2i(1, 1)] = GetItemName(UnitItemInSlot(hero, 0))
                items[xy2i(2, 1)] = GetItemName(UnitItemInSlot(hero, 1))
                items[xy2i(1, 2)] = GetItemName(UnitItemInSlot(hero, 2))
                items[xy2i(2, 2)] = GetItemName(UnitItemInSlot(hero, 3))
                items[xy2i(1, 3)] = GetItemName(UnitItemInSlot(hero, 4))
                items[xy2i(2, 3)] = GetItemName(UnitItemInSlot(hero, 5))
                
                items[xy2i(4, 3)] = "#商店主页"
                
                SetShop(u, items)
            end
        else
            --浏览物品
            if first == "<" or first == ">" then
                name = string.sub(name, 2)
            end
            local items = table.new(false) --创建一个默认为false的表
            local x, y = GetShopItemXY(id)
            local x1, x2 --返回上一层/返回目录 所在的x坐标
            local y1, y2 --可升级道具/合成材料 所在的y坐标
            
            if x < 3 then
                x1, x2 = 3, 4
            else
                x1, x2 = 1, 2
            end
            
            if y == 1 then
                y1, y2 = 2, 3
            elseif y == 2 then
                y1, y2 = 1, 3
            else
                y1, y2 = 1, 2
            end
            
            --物品/返回上一层/返回目录
            items[xy2i(x, y)] = "$" .. name
            if GetCurrentShopPage(u) ~= "#商店主页" then
                items[xy2i(x1, y)] = GetCurrentShopPage(u)
            end
            items[xy2i(x2, y)] = "#商店主页"
            
            --查看合成材料
            local complex = GetItemComplex(name)
            local hasComplex = {}
            for x = 1, 4 do
                local name = complex[x]
                if name and not hasComplex[name] then
                    hasComplex[name] = true
                    items[xy2i(x, y2)] = "<" .. name
                end
            end
            
            --查看升级物品
            local up = GetItemUpdata(name)
            for x = 1, 4 do
                local name = up[x]
                if name then
                    items[xy2i(x, y1)] = ">" .. name
                end
            end
            
            SetShop(u, items)
        end
    end
    
    GetItemComplex = function(name)
        local item = GetItem(name)
        local complex = item.complex
        local items = {}
        if complex then
            for _, name in ipairs(complex) do
                if type(name) == "string" then
                    table.insert(items, name)
                end
            end
        end
        return items
    end
    
    --购买物品
    BuyItem = function(shop, name)
        local item = GetItem(name)
        local p = GetOwningPlayer(shop)
        local i = GetPlayerId(p)
        local mygold = GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD)
        local gold = 0
        if item.complex then
            local itemused = table.new(0)
            local items = PlayerItems[i]
            local nitems = {}
            local want = {}
            local complex
            local debug = {times = 0, stack = {}} --递归次数与递归栈
            complex = function(item)
                --DEBUG
                debug.times = debug.times + 1
                debug.stack[debug.times] = item.name
                if debug.times == 10 then
                    print("<DEBUG>在商店购买" .. name .. " 时拆散合成材料的递归次数达到10次,递归栈如下,请截图汇报")
                    print(string.concat(debug.stack, " - "))
                    return
                end
                --DEBUG
                
                for _, name in ipairs(item.complex) do
                    if items[name] - itemused[name] > 0 then
                        --玩家已经拥有的道具数量
                        itemused[name] = itemused[name] + 1 --记录玩家拥有的道具中本次已经使用的数量
                    else
                        --玩家没有的道具需要购入
                        local item = GetItem(name)
                        if item.complex then
                            --如果合成材料也能合成,进行递归合成
                            complex(item)
                        else
                            --如果合成材料不能合成,则直接购入并记录所需要的金钱
                            table.insert(nitems, name)
                            gold = gold + item.gold
                        end
                    end
                end
            end
            complex(item) --将所有合成材料拆成最散件
            if gold > mygold then
                return "金钱不足(还差" .. (gold - mygold) .. ")"
            elseif gold == 0 then
                return "你已经购买了该物品的所有配件,请拾取合成材料进行合成"
            else
                SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, mygold - gold)
                if IsUnitAlive(Hero[i]) and GetBetween(shop, Hero[i]) < 1000 then
                    AddItems(Hero[i], nitems, name)
                else
                    AddItems(Maid[i], nitems, name)
                end
            end
        else
            gold = item.gold
            if gold > mygold then
                return "金钱不足(还差" .. (gold - mygold) .. ")"
            else
                SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, mygold - gold)
                if IsUnitAlive(Hero[i]) and GetBetween(shop, Hero[i]) < 1000 then
                    AddItems(Hero[i], {name})
                else
                    AddItems(Maid[i], {name})
                end
            end
        end
    end
    
    --获取商店中物品的说明文字
    GetShopItemTip = function(p, item)
        local tip = item.tip --物品的基础说明文字
        if item.complex then
            local gold = 0
            local mygold = GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD)
            local tips = {}
            local itemused = table.new(0)
            local items = PlayerItems[GetPlayerId(p)]
            local complex
            local debug = {times = 0, stack = {}} --递归次数与递归栈
            complex = function(item, loopback)
                --DEBUG
                debug.times = debug.times + 1
                debug.stack[debug.times] = item.name
                if debug.times == 10 then
                    print("<DEBUG>在商店预览" .. name .. " 时拆散合成材料的递归次数达到10次,递归栈如下,请截图汇报")
                    print(string.concat(debug.stack, " - "))
                    return
                end
                --DEBUG
                
                local loopgold = 0
                for _, name in ipairs(item.complex) do
                    if items[name] - itemused[name] > 0 then
                        --玩家已经拥有的道具数量
                        itemused[name] = itemused[name] + 1 --记录玩家拥有的道具中本次已经使用的数量
                        if not loopback then --如果是递归就不要再显示了
                            table.insert(tips, "|cff8888ff" .. name .. "|r")
                        end
                    else
                        --玩家没有的道具需要购入
                        local item = GetItem(name)
                        if item.complex then
                            --如果合成材料也能合成,进行递归合成
                            local thatgold = complex(item, true) --合成该材料所需要的钱
                            gold = loopgold + thatgold
                            loopgold = loopgold + thatgold
                            if not loopback then
                                if thatgold > mygold then
                                    --买不起
                                    table.insert(tips, string.format("|cffff1111%s - (%d)|r", name, thatgold))
                                else
                                    --买得起
                                    table.insert(tips, string.format("|cffffff11%s - (%d)|r", name, thatgold))
                                end
                            end
                        else
                            --如果合成材料不能合成,则直接购入并记录所需要的金钱
                            gold = gold + item.gold
                            loopgold = loopgold + item.gold
                            if not loopback then
                                if item.gold > mygold then
                                    --买不起
                                    table.insert(tips, string.format("|cffff1111%s - (%d)|r", name, item.gold))
                                else
                                    --买得起
                                    table.insert(tips, string.format("|cffffff11%s - (%d)|r", name, item.gold))
                                end
                            end
                        end
                    end
                end
                return loopgold
            end
            complex(item)
            if gold > mygold then
                gold = "还需支付:\n|cffff1111" .. gold .. "  |r(|cffffcc00缺少" .. (gold - mygold) .. "|r)"
            elseif gold == 0 then
                gold = "\n|cffffff11你已经购买了该物品的所有配件,请拾取合成材料进行合成|r"
            else
                gold = "还需支付:\n|cffffff11" .. gold .. "|r"
            end
            tip = tip .. "\n\n合成材料:\n" .. string.concat(tips, "\n") .. "\n\n" .. gold
        else
            local gold = item.gold
            local mygold = GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD)
            if gold > mygold then
                gold = "\n\n还需支付:\n|cffff1111" .. gold .. "  |r(|cffffcc00缺少" .. (gold - mygold) .. "|r)"
            else
                gold = "\n\n还需支付:\n|cffffff11" .. gold .. "|r"
            end
            tip = tip .. gold
        end
        return tip
    end
    
    --传统商店
    
    oldShopAction = function()
        local u = GetTriggerUnit()
        local id = GetSpellAbilityId()
        local count = GetUnitUserData(u)
        local p = GetOwningPlayer(u)
        local i = GetPlayerId(p)
        local name = OldShopPageItems[count][id]
        local item = GetItem(name)
        if item then
            if item.complex then
                name = "合成卷轴(" .. name .. ")"
                item = GetItem(name)
            end
            local gold = GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD)
            if gold < item.gold then
                printTo(p, 15, "|cffffcc00金钱不足(还差" .. (item.gold - gold) .. ")|r")
                if SELFP == p then
                    StartSound(gg_snd_Error)
                end
            else
                if SELFP == p then
                    StartSound(gg_snd_ReceiveGold)
                end
                SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, gold - item.gold)
                if IsUnitAlive(Hero[i]) and GetBetween(u, Hero[i]) < 1000 then
                    AddItems(Hero[i], {name})
                else
                    AddItems(Maid[i], {name})
                end
            end
        end        
    end    
    
    GetOldShopItemTip = function(item, page)
        local tip = item.tip --物品的基础说明文字
        if item.complex then
            local list = {tip, "\n"}
            for _, name in ipairs(item.complex) do 
                table.insert(list, ("|cff8888ff%-30s - %-4s    [%s]"):format(name, GetItemData(name, "gold"), page[name] or "点击购买"))                
            end
            tip = table.concat(list, "\n")
        end
        return tip
    end
    
