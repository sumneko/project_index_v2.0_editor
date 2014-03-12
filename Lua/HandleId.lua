    do return end
    TimerStart(CreateTimer(), 1, true,
        function()
            local h = jass.CreateTimer()
            old.print(GetHandleId(h))
            jass.DestroyTimer(h)
        end
    )
    
    luaDone()
