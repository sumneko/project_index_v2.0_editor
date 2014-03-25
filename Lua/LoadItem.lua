    
    local Items = {}
    local metaitem = { __index = {
        gold = 0,
        wood = 0,
        hp = 1,
        
        add = function(item, p, u)
            local i = GetPlayerId(p)
            local t = PlayerItems[i]
            if not IsUnitIllusion(u) then
                t[item.name] = t[item.name] + 1
                table.insert(PlayerItemList[i], item)
            end
            item.player = p
        end,        
        remove = function(item, u)
            if not item.player then return end
            local i = GetPlayerId(item.player)
            local t = PlayerItems[i]
            if not u or not IsUnitIllusion(u) then
                t[item.name] = t[item.name] - 1
                table.remove2(PlayerItemList[i], item)
            end
            --[[额外的,在玩家失去物品时立即刷新商店显示(其实一般用不到)
            --不使用
            if Shop[i] then
                RefreshShopPage(Shop[i])
            end
            --]]
            item.player = nil
        end,        
        --替换物品
        newId = function(item, nid)
            if item.unit then
                --物品在单位身上
                if IsUnitDead(item.unit) then
                    return false
                end
                DisableTrigger(getTrg)
                DisableTrigger(loseTrg)
                local x, y = GetXY(item.unit)
                local ts = {}
                for i = 0, 5 do
                    local it = UnitItemInSlot(item.unit, i)
                    if not it then
                        local it = CreateItem(|ches|, x, y)
                        table.insert(ts, it)
                        jass.UnitAddItem(item.unit, it)
                    elseif it == item.item then
                        Mark(item.item)
                        removeItemFlag = true
                        jass.RemoveItem(item.item)
                        local it = CreateItem(nid, x, y)
                        InitNewItem(item, it)
                        jass.UnitAddItem(item.unit, it)
                        break
                    end
                end
                for _, it in ipairs(ts) do
                    jass.RemoveItem(it)
                end
                EnableTrigger(getTrg)
                EnableTrigger(loseTrg)
            else
                --物品在地上
                local x, y = GetXY(item.item)
                Mark(item.item)
                removeItemFlag = true
                jass.RemoveItem(item.item)
                local it = CreateItem(item.id, x, y)
                InitNewItem(item, it)
            end
            item.id = nid
            return item
        end
    }}
    
    --注册物品
    local upItems = {} --存放可升级到的装备
    local skillOnlys = {}
    
    InitItem = function(item)
        Items[item.name] = item
        table.insert(Items, item)
        local ob = getObj(slk.item, item.id)
        item.gold = item.gold or tonumber(ob.goldcost or 0)
        item.art = ob.Art or "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp"
        Preload(item.art) --预读图片
        item.coststring = "|cffffff11" .. item.gold .. "|r"
        item.tip = ob.Ubertip
        if ob.abilList then
            item.useid = string2id(ob.abilList)
        end
        if item.skillOnly then
            for name, func in pairs(item.skillOnly) do
                if func then
                    skillOnlys[name] = func
                else
                    if skillOnlys[name] then
                        item.skillOnly[name] = skillOnlys[name]
                    else
                        print("<DEBUG>没有找到物品唯一技能:" ..  name)
                    end
                end
            end
        end
        return item
    end
    
    GetItemData = function(name, data)
        local item = Items[name]
        if item then
            return item[data]
        end
        print(("<GetItemData>没有找到名称为<%s>的物品"):format(name))
    end
    
    --创建合成卷轴
    local InitComplexItem = function(name, gold)
        local nname = "合成卷轴(" .. name .. ")"
        local item = InitItem{
            name = nname,
            gold = gold,
            id = |I0AR|,
            use = function(this)
                printTo(this.player, string.format("该合成卷轴用于合成|cffffff11 %s |r.", name))
            end
        }
        upItems[nname] = {name} --记录合成卷轴可以升级的物品
        return item
    end
    
    Wait(1,
        function()
            for _, item in ipairs(Items) do
                if item.complex then
                    local gold = 0
                    item.acomplex = {}
                    --存放可以升级到的材料
                    for _, name in ipairs(item.complex) do
                        if not upItems[name] then
                            upItems[name] = {}
                        end
                        if not table.has(upItems[name], item.name) then
                            table.insert(upItems[name], item.name)
                        end
                        local nitem = GetItem(name)
                        if nitem then
                            gold = gold + nitem.gold
                        else
                            print("<DEBUG>合成材料未注册")
                            print("<当前物品>" .. item.name)
                            print("<未注册物品>" .. name)
                        end
                        item.acomplex[name] = (item.acomplex[name] or 0) + 1
                    end
                    
                    if item.gold > gold then
                        if not upItems[gold] then
                            upItems[gold] = {}
                        end
                        table.insert(upItems[gold], item.name)
                        gold = item.gold - gold
                        gold = InitComplexItem(item.name, gold)
                        table.insert(item.complex, gold.name) --合成卷轴
                        item.acomplex[gold.name] = 1
                    elseif item.gold < gold then
                        print(string.format("<ERROR>物品定价错误\n<名称>%s<定价>%s<合成材料总价值>%s", item.name, item.gold, gold))
                    end
                end
            end
        end
    )
    
    GetItem = function(name)
        return Items[name]
    end
    
    GetItemUpdata = function(name)
        return upItems[name] or {}
    end
    
    --摧毁物品
    removeItemFlag = false
    
    local Destrg = CreateTrigger()
    TriggerAddCondition(Destrg, Condition(
        function()
            if removeItemFlag then
                removeItemFlag = false
                return
            end
            local it = GetTriggerWidget()
            local item = Mark(it, "数据")
            item:remove()
            Mark(it)
            SetWidgetLife(it, 1)
            removeItemFlag = true
            jass.RemoveItem(it)
       end
    ))
    
    --出售物品
    local sellflag = false
    
    local Selltrg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(Selltrg, EVENT_PLAYER_UNIT_PAWN_ITEM)
    TriggerAddCondition(Selltrg, Condition(
        function()
            local it = GetSoldItem()
            local item = Mark(it, "数据")
            item.sellflag = true --出售物品时先触发抵押物品事件再触发丢弃物品事件,因此标记后在丢弃物品中移除物品
        end
    ))
    
    InitNewItem = function(item, it)
        Mark(it, "数据", item)
        item.item = it
        setmetatable(item, metaitem)
        SetWidgetLife(it, 1)
        TriggerRegisterDeathEvent(Destrg, it)
    end
    
    --记录玩家的物品
    PlayerItems = {}
    PlayerItemList = {}
    for i = 0, 15 do
        PlayerItems[i] = table.new(0)
        PlayerItemList[i] = {}
    end
    
    --创建物品
    local addItemFlag --表示由触发器添加物品
    
    AddItem = function(u, name)
        local item
        item = table.copy(Items[name], false)
        local x, y = GetXY(u)
        local it = CreateItem(item.id, x, y)
        InitNewItem(item, it)
        if type(u) ~= "table" then
            item:add(GetOwningPlayer(u), u)
            addItemFlag = true
            if not UnitAddItem(u, it) then
                addItemFlag = false
            end
        end
        return item
    end
    
    --物品合成(单位, 所有物品数量, 即将获得的物品数量, 想要合成的物品)
    ComplexItem = function(u, allitems, getitems, want)
        local wantitem = GetItem(want)
        local wantitems = wantitem.acomplex
        if not wantitems then
            print("<DEBUG>没有找到物品的合成列表:" .. want)
            return
        end
        for name, count in pairs(wantitems) do
            if allitems[name] < count then
                return
            end
        end
        --可以合成成功
        local bagitems = table.new(0)
        for name, count in pairs(wantitems) do
            if count > getitems[name] then
                bagitems[name] = count - getitems[name] --不够的部分从包里面扣除 
                getitems[name] = 0 --物品表中的物品被扣除完
            else
                getitems[name] = getitems[name] - count --只需要扣除物品表中的物品
            end                
        end
        for i = 0, 5 do
            local it = UnitItemInSlot(u, i)
            if it then
                local item = Mark(it, "数据")
                local name = item.name
                if bagitems[name] > 0 then
                    bagitems[name] = bagitems[name] - 1
                    RemoveItem(item)
                end
            end
        end
        local items = {want} --物品表中的剩余物品,包括刚刚合成完毕的
        for name, count in pairs(getitems) do
            for i = 1, count do
                table.insert(items, name)
            end
        end
        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl", u, "origin"))
        AddItems(u, items) --尝试是否能合成新的物品
        return want
    end
    
    --批量创建物品(单位, 物品表, 希望合成的物品, 是否是通过拾取物品触发)
    AddItems = function(u, items, want, loot)
        local allitems = table.new(0)
        local getitems = table.new(0)
        for _, name in ipairs(items) do
            allitems[name] = allitems[name] + 1
            getitems[name] = getitems[name] + 1
        end
        for i = 0, 5 do
            local it = UnitItemInSlot(u, i)
            if it then
                local item = Mark(it, "数据")
                if item then
                    local name = item.name
                    if item.stack then
                        allitems[name] = allitems[name] + GetItemCharges(it)
                    else
                        allitems[name] = allitems[name] + 1
                    end
                else
                    print("<ERROR>物品没有绑定数据!!!:" .. GetItemName(it))
                end
            end
        end
        --优先合成想要合成的道具
        if want then
            if ComplexItem(u, allitems, getitems, want) then
                return want
            end
        end
        --搜索可能堆叠的物品
        for name, getnum in pairs(getitems) do
            local item = GetItem(name)
            if item.stack then --表示可以堆叠
                getitems[name] = nil --直接移除该物品
                local num = allitems[name] --玩家拥有该物品的总数
                if num > getnum then --说明玩家物品栏中已经有该物品了
                    for i = 0, 5 do
                        local it = UnitItemInSlot(u, i)
                        if it then
                            local item = Mark(it, "数据")
                            local name2 = item.name
                            if name == name2 then --找到物品栏中的相同道具
                                local cha = GetItemCharges(it)
                                if item.stack > cha then --该物品没有堆满
                                    local ncha = math.min(item.stack, cha + getnum)
                                    SetItemCharges(it, ncha)
                                    getnum = getnum - ncha + cha --获得的道具剩余数量
                                    if getnum == 0 then
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                while getnum > 0 do --循环添加物品给英雄
                    local item = AddItem(u, name)
                    if item.stack > getnum then
                        SetItemCharges(item.item, getnum)
                        getnum = 0
                    else
                        SetItemCharges(item.item, item.stack)
                        getnum = getnum - item.stack
                    end
                    if not item.unit and not IsUnitHasEmptySlot(u) then
                        toEvent("物品栏已满", {unit = u,item = item})
                    end
                end
                if loot then
                    return true
                end
            end
        end
        --搜寻可能的合成物品
        local wants = {}
        for name in pairs(getitems) do
            local ups = upItems[name] --可以升级到的物品列表
            if ups then
                for _, name in ipairs(ups) do
                    if name ~= want and not wants[name] then
                        wants[name] = true
                        if ComplexItem(u, allitems, getitems, name) then
                            return name
                        end
                    end
                end
            end
        end
        --没能合成物品
        if not loot or IsUnitHasEmptySlot(u) then --如果是拾取物品且没有空格,就不创建物品,返回nil
            --把所有材料创建给单位
            local ri = {}
            for name, n in pairs(getitems) do
                for i = 1, n do
                    table.insert(ri, AddItem(u, name)) --把所有材料创建给单位
                end
            end
            return ri
        end
    end

    --单位手否含有空物品栏
    IsUnitHasEmptySlot = function(u)
        for i = 0, 5 do
            if UnitItemInSlot(u, i) == nil then return true end
        end
    end
    
    local loseItemFlag --触发器丢弃物品
    
    getTrg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(getTrg, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    TriggerAddCondition(getTrg, Condition(
        function()
            local u = GetTriggerUnit()
            local it = GetManipulatedItem()
            if addItemFlag then
                addItemFlag = false
            else
                --说明是其他单位直接把物品丢给了该单位
                if not it then return end --说明该物品被丢弃事件给摧毁了,拾取事件跳过
                loseItemFlag = true
                SetItemPosition(it, GetUnitX(u), GetUnitY(u))
                UnitLootItem(u, it)
                return
            end
            local items = Mark(u, "物品")
            if not items then
                items = table.new(0)
                Mark(u, "物品", items)
            end
            local item = Mark(it, "数据")
            item.unit = u
            table.insert(items, item)
            --回调函数
            item.event = "获得"
            if item.skillOnly then
                for name, func in pairs(item.skillOnly) do
                    items[name] = items[name] + 1
                    if items[name] == 1 then
                        item.skillname = name
                        func(item)
                    end
                end
            end
            
            if item.skill then
                item:skill()
            end
        end
    ))
    
    RemoveItem = function(item)
        if not item then return end
        if type(item) ~= "table" then
            item = Mark(item, "数据")
        end
        if item.unit then
            local x, y = GetXY(item.unit)
            SetItemPosition(item.item, x, Y)
        end
        jass.RemoveItem(item.item)
    end
    
    loseTrg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(loseTrg, EVENT_PLAYER_UNIT_DROP_ITEM)
    TriggerAddCondition(loseTrg, Condition(
        function()
            if loseItemFlag then
                loseItemFlag = false
                return
            end
            local u = GetTriggerUnit()
            local it = GetManipulatedItem()
            local items = Mark(u, "物品")
            local item = Mark(it, "数据")
            table.remove2(items, item)
            items[item.name] = items[item.name] - 1
            --回调函数
            item.event = "失去"
            if item.skillOnly then
                for name, func in pairs(item.skillOnly) do
                    items[name] = items[name] - 1
                    if items[name] == 0 then
                        item.skillname = name
                        func(item)
                    end
                end
            end
            
            if item.skill then
                item:skill()
            end
            
            item.unit = nil
            
            if item.sellflag then --如果是因为出售物品而触发丢弃物品事件则清除数据
                sellflag = false
                item:remove(u)
                Mark(it)
            end
        end
    ))
    
    --拾取物品
    local LootTrg = CreateTrigger()
    
    InitUnitLoot = function(u)
        UnitAddAbility(u, |A187|)
        UnitMakeAbilityPermanent(u, true, |A187|)
        TriggerRegisterUnitEvent(LootTrg, u, EVENT_UNIT_SPELL_EFFECT)
    end
    
    TriggerAddCondition(LootTrg, Condition(
        function()
            if GetSpellAbilityId() == |A187| and GetSpellTargetItem() then
                local u = GetTriggerUnit()
                local it = GetSpellTargetItem()
                if UnitLootItem(u, it) then
                    local p = GetOwningPlayer(u)
                    if p == SELFP then
                        StartSound(gg_snd_Error)
                    end
                    printTo(p, "|cffffcc00该物品不属于你!|r")
                end
            end
        end
    ))
    
    UnitLootItem = function(u, it)
        if IsUnitIllusion(u) then
            return true
        end
        local item = Mark(it, "数据")
        local name = item.name
        local want = item.wantcomplex
        local p = GetOwningPlayer(u)
        if item.player and item.player ~= p then
            return true
        end
        local names = {}
        if item.stack then
            for i = 1, GetItemCharges(it) do
                names[i] = name
            end
        else
            names[1] = name
        end
        if AddItems(u, names, want, true) then
            RemoveItem(it)
            if p == SELFP then
                StartSound(gg_snd_PickUpItem)
            end
        else
            printTo(p, "|cffffcc00物品栏已满|r")
            if p == SELFP then
                StartSound(gg_snd_Error)
            end
        end
    end
    
    --使用物品
    local lastUse = {}
    
    Event("发动技能",
        function(this)
            local target = GetSpellTargetUnit()
            if target == nil then
                target = GetSpellTargetItem()
                if target == nil then
                    target = GetSpellTargetLoc()
                else
                    lastUse.item = true
                end
            end
            lastUse.unit, lastUse.skill, lastUse.target = this.unit, this.skill, target
        end
    )
    
    local useItemTrg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(useItemTrg, EVENT_PLAYER_UNIT_USE_ITEM)
    TriggerAddCondition(useItemTrg, Condition(
        function()
            local u = GetTriggerUnit()
            local it = GetManipulatedItem()
            local item = Mark(it, "数据")
            if u == lastUse.unit and item.useid == lastUse.skill then
                item.target = lastUse.target
                item.isitemtarget = lastUse.item
                lastUse.unit, lastUse.skill, lastUse.target, lastUse.item = nil
                if item.use then
                    item:use()
                else
                    print("<DEBUG>未找到物品的主动技能: " .. item.name)
                end
            end
            if item.stack and GetItemCharges(it) == 0 then
                RemoveItem(it)
            end
        end
    ))
    
    --移动物品
    Event("物体目标指令",
        function(data)
            local to = data.id - 852001
            if to > 0 and to < 7 then
                local it = GetOrderTargetItem()
                local item = Mark(it, "数据")
                if item and item.move then
                    for i = 0, 5 do
                        if UnitItemInSlot(item.unit, i) == it then
                            item:move(i + 1, to)
                            return
                        end
                    end
                end
            end
        end
    )
    
    --将鼠标右击指令转化为攻击
    local smart = OrderId("smart")
    local smart2attack = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(smart2attack, EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER)
    TriggerAddCondition(smart2attack, Condition(
        function()
            if GetIssuedOrderId() == smart then
                local u1 = GetTriggerUnit()
                local u2 = GetOrderTargetUnit()
                if IsUnitEnemy(u2, GetOwningPlayer(u1)) then
                    IssueTargetOrder(u1, "attack", u2)
                elseif u1 == u2 then
                    IssueImmediateOrder(u1, "stop")
                else
                    IssueTargetOrder(u1, "move", u2)
                end
            end
        end
    ))
    
    --将鼠标右击视野外的建筑指令转化为攻击
    do
        local smart = OrderId("smart")
        local trg = CreateTrigger()
        
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
        TriggerAddCondition(trg, Condition(
            function()
                if GetIssuedOrderId() == smart then
                    local p = GetTriggerPlayer()
                    local loc = GetOrderPointLoc()
                    local u1 = GetTriggerUnit()
                    IssuePointOrderLoc(u1, "move", loc)
                    if IsLocationVisibleToPlayer(loc, p) == false then
                        forRange(loc, 0,
                            function(u2)
                                if GetUnitX(u2) == loc[1] and GetUnitY(u2) == loc[2] and IsUnitType(u2, UNIT_TYPE_STRUCTURE) then
                                    if IsUnitEnemy(u2, p) then
                                        UnitShareVision(u2, p, true)
                                        IssueTargetOrder(u1, "attack", u2)
                                        UnitShareVision(u2, p, false)
                                        return true
                                    end
                                end
                            end
                        )
                    end
                end
            end
        ))
    end
    
    --触发器发布的点目标smart指令转化
    do
        local move = OrderId("move")
        local old1 = IssuePointOrder
        local old2 = IssuePointOrderById
        
        IssuePointOrder = function(u, o, x, y)
            if o == "smart" then
                old1(u, "move", x, y)
            else
                old1(u, o, x, y)
            end
        end
        
        IssuePointOrderById = function(u, o, x, y)
            if o == smart then
                old2(u, move, x, y)
            else
                old2(u, o, x, y)
            end
        end
    end
    
    --加载物品数据
    
    require "Item1.lua"
    require "Item2.lua"
    require "Item3.lua"
    require "Item4.lua"
    require "Item5.lua"
    require "Item6.lua"
    require "Item7.lua"
    require "Item8.lua"
    require "Item9.lua"
    require "Item10.lua"

