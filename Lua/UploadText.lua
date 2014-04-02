    
    upload = {
        gc = InitGameCache("U"),
        byte = 2 ^ 31,
        chars = "123456789abcdefghijklmnopqrstuvwxyz",
        ver = "1.1",
        zipver = "0.0",
        i2k = function(i)
			if i == 0 then return "0" end
            local t = {}
            while i > 0 do
                local k = i % 36
				if k == 0 then
					table.insert(t, 0)
				else
					table.insert(t, upload.chars:sub(k, k))
				end
                i = (i - k) / 36
            end
            return table.concat(t)
        end,
        start = function(data)
            local len = data.text:len() --字符串长度
            --先同步文本长度
            Sync(
                data.player,
                {len},
                function(sync)
                    local len = sync[1]
                    data.len = len --记录文本长度
                    data.size = len
                    local starttime = GetTime()
                    data.starttime = starttime
                    data.pastbyte = 0
                    data.pasttime = 0
                    data.speed = 0
                    local last = 0
                    local st = {}
                    if data.ready and data:ready() then
                        return
                    end
                    len = data.size
                    local count = math.ceil(len / 4) --拆成x份
                    if len < count * 4 then
                        data.text = data.text .. (" "):rep(count * 4 - len) --在字符串后面补上空格,凑成4的倍数
                    end
                    local func = function()
                        for x = 1, count do
                            local i = string2id(data.text:sub(x * 4 - 3, x * 4)) --将4个字符组成一个整数
                            i = i - upload.byte --转化为带符号的整数
                            local k = upload.i2k(x)
                            StoreInteger(upload.gc, "", k, i)
                            SyncStoredInteger(upload.gc, "", k)
                        end
                        StoreInteger(upload.gc, "", "", 1)
                        SyncStoredInteger(upload.gc, "", "")
                    end
                    if data.player == SELFP then
                        func()
                    end
                    for x = 1, count do
                        local k = upload.i2k(x)
                        StoreInteger(upload.gc, "", k, - upload.byte)
                    end
                    StoreInteger(upload.gc, "", "", 0)
                    data.text = nil
                    Loop(0.1,
                        function()
                            for x = last + 1, count do
								last = count
                                local k = upload.i2k(x)
                                local i = GetStoredInteger(upload.gc, "", k)
                                if i == - upload.byte then
                                    last = x - 1
                                    break
                                else
                                    i = i + upload.byte --转化为不带符号的整数
                                    st[x] = id2string(i)
                                end
                            end
                            data.pastbyte = last * 4
                            data.pasttime = GetTime() - starttime
                            data.speed = data.pastbyte / math.max(1, data.pasttime)
                            if data.past then
                                data:past()
                            end
                            if GetStoredInteger(upload.gc, "", "") == 1 then
                                EndLoop()
                                local text = table.concat(st)
                                text = text:sub(1, len) --截取为原本字符串的长度
                                data.text = text
                                if data.finish then
                                    data:finish()
                                end
                            end
                        end
                    )
                end
            )
        end,
    }
    
