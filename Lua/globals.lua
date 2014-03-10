
    --SnowArea = GetEntireMapRect()
    NP = true --新手保护
    InGame = true --游戏环境(不在录像模式中)
    IO = true --物品唯一
    
    MH = {} --MH检测点
    MH.temp = GetRectCenter(gg_rct_MH)
    
    JC = {} --节操
    JC[2] = 100
    JC[3] = 100
    
    SI = {} --是否显示队友头像
    for i = 0,11 do
        SI[i] = true
    end
    
    Hero = {} --记录玩家的英雄
    Hero[0] = gg_unit_h00P_0029
    Hero[6] = gg_unit_hcas_0061
    --Hero[12] = gg_unit_Etyr_0124
    
    PA = {} --学园都市方一组的玩家
    PB = {} --罗马正教方一组的玩家
    P = {} --所有玩家
    Com = {} --出兵玩家
    
    Com[0] = Player(0)
    Com[1] = Player(6)
    
    for i = 0, 5 do
        PA[i] = Player(i)
        PB[i] = Player(i+6)
    end
    for i = 1, 5 do
        P[i] = PA[i]
        P[i+5] = PB[i]
    end
    
    PA[-1] = Player(13)
    PB[-1] = Player(14)
    
    dummy = |e01B| --标准马甲单位的ID
    
    Color = {} --玩家颜色
    Color[0] = "|cffff0303"
    Color[13] = "|cffff0303"
    Color[1] = "|cff0042ff"
    Color[2] = "|cff1ce6b9"
    Color[3] = "|cff540081"
    Color[4] = "|cfffffc01"
    Color[5] = "|cffff8000"
    Color[6] = "|cff20c000"
    Color[14] = "|cff20c000"
    Color[7] = "|cffe55bb0"
    Color[8] = "|cff959697"
    Color[9] = "|cff7ebff1"
    Color[10] = "|cff106246"
    Color[11] = "|cff4e2a04"
    Color[12] = "|cffffffff"
    Color[15] = "|cffffffff"
    Color[21] = "|cffffffff"
    Color[22] = "|cffffffff"
    Color[23] = "|cffffffff"
    Color[24] = "|cffffffff"
    
    PlayerName = {} --玩家名字
    PlayerName[13] = "学院都市"
    PlayerName[14] = "罗马正教"
    PlayerName[21] = "黑白子"
    PlayerName[22] = "Y叔"
    PlayerName[23] = "宙斯(奥林匹斯之王)"
    PlayerName[24] = "野怪"
    
    --称号名称
    CHName = {}
    
    --寻找第一个玩家
    for i = 0, 15 do
        if IsPlayer(Player(i)) then
            FirstPlayer = Player(i)
            break
        end
    end
    
    --英雄开始点
    StartPoint = {}
    
    StartPoint[0] = GetRectCenter(gg_rct_CollageResurrection)
    StartPoint[1] = GetRectCenter(gg_rct_RomeResurrection)
    
    --商店
    Shop = {}
    
    Shop[0] = gg_unit_e032_0004
    Shop[1] = gg_unit_e032_0003
    
    --涡点
    Gate = {}
    local g = CreateGroup()
    GroupEnumUnitsOfPlayer(g, Player(15), Condition(
        function()
            local u = GetFilterUnit()
            if GetUnitTypeId(u) == |n00K| then
                table.insert(Gate, u)
            end
        end
    ))
    DestroyGroup(g)
