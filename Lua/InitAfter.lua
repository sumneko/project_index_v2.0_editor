    
    Wait(0,
        function()
            --创建缓存
            GC = InitGameCache("temp.w3v")
            
            --do return end
            --共享单位视野
            local g = CreateGroup()
            GroupEnumUnitsOfPlayer(g, PA[0], nil)
            for _,u in group(g) do
                for i = 1, 5 do
                    UnitShareVision(u, PA[i], true)
                end
            end
            GroupEnumUnitsOfPlayer(g, PB[0], nil)
            for _,u in group(g) do
                for i = 1, 5 do
                    UnitShareVision(u, PB[i], true)
                end
            end
            DestroyGroup(g)
        end
    )
    
    luaDone()
    
