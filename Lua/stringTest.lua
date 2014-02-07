
    stringTest = function(ss, i)
        local s = string.split(ss, " ")
        s[1] = string.lower(s[1])
        if s[1] == ".lv" then
            SetHeroLevel(Hero[i], s[2] or 20, true)
        elseif s[1] == ".startgame" then
            StartGameIn(s[2] or 0)
        elseif s[1] == ".noarmy" then
            StartArmy = function()end
        elseif s[1] == ".cd" then
            UnitResetCooldown(Hero[i])
        elseif s[1] == ".hp" then
            SetUnitState(Hero[i], UNIT_STATE_LIFE, s[2] or 1000000)
            SetUnitState(Hero[i], UNIT_STATE_MANA, s[3] or 1000000)
        elseif s[1] == ".item" then
            AddItem(Hero[i], s[2])
        elseif s[1] == ".gold" then
            GetGold(Player(i), s[2] or 1000000, s[2] or 1000000)
            AddPlayerFood(Player(i), s[2] or 100000)
        elseif s[1] == ".damage" then
            Damage(Hero[i], Hero[i], tonumber(s[2] or 100), false, false, {damageReason = "测试指令"})
        elseif s[1] == ".liferecover" then
            LifeRecover(Hero[i], tonumber(s[2] or 0))
        elseif s[1] == ".move" then
            Sync(Player(i), GetCameraTargetPositionLoc(),
                function(loc)
                    SetUnitXY(Hero[i], loc)
                end
            )
        elseif s[1] == ".icu" then
            CreateFogModifierRectBJ(true, Player(i), FOG_OF_WAR_VISIBLE, GetPlayableMapRect())
        elseif s[1] == ".allhave" then
            for x = 0, 15 do
                SetPlayerAlliance(Player(x), Player(i), ALLIANCE_SHARED_CONTROL, true)
            end
        elseif s[1] == ".ms" then
            MoveSpeed(Hero[i], s[2] or 0)
        elseif s[1] == ".pairs" then
            PauseTimer(visibleTimer)
        elseif s[1] == ".research" then
            local level = GetResearchLevel(i)
            for x = 1, 99 do
                level[x] = 99
            end
        end
    end

