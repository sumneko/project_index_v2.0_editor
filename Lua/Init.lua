    jass_ext.EnableConsole() --打开Lua引擎控制台
    
    old = {}
    
    require "AnsiWord.lua"
    
    function jass_ext.runtime.error_handle(msg) --调用栈
        old.print("---------------------------------------")
        old.print("       " .. ANSI.error)
        old.print("---------------------------------------")
        old.print(tostring(msg) .. "\n")
        old.print(debug.traceback())
        old.print("---------------------------------------")
    end

    setmetatable(_G, { __index = getmetatable(jass).__index})
    
    
    old.require = require
    old.print = print
    
    local stack = {}
    local top = 1
    
    local loaded = {}
    
    require = function(s)
        if loaded[s] then return end
        loaded[s] = true
        old.print("loading[" .. s .. "]")
        top = top + 1
        stack[top] = s
        local returns = {old.require(s)}
        old.print("finish [" .. stack[top] .. "]")
        top = top - 1
        return unpack(returns)
    end

