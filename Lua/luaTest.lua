    
    local code = {}

    local showCode = function(i)
        if code[i] then
            if i == SELF then
                ClearTextMessages()
            end
            local x = 1
            while code[i][x] do
                printTo(i, 60, code[i][x])
                x = x + 1
            end
        else
            printTo(i, 60, "你还没有输入过代码!")
        end
    end

    local trg = CreateTrigger()
    for i = 0, 1 do
        TriggerRegisterPlayerChatEvent(trg, Player(i), "", false)
    end
    TriggerAddCondition(trg,Condition(function()
        local s = GetEventPlayerChatString()
        local i = GetPlayerId(GetTriggerPlayer())
        if string.sub(s, 1, 1) == "." then
            s = string.lower(s)
            if s == ".start" then
                code[i] = {}
                code[i][0] = 0
                code[i].flag = true
                printTo(i, 60, "请输入代码")
            elseif s == ".end" then
                code[i].flag = false
                showCode(i)
            elseif s == ".clear" and code[i][0] > 0 then
                local x = code[i][0]
                code[i][x] = nil
                code[i][0] = x - 1
                showCode(i)
            elseif s == ".info" then
                printTo(i, 60, "欢淫使用lua测试系统\n输入.start开始录制代码\n输入.end结束录制\n输入.run运行录制的代码\n输入.clear清除上一句代码\n输入.info查看该信息")
            elseif s == ".show" then
                showCode(i)
            elseif s == ".run" and code[i] then
                code[i].flag = false
                local x = 1
                local ss = "_ENV = ..."
                while code[i][x] do
                    ss = ss .. ";" .. code[i][x]
                    x = x + 1
                end
                local f = assert(loadstring(ss))
                if type(f) == "function" then
                    f(_ENV)
                else
                    print(f)
                end
            elseif s == ".test" then
                for i = 2, 11 do
                    TriggerRegisterPlayerChatEvent(trg, Player(i), "", false)
                end
            else
                stringTest(GetEventPlayerChatString(), i)
            end
        elseif code[i] and code[i].flag then
            code[i][0] = code[i][0] + 1
            local x = code[i][0]
            code[i][x] = s
            showCode(i)
        end
    end
    ))  

    luaDone()

