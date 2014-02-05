    
    ComBuildings = {}
    
    local getItem = function(u)
        local name = GetUnitName(u)
        
        if name == "前线碉堡" then
                AddItem(u, "真实视域")
                AddItem(u, "英雄守护者")
                AddItem(u, "壁垒")
                
            elseif name == "哨岗塔" then
                AddItem(u, "真实视域")
                AddItem(u, "英雄守护者")
                AddItem(u, "壁垒")

            elseif name == "警戒塔" then
                AddItem(u, "真实视域")
                AddItem(u, "英雄守护者")
                AddItem(u, "壁垒")

            elseif name == "要塞" then
                AddItem(u, "真实视域")
                AddItem(u, "英雄守护者")
                AddItem(u, "壁垒")

            elseif name == "脉冲发射塔" then
                AddItem(u, "真实视域")
                AddItem(u, "英雄守护者")
                AddItem(u, "壁垒")
                AddItem(u, "能场发散")

            elseif name == "魔术堡垒" then
                AddItem(u, "真实视域")
                AddItem(u, "英雄守护者")
                AddItem(u, "壁垒")
                AddItem(u, "能场发散")
                
            elseif name == "生命之泉" then
                AddItem(u, "真实视域")
                AddItem(u, "英雄守护者")
                AddItem(u, "壁垒")
                
            elseif name == "研究所" then
                AddItem(u, "真实视域")
                AddItem(u, "壁垒")
                AddItem(u, "研发核心")

            elseif name == "十字教" then
                AddItem(u, "真实视域")
                AddItem(u, "壁垒")
                AddItem(u, "研发核心")

            elseif name == "警备站" then
                AddItem(u, "真实视域")
                AddItem(u, "壁垒")
                AddItem(u, "研发核心")

            elseif name == "教堂" then
                AddItem(u, "真实视域")
                AddItem(u, "壁垒")
                AddItem(u, "研发核心")

            elseif name == "五行机关虚数学区" then
                AddItem(u, "真实视域")
                AddItem(u, "壁垒")
                AddItem(u, "研发核心")

            elseif name == "罗马大教堂" then
                AddItem(u, "真实视域")
                AddItem(u, "壁垒")
                AddItem(u, "研发核心")

            end
    end
    
    local InitOne = function()
        local u = GetFilterUnit()
        
        if IsUnitType(u, UNIT_TYPE_STRUCTURE) and GetUnitAbilityLevel(u, |Aloc|) == 0 then
            UnitAddAbility(u, |A0PS|) --添加物品栏(不能丢弃物品)
            
            table.insert(ComBuildings, u)
            Mark(u, "电脑建筑", true)
            
            getItem(u)
        end
    end
    
    Event("死亡",
        function(data)
            if Mark(data.unit, "电脑建筑") then
                for i = 0, 5 do
                    local it = UnitItemInSlot(data.unit, i)
                    if it then
                        RemoveItem(it)
                    end
                end
            end
        end
    )
    
    local InitItems = function()
        require "LoadItem.lua"
        --真实视域
        InitItem{
            name = "真实视域",
            id = |I0AI|,
            tip = "\
|cffffcc00真实视域(唯一)|r\
\
探测到附近900范围内的隐身单位",
            skillOnly = {
                ["真实视域"] = function(this) --唯一被动技能
                    local p = GetOwningPlayer(this.unit)
                    if this.event == "获得" then
                        UnitAddAbility(this.unit, |A03Z|)
                        --如果是电脑获得了这个技能,由于电脑不给玩家共享视野(真实视域),因此需要创建马甲来提供
                        if IsCom(p) then
                            local ps
                            if GetPlayerTeam(p) == 0 then
                                ps = PA[1]
                            else
                                ps = PB[1]
                            end
                            this.dummyunit = CreateUnit(ps, dummy, GetUnitX(this.unit), GetUnitY(this.unit), 0)
                            UnitAddAbility(this.dummyunit, |A03Z|)
                        end
                    elseif this.event == "失去" then
                        UnitRemoveAbility(u, |A03Z|)
                        if this.dummyunit then
                            RemoveUnit(this.dummyunit)
                        end
                    end
                end
            }
        }
        
        Event("洗牌后",
            function()
                for i, u in ipairs(ComBuildings) do
                    for i = 0, 5 do
                        local it = UnitItemInSlot(u, i)
                        RemoveItem(it)
                    end
                    
                    getItem(u)
                end
            end
        )
        
        --英雄守护者
        InitItem{
            name = "英雄守护者",
            id = |I0AJ|,
            tip = "\
|cffffcc00狂轰滥炸(唯一)|r\
\
连续攻击英雄单位时,伤害会递增20%\
\
|cffffcc00选择性无视(唯一)|r\
\
防御塔总是优先攻击非英雄单位,但是如果射程内的敌方英雄对友方英雄造成了伤害,防御塔就会毫不留情的进行猛轰\
\
|cffffcc00攻击预警(唯一)|r\
\
标识并警告防御塔正在攻击的目标",
            skillOnly = {
                ["狂轰滥炸"] = function(this) --唯一被动技能
                    if this.event == "获得" then
                        local name = this.skillname .. 1
                        Mark(this.unit, name, 0)
                        Mark(this.unit, this.skillname, Event("伤害加成",
                            function(damage)
                                if damage.attack and damage.from == this.unit then
                                    local ut = GetUnitTypeId(damage.to)
                                    if IsHeroUnitId(ut) then
                                        local up = Mark(this.unit, name)
                                        Mark(this.unit, name, up + 50)
                                        damage.damage = damage.damage + damage.odamage * up / 100
                                    else
                                        Mark(this.unit, name, 0)
                                    end
                                end
                            end
                        ))
                    elseif this.event == "失去" then
                        Event("-伤害加成", Mark(this.unit, this.skillname))
                    end
                end,
                ["选择性无视"] = function(this)
                    if this.event == "获得" then
                        local u = this.unit
                        local p = GetOwningPlayer(this.unit)
                        
                        Mark(this.unit, this.skillname, Event("攻击",
                            function(this)
                                if this.from == u then
                                    if Mark(this.from, "攻击目标") == this.to then
                                        return
                                    end
                                    --优先攻击小兵
                                    
                                    if IsHero(this.to) and Mark(this.from, "反击目标") ~= this.to then
                                        local rng = GetUnitState(this.from, ConvertUnitState(0x16))
                                        local t = {}
                                        forRange(this.from, rng + 200,
                                            function(u)
                                                if IsUnitInRange(u, this.from, rng) and not IsHero(u) and EnemyFilter(p, u, {["魔免"] = true, ["建筑"] = true}) then
                                                    table.insert(t, u)
                                                end
                                            end
                                        )
                                        if #t == 0 then
                                            toEvent("防御塔确定攻击目标", {from = this.from, to = this.to})
                                        else
                                            local to = table.getone(t,
                                                function(u1, u2)
                                                    return GetBetween(this.from, u1) < GetBetween(this.from, u2)
                                                end
                                            )
                                            
                                            if to then
                                                toEvent("防御塔确定攻击目标", {from = this.from, to = to})
                                                if not IssueTargetOrder(this.from, "attack", to) then
                                                    Debug("<防御塔攻击目标失败>" .. GetUnitName(to))
                                                end
                                            else
                                                toEvent("防御塔确定攻击目标", {from = this.from, to = this.to})
                                            end
                                        end
                                    else
                                        toEvent("防御塔确定攻击目标", {from = this.from, to = this.to})
                                    end
                                end
                            end
                        ))
                        
                        Mark(this.unit, this.skillname .. 1, Event("伤害后", 
                            function(this)
                                if this.from and IsHero(this.to) and IsUnitAlly(this.to, p) and IsPlayer(GetOwningPlayer(this.from)) and IsUnitInRange(this.from, u, GetUnitState(u, ConvertUnitState(0x16))) and EnemyFilter(p, this.from, {["魔免"] = true, ["建筑"] = true}) then
                                    Mark(u, "反击目标", this.from)
                                    if not IssueTargetOrder(u, "attack", this.from) then
                                        Debug("<防御塔反击目标失败>" .. GetUnitName(this.from))
                                    end
                                end
                            end
                        ))
                    elseif this.event == "失去" then
                        Event("-攻击", Mark(this.unit, this.skillname))
                        Event("-伤害后", Mark(this.unit, this.skillname .. 1))
                    end
                end,
                ["攻击预警"] = function(this)
                    if this.event == "获得" then
                        local u = this.unit
                        Mark(this.unit, this.skillname, Event("防御塔确定攻击目标",
                            function(this)
                                if this.from == u then
                                    if GetOwningPlayer(this.to) == SELFP and IsHero(this.to) and Mark(this.from, "攻击目标") ~= this.to then
                                        StartSound(gg_snd_Warning)
                                    end
                                    Mark(this.from, "攻击目标", this.to)
                                    if not Mark(this.from, "攻击目标连线") then
                                        local ln = AddLightningEx("LN01", false, 0, 0, 0, 0, 0, 0)
                                        local rng = GetUnitState(this.from, ConvertUnitState(0x16))
                                        local a = true
                                        Mark(this.from, "攻击目标连线", true)
                                        SetLightningColor(ln, 1, 0, 0, 0.5)
                                        LoopRun(0.02,
                                            function()
                                                if IsUnitDead(this.from) then
                                                    DestroyLightning(ln)
                                                    EndLoop()
                                                    return
                                                end
                                                local to = Mark(this.from, "攻击目标")
                                                if IsUnitInRange(to, this.from, rng) and IsUnitAlive(to) then
                                                    a = true
                                                    MoveLightningEx(ln, false, GetUnitX(this.from), GetUnitY(this.from), GetUnitZ(this.from) + 300, GetUnitX(to), GetUnitY(to), GetUnitZ(to) + 100)
                                                elseif a then
                                                    MoveLightningEx(ln, false, 0, 0, 999999, 0, 0, 999999)
                                                    Mark(this.from, "攻击目标", false)
                                                    Mark(this.from, "反击目标", false)
                                                    a = false
                                                end
                                            end
                                        )
                                    end
                                end
                            end
                        ))
                    elseif this.event == "失去" then
                        Event("-防御塔确定攻击目标", Mark(this.unit, this.skillname))
                    end
                end
            }
        }
        
        --壁垒
        InitItem{
            name = "壁垒",
            id = |I0AK|,
            tip = "\
|cffffcc00铁壁堡垒(唯一)|r\
\
当周围1000范围内没有敌方小兵,且15秒没有受到来自敌方的小兵伤害时,防御塔会将减免75%的伤害,并将这些伤害返还给伤害来源",
            skillOnly = {
                ["铁壁堡垒"] = function(this)
                    if this.event == "获得" then
                        Mark(this.unit, "铁壁堡垒1", 0)
                        
                        Mark(this.unit, this.skillname, Event("伤害减免",
                            function(damage)
                                if damage.from and damage.to == this.unit then
                                    if Mark(damage.from, "分路") then
                                        --来自小兵的伤害
                                        Mark(this.unit, "铁壁堡垒1", GetTime())
                                    else
                                        if GetTime() - Mark(this.unit, "铁壁堡垒1") > 15 then
                                            local d = damage.mdamage * 0.75
                                            damage.damage = damage.damage - d
                                            if not damage.change then
                                                Damage(this.unit, damage.from, d, false, false, {item = true, change = true, damageReason = "铁壁堡垒"})
                                            end
                                        end
                                    end
                                end
                            end
                        ))
                        
                        local p = GetOwningPlayer(this.unit)
                        
                        Mark(this.unit, this.skillname .. 2, Loop(1,
                            function()
                                local flag
                                forRange(this.unit, 1000,
                                    function(u)
                                        if IsUnitAlive(u) and IsUnitEnemy(u, p) and Mark(u, "分路") then
                                            flag = true
                                        end
                                    end
                                )
                                if flag then
                                    Mark(this.unit, "铁壁堡垒1", math.max(GetTime() - 10, Mark(this.unit, "铁壁堡垒1")))
                                end
                            end
                        ))
                        
                    elseif this.event == "失去" then
                        Event("-伤害减免", Mark(this.unit, this.skillname))
                        DestroyTimer(Mark(this.unit, this.skillname .. 2))
                        
                    end
                end
            }
        }
        
        --能场发散
        InitItem{
            name = "能场发散",
            id = |I0AL|,
            tip = "\
|cffffcc00能场发散(唯一)|r\
\
攻击命中后对附近225范围的单位造成50%的扩散伤害",
            skillOnly = {
                ["能场发散"] = function(this)
                    if this.event == "获得" then
                        local p = GetOwningPlayer(this.unit)
                        Mark(this.unit, this.skillname, Event("伤害效果",
                            function(damage)
                                if damage.attack and damage.from == this.unit then
                                    local d = damage.damage * 0.5
                                    forRange(damage.to, 225,
                                        function(u)
                                            if damage.to ~= u and EnemyFilter(p, u, {["魔免"] = true, ["建筑"] = true}) then
                                                Damage(this.unit, u, d, false, false, {item = true, aoe = true, arry = true, damageReason = "能场扩散"})
                                            end
                                        end
                                    )
                                end
                            end
                        ))
                    elseif this.event == "失去" then
                        Event("-伤害效果", Mark(this.unit, this.skillname))
                    end
                end
            }
        }
        
        --研发核心
        InitItem{
            name = "研发核心",
            id = |I0CY|,
            skillOnly = {
                ["生产节操"] = function(this)
                    local tid = GetPlayerTeam(this.player)
                    if this.event == "获得" then
                        FoodS[tid] = FoodS[tid] + 0.1
                    elseif this.event == "失去" then
                        FoodS[tid] = FoodS[tid] - 0.1
                    end
                end
            }
        }
    end
    
    Wait(0,
        function()
            InitItems()
            local g = CreateGroup()
            --遍历2个电脑的建筑物
            GroupEnumUnitsOfPlayer(g, Com[0], Condition(InitOne))
            GroupEnumUnitsOfPlayer(g, Com[1], Condition(InitOne))
            DestroyGroup(g)
        end
    )
    
