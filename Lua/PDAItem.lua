    
    local items = {
        --当麻面包,运动饮料,镇定剂,黑子的电脑配件,体晶,扰乱之羽
        {|I0CW|, |I0CX|, |I0CZ|, |I0D0|, |I0D1|, |I0D2|}, --真物品1
        {|I09S|, |I09P|, |I09O|, |I09N|, |I09R|, |I09Q|}, --保管物品2
        {|I04M|, |I01L|, |I02C|, |I042|, |I04N|, |I04O|}, --马甲物品3
        {"当麻面包", "运动饮料", "镇定剂", "黑子的电脑配件", "体晶", "扰乱之羽"}, --名字
    }
    
    local DropingFlag = false
    
    InitPDAItem = function(pda)
        for i = 1, 6 do
            AddItem(pda, items[4][i] .. 2)
        end
        
        InitPDAItemSkill(pda)
    end
    
    local pdaGetItem = function(this, name, name2)
        local i = GetPlayerId(this.player)
        local hero = Hero[i]
        local count = 0
        local id2 = GetItemData(name2, "id")
        this.skill = nil --关闭掉丢弃动作
        for i = 0, 5 do
            local it = UnitItemInSlot(hero, i)
            local id = GetItemTypeId(it)
            if id == id2 then
                count = count + GetItemCharges(it)
                RemoveItem(it)
            end
        end
        if count > 0 then
            local u = this.unit
            RemoveItem(this)
            local items = {}
            for i = 1, count do
                items[i] = name
            end
            AddItems(u, items)
        end
    end
    
    local pdaLoseItem = function(this, name)
        local u = this.unit
        Wait(0,
            function()
                AddItem(u, name)
            end
        )
    end
    
    local targetCool = {}
    
    PDAStartHeroItemCool = function(this, name)
        local i = GetPlayerId(this.player)
        local u = Hero[i]
        local id = GetItemData(name, "id")
        local skill = get256n(getObj(slk.item, id, "abilList"))
        SetSkillCool(u, skill)
        targetCool[i .. name] = GetTime() + tonumber(getObj(slk.ability, skill, "Cool1", 0))
    end
    
    PDARestartHeroItemCool = function(this, name)
        local i = GetPlayerId(this.player)
        local time = targetCool[i .. name]
        if time then
            time = time - GetTime()
            if time > 0 then
                local u = this.unit
                local skill = get256n(getObj(slk.item, this.id, "abilList"))
                SetSkillCool(u, skill, time)
            end
        end
    end
    
    PDAStartPdaItemCool = function(this, name)
        local i = GetPlayerId(this.player)
        local u = PDA[i]
        local id = GetItemData(name, "id")
        local skill = get256n(getObj(slk.item, id, "abilList"))
        SetSkillCool(u, skill)
        targetCool[i .. name] = GetTime() + tonumber(getObj(slk.ability, skill, "Cool1", 0))
    end
    
    PDARestartPdaItemCool = function(this, name)
        local i = GetPlayerId(this.player)
        local time = targetCool[i .. name]
        if time then
            time = time - GetTime()
            if time > 0 then
                local u = this.unit
                local skill = get256n(getObj(slk.item, this.id, "abilList"))
                SetSkillCool(u, skill, time)
            end
        end
    end
    
    local pdaUseItem = function(this, name)
        local u = this.unit
        local i = GetPlayerId(this.player)
        local hero = Hero[i]
        this.pda = true
        if IsUnitDead(hero) then
            if SELFP == this.player then
                StartSound(gg_snd_Error)
            end
            printTo(this.player, "|cffffcc00你的英雄已经死亡!|r")
            SetItemCharges(this.item, 1 + GetItemCharges(this.item))
            return
        end
        if CanUseItem(hero) then
            this.unit = hero
            this.target = hero
            GetItemData(name, "use")(this)
            PDAStartHeroItemCool(this, name)
            this.unit = u
            RecommandHero(hero)
        else
            local data = Mark(hero, "等待使用物品")
            SetItemCharges(this.item, 1 + GetItemCharges(this.item))
            if data then
                data.this = this
                data.name = name
            else
                data = {
                    hero = hero,
                    unit = u,
                    timer = CreateTimer(),
                    code = function()
                        if IsUnitDead(data.hero) then
                            DestroyTimer(data.timer)
                            Mark(data.hero, "等待使用物品", false)
                        elseif CanUseItem(data.hero) then
                            DestroyTimer(data.timer)
                            Mark(data.hero, "等待使用物品", false)
                            data.this.unit = data.hero
                            data.this.target = data.hero
                            GetItemData(data.name, "use")(data.this)
                            PDAStartHeroItemCool(data.this, data.name)
                            data.this.unit = data.unit
                            SetItemCharges(data.this.item, GetItemCharges(data.this.item) - 1)
                            RecommandHero(data.hero)
                        end
                    end,
                    this = this,
                    name = name
                }
                TimerStart(data.timer, 0.1, true, data.code)
            end
        end
    end
    
    local pdaMoveItem = function(this, from, to, name)
        if from == to then
            local count = GetItemCharges(this.item)
            local i = GetPlayerId(this.player)
            local hero = Hero[i]
            if IsUnitAlive(hero) then
                RemoveItem(this.item)
                local items = {}
                for i = 1, count do
                    items[i] = name
                end
                DropingFlag = true
                AddItems(hero, items)
                DropingFlag = false
            end
        end
    end
    
    local pdaLoseItem2 = function(this)
        this.skill = nil --防止反复触发
        local u = this.unit
        RemoveItem(this)
        Wait(0,
            function()
                AddItem(u, this.name) --重新创建给PDA
            end
        )
    end
    
    
    --当麻面包系列
    do
        local now = 1
    
        InitItem{
            name = items[4][now] .. 2,
            id = items[2][now],
            skill = function(this)
                if this.event == "失去" then
                    pdaLoseItem2(this)
                end
            end,
            use = function(this)
                pdaGetItem(this, items[4][now] .. 3, items[4][now])
            end
        }
        
        InitItem{
            name = items[4][now] .. 3,
            id = items[3][now],
            use = function(this)
                pdaUseItem(this, items[4][now])
            end,
            skill = function(this)
                if this.event == "获得" then
                    PDARestartPdaItemCool(this, this.name)
                elseif this.event == "失去" then
                    pdaLoseItem(this, items[4][now] .. 2)
                    this.name = items[4][now] --转化为真物品
                end
            end,
            move = function(this, from, to)
                pdaMoveItem(this, from, to, items[4][now])
            end,
            stack = 1000
        }
    end
    
    --运动饮料系列
    do
        local now = 2
    
        InitItem{
            name = items[4][now] .. 2,
            id = items[2][now],
            skill = function(this)
                if this.event == "失去" then
                    pdaLoseItem2(this)
                end
            end,
            use = function(this)
                pdaGetItem(this, items[4][now] .. 3, items[4][now])
            end
        }
        
        InitItem{
            name = items[4][now] .. 3,
            id = items[3][now],
            use = function(this)
                pdaUseItem(this, items[4][now])
            end,
            skill = function(this)
                if this.event == "获得" then
                    PDARestartPdaItemCool(this, this.name)
                elseif this.event == "失去" then
                    pdaLoseItem(this, items[4][now] .. 2)
                    this.name = items[4][now] --转化为真物品
                end
            end,
            move = function(this, from, to)
                pdaMoveItem(this, from, to, items[4][now])
            end,
            stack = 1000
        }
    end
    
    --镇定剂系列
    do
        local now = 3
    
        InitItem{
            name = items[4][now] .. 2,
            id = items[2][now],
            skill = function(this)
                if this.event == "失去" then
                    pdaLoseItem2(this)
                end
            end,
            use = function(this)
                pdaGetItem(this, items[4][now] .. 3, items[4][now])
            end
        }
        
        InitItem{
            name = items[4][now] .. 3,
            id = items[3][now],
            use = function(this)
                pdaUseItem(this, items[4][now])
            end,
            skill = function(this)
                if this.event == "获得" then
                    PDARestartPdaItemCool(this, this.name)
                elseif this.event == "失去" then
                    pdaLoseItem(this, items[4][now] .. 2)
                    this.name = items[4][now] --转化为真物品
                end
            end,
            move = function(this, from, to)
                pdaMoveItem(this, from, to, items[4][now])
            end,
            stack = 1000
        }
    end
    
    --黑子的电脑配件系列
    do
        local now = 4
    
        InitItem{
            name = items[4][now] .. 2,
            id = items[2][now],
            skill = function(this)
                if this.event == "失去" then
                    pdaLoseItem2(this)
                end
            end,
            use = function(this)
                pdaGetItem(this, items[4][now] .. 3, items[4][now])
            end
        }
        
        InitItem{
            name = items[4][now] .. 3,
            id = items[3][now],
            use = function(this)
                pdaUseItem(this, items[4][now])
            end,
            skill = function(this)
                if this.event == "获得" then
                    PDARestartPdaItemCool(this, this.name)
                elseif this.event == "失去" then
                    pdaLoseItem(this, items[4][now] .. 2)
                    this.name = items[4][now] --转化为真物品
                end
            end,
            move = function(this, from, to)
                pdaMoveItem(this, from, to, items[4][now])
            end,
            stack = 1000
        }
    end
    
    --体晶系列
    do
        local now = 5
    
        InitItem{
            name = items[4][now] .. 2,
            id = items[2][now],
            skill = function(this)
                if this.event == "失去" then
                    pdaLoseItem2(this)
                end
            end,
            use = function(this)
                pdaGetItem(this, items[4][now] .. 3, items[4][now])
            end
        }
        
        InitItem{
            name = items[4][now] .. 3,
            id = items[3][now],
            use = function(this)
                pdaUseItem(this, items[4][now])
            end,
            skill = function(this)
                if this.event == "获得" then
                    PDARestartPdaItemCool(this, this.name)
                elseif this.event == "失去" then
                    pdaLoseItem(this, items[4][now] .. 2)
                    this.name = items[4][now] --转化为真物品
                end
            end,
            move = function(this, from, to)
                pdaMoveItem(this, from, to, items[4][now])
            end,
            stack = 1000
        }
    end
    
    --扰乱之羽系列
    do
        local now = 6
    
        InitItem{
            name = items[4][now] .. 2,
            id = items[2][now],
            skill = function(this)
                if this.event == "失去" then
                    pdaLoseItem2(this)
                end
            end,
            use = function(this)
                pdaGetItem(this, items[4][now] .. 3, items[4][now])
            end
        }
        
        InitItem{
            name = items[4][now] .. 3,
            id = items[3][now],
            use = function(this)
                pdaUseItem(this, items[4][now])
            end,
            skill = function(this)
                if this.event == "获得" then
                    PDARestartPdaItemCool(this, this.name)
                elseif this.event == "失去" then
                    pdaLoseItem(this, items[4][now] .. 2)
                    this.name = items[4][now] --转化为真物品
                end
            end,
            move = function(this, from, to)
                pdaMoveItem(this, from, to, items[4][now])
            end,
            stack = 1000
        }
    end
    
    --技能    
    do
        local trg = CreateTrigger()
        
        InitPDAItemSkill = function(u)
            TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_SPELL_EFFECT)
            TriggerAddCondition(trg, Condition(
                function()
                    local u = GetTriggerUnit()
                    local skill = GetSpellAbilityId()
                    local p = GetOwningPlayer(u)
                    local i = GetPlayerId(p)
                    local hero = Hero[i]
                    if IsUnitDead(hero) then
                        printTo(p, "|cffffcc00你的英雄已经阵亡!|r")
                        if SELFP == p then
                            StartSound(gg_snd_Error)
                        end
                        return
                    end
                    if skill == |A0DQ| then
                        --保管消耗品
                        for x = 0, 5 do
                            local it = UnitItemInSlot(hero, x)
                            if it then
                                local id = GetItemTypeId(it)
                                local type
                                for y = 1, 6 do
                                    if id == items[1][y] then
                                        type = y
                                        break
                                    end
                                end
                                if type then
                                    local count = GetItemCharges(it)
                                    RemoveItem(it) --移除英雄身上的物品
                                    for x = 0, 5 do
                                        local it = UnitItemInSlot(u, x)
                                        local id = GetItemTypeId(it)
                                        if id == items[2][type] then
                                            --保管类物品
                                            local this = Mark(it, "数据")
                                            this.skill = nil --关闭丢弃函数
                                            RemoveItem(it)
                                            local name = items[4][type] .. 3
                                            local items = {}
                                            for i = 1, count do
                                                items[i] = name
                                            end
                                            AddItems(u, items)
                                            break
                                        elseif id == items[3][type] then
                                            --使用类物品
                                            SetItemCharges(it, count + GetItemCharges(it))
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    elseif skill == |A0DH| then
                        --转移所有物品
                        DropingFlag = true
                        for x = 0, 5 do
                            local it = UnitItemInSlot(u, x)
                            local count = GetItemCharges(it)
                            if count > 0 then
                                local id = GetItemTypeId(it)
                                local type
                                for y = 1, 6 do
                                    if id == items[3][y] then
                                        type = y
                                        break
                                    end
                                end
                                RemoveItem(it)
                                local name = items[4][type]
                                local items = {}
                                for i = 1, count do
                                    items[i] = name
                                end
                                AddItems(hero, items)
                            end
                        end
                        DropingFlag = false
                    end
                end
            ))
        end
    end
    
    --物品栏已满自动保管
    Event("物品栏已满",
        function(this)
            if DropingFlag or not IsHero(this.unit) then return end
            this = this.item
            if this.stack then
                local type
                for i = 1, 6 do
                    if this.id == items[1][i] then
                        type = i
                        break
                    end
                end
                if type then
                    local name = items[4][type]
                    local count = GetItemCharges(this.item)
                    local p = this.player
                    local i = GetPlayerId(this.player)
                    RemoveItem(this)
                    local u = PDA[i]
                    for x = 0, 5 do
                        local it = UnitItemInSlot(u, x)
                        local id = GetItemTypeId(it)
                        if id == items[2][type] then
                            --保管类物品
                            local this = Mark(it, "数据")
                            this.skill = nil --关闭丢弃函数
                            RemoveItem(it)
                            local name = items[4][type] .. 3
                            local items = {}
                            for i = 1, count do
                                items[i] = name
                            end
                            AddItems(u, items)
                            break
                        elseif id == items[3][type] then
                            --使用类物品
                            count = count + GetItemCharges(it)
                            SetItemCharges(it, count)
                            break
                        end
                    end
                    printTo(p, ("|cffffcc00物品栏已满|r,你刚刚获得的 |cffffcc00%s|r 已经自动转交给 |cffffcc00携带女仆|r"):format(name))
                end
            end
        end
    )
    
