    
    local lastTime = {}
    
    Event("伤害后",
        function(damage)
            if damage.from and IsHero(damage.to) and IsUser(GetOwningPlayer(damage.from)) then
                local p1 = GetOwningPlayer(damage.to)
                if IsUnitEnemy(damage.from, p1) and IsUnitVisible(damage.from, p1) and GetBetween(damage.from, damage.to) < 1000 then
                    local time = GetTime()
                    if not lastTime[damage.to] or time - lastTime[damage.to] > 2 then
                        lastTime[damage.to] = time
                        local units = {}
                        local x = GetPlayerTeam(p1)
                        local p = Com[x]
                        forRange(damage.to, 400,
                            function(u)
                                if GetOwningPlayer(u) == p and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_DEAD) then
                                    table.insert(units, u)
                                    IssueTargetOrder(u, "attack", damage.from)
                                end
                            end
                        )
                        forRange(damage.from, 400,
                            function(u)
                                if GetOwningPlayer(u) == p and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_DEAD) then
                                    table.insert(units, u)
                                    IssueTargetOrder(u, "attack", damage.from)
                                end
                            end
                        )
                        Wait(2,
                            function()
                                for _, u in ipairs(units) do
                                    if IsUnitAlive(u) then
                                        local u2 = Mark(u, "专注攻击目标")
                                        if u2 then
                                            IssueTargetOrder(u, "attack", u2)
                                        else
                                            local y = Mark(u, "分路")
                                            local z = Mark(u, "目标")
                                            if y and z then
                                                local point = ArmyPoint[x][y][z]
                                                if point then
                                                    IssuePointOrderLoc(u, "attack", point)
                                                else
                                                    Debug("<保护英雄后重新攻击>没有找到攻击目标")
                                                end
                                            else
                                                Debug("<保护英雄后重新攻击>没有找到分路信息:" .. GetUnitName(u))
                                            end
                                        end
                                    end
                                end
                            end
                        )
                    end
                end
            end
        end
    )
    
