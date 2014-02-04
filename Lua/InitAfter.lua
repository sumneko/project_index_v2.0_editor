    
    Wait(0,
        function()
            --创建缓存
            GC = InitGameCache("temp.w3v")
            
            --do return end
            --共享单位视野
            local func1 = function()
                local g = CreateGroup()
                GroupEnumUnitsOfPlayer(g, PA[0], nil)
                for _,u in group(g) do
                    for i = 1, 5 do
                        UnitShareVision(u, PA[i], true)
                        UnitShareVision(u, PB[i], false)
                    end
                end
                GroupEnumUnitsOfPlayer(g, PB[0], nil)
                for _,u in group(g) do
                    for i = 1, 5 do
                        UnitShareVision(u, PB[i], true)
                        UnitShareVision(u, PA[i], false)
                    end
                end
                DestroyGroup(g)
            end
            
            func1()
            
            Event("洗牌后",
                function()
                    func1()
                end
            )
        end
    )
    
    luaDone()
    
