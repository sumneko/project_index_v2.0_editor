    
    Wait(0,
        function()
            local trg = CreateTrigger()
            EnumDestructablesInRect(GetPlayableMapRect(), nil,
                function()
                    TriggerRegisterDeathEvent(trg, GetEnumDestructable())
                end
            )
            TriggerAddCondition(trg, Condition(
                function()
                    local w = GetTriggerDestructable()
                    Wait(60,
                        function()
                            DestructableRestoreLife(w, GetDestructableMaxLife(w), true)
                            TempEffect(w, "s_TreeExtraction_Rain.mdx")
                        end
                    )
                end
            ))
        end
    )  
    
    luaDone()
