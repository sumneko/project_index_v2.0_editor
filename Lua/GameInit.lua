    require "globals.lua"

    --隐藏多面板模式
    MultiboardSuppressDisplay( true )
    
    --关闭黑色阴影,让2个OB和中立被动可以看到全图
    FogMaskEnable( false )
    
    FogModifierStart( CreateFogModifierRect(Player(0), FOG_OF_WAR_VISIBLE, GetPlayableMapRect(), false, false) )
    FogModifierStart( CreateFogModifierRect(Player(6), FOG_OF_WAR_VISIBLE, GetPlayableMapRect(), false, false) )
    FogModifierStart( CreateFogModifierRect(Player(PLAYER_NEUTRAL_PASSIVE), FOG_OF_WAR_VISIBLE, GetPlayableMapRect(), false, false) )
    
    --暂时关闭迷雾
    FogEnable(false)
    
    --播放背景音乐
    PlayMusic( gg_snd_BGM )
    --使用环境音效
    SetAmbientNightSound( "LordaeronSummerNight" )

    --一些玩家设置
    for i = 0,11 do
        SetPlayerState(Player(i), PLAYER_STATE_RESOURCE_HERO_TOKENS, bj_MELEE_STARTING_HERO_TOKENS) --第一个英雄免费
        SetPlayerState(Player(i), PLAYER_STATE_RESOURCE_GOLD, 1250 ) --现有黄金设置为1250
        SetPlayerState(Player(i), PLAYER_STATE_RESOURCE_LUMBER, 150 ) --现有木材设置为150
        --SetPlayerState(Player(i), PLAYER_STATE_RESOURCE_FOOD_CAP, 300 ) --人口上限(节操上限)设置为300
        SetPlayerAbilityAvailable(Player(i), |A000|, false ) --禁用技能
        --StartCampaignAI(Player(i), "map.ai" ) --启用战役AI
    end
    
    --设置屏幕平滑
    if IsPlayerObserver(SELFP) then
        CameraSetSmoothingFactor( 100.00 )
    end
    
    MeleeStartingVisibility(  ) -- 使用对战昼夜设置
    
    --隐藏2个单位
    --ShowUnitHide( gg_unit_Hmbr_0215 )
    --ShowUnitHide( gg_unit_nfrm_0194 )
    
    --锁定游戏速度
    SetGameSpeed( MAP_SPEED_FASTEST )
    LockGameSpeedBJ(  )
    
    --关闭昼夜交替
    UseTimeOfDayBJ( false )
    
    --设置英雄图标数量
    if IsPlayerObserver(SELFP) then
        SetReservedLocalHeroButtons( 0 )
    else
        SetReservedLocalHeroButtons( 2 )
    end
    
    --关闭中立敌对的奖励
    SetPlayerState( Player(PLAYER_NEUTRAL_AGGRESSIVE), PLAYER_STATE_GIVES_BOUNTY, 0 )
    
    --给中立被动木材
    SetPlayerStateBJ( Player(PLAYER_NEUTRAL_PASSIVE), PLAYER_STATE_RESOURCE_LUMBER, 1000000 )
    
    --设置自动贩卖机的动画速度
    SetUnitTimeScalePercent( gg_unit_h001_0120, 0.00 )
    SetUnitTimeScalePercent( gg_unit_h00R_0121, 0.00 )
    
    --往任务里添加一些文本
    require "Info.lua"
    
    --设置玩家的初始结盟
    require "Alliance.lua"
    
    --禁用野怪的技能
    SetPlayerAbilityAvailable( Player(PLAYER_NEUTRAL_AGGRESSIVE), |Aens|, false )
    SetPlayerAbilityAvailable( Player(PLAYER_NEUTRAL_AGGRESSIVE), |Aweb|, false )
    SetPlayerAbilityAvailable( Player(PLAYER_NEUTRAL_AGGRESSIVE), |ACvs|, false )
    SetPlayerAbilityAvailable( Player(PLAYER_NEUTRAL_AGGRESSIVE), |Ambd|, false )
    SetPlayerAbilityAvailable( Player(PLAYER_NEUTRAL_AGGRESSIVE), |A0NJ|, false )
    SetPlayerAbilityAvailable( Player(PLAYER_NEUTRAL_AGGRESSIVE), |A0GS|, false )
    SetPlayerAbilityAvailable( Player(PLAYER_NEUTRAL_AGGRESSIVE), |Acht|, false )
    SetPlayerAbilityAvailable( Player(PLAYER_NEUTRAL_AGGRESSIVE), |ACsw|, false )
    SetPlayerAbilityAvailable( Player(PLAYER_NEUTRAL_AGGRESSIVE), |AChw|, false )
    SetPlayerAbilityAvailable( Player(PLAYER_NEUTRAL_PASSIVE), |A0SY|, false )
    SetPlayerAbilityAvailable( Player(PLAYER_NEUTRAL_PASSIVE), |A0TA|, false )
    
    --禁用玩家的技能
    for bj_forLoopAIndex = 1, 12 do
        SetPlayerAbilityAvailable( ConvertedPlayer(bj_forLoopAIndex), |A0SY|, false )
        SetPlayerAbilityAvailable( ConvertedPlayer(bj_forLoopAIndex), |A0TA|, false )
        SetPlayerAbilityAvailable( ConvertedPlayer(bj_forLoopAIndex), |A0KW|, false )
        SetPlayerAbilityAvailable( ConvertedPlayer(bj_forLoopAIndex), |A0TK|, false )
        SetPlayerAbilityAvailable( ConvertedPlayer(bj_forLoopAIndex), |A0TL|, false )
    end
    
    Wait(20, --等待玩家分组确定
        function()
            --打开迷雾
            FogEnable(true)
            
            --设置玩家的特殊点(暂时无用)
            for i = 1, 5 do
                MH[GetPlayerId(PA[i])] = Location(-5300.00, -5800.00)
                MH[GetPlayerId(PB[i])] = Location(5300.00, 5200.00)
            end
            
            --创建商店名字
            --require "ShopTag.lua"
            
        end
    )
    
    --游戏模式
    GameMode = {}
    
    SetGameTime(-15) --倒计时15秒
    
    Wait(15, --等待是否选择了特殊选英雄模式
        function()
            if not table.has(GameMode, "AD") --全体征召模式
            and not table.has(GameMode, "RD") --随机征召模式
            and not table.has(GameMode, "AR") --全体随机模式
            then
                
                --注册酒馆选英雄
                require "BuyHero.lua"
                
                --游戏在90秒后开始
                require "GameStart.lua"
                StartGameIn(90)
                
            end
        end
    )
