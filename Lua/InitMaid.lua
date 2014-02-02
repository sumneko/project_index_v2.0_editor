    
    --创建携女仆
    PDA = {}
    
    CreatePDA = function(p, u)
        local i = GetPlayerId(p)
        if PDA[i] then return end
        
        local tid = GetPlayerTeam(p)
        
        --创建女仆
        PDA[i] = CreateUnit(p, |h022|, GetLocationX(MH.temp), GetLocationY(MH.temp), 0)
        
        --飞到天上去
        FlyEnable(PDA[i])
        SetUnitFlyHeight(PDA[i], 5000, 0)
        
        --注册携带女仆技能
        require "PDASkill.lua"
        InitPDASkill(PDA[i])
        
        --添加物品
        require "PDAItem.lua"
        InitPDAItem(PDA[i])
    end
    
    --创建家务女仆
    Maid = {}
    
    CreateMaid = function(p, u)
        local i = GetPlayerId(p)
        if Maid[i] then return end
        
        local tid = GetPlayerTeam(p)
        
        --创建女仆
        point = MovePoint(StartPoint[tid], {50, 72*i})
        Maid[i] = CreateUnit(p, |enec|, point[1], point[2], -90)
        
        --设置缩放
        if p == SELFP then
            SetUnitScale(Maid[i], 0.50, 0.50, 0.50)
        else
            SetUnitScale(Maid[i], 0.30, 0.30, 0.30)
        end
        
        --注册物品拾取
        InitUnitLoot(Maid[i])
        
        --注册家务女仆技能
        require "MaidSkill.lua"
        InitMaidSkill(Maid[i])
    end
    
