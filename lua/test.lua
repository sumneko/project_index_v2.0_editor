    
    do return end
    
    local u
    
    Wait(1,
        function()
            u = CreateUnit(PA[1], |e031|, 0, 0, 0)
            AddSpecialEffectTarget("RocketMissile1.mdl", u, "origin")
            Loop(0.02,
                function()
                    if u then
                        ClearTextMessages()
                        print("UnitZ:" .. GetUnitZ(u))
                        print("Fly:" .. GetUnitFlyHeight(u))
                        print("locZ:" .. getZ(u))
                        SetUnitZ(u, 300)
                    end
                end
            )
        end
    )
       
