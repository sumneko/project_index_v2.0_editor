--该文件位于所有lua触发器之后,用于自动生成文件.注意新建的触发器在重新读取地图之前始终排在触发器列表的末尾,因此补充预留触发器后需要重启编辑器加载地图来更新列表顺序

    table.insert(logtable, ("[%s]脚本保存完毕,开始生成FileList"):format(os.date("%X")))
    
    --自动生成FileList
    local script = table.concat(luanames, "\n")
    old("FileList.lua")(script)
    luascripts["FileList.lua"] = script
    
    table.insert(logtable, ("[%s]FileList生成完毕,总共%s个文件"):format(os.date("%X"), #luanames))
    
    --自动往GitHub目录中更新文件
    local filename = "F:\\GitHub\\project_index_v2.0_editor\\Lua\\%s" --我电脑上脚本存储的位置
    
    luascripts["BJ.lua"] = nil --不对比或生成BJ.lua,因为该文件太长,比较耗费资源,且不会主动去修改它
    
    table.insert(logtable, ("[%s]开始对比并更新GitHub目录下的对应文件..."):format(os.date("%X")))
    
    for name, script in pairs(luascripts) do --遍历此次生成的文件
        local nname = filename:format(name) --准备打开的文件
        local lua = io.open(nname, "r") --读取模式打开文件
        local oldscript
        if lua then
            oldscript = lua:read("*all") --读取文件内容
            lua:close() --关闭文件
        end
        if script ~= oldscript then --如果此次生成的文件内容与已有文件内容不同
            lua = io.open(nname, "w") --写入模式打开文件
            lua:write(script) --将脚本写入文件
            lua:close() --关闭文件
            table.insert(logtable, ("[%s]更新了文件:%s"):format(os.date("%X"), name))
        end
    end
    
    table.insert(logtable, ("[%s]文件更新完成,开始导入ANSI编码的外部文件..."):format(os.date("%X")))
    
    --导入外部以ANSI编码写的文件
    local lua = io.open(filename:format("AnsiWord.lua"), "r")
    local s = lua:read("*all")
    lua:close()
    old("AnsiWord.lua")(s)
    
    table.insert(logtable, ("[%s]文件导入完成,开始生成日志\n用时:%.4f秒"):format(os.date("%X"), os.clock() - startclock))
    
    --生成日志文件
    filename = "F:\\GitHub\\project_index_v2.0_editor\\Log\\LuaPreloadLog.txt"
    local log = io.open(filename, "w")
    log:write(table.concat(logtable, "\n"))
    log:close()
	