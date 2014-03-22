    
    --给玩家创建商店
    local u = {Shop[0], Shop[1]}
    Shop[0], Shop[1] = nil, nil
    
    ShowUnit(u[1], false)
    ShowUnit(u[2], false)
    
    Event("创建英雄",
        function(data)
            local p = GetOwningPlayer(data.unit)
            local i = GetPlayerId(p)
            if not Shop[i] then
                local tid = GetPlayerTeam(p) + 1
                Shop[i] = CreateUnit(p, |e032|, GetUnitX(u[tid]), GetUnitY(u[tid]), 270)
                if SELF ~= i then
                    SetUnitFlyHeight(Shop[i], 5000, 0)
                end
                UnitRemoveAbility(Shop[i], |Amov|)
                InitShop(Shop[i])
            end
        end
    )
    
    --给商店添加技能
    local shopSkills = {
        {
            |A17U|,
            |A17Y|,
            |A182|
        },
        {
            |A17V|,
            |A17Z|,
            |A183|
        },
        {
            |A17W|,
            |A180|,
            |A184|
        },
        {
            |A17X|,
            |A181|,
            |A185|
        }
    }
    
    --根据技能ID获取该技能的位置
    local nowPage = {}
    
    for x = 1, 4 do
        for y = 1, 3 do
            local id = shopSkills[x][y]
            shopSkills[id] = {x, y}
            table.insert(shopSkills, id)
        end
    end
    
    --预读商店图标
    ForLoop(0.5, #shopSkills,
        function(i)
            local id = shopSkills[i]
            if type(id) == "number" then
                UnitAddAbility(Dummy, id)
                local ab = japi.EXGetUnitAbility(Dummy, id)
                local mlv = tonumber(getObj(slk.ability, id, "levels", 1))
                for i = 1, mlv do
                    japi.EXSetAbilityDataReal(ab, i, 110, 1) --显示图标
                end
                UnitRemoveAbility(Dummy, id)
            end
        end
    )
    
    GetShopItemXY = function(id)
        return unpack(shopSkills[id])
    end
    
    GetShopItemName = function(u, id)
        local x, y = GetShopItemXY(id)
        return nowPage[u][x][y]
    end
    
    local shopSkillKeys = {
        {
            'Q',
            'A',
            'Z'
        },
        {
            'W',
            'S',
            'X'
        },
        {
            'E',
            'D',
            'C'
        },
        {
            'R',
            'F',
            'V'
        }
    }
    
    local shopAction, oldShopAction = require "ShopItems.lua"
    local trg = CreateTrigger()
    TriggerAddCondition(trg, Condition(shopAction))
    
    local shopRefreshTrg = CreateTrigger()
    TriggerAddCondition(shopRefreshTrg, Condition(
        function()
            local u = GetTriggerUnit()
            if GetTriggerEventId() == EVENT_UNIT_SELECTED then
                RefreshShopPage(u)
                if not Mark(u, "商店刷新计时器") then
                    Mark(u, "商店刷新计时器", Loop(0.5, 
                        function()
                            RefreshShopPage(u)
                        end
                    ))
                end
            else
                local timer = Mark(u, "商店刷新计时器")
                if timer then
                    DestroyTimer(timer)
                    Mark(u, "商店刷新计时器", false)
                end
            end
        end
    ))
    
    InitShop = function(u)
        nowPage[u] = {}
        for x = 1, 4 do
            nowPage[u][x] = {}
            for y = 1, 3 do
                UnitAddAbility(u, shopSkills[x][y])
            end
        end
        
        TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_SPELL_EFFECT)
        TriggerRegisterUnitEvent(shopRefreshTrg, u, EVENT_UNIT_SELECTED)
        TriggerRegisterUnitEvent(shopRefreshTrg, u, EVENT_UNIT_DESELECTED)
        
        OpenShopPage(u, "#商店主页")
    end
    
    local xy2i = function(x, y)
        return x + y * 4 - 4
    end
    
    SetShop = function(u, t)
        for x = 1, 4 do
            for y = 1, 3 do
                SetShopItem(u, x, y, t[xy2i(x, y)])
            end
        end
        RefreshTips(u)
    end
    
    RefreshShopPage = function(u)
        local t = nowPage[u]
        for x = 1, 4 do
            for y = 1, 3 do
                SetShopItem(u, x, y, t[x][y])
            end
        end
        RefreshTips(u)
    end
    
    SetShopItem = function(u, x, y, name)
        local p = GetOwningPlayer(u)
        nowPage[u][x][y] = name
        if name then
            SetPlayerAbilityAvailable(p, shopSkills[x][y], true)
            local ab = japi.EXGetUnitAbility(u, shopSkills[x][y])
            local first = string.sub(name, 1, 1)
            if first == "#" then
                --页面
                local page = GetShopPage(name)
                --准备修改技能数据
                if SELFP == p then
                    japi.EXSetAbilityDataString(ab, 1, 204, page.art) --修改图标
                    japi.EXSetAbilityDataString(ab, 1, 215, string.format("|cffffcc00%s|r - [|cffffcc00%s|r]", string.sub(name, 2), shopSkillKeys[x][y])) --修改标题
                    japi.EXSetAbilityDataString(ab, 1, 218, page.tip) --修改文字内容
                end
            elseif first == "@" then
                --特殊页面
                local page = GetShopPage(name)
                --准备修改技能数据
                if SELFP == p then
                    japi.EXSetAbilityDataString(ab, 1, 204, page.art) --修改图标
                    japi.EXSetAbilityDataString(ab, 1, 215, string.format("|cffffcc00%s|r - [|cffffcc00%s|r]", string.sub(name, 2), shopSkillKeys[x][y])) --修改标题
                    japi.EXSetAbilityDataString(ab, 1, 218, page.tip) --修改文字内容
                end
            elseif first == "$" then
                --付费
                local item = GetItem(string.sub(name, 2))
                --准备修改技能数据
                if SELFP == p then --进行本地修改
                    japi.EXSetAbilityDataString(ab, 1, 204, item.art) --修改图标
                    japi.EXSetAbilityDataString(ab, 1, 215, "|cffffcc00购买|r") --修改标题
                    japi.EXSetAbilityDataString(ab, 1, 218, string.format("[|cffffcc00%s|r] - [%s] - [|cffffcc00%s|r]\n\n%s", item.name, item.coststring, shopSkillKeys[x][y], GetShopItemTip(p, item))) --修改文字内容
                end
            else
                --浏览物品
                local tip
                if first == "<" then
                    name = string.sub(name, 2)
                    tip = "|cffffcc00查看 |cff11ff11合成材料|r"
                elseif first == ">" then
                    name = string.sub(name, 2)
                    tip = "|cffffcc00查看 |cffff11ff晋级装备|r"
                else
                    tip = "|cffffcc00查看 (双击购买)|r"
                end
                local item = GetItem(name)
                --准备修改技能数据
                if SELFP == p then --进行本地修改
                    japi.EXSetAbilityDataString(ab, 1, 204, item.art) --修改图标
                    japi.EXSetAbilityDataString(ab, 1, 215, tip) --修改标题
                    japi.EXSetAbilityDataString(ab, 1, 218, string.format("[|cffffcc00%s|r] - [%s] - [|cffffcc00%s|r]\n\n%s", item.name, item.coststring, shopSkillKeys[x][y], GetShopItemTip(p, item))) --修改文字内容
                end
            end
            
        elseif name == false then
            SetPlayerAbilityAvailable(p, shopSkills[x][y], false)
        end
    end
    
    --注册商店页面
    local shopPages = {}
    
    InitShopPage = function(t)
        shopPages[t.name] = t
    end
    
    GetShopPage = function(name)
        return shopPages[name]
    end
    
    OpenShopPage = function(u, name)
        nowPage[u][0] = name --记录当前页面的名字
        SetShop(u, shopPages[name].items)
    end
    
    GetCurrentShopPage = function(u)
        return nowPage[u][0]
    end
    
    --声明页面    
    InitShopPage{
        name = "#商店主页",
        art = "ReplaceableTextures\\WorldEditUI\\Editor-Random-Unit.blp",
        tip = "返回商店主页",
        items = {
            "#无坚不摧", "#奥术光辉", "#神兵利器", "#小卖部",
            "#因材施教", "#生命之源", "#荣耀守卫", false,
            "#迅疾如风", "#能量之源", "#备用仓库", "@查看背包",
        }
    }
    
    InitShopPage{
        name = "#无坚不摧",
        art = "ReplaceableTextures\\CommandButtons\\BTNSpiritWalkerMasterTraining.blp",
        tip = "与物理攻击相关的装备",
        items = {
            "菜刀", "吸血鬼指环", "锐眼之石", "太刀",
            "大斧", "吸血鬼之触", "魔眼之石", "七天七刀",
            "长枪", "血族面具",   "天丛云剑", "#商店主页",
        }
    }
    
    InitShopPage{
        name = "#因材施教",
        art = "ReplaceableTextures\\CommandButtons\\BTNHelmutPurple.blp",
        tip = "与属性相关的装备",
        items = {
            "力量手套", "敏捷指环", "智力斗篷",       "呱太",
            "力量之锤", "敏捷之靴", "智力挂饰",       "能量增幅器",
            "重型战斧", "莺歌弓",   "大魔法师的秘典", "#商店主页",
        }
    }
    
    InitShopPage{
        name = "#迅疾如风",
        art = "ReplaceableTextures\\CommandButtons\\BTNTrueShot.blp",
        tip = "与速度相关的装备",
        items = {
            "跑鞋",       "上条牌运动鞋", "加速手套",     "天丛云剑",
            false,        "动能装置",     "唤灵之笛",     false,
            "特制弹跳鞋", "奥术鞋",       "高能震动短剑", "#商店主页",
        }
    }
    
    InitShopPage{
        name = "#奥术光辉",
        art = "ReplaceableTextures\\CommandButtons\\BTNMagicalSentry.blp",
        tip = "与技能相关的装备",
        items = {
            "黑曜石",     "散热器",   "血珠",     "莲花杖",
            "魔能法杖",   "冷凝核心", "恶魔坠饰", false,
            "携带能量点", "钻石星辰", "血族面具", "#商店主页",
        }
    }
    
    InitShopPage{
        name = "#生命之源",
        art = "ReplaceableTextures\\CommandButtons\\BTNInnerFire.blp",
        tip = "与生命和护甲相关的装备",
        items = {
            "初春的花环", "守护指环", "生命甲", "警备员的防护服",
            "生命宝珠",   "锁子甲",   "天使铠", "驱动铠",
            "魔能宝珠",   "防暴盾",   false,    "#商店主页",
        }
    }
    
    InitShopPage{
        name = "#能量之源",
        art = "ReplaceableTextures\\CommandButtons\\BTNNeutralManaShield.blp",
        tip = "与法力和抗性相关的装备",
        items = {
            "月之石",   "幸运护符", "演算代理装置", "驱魔项链",
            "能量宝珠", "主教服",   "风神杖",       "黑刃魔剑",
            "魔能宝珠", "大主教服", "魔神之杖",     "#商店主页",
        }
    }
    
    InitShopPage{
        name = "#神兵利器",
        art = "ReplaceableTextures\\CommandButtons\\BTNFrostMourne.blp",
        tip = "与攻击效果相关的装备",
        items = {
            "稀有呱太", "寒玉",         "净化宝珠", "伪焰形剑",
            "皮鞭",     "霜刃",         "净化之刃", "焰形剑",
            "天丛云剑", "亚德里亚之枪", "光电子剑", "#商店主页",
        }
    }
    
    InitShopPage{
        name = "#荣耀守卫",
        art = "ReplaceableTextures\\CommandButtons\\BTNMassTeleport.blp",
        tip = "与团队相关的装备",
        items = {
            "空气净化装置", "圣光护腕", "巫毒玩偶", "负之遗产",
            "护盾发生器",   "圣光庇护", false,      "君士坦丁大帝之书",
            "天空之墙",     "圣光普照", false,      "#商店主页",
        }
    }
    
    InitShopPage{
        name = "#备用仓库",
        art = "ReplaceableTextures\\CommandButtons\\BTNSpellSteal.blp",
        tip = "在商店翻页系统完成前,其他商店放不下的物品会暂时先放在这里",
        items = {
            "风之鞭",   false, false, false,
            "风魔之弦", false, false, false,
            false,      false, false, "#商店主页",
        }
    }
    
    InitShopPage{
        name = "#小卖部",
        art = "ReplaceableTextures\\CommandButtons\\BTNPotionGreen.blp",
        tip = "消耗品(|cffff1111注意!此页面中的道具单击即可购买|r)",
        items = {
            "$当麻面包", "$运动饮料",       false, false,
            "$镇定剂",   "$黑子的电脑配件", false, false,
            "$体晶",     "$扰乱之羽",       false, "#商店主页",
        }
    }
    
    InitShopPage{
        name = "@查看背包",
        art = "ReplaceableTextures\\CommandButtons\\BTNDustOfAppearance.blp",
        tip = "查看你背包中已经拥有的物品类型",
    }
    
    --传统商店
    
    local ou = {OldShop[0], OldShop[1]}
    OldShop[0], OldShop[1] = nil, nil
    
    for _, u in ipairs(ou[1]) do
        ShowUnit(u, false)
    end
    for _, u in ipairs(ou[2]) do
        ShowUnit(u, false)
    end
    
    Event("创建英雄",
        function(data)
            local p = GetOwningPlayer(data.unit)
            local i = GetPlayerId(p)
            if not OldShop[i] then
                local tid = GetPlayerTeam(p) + 1
                OldShop[i] = {}
                for count, u in ipairs(ou[tid]) do
                    OldShop[i][count] = CreateUnit(p, GetUnitTypeId(u), GetUnitX(u), GetUnitY(u), 270)
                    if SELF ~= i then
                        SetUnitFlyHeight(OldShop[i][count], 5000, 0)
                    end
                    UnitRemoveAbility(OldShop[i][count], |Amov|)
                    SetUnitUserData(OldShop[i][count], count)
                    InitOldShop(OldShop[i][count], count)
                end
            end
        end
    )
    
    trg = CreateTrigger()
    TriggerAddCondition(trg, Condition(oldShopAction))
    
    InitOldShop = function(u, count)
        for x = 1, 4 do
            for y = 1, 3 do
                UnitAddAbility(u, shopSkills[x][y])
                SetUnitAbilityLevel(u, shopSkills[x][y], count)
            end
        end
        
        TriggerRegisterUnitEvent(trg, u, EVENT_UNIT_SPELL_EFFECT)
        
        
    end
