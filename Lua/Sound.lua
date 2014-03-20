
    local sounds = {}
    local i = 0
    
    StartSound = function(s, p)
        if type(s) == "string" then
            i = i % 10 + 1
            local sound = CreateSound(s, false, false, false, 10, 10, i)
            if sound then
                if not p or p == SELFP then
                    jass.StartSound(sound)
                    SetSoundVolume(sound, 127)
                end
                table.insert(sounds, {sound, GetTime()})
                --KillSoundWhenDone(sound)
                return sound
            else
                Debug("音效文件不存在:" .. s)
            end
        else
            if s then
                if not p or p == SELFP then
                    jass.StartSound(s)
                    SetSoundVolume(s, 127)
                end
                return s
            else
                Debug("音效文件不存在")
            end
        end
    end
    
    Loop(60,
        function()
            local new = {}
            local time = GetTime()
            for i, data in ipairs(sounds) do
                if time - data[2] > 60 then
                    KillSoundWhenDone(data[1])
                else
                    table.insert(new, data)
                end
            end
            sounds = new
        end
    )
    
    Event("创建英雄", "复活",
        function(data)
            local i = GetUnitPointValue(data.unit)
            local p = GetOwningPlayer(data.unit)
            if HeroReadySound[i] then
                StartSound(HeroReadySound[i], p)
            end
        end
    )
    
