    
    require "HeroSub.lua" --选择英雄
    
    require "RandomHero.lua" --随机英雄
    
    --买英雄的触发
    local trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SELL)
    TriggerAddCondition(trg, Condition(
        function()
            local u = GetSoldUnit() --被贩卖的单位(英雄)
            local p = GetOwningPlayer(u)
            local id = GetPlayerId(p)
            if not Hero[id] then
                if GetUnitTypeId(u) == |Hmbr| then --随机英雄
                    SelectRandomHero(p) --获取一个随机英雄
                else
                    toEvent("进入地图", {unit = u})
                    SelectHeroSub(p, u) --注册选择的英雄
                    return
                end
            end
            RemoveUnit(u)
        end
    ))
    
