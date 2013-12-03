    
    Event("死亡",
        function(data)
            local u1 = data.killer
            local u2 = data.unit
            
            if GetUnitAbilityLevel(u2, |Aloc|) == 1 --死亡单位是蝗虫
            or IsUnitIllusion(u2) then--死亡单位是镜像
                return
            end
            
            if IsUnitType(u2, UNIT_TYPE_HERO) and not IsUnitType(u2, UNIT_TYPE_SUMMONED) then --如果是英雄且不是召唤单位,则转到HeroKill中
                KillHero(u1, u2)
                return
            end
            
            if not u1 then return end --如果击杀者不存在
            
            local p1 = GetOwningPlayer(u1)
            local p2 = GetOwningPlayer(u2)
            
            if IsUnitEnemy(u2, p1) then --被杀者是击杀者的敌人
                local gold = GetUnitPointValue(u2)
                local kill = {gold = gold, ogold = gold, wood = 0, u1 = u1, u2 = u2, p1 = p1, p2 = p2} --可以拿到的钱
                toEvent("正补", kill) --发起正补事件,用于称号等效果修改收入
                if IsUser(p1) then
                    GetGold(kill.p1, kill.gold, kill.wood, kill.u2)
                else
                    --增加节操
                    AddFood(GetPlayerTeam(p1), 1)
                end
            else
                local kill = {gold = 0, wood = 0, u1 = u1, u2 = u2, p1 = p1, p2 = p2} --可以拿到的钱
                toEvent("反补", kill) --发起反补事件,用于称号等效果修改收入
                if IsUser(p1) then
                    GetGold(kill.p1, kill.gold, kill.wood)
                    Text{
                        word = string.format("%s%s|r", Color[GetPlayerId(p1)], Lang["!"]),
                        size = 16,
                        unit = u2,
                        speed = {58, 90},
                        life = {2, 3},
                    }
                end
            end
            
        end
    )
    
    ArmyEXP = {
        [0] = 0,
        50,
        75,
        125,
        200,
        300,
        425,
        575,
        750,
        950,
    }
    
    --获得经验
    Event("正补", "反补",
        function(this)
            local exp
            local lv = GetUnitLevel(this.u2)
            local t = {}
            if this.event == "正补" then
                exp = ArmyEXP[lv]
                forRange(this.u2, 1200,
                    function(u)
                        if IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitType(u, UNIT_TYPE_SUMMONED) and IsUnitAlly(u, this.p1) then
                            if GetHeroLevel(u) ~= 20 then
                                table.insert(t, u)
                            end
                        end
                    end
                )
            else
                exp = ArmyEXP[lv] * 0.5
                forRange(this.u2, 1200,
                    function(u)
                        if IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitType(u, UNIT_TYPE_SUMMONED) and IsUnitEnemy(u, this.p1) then
                            if GetHeroLevel(u) ~= 20 then
                                table.insert(t, u)
                            end
                        end
                    end
                )
            end
            local count = #t
            if count == 0 then return end
            exp = exp / count
            for _,u in ipairs(t) do
                AddHeroXP(u, exp, true)
            end
        end
    )

