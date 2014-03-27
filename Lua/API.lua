    
    pcall(old.require, "MoeUshio\\PI2\\API2.lua")
    
    Loop(1,
        function()
            toEvent("插件周期", {})
        end
    )
    
    for i = 1, 100 do
        local suc, name = pcall(old.require, "MoeUshio\\PI2\\Add" .. i .. ".lua")
        if suc then
            printTo(SELFP, "已加载插件:|cffffcc00" .. name .. "|r")
        end
    end
    
    old.print(ANSI.info)
    old.print(ANSI.info2)
