    
    InitBattle{
        name = "侦查守卫",
        id = |A192|,
        cost = 100,
        rng = 400,
        tip = "放置一个拥有200生命值的隐形守卫监视附近的区域,持续180秒.\
该守卫在白天拥有1200的视野,在晚上拥有300的视野.",
        code = function(this)
            if IsUnitDead(this.hero) then
                return "你的英雄已经死亡"
            end
            if UnitAddAbility(this.hero, |A197|) then
                UnitMakeAbilityPermanent(this.hero, true, |A197|)
            end
            IssuePointOrder(this.hero, "sacrifice", GetXY(this.target))
            Mark(this.player, "侦查守卫花费", this.cost)
            SetPlayerState(this.player, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(this.player, PLAYER_STATE_RESOURCE_LUMBER) + this.cost)
        end
    }
    
    Event("发动技能",
        function(data)
            if data.skill == |A197| then
                local p = GetOwningPlayer(data.unit)
                local ut = |oeye|
                local cost = Mark(p, "侦查守卫花费") or 100
                local wood = GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER)
                if wood < cost then
                    return
                else
                    SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, wood - cost)
                end
                if Mark(p, "强化侦查守卫") then
                    ut = |o003|
                end
                local u = CreateUnitAtLoc(p, ut, GetSpellTargetLoc(), 270)
                UnitAddAbility(u, |Aeth|)
                UnitAddAbility(u, |Agho|)
                UnitApplyTimedLife(u, 'BTLF', 180)
                SetUnitAnimation(u, "birth")
                QueueUnitAnimation(u, "stand")
                SetUnitFlyHeight(u, 0, 0)
            end
        end
    )
    
    InitBattle{
        name = "岗哨守卫",
        id = |A193|,
        cost = 100,
        rng = 400,
        tip = "放置一个拥有200生命值的隐形守卫监视附近的区域,持续120秒.\
该守卫在白天拥有300的视野,在晚上拥有300的视野.\
该守卫可以看到900范围内的隐身单位.",
        code = function(this)
            if IsUnitDead(this.hero) then
                return "你的英雄已经死亡"
            end
            if UnitAddAbility(this.hero, |A196|) then
                UnitMakeAbilityPermanent(this.hero, true, |A196|)
            end
            IssuePointOrder(this.hero, "sanctuary", GetXY(this.target))
            Mark(this.player, "岗哨守卫花费", this.cost)
            SetPlayerState(this.player, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(this.player, PLAYER_STATE_RESOURCE_LUMBER) + this.cost)
        end
    }
    
    Event("发动技能",
        function(data)
            if data.skill == |A196| then
                local p = GetOwningPlayer(data.unit)
                local ut = |nwad|
                local cost = Mark(p, "岗哨守卫花费") or 100
                local wood = GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER)
                if wood < cost then
                    return
                else
                    SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, wood - cost)
                end
                if Mark(p, "强化岗哨守卫") then
                    ut = |n00E|
                end
                local u = CreateUnitAtLoc(p, ut, GetSpellTargetLoc(), 270)
                UnitAddAbility(u, |Aeth|)
                UnitAddAbility(u, |Adt1|)
                UnitAddAbility(u, |Agho|)
                UnitApplyTimedLife(u, 'BTLF', 180)
                SetUnitAnimation(u, "birth")
                QueueUnitAnimation(u, "stand")
            end
        end
    )
    
    InitBattle{
        name = "屏障",
        id = |A195|,
        cost = 500,
        tip = "开启屏障,使友方建筑物在接下来的5秒内免疫一切伤害.\
己方玩家共享30秒冷却时间.\
英雄处于死亡状态时也可以使用该技能.",
        code = function(this)
            local g = CreateGroup()
            local tid = GetPlayerTeam(this.player)
            local t = {}
            GroupEnumUnitsOfPlayer(g, Com[tid], Condition(
                function()
                    local u = GetFilterUnit()
                    if IsUnitType(u, UNIT_TYPE_STRUCTURE) and IsUnitAlive(u) then
                        t[u] = AddSpecialEffectTarget("Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl", u, "origin")
                    end
                end
            ))
            DestroyGroup(g)
            local func
            if Mark(this.player, "强化屏障") then
                func = Event("伤害减免",
                    function(damage)
                        if t[damage.to] then
                            local data = table.copy(damage.data)
                            data.changed = "强化屏障"
                            Damage(damage.to, damage.from, damage.damage, false, false, data)
                            damage.damage = 0
                        end
                    end
                )
            else
                func = Event("伤害减免",
                    function(damage)
                        if t[damage.to] then
                            damage.damage = 0
                        end
                    end
                )
            end
           
            local ps = GetAllyUsers(this.player)
            for i = 1, 5 do
                local id = GetPlayerId(ps[i])
                if PDA[id] and ps[i] ~= this.player then
                    local ab = japi.EXGetUnitAbility(PDA[id], this.id)
                    local cd = 180
                    japi.EXSetAbilityState(ab, 1, cd)
                end
            end
            Wait(5,
                function()
                    for u, e in pairs(t) do
                        DestroyEffect(e)
                    end
                    Event("-伤害减免", func)
                end
            )
        end
    }
    
    InitBattle{
        name = "涡点",
        id = |A198|,
        cost = 200,
        tip = "持续施法6秒后,传送到指定涡点附近400范围以内的地点.\
60秒冷却时间.",
        code = function(this)
            if IsUnitDead(this.hero) then
                return "你的英雄已经死亡"
            end
            if UnitAddAbility(this.hero, |A199|) then
                UnitMakeAbilityPermanent(this.hero, true, |A199|)
            end
            IssueImmediateOrder(this.hero, "selfdestruct")
            local gate = table.getone(Gate,
                function(u1, u2)
                    return GetBetween(this.target, u1) < GetBetween(this.target, u2)
                end
            )
            local l = GetBetween(this.target, gate)
            local p = this.target
            local a = GetBetween(gate, p, true)
            p = MovePointSafe(gate, {math.min(l, 400), a})
            Mark(this.hero, "涡点特效", AddSpecialEffectTarget("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTo.mdl", this.hero, "origin"))
            Mark(this.hero, "涡点目标", AddSpecialEffect("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTo.mdl", GetXY(p)))
            Mark(this.hero, "涡点", p)
        end
    }
    
    Event("施放结束", "停止施放",
        function(data)
            if data.skill == |A199| then
                if data.event == "停止施放" then
                    DestroyEffect(Mark(data.unit, "涡点特效"))
                    DestroyEffect(Mark(data.unit, "涡点目标"))
                elseif data.event == "施放结束" then 
                    local p = Mark(data.unit, "涡点")
                    TempEffect(data.unit, "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl")
                    TempEffect(p, "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl")
                    SetUnitXY(data.unit, p)
                end
            end
        end
    )
    
    InitBattle{
        name = "纳米护盾",
        id = |A19M|,
        cost = 500,
        tip = "周围1000范围的友方小兵护甲提高100点,抗性提高400点,持续10秒.\
60秒冷却时间.",
        code = function(this)
            if IsUnitDead(this.hero) then
                return "你的英雄已经死亡"
            end
            TempEffect(this.hero, "Abilities\\Spells\\Items\\AIda\\AIdaCaster.mdl")
            local g = {}
            forRange(this.hero, 1000,
                function(u)
                    if IsUnitAlly(u, this.player) and IsUnitAlive(u) and GetOwningPlayer(u) == Com[this.team] and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                        Def(u, 100)
                        Ant(u, 400)
                        g[u] = AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIda\\AIdaTarget.mdl", u, "overhead")
                    end
                end
            )
            Wait(10,
                function()
                    for u, e in pairs(g) do
                        Def(u, -100)
                        Ant(u, -400)
                        DestroyEffect(e)
                    end
                end
            )
        end
    }
    
