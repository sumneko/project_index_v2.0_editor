	local X = 0
    local Y = 0
    
    TrueSkillId = {
        ["热键"] = {|Q|, |W|, |E|, |R|, |D|, |F|},
        ["热键字符"] = {"Q", "W", "E", "R", "D", "F"},
        ["学习"] = {},
        ["技能"] = {},
        ["主动"] = {},
        ["被动"] = {},
        ["开关"] = {buff = |B069|},
    }
    
    --注册所有技能
    SkillTable = {}
    
    InitSkill = function(data)
        Y = Y + 1
        SkillTable[X*1000+Y] = data --先把技能数据完整的记录在表中
        if SkillTable[data.name] then
            print("<加载技能错误:技能名重复>" .. data.name)
        else
            SkillTable[data.name] = X*1000+Y
        end
        for _, event in ipairs(data.events) do
            data.events[event] = true --建立事件反向表
        end
        --获取技能数据
        data.get = function(data, i)
            local s
            if type(i) == "number" then
                s = data.data[i] or data.undata[i]
            else
                s = data[i]
            end
            if type(s) == "table" then
                s = s[data.lv] or 0
            elseif type(s) == "function" then
                s = s(GetAP(data.unit), GetAD(data.unit), data)
            end
            if s then
                if i == "cool" then
                    s = s * (1 - math.min((Mark(data.unit, "冷却缩减") or 0) / 100, 0.5)) --冷却缩减
                elseif s == "全地图" then
                    s = 999999
                end
            end
            return s or 0
        end
        --一些默认值
        --使用次数
        data.usecount = 0
        --停止次数
        data.stopcount = 0
        --施法时间
        if not data.cast then
            data.cast = 0
        end
        --法力消耗
        if not data.mana then
            data.mana = 0
        end
        --占用图标
        if not data.icon then
            data.icon = 1
        end
        if not data.time then
            if data.type[1] == "主动" then
                data.time = 0.5 + data.cast --主动技能后摇默认0.5
            else
                data.time = 0.001
            end
        elseif data.time == 0 then
            data.time = 0.001
        end
        if type(data.researchtip) == "table" then
            data.research = {}
        end
    end
    
    require "SkillLibrary.lua"
    
    HeroTypeCount = 13 --制作中
    
    local nilTable = {}
    
    for x = 1, HeroTypeCount do
        X = x
        Y = 0
        require(string.format("H%03d.lua", x))
        TrueSkillId["学习"][x] = LearnSkillId
    end
    
    --所有通魔技能ID
    TrueSkillId["技能"][1] = {|A150|, |A16H|, |A16I|, |A16J|, |A16K|, |A16L|}
    TrueSkillId["技能"][2] = {|A154|, |A16M|, |A16N|, |A157|, |A158|, |A16O|}
    TrueSkillId["技能"][3] = {|A159|, |A15A|, |A16P|, |A15C|, |A16Q|, |A16R|}
    TrueSkillId["技能"][4] = {|A15D|, |A15E|, |A15F|, |A16S|, |A16T|, |A16U|}
    TrueSkillId["技能"][5] = {|A15M|, |A15N|, |A15O|, |A15P|, |A16V|, |A16W|}
    TrueSkillId["技能"][6] = {|A15V|, |A15W|, |A15X|, |A15Y|, |A16X|, |A16Y|}
    TrueSkillId["技能"][7] = {|A161|, |A162|, |A163|, |A164|, |A165|, |A16C|}
    TrueSkillId["技能"][8] = {|A16Z|, |A170|, |A171|, |A172|, |A173|, |A174|}
    TrueSkillId["技能"][9] = {|A175|, |A176|, |A177|, |A178|, |A179|, |A17A|}
    TrueSkillId["技能"][10] = {|A17B|, |A17C|, |A17D|, |A17E|, |A17F|, |A17G|}
    
	local Skill = {}
	
	GetHeroSkill = function(u, i)
        if not u then return end
        local t = Mark(u, "技能")
        if t then
            return t[i]
        end
    end
    
    GetSkillIcon = function(t)
        if t then
            return "ReplaceableTextures\\CommandButtons\\" .. t.art[1]
        else
            return "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp"
        end
    end
    
    local GetTipWord = function(s, lv, u, data)
        if type(s) == "table" then
            local t = {}
            for i,ss in ipairs(s) do
                if lv == i then
                    if i == 4 then
                        t[i] = "|cffffff00" .. ss .. "|r"
                    else
                        t[i] = "|cffffff00" .. ss .. "|cff888888"
                    end
                else
                    if i == 1 then
                        t[i] = "|cff888888" .. ss
                    elseif i == 4 then
                        t[i] = ss .. "|r"
                    else
                        t[i] = ss
                    end
                end
            end
            return string.concat(t, "/")
        elseif type(s) == "function" then
            return s(GetAP(u), GetAD(u), data)
        end
        return s
    end
    
    local GetTipWords = function(t)
        local r = {}
        for _,s in ipairs(t.data) do
            table.insert(r, GetTipWord(s, t.lv, t.unit, t))
        end
        return unpack(r)
    end
    
    local GetTip = function(t)
        return string.format(t.tip, GetTipWords(t))
    end
    
    --刷新技能的关闭说明
    SetUnTip = function(u, y)
        local t = Mark(u, "技能")[y]
        if t.lv == 0 then return end
        y = t.y
        local skill = japi.EXGetUnitAbility(u, t.id) --获取技能对象(JAPI)
        local untip = string.format(t.untip, unpack(t.undata))
        local unname = string.format("关闭 |cffffcc00%s|r [|cffffcc00%s|r]", t.tipname or t.name, TrueSkillId["热键字符"][y])
        japi.EXSetAbilityDataString(skill, 1, 216, unname) --标题
        japi.EXSetAbilityDataString(skill, 1, 219, untip) --文本
    end
    
    --刷新技能的说明  单位,第几个技能
    SetSkillTip = function(u, y)
        local t = Mark(u, "技能")[y]
        if not t or t.lv == 0 then return end
        y = t.y
        local skill = japi.EXGetUnitAbility(u, t.id) --获取技能对象(JAPI)
        local tip
        if t.type[1] == "被动" then
            tip = string.format("%s - 等级 |cffffcc00%d|r", t.tipname or t.name, t.lv)
        else
            tip = string.format("%s [|cffffcc00%s|r] - 等级 |cffffcc00%d|r", t.tipname or t.name, TrueSkillId["热键字符"][y], t.lv)
        end
        local tip2
        local tip3 = {}
        if t.cool then
            table.insert(tip3, string.format("|cffcc00ff冷却|r: %s(|cff00ffcc%+.2f|r)", GetTipWord(t.cool, t.lv), -GetCoolDown(u, t.cool, t.lv)))
        end
        if t.rng then
            table.insert(tip3, string.format("|cffcc00ff施法距离|r: %s", GetTipWord(t.rng, t.lv)))
        end
        if t.dur then
            table.insert(tip3, string.format("|cffcc00ff持续时间|r: %s", GetTipWord(t.dur, t.lv)))
        end
        if t.area then
            table.insert(tip3, string.format("|cffcc00ff影响范围|r: %s", GetTipWord(t.area, t.lv)))
        end
        if t.research then
            if t.research == true then
                table.insert(tip3, "\n|cffffff00研发: " .. t.researchtip .. "|r")
            else
                for i = 1, 3 do
                    if t.research[i] then
                        table.insert(tip3, "\n|cffffff00研发: " .. t.researchtip[i] .. "|r")
                    end
                end
            end
        end
        tip3 = string.concat(tip3, "\n")  
        if tip3 == "" then
            tip2 = GetTip(t)
        else
            tip2 = GetTip(t) .. "\n\n" .. tip3
        end
        --文本
        japi.EXSetAbilityDataString(skill, 1, 203, t.tipname or t.name) --名称
        japi.EXSetAbilityDataString(skill, 1, 204, "ReplaceableTextures\\CommandButtons\\" .. (t.art[2] or t.art[1])) --图标
        japi.EXSetAbilityDataString(skill, 1, 215, tip) --标题
        japi.EXSetAbilityDataString(skill, 1, 218, tip2) --文本
        --设置
        japi.EXSetAbilityDataReal(skill, 1, 109, t.type[2] or 0) --目标类型
        japi.EXSetAbilityDataReal(skill, 1, 110, t.type[3] or 1) --通魔选项
        japi.EXSetAbilityDataInteger(skill, 1, 100, t.type[4] or 0) --目标允许
        --耗蓝
        japi.EXSetAbilityDataInteger(skill, 1, 104, t:get("mana")) --耗蓝
        --施法距离
        if t.rng then
            local rng = t:get("rng")
            japi.EXSetAbilityDataReal(skill, 1, 107, rng) --施法距离
        end
        --影响范围
        japi.EXSetAbilityDataReal(skill, 1, 106, t:get("area")) --影响范围
        --持续施法时间
        if t.type[1] ~= "被动" then
            japi.EXSetAbilityDataReal(skill, 1, 108, (t:get("time") or 1) + t:get("cast")) --施法持续时间
            if t.targs then
                japi.EXSetAbilityDataInteger(skill, 1, 100, t.targs) --目标允许
                --刷新数据
                SetUnitAbilityLevel(u, t.id, 2)
                SetUnitAbilityLevel(u, t.id, 1) 
            end
        end
    end
    
    --刷新技能的学习说明  单位,第几个技能
    SetLearnSkillTip = function(u, y)
        local t = Mark(u, "技能")[y]
        if not t then return end
        y = t.y
        local id = GetUnitPointValue(u)
        if (y < 4 and t.lv == 4) or (y == 4 and t.lv == 3 ) then return end
        if t.lv == 0 then
            UnitAddAbility(u, TrueSkillId["学习"][id][y])
        end
        t.lv = t.lv + 1
        local skill = japi.EXGetUnitAbility(u, TrueSkillId["学习"][id][y]) --获取技能对象(JAPI)
        local tip = string.format("学习 |cffffcc00%s|r [|cffffcc00%s|r] - 等级 |cffffcc00%d|r", t.tipname or t.name, TrueSkillId["热键字符"][y], t.lv)
        local tip2
        local tip3 = {}
        if t.mana and t.mana ~= 0 then
            table.insert(tip3, string.format("|cffcc00ff消耗|r: %s", GetTipWord(t.mana, t.lv)))
        end
        if t.cool then
            table.insert(tip3, string.format("|cffcc00ff冷却|r: %s(|cff00ffcc%+.2f|r)", GetTipWord(t.cool, t.lv), -GetCoolDown(u, t.cool, t.lv)))
        end
        if t.rng then
            table.insert(tip3, string.format("|cffcc00ff施法距离|r: %s", GetTipWord(t.rng, t.lv)))
        end
        if t.dur then
            table.insert(tip3, string.format("|cffcc00ff持续时间|r: %s", GetTipWord(t.dur, t.lv)))
        end
        if t.area then
            table.insert(tip3, string.format("|cffcc00ff影响范围|r: %s", GetTipWord(t.area, t.lv)))
        end
        if t.research then
            if t.research == true then
                table.insert(tip3, "\n|cffffff00研发: " .. t.researchtip .. "|r")
            else
                for i = 1, 3 do
                    if t.research[i] then
                        table.insert(tip3, "\n|cffffff00研发: " .. t.researchtip[i] .. "|r")
                    end
                end
            end
        end
        tip3 = string.concat(tip3, "\n")
        if tip3 == "" then
            tip2 = GetTip(t)
        else
            tip2 = GetTip(t) .. "\n\n" .. tip3
        end
        t.lv = t.lv - 1
        japi.EXSetAbilityDataString(skill, 1, 203, t.tipname or t.name) --名称
        japi.EXSetAbilityDataString(skill, 1, 204, "ReplaceableTextures\\CommandButtons\\" .. t.art[1]) --图标
        japi.EXSetAbilityDataString(skill, 1, 214, tip) --学习标题
        japi.EXSetAbilityDataString(skill, 1, 217, tip2) --学习文本
        if t.lv == 0 then
            UnitRemoveAbility(u, TrueSkillId["学习"][id][y])
        end
    end
    
    --刷新技能的所有数据
    RefreshHeroSkills = function(u)
        if Mark(u, "注册英雄") then
            for y = 1, 6 do
                SetSkillTip(u, y)
            end
            for y = 1, 4 do
                SetLearnSkillTip(u, y)
            end
        end
    end
    
    GetTrueSkillId = function(u, y)
        local x = Mark(u, "技能序号")
        if not x then
            for i = 1, 10 do
                if not TrueSkillId["技能"][i][0] then
                    x = i
                    TrueSkillId["技能"][i][0] = u
                    Mark(u, "技能序号", x)
                    break
                end
            end
            if not x then
                print("<注册英雄数量超过10个>")
            end
        end
        return TrueSkillId["技能"][x][y]
    end
    
    local GetSkill2 = function(u, sid, data, heroskill)
        if not SkillTable[sid] then
            print("<没有找到技能>编号:" .. sid)
            return
        end
        local skills = Mark(u, "技能")
        local id = GetUnitPointValue(u)
        
        --记录技能
        local t = table.copy(SkillTable[sid], true)
        if data then
            for k, v in pairs(data) do
                t[k] = v
            end
        end
        t.sid = sid
        
        --获取技能位置
        local scount
        if heroskill then
            scount = #skills + 1
        else
            for i = 5, 99 do
                if not skills[i] then
                    scount = i
                    break
                end
            end
        end
        
        --记录技能真实id
        local ty = t.type[1]
        t.id = GetTrueSkillId(u, scount)
        if not t.id then return end
        
        --设置剩余图标
        if heroskill then
            local c = t.icon or 1 --获取技能占用图标数量
            local uc = Mark(u, "空余图标")
            Mark(u, "空余图标", uc - c)
        end
        
        --记录技能拥有者
        t.unit = u
        t.player = GetOwningPlayer(u)
        
        --记录这是第几个技能
        t.y = scount
        skills[scount] = t
        skills[t.id] = t
        skills[t.name] = t
        local lid = TrueSkillId["学习"][id][scount]
        if lid and heroskill then
            skills[lid] = t
        
            --准备修改学习技能的说明文字
            t.lv = 0
            UnitAddAbility(u, lid)
            SetLearnSkillTip(u, scount)
            UnitRemoveAbility(u, lid)
        
        end
        
        --直接添加技能
        if not heroskill then
            t.lv = t.lv or 1
            UnitAddAbility(u, t.id)
            UnitMakeAbilityPermanent(u, true, t.id)
            toEvent("获得技能", {unit = u, skill = t.id, abil = t})
            if t.lv > 1 then
                for i = 1, t.lv - 1 do
                    toEvent("升级技能", {unit = u, skill = t.id, abil = t})
                end
            end
        end
        
        return t
    end
	
	local GetSkill = function(u, x, y)
        if x == 0 then --安装黄点
            local uc = Mark(u, "空余图标")
            if uc > 0 then --剩余图标大于0时替换成有图标的黄点
                UnitAddAbility(u, |A0TN|)
                UnitRemoveAbility(u, |A0TN|)
            end
        else --安装技能
            GetSkill2(u, x*1000+y, nil, true)
        end
    end
    
    --安装技能
    AddSkill = function(u, name, data)
        local id = SkillTable[name]
        if not id then
            --如果是dummy技能或茵蒂克丝偷取技能等会在技能名后加括号,尝试去掉括号进行匹配
            local x = name:find("%(")
            if not x then return end
            name = name:sub(1, x - 1)
            id = SkillTable[name]
            if not id then return end
        end
        return GetSkill2(u, id, data)
    end
    
    --移除技能
    RemoveSkill = function(u, name)
        local skill = findSkillData(u, name)
        if not skill then return end
        local id = skill.id
        local skills = Mark(u, "技能")
        if skill.type[1] == "开关" and skill.openflag then
            skill:closeskill()
        end
        toEvent("失去技能", {unit = u, skill = id, abil = skill})
        UnitRemoveAbility(u, id)
        for i = 5, 99 do
            if skills[i] == skill then
                skills[i] = nil
                break
            end
        end
        skills[skill.id] = nil
        skills[skill.name] = nil
        skill.id = 0
        return true
    end
	
	--给英雄装备技能
    HeroGetSkill = function(u)
        local x = GetUnitPointValue(u) --英雄编号
        Mark(u, "技能", {}) --保存英雄的技能
        Mark(u, "空余图标", 6) --英雄的空余图标为6
        if table.has(GameMode, "SS") then --自选技能
        else
            for y = 1, 4 do
                GetSkill(u, x, y) --安装技能
            end
            GetSkill(u, 0) --安装黄点
        end
    end
    
    --学习技能
    local hasInit = {}
    
    Event("学习技能",
        function(data)
            local u = data.unit
            local id = data.skill
            local uid = GetUnitPointValue(u)
            if id == |A00J| or id == |A0L0| then
                Sai(u, 3, 3, 3) --所有属性加成3点
                return
            end
            local y = 0
            for i = 1, 4 do
                if id == TrueSkillId["学习"][uid][i] then
                    y = i
                    break
                end
            end
            local t = Mark(u, "技能")[y]
            local lv = GetUnitAbilityLevel(u, id)
            t.lv = lv
            if lv == 1 then
                --获得技能
                UnitAddAbility(u, t.id)
                UnitMakeAbilityPermanent(u, true, t.id)
                toEvent("获得技能", {unit = u, skill = t.id, abil = t})
                if not table.has(hasInit, t.name) then
                    table.insert(hasInit, t.name)
                    toEvent("注册技能", {unit = u, skill = t.id, abil = t})
                end
            else
                --升级技能
                toEvent("升级技能", {unit = u, skill = t.id, abil = t})
            end
        end
    )
    
    --注册技能(技能第一次出现在游戏中)
    Event("注册技能",
        function(data)
            local skill = SkillTable[data.abil.sid] --获取技能的原始模板
            --回调函数
            if skill.events[data.event] then
                skill.event = data.event
                skill:code()
            end
        end
    )
    
    --获得/升级技能
    Event("获得技能", "升级技能",
        function(data)
            local u = data.unit
            local id = data.skill
            local skill = data.abil
            local ab = japi.EXGetUnitAbility(u, id)
            if skill.type[1] == "被动" then
                japi.EXSetAbilityDataReal(ab, 1, 105, 1000000)
                japi.EXSetAbilityState(ab, 1, 10000) --将被动技能设置为永久处于冷却状态
            else
                japi.EXSetAbilityDataReal(ab, 1, 105, 0)
            end
            SetSkillTip(u, skill.y)
            SetLearnSkillTip(u, skill.y)
            
            --回调函数
            if skill.events[data.event] then
                skill.event = data.event
                skill:code()
            end
        end
    )
    
    --发动技能
    Event("发动技能", "施放结束", "停止施放",
        function(data)
            local skill = findSkillData(data.unit, data.skill)
            if skill then
                local y = skill.y
                
                if data.event == "发动技能" then
                    if skill.type[1] == "开关" and skill.openflag then
                        skill.userclose = true
                        skill:closeskill()
                        return
                    end
                    Wait(0,
                        function()
                            if skill.ani then
                                SetUnitAnimation(data.unit, skill.ani)
                                --QueueUnitAnimation(data.unit, "stand")
                            end
                            --返还法力
                            SetUnitState(data.unit, UNIT_STATE_MANA, GetUnitState(data.unit, UNIT_STATE_MANA) + skill:get("mana"))
                        end
                    )
                    
                    skill.target = GetSpellTargetUnit() or GetSpellTargetItem() or GetSpellTargetLoc()
                    
                    skill.usecount = skill.usecount + 1
                    
                    local stop = skill.stopcount
                    Wait(skill:get("cast"),
                        function()
                            if stop == skill.stopcount then --表示依然在施放这个技能的过程中
                                local mana = skill:get("mana")
                                if GetUnitState(data.unit, UNIT_STATE_MANA) > mana then
                                    --扣除法力值
                                    SetUnitState(data.unit, UNIT_STATE_MANA, GetUnitState(data.unit, UNIT_STATE_MANA) - mana)
                                    --发起事件
                                    skill.spellflag = GetTime()
                                    skill.targetcooltime = skill.spellflag + (skill:get("cool") or 0)
                                    toEvent("发动英雄技能", {unit = data.unit, skill = data.skill, name = skill.tipname or skill.name, data = skill})
                                    if skill.events["发动技能"] then
                                        skill.event = "发动技能"
                                        skill:code()
                                        toEvent("英雄技能回调", {skill = skill})
                                    end
                                    toEvent("发动英雄技能后", {unit = data.unit, skill = data.skill, name = skill.name, data = skill})
                                    --开关类技能
                                    if skill.type[1] == "开关" then
                                    
                                        --修改技能说明与图标
                                        if skill.untip then
                                            skill.tip, skill.untip = skill.untip, skill.tip
                                            skill.data, skill.undata = skill.undata, skill.data
                                        end
                                        if skill.art[3] then
                                            skill.art[2], skill.art[3] = skill.art[3], skill.art[2]
                                        end
                                        
                                        skill.type2 = skill.type
                                        skill.type = {"开关"}
                                        
                                        skill.time2, skill.cast2 = skill.time, skill.cast
                                        skill.time, skill.cast = 0.001, 0
                                        
                                        --修改耗蓝
                                        skill.mana2 = skill.mana
                                        skill.mana = 0
                                        SetSkillTip(skill.unit, skill.y)
                                        RefreshTips(skill.unit)
                                        skill.openflag = skill.spellflag
                                        
                                        
                                        --关闭技能函数
                                        skill.closeskill = function(skill)
                                            if not skill.openflag then
                                                return
                                            end
                                            skill.openflag = false
                                            if skill.untip then
                                                skill.tip, skill.untip = skill.untip, skill.tip
                                                skill.data, skill.undata = skill.undata, skill.data
                                            end
                                            
                                            if skill.art[3] then
                                                skill.art[2], skill.art[3] = skill.art[3], skill.art[2]
                                            end
                                            
                                            skill.type = skill.type2
                                            
                                            skill.time, skill.cast = skill.time2, skill.cast2
                                            
                                            if skill.events["关闭技能"] then
                                                skill.event = "关闭技能"
                                                skill:code()
                                                toEvent("英雄技能回调", {skill = skill})
                                            end
                                            
                                            skill.userclose = false
                                            
                                            Wait(0,
                                                function()
                                                    skill.mana = skill.mana2 --将法力值互换移动到0秒后以免手动关闭会扣蓝
                                                    SetSkillTip(skill.unit, skill.y)
                                                    RefreshTips(skill.unit)
                                                    --开始冷却
                                                    local ab = japi.EXGetUnitAbility(skill.unit, skill.id)
                                                    local cd
                                                    if skill.freshcool then
                                                        cd = skill.freshcool
                                                        skill.freshcool = false
                                                    else
                                                        cd = skill.targetcooltime - GetTime()
                                                    end
                                                    if cd > 0 then
                                                        japi.EXSetAbilityDataReal(ab, 1, 105, math.max(cd, skill:get("cool")))
                                                        japi.EXSetAbilityState(ab, 1, cd)
                                                        japi.EXSetAbilityDataReal(ab, 1, 105, 0)
                                                        --SetUnitAnimation(skill.unit, "stand")
                                                        --IssueImmediateOrder(skill.unit, "stop")
                                                    end
                                                    
                                                end
                                            )
                                           
                                        end
                                        
                                        local count = skill.usecount
                                        if skill.dur then
                                            local dur
                                            if type(skill.dur) == "table" then
                                                dur = skill.dur[skill.lv]
                                            else
                                                dur = skill.dur
                                            end
                                            skill.closeReason = "use"
                                            Wait(dur,
                                                function()
                                                    if count == skill.usecount then
                                                        skill.closeReason = "dur"
                                                        skill:closeskill()
                                                    end
                                                end
                                            )
                                        end
                                    elseif skill.type[1] == "主动" then
                                        --开始技能冷却
                                        local cd
                                        if skill.freshcool then
                                            cd = skill.freshcool
                                            skill.freshcool = false
                                        else
                                            cd = skill:get("cool")
                                        end
                                        if cd then
                                            local ab = japi.EXGetUnitAbility(data.unit, skill.id)
                                            --Debug("<handle>" .. GetHandleId(ab) .. "<id>" .. skill.id .. "<cd>" .. cd)
                                            japi.EXSetAbilityDataReal(ab, 1, 105, cd)
                                            japi.EXSetAbilityState(ab, 1, cd)
                                            japi.EXSetAbilityDataReal(ab, 1, 105, 0)
                                        end
                                    end
                                end
                            end
                        end
                    )
                end
                --回调函数
                if data.event ~= "发动技能" and skill.events[data.event] then
                    skill.event = data.event
                    skill:code()
                    toEvent("英雄技能回调", {skill = skill})
                end
                if data.event == "停止施放" then
                    skill.spellflag = false
                    skill.stopcount = 1 + skill.stopcount
                end
            end
        end
    )
    
    Event("死亡",
        function(data)
            if IsHero(data.unit) then
                for i = 1, 6 do
                    local skill = findSkillData(data.unit, i)
                    if skill then
                        if skill.type[1] == "开关" and skill.openflag then
                            skill:closeskill()
                        end
                    end
                end
            end
        end
    )
    
    Event("升级",
        function(data)
            if Mark(data.unit, "注册英雄") then
                RefreshHeroSkills(data.unit)
                RefreshTips(data.unit)
            end
        end
    )
    
    Event("失去技能",
        function(data)
            local skill = data.abil
            --回调函数
            if skill.events[data.event] then
                skill.event = data.event
                skill:code()
            end
        end
    )
    
    --被动技能校正
    Loop(150,
        function()
            for _, u in ipairs(AllHeroes) do
                for i = 1, 6 do
                    local this = findSkillData(u, i)
                    if this and this.type[1] == "被动" then
                        local ab = japi.EXGetUnitAbility(u, this.id)
                        local mcd = japi.EXGetAbilityDataReal(ab, 1, 105)
                        if mcd == 1000000 then
                            japi.EXSetAbilityState(ab, 1, 10000)
                        end
                    end
                end
            end
        end
    )
