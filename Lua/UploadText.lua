    
    upload = {
        gc = InitGameCache("Upload"),
        max = 25, --同时传输25*4个字节
        byte = 2 ^ 31,
        start = function(data)
            local len = data.text:len() --字符串长度
            --先同步文本长度
            Debug("开始传输文本长度...")
            Sync(
                data.player,
                {len},
                function(sync)
                    local len = sync[1]
                    Debug("文本长度传输完毕,长度为|cffffcc00" .. len .. "|r个字节")
                    local count = math.ceil(len / 4) --拆成x份
                    if len < count * 4 then
                        data.text = data.text .. (" "):rep(count * 4 - len) --在字符串后面补上空格,凑成4的倍数
                    end
                    local func = function()
                        for x = 1, count do
                            local i = string2id(data.text:sub(x * 4 - 3, x * 4)) --将4个字符组成一个整数
                            i = i - upload.byte --转化为带符号的整数
                            StoreInteger(upload.gc, "", x, i)
                            SyncStoredInteger(upload.gc, "", x)
                        end
                        StoreInteger(upload.gc, "", "", 1)
                        SyncStoredInteger(upload.gc, "", "")
                    end
                    if data.player == SELFP then
                        func()
                    end
                    for x = 1, count do
                        StoreInteger(upload.gc, "", x, - upload.byte)
                    end
                    StoreInteger(upload.gc, "", "", 0)
                    local starttime = GetTime()
                    local last = 0
                    local getGlobalSpeed = function()
                        local now = GetTime()
                        local past = now - starttime
                        local pastbyte = last * 4
                        return pastbyte / past
                    end
                    Loop(0.1,
                        function()
                            if GetStoredInteger(upload.gc, "", "") == 1 then
                                EndLoop()
                                local st = {}
                                for x = 1, count do
                                    local i = GetStoredInteger(upload.gc, "", x)
                                    i = i + upload.byte --转化为不带符号的整数
                                    st[x] = id2string(i)
                                end
                                local text = table.concat(st)
                                text = text:sub(1, len) --截取为原本字符串的长度
                                Debug("文本传输完毕,全文如下:")
                                Debug(text)
                                old.print(text)
                            else
                                for x = last + 1, count do
                                    if GetStoredInteger(upload.gc, "", x) == - upload.byte then
                                        last = x - 1
                                        break
                                    end
                                end
                                Debug(("[%.2f][%d]传输进度:|cffffcc00%.2f|r%% 传输速度:|cffffcc00%.2f|r字节/秒")
                                :format(
                                    GetTime(),
                                    last,
                                    last / count * 100,
                                    getGlobalSpeed()
                                ))
                            end
                        end
                    )
                end
            )
        end,
    }
    
