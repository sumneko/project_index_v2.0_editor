    
    local count = 0
    
    local func
    
    IsInGame = true
    
    func = function()
        Wait(GetRandomReal(5, 10),
            function()
                --获取当前镜头位置
                local x = GetCameraTargetPositionX()
                local y = GetCameraTargetPositionY()
                
                --进行同步
                if SELFP == FirstPlayer then
                    StoreReal(GC, "IG", "x", x)
                    StoreReal(GC, "IG", "y", y)
                    SyncStoredReal(GC, "IG", "x")
                    SyncStoredReal(GC, "IG", "y")
                end
                
                --清空数据以免掉线
                StoreReal(GC, "IG", "x", 0)
                StoreReal(GC, "IG", "y", 0)
                
                --等待同步完成
                Wait(5,
                    function()
                    
                        --看录像的时候默认为第一个玩家
                        if SELFP == FirstPlayer then
                            if x ~= GetStoredReal(GC, "IG", "x") or y ~= GetStoredReal(GC, "IG", "y") then
                                IsInGame = false
                            end
                        end
                    
                        --如果同步失败,重新同步(限10次)
                        if GetStoredReal(GC, "IG", "x") == 0 and GetStoredReal(GC, "IG", "y") == 0 and count < 10 then
                            count = count + 1
                            func()
                        end
                    end
                )
            end
        )
    end
    
    --如果有OB了,就不检查是否为录像模式
    if not IsPlayerObserver(Player(0)) then
        func()
    end
