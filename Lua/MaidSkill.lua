    
    local maidHomeTrg
    
    HomeRect = {}
    
    HomeRect[0] = gg_rct_CollageResurrection
    HomeRect[1] = gg_rct_RomeResurrection
    
    InitMaidSkill = function(u)
        local rect
        if GetPlayerTeam(GetOwningPlayer(u)) == 0 then
            rect = gg_rct_CollageResurrection
        else
            rect = gg_rct_RomeResurrection
        end
        TriggerRegisterLeaveRectSimple(maidHomeTrg, rect)
        MaidInitGiveItem(u, rect)
    end
    
    --买活
    Event("阵亡", "发动技能",
        function(this)
            if this.event == "阵亡" then
                local p = GetOwningPlayer(this.u2)
                local id = GetPlayerId(p)
                local u = Maid[id]
                local tip = "|cffffcc00$%d|r"
                local lv = GetHeroLevel(this.u2)
                local _, gt = GetGameTime()
                local gold = lv * 100 + math.max(0, gt)
                local t = lv * 4 + 10
                local mg = gold * 0.5 / t
                LoopRun(1,
                    function()
                        local skill = japi.EXGetUnitAbility(u, |A0DP|)
                        if IsUnitDead(Hero[id]) then
                            if id == SELFP then
                                japi.EXSetAbilityDataString(skill, 1, 218, string.format(tip, gold))
                            end
                            japi.EXSetAbilityDataReal(skill, 1, 107, gold) --把买活的钱存在 rng 里
                            gold = gold - mg
                        else
                            EndLoop()
                            if id == SELFP then
                                japi.EXSetAbilityDataString(skill, 1, 218, "你的英雄还未死亡")
                            end
                            japi.EXSetAbilityDataReal(skill, 1, 107, 0)
                        end
                        RefreshTips(u)
                    end
                )
                if p == SELFP then
                    SelectUnit(u, true)
                end
            elseif this.event == "发动技能" then
                --买活
                if this.skill == |A0DP| then
                    local skill = japi.EXGetUnitAbility(this.unit, |A0DP|)
                    local gold = math.floor(japi.EXGetAbilityDataReal(skill, 1, 107))
                    local p = GetOwningPlayer(this.unit)
                    if gold == 0 then
                        printTo(p, "|cffffcc00你的英雄还未死亡|r")
                        IssueImmediateOrder(this.unit, "stop")
                        if SELFP == p then
                            StartSound(gg_snd_Error)
                        end
                    else
                        local pg = GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD)
                        if gold > pg then
                            printTo(p, "|cffffcc00你的金钱不足|r")
                            IssueImmediateOrder(this.unit, "stop")
                            if SELFP == p then
                                StartSound(gg_snd_Error)
                            end
                        else
                            local i = GetPlayerId(p)
                            SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, pg - gold)
                            ReviveHeroLoc(Hero[i], StartPoint[GetPlayerTeam(p)], true)
                            SetUnitState(Hero[i], UNIT_STATE_LIFE, 999999)
                            toEvent("复活", {unit = Hero[i]})
                            print(PlayerNameHero(p, true) .. " 已经复活(买活) !!!")
                        end
                    end
                elseif this.skill == |A194| then
                    --空投物品
                    local u = this.unit
                    local p = GetOwningPlayer(u)
                    local items = {}
                    local id = GetPlayerId(p)
                    for i = 0, 5 do
                        local it = UnitItemInSlot(Maid[id], i)
                        if it then
                            table.insert(items, it)
                            SetItemPositionLoc(it, MH.temp)
                            SetItemVisible(it, false)
                        end
                    end
                    if #items == 0 then
                        printTo(p, "|cffffcc00你的家务女仆未持有任何物品|r")
                        if p == SELFP then
                            StartSound(gg_snd_Error)
                        end
                        IssueImmediateOrder(this.unit, "stop")
                        return 
                    end
                    local target = GetSpellTargetLoc()
                    local tid = GetPlayerTeam(p)
                    local uid
                    if tid == 0 then
                        uid = |h025|
                    else
                        uid = |h026|
                    end
                    
                    local u = CreateUnitAtLoc(Com[tid], uid, GetUnitLoc(Maid[id]), 0)
                    IssuePointOrder(u, "move", GetXY(target))
                    UnitAddAbility(u, |Avul|)
                    ArmyShareVision(tid, u)
                    
                    local hero = Hero[id]
                    local func
                    func = Event("阵亡",
                        function(data)
                            if data.u2 == hero then
                                target = Maid[id]
                                IssuePointOrder(u, "move", GetXY(target))
                                Event("-阵亡", func)
                            end
                        end
                    )
                    
                    Loop(0.5,
                        function()
                            if IsUnitAlive(hero) and GetBetween(hero, u) < 300 then
                                --直接把物品都交给英雄
                                local nitems = {}
                                for _, it in ipairs(items) do
                                    local item = Mark(it, "数据")
                                    if item.stack then
                                        for i = 1, GetItemCharges(it) do
                                            table.insert(nitems, item.name)
                                        end
                                    else
                                        table.insert(nitems, item.name)
                                    end
                                    RemoveItem(it)
                                end
                                AddItems(hero, nitems)
                                EndLoop()
                            elseif GetBetween(u, target) < 200 then
                                --把物品放在地上
                                for _, it in ipairs(items) do
                                    SetItemPosition(it, GetXY(target))
                                    SetItemVisible(it, true)
                                end
                                local x, y = GetXY(target)
                                PingMinimapEx(x, y, 10, 0, 255, 0, false)
                                printTo(p, "|cff11ff11你的物品已经送抵|r")
                                EndLoop()
                            else
                                return
                            end
                            Event("-阵亡", func)
                            RemoveUnit(u)
                        end
                    )
                end
            end
        end
    )
    
    --禁止家务女仆离开家
    local p1 = GetRectCenter(gg_rct_CollageResurrection)
    local p2 = GetRectCenter(gg_rct_RomeResurrection)
    
    maidHomeTrg = CreateTrigger()
    TriggerAddCondition(maidHomeTrg, Condition(
        function()
            local u = GetTriggerUnit()
            if GetUnitTypeId(u) == |enec| then
                local p
                if GetPlayerTeam(GetOwningPlayer(u)) == 0 then
                    p = p1
                else
                    p = p2
                end
                IssueImmediateOrder(u, "stop")
                local a = GetBetween(u, p, true)
                local nl = MovePoint(u, {10, a})
                SetUnitXY(u, nl)
            end
        end
    ))
    
    --英雄复活或回到家的时候把装备交给英雄
    do
        local trg = CreateTrigger()
        TriggerAddCondition(trg, Condition(
            function()
                local hero = GetTriggerUnit()
                if IsHero(hero) and IsUnitAlive(hero) then
                    local p = GetOwningPlayer(hero)
                    local id = GetPlayerId(p)
                    local maid = Maid[id]
                    local nitems = {}
                    for i = 0, 5 do
                        local it = UnitItemInSlot(maid, i)
                        if it then
                            local item = Mark(it, "数据")
                            if item.stack then
                                for i = 1, GetItemCharges(it) do
                                    table.insert(nitems, item.name)
                                end
                            else
                                table.insert(nitems, item.name)
                            end
                            RemoveItem(it)
                        end
                    end
                    local r = AddItems(hero, nitems)
                    if type(r) == "table" then
                        local its = {}
                        for _, item in ipairs(r) do
                            if not item.unit then
                                table.insert(its, item.name)
                                RemoveItem(item.item)
                            end
                        end
                        AddItems(maid, its)
                    end
                end
            end
        ))
        
        MaidInitGiveItem = function(u, rect)
            local p = GetOwningPlayer(u)
            local id = GetPlayerId(p)
            local hero = Hero[id]
            TriggerRegisterEnterRectSimple(trg, rect)
            
        end
    end
