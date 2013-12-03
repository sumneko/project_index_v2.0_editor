    
    require "HeroSub.lua" --选择英雄
    
    SelectRandomHero = function(p)
        local u
        while not u do
            local id = GetRandomInt(1, HeroTypeCount) --获取一个随机编号
            if not Mark("已选择的英雄类型", id) then --该类型的英雄没有被选择过
                u = CreateUnit(p, HeroType[id], 0, 0, 0)
            end
        end
        SelectHeroSub(p, u, {random = true})
    end
    
