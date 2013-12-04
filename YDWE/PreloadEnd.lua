--该文件位于所有lua触发器之后,用于自动生成文件.注意新建的触发器在重新读取地图之前始终排在触发器列表的末尾,因此补充预留触发器后需要重启编辑器加载地图来更新列表顺序

    --自动生成FileList
    local script = table.concat(luanames, "\n")
    old("FileList.lua")(script)
    luascripts["FileList.lua"] = script
    
    --自动往GitHub目录中更新文件
    local filename = "F:\\GitHub\\project_index_v2.0_editor\\Lua\\%s" --我电脑上脚本存储的位置
    
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
        end
    end
