    
    require "PlayerSet.lua"
    
    RefreshAlliance = function()
        for i = 1, 5 do
            --所有玩家对中立被动共享视野
            SetPlayerAlliance(PA[i], Player(15), ALLIANCE_SHARED_VISION, true )
            SetPlayerAlliance(PB[i], Player(15), ALLIANCE_SHARED_VISION, true )
            --学院都市对学院玩家结盟并共享视野和共享经验
            SetPlayerAlliance(PA[0], PA[i], ALLIANCE_PASSIVE, true )
            SetPlayerAlliance(PA[-1], PA[i], ALLIANCE_PASSIVE, true )
            SetPlayerAlliance(PA[0], PA[i], ALLIANCE_SHARED_SPELLS, true )
            --SetPlayerAlliance(PA[0], PA[i], ALLIANCE_SHARED_VISION, true )
            SetPlayerAlliance(PA[0], PA[i], ALLIANCE_SHARED_XP, true )
            --SetPlayerAlliance(PA[-1], PA[i], ALLIANCE_SHARED_CONTROL, true )
            --反向
            SetPlayerAlliance(PA[0], PB[i], ALLIANCE_PASSIVE, false )
            SetPlayerAlliance(PA[-1], PB[i], ALLIANCE_PASSIVE, false )
            SetPlayerAlliance(PA[0], PB[i], ALLIANCE_SHARED_SPELLS, false )
            --SetPlayerAlliance(PA[0], PB[i], ALLIANCE_SHARED_VISION, false )
            SetPlayerAlliance(PA[0], PB[i], ALLIANCE_SHARED_XP, false )
            --SetPlayerAlliance(PA[-1], PB[i], ALLIANCE_SHARED_CONTROL, false )
            --罗马正教对罗马玩家结盟并共享视野和共享经验
            SetPlayerAlliance(PB[0], PB[i], ALLIANCE_PASSIVE, true )
            SetPlayerAlliance(PB[-1], PB[i], ALLIANCE_PASSIVE, true )
            SetPlayerAlliance(PB[0], PB[i], ALLIANCE_SHARED_SPELLS, true )
            --SetPlayerAlliance(PB[0], PB[i], ALLIANCE_SHARED_VISION, true )
            SetPlayerAlliance(PB[0], PB[i], ALLIANCE_SHARED_XP, true )
            --SetPlayerAlliance(PB[-1], PB[i], ALLIANCE_SHARED_CONTROL, true )
            --反向
            SetPlayerAlliance(PB[0], PA[i], ALLIANCE_PASSIVE, false )
            SetPlayerAlliance(PB[-1], PA[i], ALLIANCE_PASSIVE, false )
            SetPlayerAlliance(PB[0], PA[i], ALLIANCE_SHARED_SPELLS, false )
            --SetPlayerAlliance(PB[0], PA[i], ALLIANCE_SHARED_VISION, false )
            SetPlayerAlliance(PB[0], PA[i], ALLIANCE_SHARED_XP, false )
            --SetPlayerAlliance(PB[-1], PA[i], ALLIANCE_SHARED_CONTROL, false )
            --学院玩家对学园都市结盟并共享视野和单位和高级共享
            SetPlayerAlliance(PA[i], PA[0], ALLIANCE_PASSIVE, true )
            SetPlayerAlliance(PA[i], PA[-1], ALLIANCE_PASSIVE, true )
            SetPlayerAlliance(PA[i], PA[0], ALLIANCE_SHARED_SPELLS, true )
            SetPlayerAlliance(PA[i], PA[0], ALLIANCE_SHARED_VISION, true )
            SetPlayerAlliance(PA[i], PA[0], ALLIANCE_SHARED_CONTROL, true )
            SetPlayerAlliance(PA[i], PA[0], ALLIANCE_SHARED_ADVANCED_CONTROL, true )
            --反向
            SetPlayerAlliance(PB[i], PA[0], ALLIANCE_PASSIVE, false )
            SetPlayerAlliance(PB[i], PA[-1], ALLIANCE_PASSIVE, false )
            SetPlayerAlliance(PB[i], PA[0], ALLIANCE_SHARED_SPELLS, false )
            SetPlayerAlliance(PB[i], PA[0], ALLIANCE_SHARED_VISION, false )
            SetPlayerAlliance(PB[i], PA[0], ALLIANCE_SHARED_CONTROL, false )
            SetPlayerAlliance(PB[i], PA[0], ALLIANCE_SHARED_ADVANCED_CONTROL, false )
            --罗马玩家对罗马正教结盟并共享视野和单位和高级共享
            SetPlayerAlliance(PB[i], PB[0], ALLIANCE_PASSIVE, true )
            SetPlayerAlliance(PB[i], PB[-1], ALLIANCE_PASSIVE, true )
            SetPlayerAlliance(PB[i], PB[0], ALLIANCE_SHARED_SPELLS, true )
            SetPlayerAlliance(PB[i], PB[0], ALLIANCE_SHARED_VISION, true )
            SetPlayerAlliance(PB[i], PB[0], ALLIANCE_SHARED_CONTROL, true )
            SetPlayerAlliance(PB[i], PB[0], ALLIANCE_SHARED_ADVANCED_CONTROL, true )
            --反向
            SetPlayerAlliance(PA[i], PB[0], ALLIANCE_PASSIVE, false )
            SetPlayerAlliance(PA[i], PB[-1], ALLIANCE_PASSIVE, false )
            SetPlayerAlliance(PA[i], PB[0], ALLIANCE_SHARED_SPELLS, false )
            SetPlayerAlliance(PA[i], PB[0], ALLIANCE_SHARED_VISION, false )
            SetPlayerAlliance(PA[i], PB[0], ALLIANCE_SHARED_CONTROL, false )
            SetPlayerAlliance(PA[i], PB[0], ALLIANCE_SHARED_ADVANCED_CONTROL, false )
            --学院玩家对罗马正教共享单位和视野
            SetPlayerAlliance(PA[i], PB[0], ALLIANCE_SHARED_CONTROL, true )
            --罗马玩家对学园都市共享单位和视野
            SetPlayerAlliance(PB[i], PA[0], ALLIANCE_SHARED_CONTROL, true )
            --玩家不对中立被动共享经验
            SetPlayerAlliance(PA[i], Player(15), ALLIANCE_SHARED_XP, false )
            SetPlayerAlliance(PB[i], Player(15), ALLIANCE_SHARED_XP, false )
            --中立被动对玩家共享单位
            SetPlayerAlliance(Player(15), PA[i], ALLIANCE_SHARED_CONTROL, true )
            SetPlayerAlliance(Player(15), PB[i], ALLIANCE_SHARED_CONTROL, true )
            --玩家对中立受害共享视野
            SetPlayerAlliance(PA[i], Player(13), ALLIANCE_SHARED_VISION, true)
            SetPlayerAlliance(PB[i], Player(13), ALLIANCE_SHARED_VISION, true)
            --玩家互艹
            for j = 1, 5 do
                SetPlayerAlliance(PA[i], PA[j], ALLIANCE_PASSIVE, true )
                SetPlayerAlliance(PA[i], PA[j], ALLIANCE_SHARED_SPELLS, true )
                SetPlayerAlliance(PA[i], PA[j], ALLIANCE_SHARED_VISION, true )
                SetPlayerAlliance(PA[i], PA[j], ALLIANCE_SHARED_XP, true )
                
                SetPlayerAlliance(PA[i], PB[j], ALLIANCE_PASSIVE, false )
                SetPlayerAlliance(PA[i], PB[j], ALLIANCE_SHARED_SPELLS, false )
                SetPlayerAlliance(PA[i], PB[j], ALLIANCE_SHARED_VISION, false )
                SetPlayerAlliance(PA[i], PB[j], ALLIANCE_SHARED_XP, false )
                
                SetPlayerAlliance(PB[i], PB[j], ALLIANCE_PASSIVE, true )
                SetPlayerAlliance(PB[i], PB[j], ALLIANCE_SHARED_SPELLS, true )
                SetPlayerAlliance(PB[i], PB[j], ALLIANCE_SHARED_VISION, true )
                SetPlayerAlliance(PB[i], PB[j], ALLIANCE_SHARED_XP, true )
                
                SetPlayerAlliance(PB[i], PA[j], ALLIANCE_PASSIVE, false )
                SetPlayerAlliance(PB[i], PA[j], ALLIANCE_SHARED_SPELLS, false )
                SetPlayerAlliance(PB[i], PA[j], ALLIANCE_SHARED_VISION, false )
                SetPlayerAlliance(PB[i], PA[j], ALLIANCE_SHARED_XP, false )
            end
        end
        
        --学园都市与罗马正教共享视野
        SetPlayerAlliance(PA[0], PB[0], ALLIANCE_SHARED_VISION, true )
        SetPlayerAlliance(PB[0], PA[0], ALLIANCE_SHARED_VISION, true )
        
        --学园都市与罗马正教交换意见
        SetPlayerAlliance(PA[0], PB[0], ALLIANCE_PASSIVE, false )
        SetPlayerAlliance(PA[0], PB[-1], ALLIANCE_PASSIVE, false )
        SetPlayerAlliance(PA[0], PA[-1], ALLIANCE_PASSIVE, true )
        
        SetPlayerAlliance(PB[0], PA[0], ALLIANCE_PASSIVE, false )
        SetPlayerAlliance(PB[0], PA[-1], ALLIANCE_PASSIVE, false )
        SetPlayerAlliance(PB[0], PB[-1], ALLIANCE_PASSIVE, true )
        
        SetPlayerAlliance(PA[-1], PB[0], ALLIANCE_PASSIVE, false )
        SetPlayerAlliance(PA[-1], PB[-1], ALLIANCE_PASSIVE, false )
        SetPlayerAlliance(PA[-1], PA[0], ALLIANCE_PASSIVE, true )
        
        SetPlayerAlliance(PB[-1], PA[0], ALLIANCE_PASSIVE, false )
        SetPlayerAlliance(PB[-1], PA[-1], ALLIANCE_PASSIVE, false )
        SetPlayerAlliance(PB[-1], PB[0], ALLIANCE_PASSIVE, true )
        
        --设置玩家组
        for i = 0, 5 do
            SetPlayerTeam(PA[i], 0)
            SetPlayerTeam(PB[i], 1)
        end
        
        --电脑关闭对自己的共享
        SetPlayerAlliance(PA[0],PA[0], ALLIANCE_SHARED_CONTROL, false )
        SetPlayerAlliance(PB[0],PB[0], ALLIANCE_SHARED_CONTROL, false )
        
        --设置玩家的颜色
        SetPlayerColorBJ( Player(0), PLAYER_COLOR_RED, true )
        SetPlayerColorBJ( Player(6), PLAYER_COLOR_GREEN, true )
        SetPlayerColorBJ( Player(bj_PLAYER_NEUTRAL_VICTIM), PLAYER_COLOR_RED, true )
        SetPlayerColorBJ( Player(bj_PLAYER_NEUTRAL_EXTRA), PLAYER_COLOR_GREEN, true )
        
    end
    
    RefreshAlliance()
    
    ClearTextMessages()
    
