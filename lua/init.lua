    jass_ext.EnableConsole() --打开Lua引擎控制台
    
    require "ansiword.lua"

    setmetatable(_G, { __index = getmetatable(jass).__index})
    
    old = {}
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

