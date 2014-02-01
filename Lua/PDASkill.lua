    local stateString = "\
|cffffcc00生命值|r     %d/%d (|cff11ff11%+.2f|r)\
|cffffcc00法力值|r     %d/%d (|cff11ff11%+.2f|r)\
\
|cffffcc00攻击速度|r  %.2f (最大500)\
|cffffcc00移动速度|r  %.2f (|cff11ff11%+.2f|r) (最大1000)\
\
|cffffcc00护甲|r       %d (|cff11ff11%.2f%%|r)\
|cffffcc00抗性|r       %d (|cff11ff11%.2f%%|r)\
\
|cffffcc00攻击强度|r  %d\
|cffffcc00技能强度|r  %.2f\
\
|cffffcc00护甲穿透|r  %.2f/%.2f%%\
|cffffcc00冷却缩减|r  %.2f%% (最大50%%)\
\
|cffffcc00暴击率|r     %.2f%%\
|cffffcc00暴击系数|r  %.2f%%\
\
|cffffcc00攻击吸血|r  %.2f%%/%.2f\
|cffffcc00技能吸血|r  %.2f%% (群体伤害为%.2f%%)\
\
|cffffcc00每秒工资|r  %.2f\
|cffffcc00每秒节操|r  %.2f\
|cffffcc00存在感获得率|r %d%%\
"

    local RefreshState = function(i)
        local pda = PDA[i]
        local u = Hero[i]
        local ab = japi.EXGetUnitAbility(pda, |A18D|)
        local hp, mp = GetRecover(u)
        local def, ant = GetUnitState(u, ConvertUnitState(0x20)), GetAnt(u)
        local dr, ar = 100 - 10000 / (100 + def), 100 - 10000 / (100 + ant)
        local tid = GetPlayerTeam(GetOwningPlayer(u))
        local str = string.format(stateString,
            GetUnitState(u, UNIT_STATE_LIFE), GetUnitState(u, UNIT_STATE_MAX_LIFE), hp,--生命值
            GetUnitState(u, UNIT_STATE_MANA), GetUnitState(u, UNIT_STATE_MAX_MANA), mp,--法力值
            (Mark(u, "额外攻击速度") or 0) * 100 + 100, --额外攻击速度
            GetUnitMoveSpeed(u), Mark(u, "额外移动速度") or 0, --额外移动速度
            def, dr, --护甲
            ant, ar, --抗性
            GetAD(u), --攻击强度
            GetAP(u), --技能强度
            Mark(u, "护甲穿透1") or 0, Mark(u, "护甲穿透2") or 0, --护甲穿透
            Mark(u, "冷却缩减") or 0, --冷却缩减
            Mark(u, "暴击率") or 0, --暴击率
            200 + (Mark(u, "暴击系数") or 0), --暴击系数
            Mark(u, "攻击吸血") or 0, Mark(u, "攻击吸血2") or 0, --攻击吸血
            Mark(u, "技能吸血") or 0, (Mark(u, "技能吸血") or 0) / 3, --技能吸血
            Wage(i),
            FoodS[tid],
            DamageWoodS[i] * 100
        )
        japi.EXSetAbilityDataString(ab, 1, 218, str)
    end
    
    local isSelect = {}

    local selectTrg = CreateTrigger()
    TriggerAddCondition(selectTrg, Condition(
        function()
            local u = GetTriggerUnit()
            local id = GetPlayerId(GetOwningPlayer(u))
            if GetTriggerEventId() == EVENT_UNIT_SELECTED then
                isSelect[id] = true
                RefreshState(id)
            else
                isSelect[id] = false
            end
        end
    ))
    
    InitPDASkill = function(u)
        local p = GetOwningPlayer(u)
        local i = GetPlayerId(p)
        local hero = Hero[i]
        local id = GetUnitPointValue(hero)
        
        --检查玩家是否选中了携带女仆
        TriggerRegisterUnitEvent(selectTrg, u, EVENT_UNIT_SELECTED)
        TriggerRegisterUnitEvent(selectTrg, u, EVENT_UNIT_DESELECTED)
        
        --每0.1秒移动到英雄的位置
        local hide = false
        Loop(0.1,
            function()
                if false then
                    if not hide and (IsUnitDead(hero) or IsUnitHidden(hero)) then
                        ShowUnit(u, false)
                        hide = true
                    elseif hide and IsUnitAlive(hero) and not IsUnitHidden(hero) then
                        ShowUnit(u, true)
                        hide = false
                    end
                end
                local x, y 
                if IsUnitAlive(hero) then
                    x, y = GetXY(hero)
                else
                    x, y = GetXY(Maid[i])
                end
                SetUnitX(u, x)
                SetUnitY(u, y)
                if SELFP == p then
                    SetCameraQuickPosition(x, y)
                end
            end
        )
        
        --查看英雄技能
        UnitAddAbility(u, |A18D|)
        local ab = japi.EXGetUnitAbility(u, |A18D|)
        if SELFP == p then
            japi.EXSetAbilityDataString(ab, 1, 204, HeroTypePic[id]) --修改图标
            japi.EXSetAbilityDataString(ab, 1, 215, "查看 |cffffcc00" .. HeroName[id] .. "|r 的英雄属性") --修改标题
        end
        
        Loop(0.5,
            function()
                if isSelect[i] then
                    if SELFP == p then
                        RefreshState(i)
                    end
                    RefreshTips(u)
                end
            end
        )
        
        --存在感系统
        require "BattleSystem.lua"
        
        InitBattlePDA(u)
    end
    
