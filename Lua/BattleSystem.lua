    
    local trg = CreateTrigger()
    
    BattleSkills = {}
    
    InitBattle = function(data)
        BattleSkills[data.name] = data
        BattleSkills[data.id] = data
        table.insert(BattleSkills, data)
    end
    
    require "LoadSkills.lua"
    require "BattleSkills.lua"
    
    PDASkills = {}
    
    
    --注册女仆
    InitBattlePDA = function(u)
        
        TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_SPELL_EFFECT)
        
        local p = GetOwningPlayer(u)
        local id = GetPlayerId(p)
        local tid = GetPlayerTeam(p)
        
        local skills = {}
        PDASkills[u] = skills
        
        for i, data in ipairs(BattleSkills) do
            local data = table.copy(data, true)
            data.unit = u
            data.hero = Hero[id]
            data.player = p
            data.team = tid
            skills[data.name] = data
            skills[data.id] = data
            skills[i] = data
            UnitAddAbility(u, data.id)
            local ab = japi.EXGetUnitAbility(u, data.id)
            if p == SELFP then
                japi.EXSetAbilityDataString(ab, 1, 218, string.format("|cffffcc00%d|r 存在感\n\n%s\n\n|cffff00ff施放距离|r %s", data.cost, data.tip, data.rng or "全地图"))
            end
        end
        
        RefreshTips(u)
    end
    
    TriggerAddCondition(trg, Condition(
        function()
            local u = GetTriggerUnit()
            local id = GetSpellAbilityId()
            local skills = PDASkills[u]
            local skill = skills[id]
            if not skill then return end
            local wood = GetPlayerState(skill.player, PLAYER_STATE_RESOURCE_LUMBER)
            skill.target = GetSpellTargetUnit() or GetSpellTargetLoc()
            if wood < skill.cost then
                printTo(skill.player, "|cffffcc00你的存在感不足!|r")
                IssueImmediateOrder(u, "stop")
                if skill.player == SELFP then
                    StartSound(gg_snd_Error)
                end
            else
                local error = skill:code()
                if error then
                    printTo(skill.player, "|cffffcc00" .. error .. "|r")
                    IssueImmediateOrder(u, "stop")
                    if skill.player == SELFP then
                        StartSound(gg_snd_Error)
                    end
                else
                    SetPlayerState(skill.player, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(skill.player, PLAYER_STATE_RESOURCE_LUMBER) - skill.cost)
                end
            end
            
            if SELFP == skill.player then
                ClearSelection()
                SelectUnit(Hero[GetPlayerId(skill.player)], true)
            end
        end
    ))
    
