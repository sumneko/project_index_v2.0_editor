    
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
    
    local _, runtime = pcall(require, 'jass.runtime')
    
    if not runtime then
        jass_ext.EnableConsole() --打开Lua引擎控制台
        luaVersion = 0
    else
        jass_ext = {}
        jass_ext.runtime = runtime
        jass_ext.hook = require 'jass.hook'
        jass_ext.runtime.console = true --打开Lua引擎控制台
        jass = require 'jass.common'
        japi = require 'jass.japi'
        slk  = require 'jass.slk'
        luaVersion = jass_ext.runtime.version
    end
    
    if luaVersion > 1 then
        loadstring = load
        unpack = table.unpack
    end
    
    require "AnsiWord.lua"
    
    local runtime = jass_ext.runtime
    if runtime then
    
        runtime.error_handle = function(msg) --调用栈
            old.print("---------------------------------------")
            old.print("             LUA ERROR                 ")
            old.print("---------------------------------------")
            old.print(tostring(msg) .. "\n")
            old.print(debug.traceback())
            old.print("---------------------------------------")

            Debug(tostring(msg))
        end
        
        runtime.handle_level = 2
        --0:handle直接使用number
        --1:handle使用lightuserdata,0可以隐转为nil,不影响引用计数
        --2:handle使用userdata,lua持有handle时增加引用计数
        
        runtime.sleep = false --关闭掉等待功能以提升效率
    end

    setmetatable(_ENV, { __index = getmetatable(jass).__index})

