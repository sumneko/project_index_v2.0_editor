
    BanHeroType = function(id)
        for i = 1, 10 do
            SetPlayerTechMaxAllowed(P[i], HeroType[id], 0)
        end
    end
    
    BanPlayerHeroType = function(p)
        for i = 0, HeroTypeCount do
            SetPlayerTechMaxAllowed(p, HeroType[i], 0)
        end
    end
    
    AllHeroes = {}
    
    SelectHeroSub = function(p, u, t)
        local i = GetPlayerId(p)
        local id = GetUnitPointValue(u) --获取英雄的编号
        
        Mark(u, "注册英雄", true) --记录为注册英雄
        
        --禁止玩家再选这个英雄
        BanHeroType(id)
        if not table.has(GameMode, "MH") then
            Mark("已选择的英雄类型", id, true) --记录该英雄已经被选择
        end
        
        --禁止玩家选所有英雄
        BanPlayerHeroType(p)
        
        --记录玩家的英雄
        Hero[i] = u
        
        --更改玩家的名字
        RefreshPlayerName(p)
        
        --让英雄可以飞行
        FlyEnable(u)
        
        --设置英雄缩放
        Mark(u, "模型缩放", HeroSize[id])
        SetUnitScale(u, HeroSize[id], HeroSize[id], HeroSize[id])
        
        --设置英雄满血满蓝
        SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_MAX_LIFE))
        SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MAX_MANA))
        
        --发送消息
        if t and t.random then
            print(string.format("%s%s|r 随机选择了 |cffffcc00%s|r", Color[i], PlayerName[i], HeroName[id]))
        else
            print(string.format("%s%s|r 选择了 |cffffcc00%s|r", Color[i], PlayerName[i], HeroName[id]))
        end
        
        --注册部分事件
        InitHeroRevive(u) --注册英雄复活事件
        InitUnitLoot(u) --注册物品拾取
        
        local tid = GetPlayerTeam(p) --获取玩家的队伍
        
        --把英雄移动到基地中
        SetUnitPositionLoc(u, StartPoint[tid])
        
        --特殊奖励
        local gold = 0
        local wood = 0
        if t and t.random then --随机英雄奖励
            gold = gold + 150
            wood = wood + 50
        end
        Wait(0.5, function()
            GetGold(p, gold, wood)
        end)
        
        --把镜头移动到英雄位置,并选中英雄
        if p == SELFP then
            PanCameraToTimed(GetUnitX(u), GetUnitY(u), 0.5)
            ClearSelection()
            SelectUnit(u, true)
        end
        
        --创建女仆
        require "InitMaid.lua" 
        CreateMaid(p, u)
        CreatePDA(p, u)        
        
        --创建特效
        TempEffect(u, "Abilities\\Spells\\Orc\\Reincarnation\\ReincarnationTarget.mdl")
        
        --添加英雄技能
        require "LoadSkills.lua"
        HeroGetSkill(u)
        
        --添加到全局英雄中
        table.insert(AllHeroes, u)
        
        --发起事件
        toEvent("创建英雄", {unit = u})
    end
    
