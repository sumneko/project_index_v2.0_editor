    
    --第1层
    InitProject{
        name = "富二代",
        art = "BTNMGExchange.blp",
        tip = "\
|cffff00ff英雄:|r 获得250金钱\n\
|cffff00ff团队:|r 击杀小兵与野怪获得的金钱+10%",
        code = function(this)
            GetGold(this.player, 250)
            Event("正补",
                function(data)
                    if GetPlayerTeam(data.p1) == this.team then
                        data.gold = data.gold + data.ogold * 0.1
                    end
                end
            )
        end
    }
    
    InitProject{
        name = "学霸",
        art = "BTNSorceressAdept.blp",
        tip = "\
|cffff00ff英雄:|r 获得300经验\n\
|cffff00ff团队:|r 通过战斗获得的经验+10%",
        code = function(this)
            AddHeroXP(this.hero, 300, true, this.name)
            Event("获得经验",
                function(data)
                    if data.reason ~= this.name and GetPlayerTeam(GetOwningPlayer(data.unit)) == this.team then
                        data.xp = data.xp + data.oxp * 0.1
                    end
                end
            )
        end
    }
    
    InitProject{
        name = "官二代",
        art = "BTNControlMagic.blp",
        tip = "\
|cffff00ff英雄:|r 获得200节操\n\
|cffff00ff团队:|r 每秒节操+0.15",
        code = function(this)
            AddPlayerFood(this.player, 200)
            FoodS[this.team] = FoodS[this.team] + 0.15
        end
    }
    
    --第2层
    InitProject{
        name = "砍人",
        art = "BTNArcaniteMelee.blp",
        tip = "\
|cffff00ff英雄:|r 对敌方英雄造成的伤害提高5%\n\
|cffff00ff团队:|r 小兵对英雄造成的伤害提高5点",
        code = function(this)
            Event("伤害加成",
                function(damage)
                    if IsHero(damage.to) then
                        if damage.from == this.hero then
                            damage.damage = damage.damage + damage.odamage * 0.05
                        elseif damage.from and GetPlayerTeam(GetOwningPlayer(damage.from)) == this.team then
                            damage.damage = damage.damage + 5
                        end
                    end
                end
            )
        end
    }
    
    InitProject{
        name = "刷兵",
        art = "BTNOrcMeleeUpTwo.blp",
        tip = "\
|cffff00ff英雄:|r 对小兵与野怪造成的伤害提高15%\n\
|cffff00ff团队:|r 小兵的护甲与抗性提高5点",
        code = function(this)
            Event("伤害加成", "刷兵",
                function(data)
                    if data.event == "伤害加成" then
                        local damage = data
                        if damage.from == this.hero and not IsHero(damage.to) and not IsUnitType(damage.to, UNIT_TYPE_STRUCTURE) then
                            damage.damage = damage.damage + damage.odamage * 0.15
                        end
                    elseif data.event == "刷兵" then
                        if data.team == this.team then
                            Def(data.unit, 5)
                            Ant(data.unit, 5)
                        end
                    end
                end
            )
        end
    }
    
    InitProject{
        name = "拆塔",
        art = "BTNFireRocks.blp",
        tip = "\
|cffff00ff英雄:|r 对建筑物造成的伤害提高25%\n\
|cffff00ff团队:|r 建筑物的护甲与抗性提高20点",
        code = function(this)
            Event("伤害加成",
                function(damage)
                    if damage.from == this.hero and IsUnitType(damage.to, UNIT_TYPE_STRUCTURE) then
                        damage.damage = damage.damage + damage.odamage * 0.25
                    end
                end
            )
            for _, u in ipairs(ComBuildings) do
                if GetPlayerTeam(GetOwningPlayer(u)) == this.team then
                    Def(u, 20)
                    Ant(u, 20)
                end
            end
        end
    }
    
    --第3层
    InitProject{
        name = "强化侦查守卫",
        art = "BTNSentryWard.blp",
        tip = "\
|cffff00ff英雄:|r 侦查守卫拥有空中视野\n\
|cffff00ff团队:|r 放置侦查守卫所花费的节操减少10点",
        code = function(this)
            local ps = GetAllyUsers(this.player)
            for i = 1, 5 do
                local id = GetPlayerId(ps[i])
                local pda = PDA[id]
                if pda then
                    local skills = PDASkills[pda]
                    local skill = skills["侦查守卫"]
                    skill.cost = skill.cost - 10
                    if skill.player == this.player then
                        skill.tip = "放置一个拥有200生命值的隐形守卫监视附近的区域,持续180秒.\
该守卫在白天拥有1200的|cffffcc00空中视野|r,在晚上拥有300的|cffffcc00空中视野|r."
                        local ab = japi.EXGetUnitAbility(pda, skill.id)
                        if SELFP == this.player then
                            japi.EXSetAbilityDataString(ab, 1, 218, string.format("|cffffcc00%d|r 存在感\n\n%s\n\n|cffff00ff施放距离|r %s", skill.cost, skill.tip, skill.rng or "全地图"))
                        end
                    end
                    RefreshTips(pda)
                end
            end
            Mark(this.player, this.name, true)
        end
    }
    
    InitProject{
        name = "强化岗哨守卫",
        art = "BTNBluesentryward.blp",
        tip = "\
|cffff00ff英雄:|r 岗哨守卫在晚上拥有900的视野\n\
|cffff00ff团队:|r 放置岗哨守卫所花费的节操减少10点",
        code = function(this)
            local ps = GetAllyUsers(this.player)
            for i = 1, 5 do
                local id = GetPlayerId(ps[i])
                local pda = PDA[id]
                if pda then
                    local skills = PDASkills[pda]
                    local skill = skills["岗哨守卫"]
                    skill.cost = skill.cost - 10
                    if skill.player == this.player then
                        skill.tip = "放置一个拥有200生命值的隐形守卫监视附近的区域,持续120秒.\
该守卫在白天拥有300的视野,在晚上拥有|cffffcc00900|r的视野.\
该守卫可以看到900范围内的隐身单位."
                        local ab = japi.EXGetUnitAbility(pda, skill.id)
                        japi.EXSetAbilityDataString(ab, 1, 218, skill.tip)
                        if SELFP == this.player then
                            japi.EXSetAbilityDataString(ab, 1, 218, string.format("|cffffcc00%d|r 存在感\n\n%s\n\n|cffff00ff施放距离|r %s", skill.cost, skill.tip, skill.rng or "全地图"))
                        end
                    end
                    RefreshTips(pda)
                end
            end
            Mark(this.player, this.name, true)
        end
    }
    
    InitProject{
        name = "强化屏障",
        art = "BTNInvulnerable.blp",
        tip = "\
|cffff00ff英雄:|r 屏障期间反射所有伤害\n\
|cffff00ff团队:|r 开启屏障所花费的节操减少100点",
        code = function(this)
            local ps = GetAllyUsers(this.player)
            for i = 1, 5 do
                local id = GetPlayerId(ps[i])
                local pda = PDA[id]
                if pda then
                    local skills = PDASkills[pda]
                    local skill = skills["屏障"]
                    skill.cost = skill.cost - 100
                    if skill.player == this.player then
                        skill.tip = "开启屏障,使友方建筑物在接下来的5秒内免疫|cffffcc00并反射|r一切伤害.\
己方玩家共享180秒冷却时间.\
英雄处于死亡状态时也可以使用该技能."
                        local ab = japi.EXGetUnitAbility(pda, skill.id)
                        japi.EXSetAbilityDataString(ab, 1, 218, skill.tip)
                        if SELFP == this.player then
                            japi.EXSetAbilityDataString(ab, 1, 218, string.format("|cffffcc00%d|r 存在感\n\n%s\n\n|cffff00ff施放距离|r %s", skill.cost, skill.tip, skill.rng or "全地图"))
                        end
                    end
                    RefreshTips(pda)
                end
            end
            Mark(this.player, this.name, true)
        end
    }
    
    --第4层
    InitProject{
        name = "屠戮",
        art = "BTNClawsOfAttack.blp",
        tip = "\
|cffff00ff英雄:|r 杀死非英雄单位时,你回复该单位最大生命值5%的生命值.你的生命值每损失1%,回复量就提升0.05%\n\
|cffff00ff团队:|r 攻击吸血+1%,技能吸血+1.5%",
        code = function(this)
            --英雄部分
            Event("死亡",
                function(data)
                    if data.killer == this.hero and not IsHero(data.unit) then
                        if IsUnitAlive(this.hero) then
                            local r = 0.05 + 0.05 * (1 - GetUnitState(this.hero, UNIT_STATE_LIFE) / GetUnitState(this.hero, UNIT_STATE_MAX_LIFE))
                            Heal(this.hero, this.hero, r * GetUnitState(data.unit, UNIT_STATE_MAX_LIFE), {healReason = this.name})
                        end
                    end
                end
            )
            --团队部分
            local ps = GetAllyUsers(this.hero)
            for i = 1, 5 do
                local id = GetPlayerId(ps[i])
                local hero = Hero[id]
                if hero then
                    AttackStealLife(hero, 1)
                    SkillStealLife(hero, 1.5)
                end
            end
        end
    }
    
    InitProject{
        name = "秘法",
        art = "BTNBrilliance.blp",
        tip = "\
|cffff00ff英雄:|r 使用英雄技能时,你回复该技能消耗的20%法力值.你的法力值每损失1%,恢复量就提升0.3%\n\
|cffff00ff团队:|r 冷却缩减+2%",
        code = function(this)
            --英雄
            Event("发动英雄技能",
                function(data)
                    if data.unit == this.hero then
                        local skill = data.data
                        local mana = skill:get("mana")
                        if mana > 0 then
                            local mp = GetUnitState(this.hero, UNIT_STATE_MANA)
                            local mmp = GetUnitState(this.hero, UNIT_STATE_MAX_MANA)
                            local r = 0.2 + 0.3 * (1 - mp / mmp)
                            SetUnitState(this.hero, UNIT_STATE_MANA, mp + mana * r)
                        end
                    end
                end
            )
            --团队
            local ps = GetAllyUsers(this.hero)
            for i = 1, 5 do
                local id = GetPlayerId(ps[i])
                local hero = Hero[id]
                if hero then
                    SetCoolDown(hero, 2)
                end
            end
        end
    }
    
    InitProject{
        name = "荒芜",
        art = "BTNAuraOfDarkness.blp",
        tip = "\
|cffff00ff英雄:|r 敌方英雄身边250范围内没有他的友方单位时,你的普通攻击可以额外造成相当于其最大生命值3%的神圣伤害\n\
|cffff00ff团队:|r 存在感获得率+10%",
        code = function(this)
            --英雄
            Event("伤害效果",
                function(damage)
                    if damage.from == this.hero and damage.weapon and IsHero(damage.to) then
                        local p2 = GetOwningPlayer(damage.to)
                        local flag = true
                        forRange(damage.to, 250,
                            function(u)
                                if u ~= damage.to and IsUnitAlive(u) and IsUnitAlly(u, p2) then
                                    flag = false
                                end
                            end
                        )
                        if flag then
                            local d = 0.03 * GetUnitState(damage.to, UNIT_STATE_MAX_LIFE)
                            Damage(damage.from, damage.to, d, false, false, {damageReason = this.name})
                        end
                    end
                end
            )
            --团队
            local ps = GetAllyUsers(this.player)
            for i = 1, 5 do
                local id = GetPlayerId(ps[i])
                DamageWoodS[id] = DamageWoodS[id] + 0.1
            end
        end
    }
    
    --第5层
    InitProject{
        name = function(this)
            this.name = findSkillData(this.hero, 1).name
        end,
        art = function(this)
            local art = findSkillData(this.hero, 1).art[1]
            this.art = "ReplaceableTextures\\CommandButtons\\" .. art
            this.disart = "ReplaceableTextures\\CommandButtonsDisabled\\DIS" .. art
        end,
        tip = function(this)
            this.tip = "\n|cffff00ff英雄:|r " .. findSkillData(this.hero, 1).researchtip
        end,
        code = function(this)
            local skill = findSkillData(this.hero, 1)
            skill.research = true
            if skill.events["研发"] then
                skill.event = "研发"
                skill:code()
            end
            SetSkillTip(this.hero, 1)
            SetLearnSkillTip(this.hero, 1)
            RefreshTips()
        end
    }
    
    InitProject{
        name = function(this)
            this.name = findSkillData(this.hero, 2).name
        end,
        art = function(this)
            local art = findSkillData(this.hero, 2).art[1]
            this.art = "ReplaceableTextures\\CommandButtons\\" .. art
            this.disart = "ReplaceableTextures\\CommandButtonsDisabled\\DIS" .. art
        end,
        tip = function(this)
            this.tip = "\n|cffff00ff英雄:|r " .. findSkillData(this.hero, 2).researchtip
        end,
        code = function(this)
            local skill = findSkillData(this.hero, 2)
            skill.research = true
            if skill.events["研发"] then
                skill.event = "研发"
                skill:code()
            end
            SetSkillTip(this.hero, 2)
            SetLearnSkillTip(this.hero, 2)
            RefreshTips()
        end
    }
    
    InitProject{
        name = function(this)
            this.name = findSkillData(this.hero, 3).name
        end,
        art = function(this)
            local art = findSkillData(this.hero, 3).art[1]
            this.art = "ReplaceableTextures\\CommandButtons\\" .. art
            this.disart = "ReplaceableTextures\\CommandButtonsDisabled\\DIS" .. art
        end,
        tip = function(this)
            this.tip = "\n|cffff00ff英雄:|r " .. findSkillData(this.hero, 3).researchtip
        end,
        code = function(this)
            local skill = findSkillData(this.hero, 3)
            skill.research = true
            if skill.events["研发"] then
                skill.event = "研发"
                skill:code()
            end
            SetSkillTip(this.hero, 3)
            SetLearnSkillTip(this.hero, 3)
            RefreshTips()
        end
    }
    
    --第6层
    InitProject{
        name = "回到战场",
        art = "BTNability_rogue_sprint.blp",
        tip = "\
|cffff00ff英雄:|r 英雄复活后移动速度增加1000点.离开基地后持续10秒",
        code = function(this)
            Event("复活",
                function(data)
                    if this.hero == data.unit then
                        MoveSpeed(data.unit, 1000)
                        local time = 10
                        local rect = HomeRect[this.team]
                        Loop(0.5,
                            function()
                                if not RectContainsUnit(rect, data.unit) then
                                    time = time - 0.5
                                    if time <= 0 then
                                        EndLoop()
                                        MoveSpeed(data.unit, -1000)
                                    end
                                end
                            end
                        )
                    end
                end
            )
        end
    }
    
    InitProject{
        name = "百折不挠",
        art = "BTNReincarnation.blp",
        tip = "\
|cffff00ff英雄:|r 英雄的复活时间减少33%",
        code = function(this)
            Event("阵亡损失",
                function(data)
                    if data.unit == this.hero then
                        data.time = data.time - data.otime * 0.33
                    end
                end
            )
        end
    }
    
    InitProject{
        name = "越战越勇",
        art = "BTNRTZS.blp",
        tip = "\
|cffff00ff英雄:|r 英雄复活后生命值上限提高100%.离开基地后持续30秒",
        code = function(this)
            Event("复活",
                function(data)
                    if data.unit == this.hero then
                        local hp = GetUnitState(data.unit, UNIT_STATE_MAX_LIFE)
                        MaxLife(data.unit, hp)
                        local rect = HomeRect[this.team]
                        local time = 30
                        Loop(1,
                            function()
                                if not RectContainsUnit(rect, data.unit) then
                                    time = time - 1
                                    if time <= 0 then
                                        EndLoop()
                                        MaxLife(data.unit, - hp)
                                    end
                                end
                            end
                        )
                    end
                end
            )
        end
    }
    
    --第7层
    InitProject{
        name = "机体压制",
        art = "BTNMetamorphosis.blp",
        tip = "\
|cffff00ff英雄:|r 每等级额外获得1点全属性\n\
|cffff00ff团队:|r 每等级额外获得1点主属性",
        code = function(this)
            local ps = GetAllyUsers(this.player)
            for i = 1, 5 do
                local id = GetPlayerId(ps[i])
                local hero = Hero[id]
                if hero then
                    local level = GetHeroLevel(hero)
                    local main = GetMain(hero)
                    if main == "力量" then
                        Sai(hero, level)
                    elseif main == "敏捷" then
                        Sai(hero, 0, level)
                    elseif main == "智力" then
                        Sai(hero, 0, 0, level)
                    end
                    if hero == this.hero then
                        Sai(hero, 1 * level, 1 * level, 1 * level)
                    end
                end
            end
            Event("升级",
                function(data)
                    if data.unit == this.hero then
                        Sai(data.unit, 1, 1, 1)
                    end
                    if GetPlayerTeam(GetOwningPlayer(data.unit)) == this.team then
                        local main = GetMain(hero)
                        if main == "力量" then
                            Sai(hero, 1)
                        elseif main == "敏捷" then
                            Sai(hero, 0, 1)
                        elseif main == "智力" then
                            Sai(hero, 0, 0, 1)
                        end
                    end
                end
            )
        end
    }
    
    InitProject{
        name = "操作压制",
        art = "BTNEvasion.blp",
        tip = "\
|cffff00ff英雄:|r 当你脱离敌人的视野时,移动速度增加100点,持续3秒.重复获得该效果时刷新持续时间.\n\
|cffff00ff团队:|r 移动速度增加10点",
        code = function(this)
            local ps = GetAllyUsers(this.player)
            for i = 1, 5 do
                local id = GetPlayerId(ps[i])
                local hero = Hero[id]
                if hero then
                    MoveSpeed(hero, 10)
                end
            end
            Event("可见度",
                function(data)
                    if data.unit == this.hero and data.reason == false then
                        if not this.timer then
                            this.timer = CreateTimer()
                            MoveSpeed(this.hero, 100)
                        end
                        TimerStart(this.timer, 3, false,
                            function()
                                DestroyTimer(this.timer)
                                this.timer = nil
                                MoveSpeed(this.hero, -100)
                            end
                        )
                    end
                end
            )
        end
    }
    
    InitProject{
        name = "智商压制",
        art = "BTNBlink.blp",
        tip = "\
|cffff00ff英雄:|r 每当对方的生命值百分比比你的生命值百分比高出1%,你对其造成的伤害也就提高1%\n\
|cffff00ff团队:|r 每秒工资+0.2,每秒节操+0.1",
        code = function(this)
            local ps = GetAllyUsers(this.player)
            for i = 1, 5 do
                Wage(ps[i], 0.2)
            end
            FoodS[this.team] = FoodS[this.team] + 0.1
            Event("伤害加成",
                function(damage)
                    if damage.from == this.hero then
                        local r1 = GetUnitState(damage.from, UNIT_STATE_LIFE) / GetUnitState(damage.from, UNIT_STATE_MAX_LIFE)
                        local r2 = GetUnitState(damage.to, UNIT_STATE_LIFE) / GetUnitState(damage.to, UNIT_STATE_MAX_LIFE)
                        local r = r2 - r1
                        if r > 0 then
                            damage.damage = damage.damage + damage.odamage * r
                        end
                    end
                end
            )
        end
    }
    
    --第8层
    InitProject{
        name = "复苏之风",
        art = "BTNCommand.blp",
        tip = "\
|cffff00ff英雄:|r 当陷入无法控制的状态时,在10秒内恢复15%最大生命值.重复获得该效果时刷新持续时间\n\
|cffff00ff团队:|r 所受负面状态的持续时间变为90%(乘法叠加)",
        code = function(this)
            --英雄部分
            local timer
            local count
            Event("无法控制",
                function(data)
                    if data.to == this.hero then
                        count = 10
                        if not timer then
                            timer = Loop(10,
                                function()
                                    count = count - 1
                                    if count == 0 then
                                        DestroyTimer(timer)
                                        timer = nil
                                    end
                                    Heal(this.hero, this.hero, 0.015 * GetUnitState(this.hero, UNIT_STATE_MAX_LIFE), {healReason = this.name})
                                end
                            )
                        end
                    end
                end
            )
            --团队部分
            Event("debuff",
                function(data)
                    if GetPlayerTeam(GetOwningPlayer(data.to)) == this.team then
                        data.time = data.time * 0.9
                    end
                end
            )
        end
    }
    
    InitProject{
        name = "浴火重生",
        art = "BTNVampiricAura.blp",
        tip = "\
|cffff00ff英雄:|r 受到伤害后生命值若低于30%,在30秒内恢复30%最大生命值.该效果每60秒只能发动一次\n\
|cffff00ff团队:|r 所受治疗效果增加10%",
        code = function(this)
            --英雄部分
            local lastTime = -60
            Event("伤害结算后",
                function(damage)
                    if damage.to == this.hero and GetTime() - lastTime > 60 and GetUnitState(this.hero, UNIT_STATE_LIFE) / GetUnitState(this.hero, UNIT_STATE_MAX_LIFE) < 0.3 then
                        lastTime = GetTime()
                        local count = 30
                        Loop(1,
                            function()
                                count = count - 1
                                if count == 0 then
                                    EndLoop()
                                end
                                Heal(this.hero, this.hero, 0.01 * GetUnitState(this.hero, UNIT_STATE_MAX_LIFE), {healReason = this.name})
                            end
                        )
                    end
                end
            )
            --团队部分
            Event("治疗加成",
                function(heal)
                    if GetPlayerTeam(GetOwningPlayer(heal.to)) == this.team then
                        heal.heal = heal.heal + 0.1 * heal.oheal
                    end
                end
            )
        end
    }
    
    InitProject{
        name = "和谐之道",
        art = "BTNDevotion.blp",
        tip = "\
|cffff00ff英雄:|r 不在敌方视野内时,每秒恢复1%最大生命值\n\
|cffff00ff团队:|r 不在敌方视野内时,受到的伤害变为80%(乘法叠加)",
        code = function(this)
            --英雄部分
            Loop(1,
                function()
                    if IsUnitType(this.hero, UNIT_TYPE_ANCIENT) then
                        Heal(this.hero, this.hero, 0.01 * GetUnitState(this.hero, UNIT_STATE_MAX_LIFE), {healReason = this.name})
                    end
                end
            )
            --团队部分
            Event("伤害减免",
                function(damage)
                    if IsUnitType(this.hero, UNIT_TYPE_ANCIENT) and GetPlayerTeam(GetOwningPlayer(damage.to)) == this.team then
                        damage.damage = damage.damage * 0.8
                    end
                end
            )
        end
    }
    
    --第9层
    InitProject{
        name = function(this)
            this.name = findSkillData(this.hero, 4).name .. 1
        end,
        art = function(this)
            local art = findSkillData(this.hero, 4).art[1]
            this.art = "ReplaceableTextures\\CommandButtons\\" .. art
            this.disart = "ReplaceableTextures\\CommandButtonsDisabled\\DIS" .. art
        end,
        tip = function(this)
            this.tip = "\n|cffff00ff英雄:|r " .. findSkillData(this.hero, 4).researchtip[1]
        end,
        code = function(this)
            local skill = findSkillData(this.hero, 4)
            if not skill.research then
                skill.research = {}
            end
            skill.research[1] = true
            if skill.events["研发"] then
                skill.event = "研发"
                skill.lastResearch = 1
                skill:code()
            end
            SetSkillTip(this.hero, 4)
            SetLearnSkillTip(this.hero, 4)
            RefreshTips()
        end
    }
    
    InitProject{
        name = function(this)
            this.name = findSkillData(this.hero, 4).name .. 2
        end,
        art = function(this)
            local art = findSkillData(this.hero, 4).art[1]
            this.art = "ReplaceableTextures\\CommandButtons\\" .. art
            this.disart = "ReplaceableTextures\\CommandButtonsDisabled\\DIS" .. art
        end,
        tip = function(this)
            this.tip = "\n|cffff00ff英雄:|r " .. findSkillData(this.hero, 4).researchtip[2]
        end,
        code = function(this)
            local skill = findSkillData(this.hero, 4)
            if not skill.research then
                skill.research = {}
            end
            skill.research[2] = true
            if skill.events["研发"] then
                skill.event = "研发"
                skill.lastResearch = 2
                skill:code()
            end
            SetSkillTip(this.hero, 4)
            SetLearnSkillTip(this.hero, 4)
            RefreshTips()
        end
    }
    
    InitProject{
        name = function(this)
            this.name = findSkillData(this.hero, 4).name .. 3
        end,
        art = function(this)
            local art = findSkillData(this.hero, 4).art[1]
            this.art = "ReplaceableTextures\\CommandButtons\\" .. art
            this.disart = "ReplaceableTextures\\CommandButtonsDisabled\\DIS" .. art
        end,
        tip = function(this)
            this.tip = "\n|cffff00ff英雄:|r " .. findSkillData(this.hero, 4).researchtip[3]
        end,
        code = function(this)
            local skill = findSkillData(this.hero, 4)
            if not skill.research then
                skill.research = {}
            end
            skill.research[3] = true
            if skill.events["研发"] then
                skill.event = "研发"
                skill.lastResearch = 3
                skill:code()
            end
            SetSkillTip(this.hero, 4)
            SetLearnSkillTip(this.hero, 4)
            RefreshTips()
        end
    }
    
    --第10层
    InitProject{
        name = "斩杀",
        art = "BTNcoupdegrace.blp",
        tip = "\
|cffff00ff英雄:|r 普通攻击对英雄造成其最大生命值15%的神圣伤害.该效果每15秒只能触发一次",
        code = function(this)
            --英雄效果
            local lastTime = -60
            Event("伤害效果",
                function(damage)
                    if damage.weapon and damage.from == this.hero and IsHero(damage.to) and GetTime() - lastTime > 10 then
                        lastTime = GetTime()
                        DestroyEffect(AddSpecialEffectTarget("Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl", damage.to, "origin"))
                        Damage(damage.from, damage.to, 0.15 * GetUnitState(damage.to, UNIT_STATE_MAX_LIFE), false, false, {damageReason = this.name})
                    end
                end
            )
        end
    }
    
    InitProject{
        name = "辉耀",
        art = "BTNinv_sword_25.blp",
        tip = "\
|cffff00ff英雄:|r 每秒对600范围内的敌方英雄造成其最大生命值1%的神圣伤害",
        code = function(this)
            Loop(1,
                function()
                    if IsUnitAlive(this.hero) then
                        forRange(this.hero, 600,
                            function(u)
                                if IsHero(u) and IsUnitEnemy(u, this.player) then
                                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\StaffOfPurification\\PurificationTarget.mdl", u, "origin"))
                                    Damage(this.hero, u, 0.01 * GetUnitState(u, UNIT_STATE_MAX_LIFE), false, false, {damageReason = this.name})
                                end
                            end
                        )
                    end
                end
            )
        end
    }
    
    InitProject{
        name = "淘汰",
        art = "BTNability_gouge.blp",
        tip = "\
|cffff00ff英雄:|r 每点主属性额外提供1点的攻击力与技能强度",
        code = function(this)
            AddSpecialEffectTarget("war3mapImported\\WaterHands.mdx", this.hero, "hand left")
            AddSpecialEffectTarget("war3mapImported\\WaterHands.mdx", this.hero, "hand right")
            local main = GetMain(this.hero)
            local n
            if main == "力量" then
                n = GetHeroStr(this.hero, true)
            elseif main == "敏捷" then
                n = GetHeroInt(this.hero, true)
            elseif main == "智力" then
                n = GetHeroAgi(this.hero, true)
            end
            Attack(this.hero, n)
            AddAP(this.hero, n)
            Event("属性变化",
                function(data)
                    if data.unit == this.hero then
                        local main = GetMain(this.hero)
                        local n
                        if main == "力量" then
                            n = data.str
                        elseif main == "敏捷" then
                            n = data.agi
                        elseif main == "智力" then
                            n = data.int
                        end
                        n = n
                        Attack(this.hero, n)
                        AddAP(this.hero, n)
                    end
                end
            )
        end
    }
    
