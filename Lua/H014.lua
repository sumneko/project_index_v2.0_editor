    
    HeroName[14] = "时崎狂三"
    HeroMain[14] = "敏捷"
    HeroType[14] = |Harf|
    RDHeroType[14] = |h017|
    HeroTypePic[14] = "ReplaceableTextures\\CommandButtons\\BTNSaber.blp"
    HeroSize[14] = 1.2
    LearnSkillId = {|A1A5|, |A1A6|, |A1A7|, |A1A8|}
    
    --吞噬时间
    InitSkill{
        name = "吞噬时间",
        type = {"开关"},
        ani = "stand",
        art = {"BTNFeedBack.blp", "BTNFeedBack.blp", "BTNWispSplode.blp"}, --左边是学习,右边是普通.不填右边视为左边
        tip = [[
|cffff00cc开启:|r
攻击时以消耗自身时间为代价,夺取对方的时间.
|cffff00cc被动:|r
杀死单位将获得永久的生命值上限提升.

|cff00ffcc技能|r: 无目标
|cff00ffcc伤害|r: 混合

|cffffcc00消耗生命|r: |cffff1111%d|r(自身当前生命值的%s%%)
|cffffcc00吸取生命|r: %s%%(对方当前生命值的百分比)
|cffffcc00生命上限提升(英雄)|r: %s(|cff1111ff+%d|r)
|cffffcc00生命上限提升(非英雄)|r: %s

|cffffcc00此技能已经为你提升的生命值上限|r: %s

|cff888888视为对自己造成伤害]],
        researchtip = "单位被麻痹时受到伤害,数值相当于额外伤害的5倍",
        data = {
            0, --消耗生命1
            10, --消耗百分比2
            {10, 12, 14, 16}, --对方生命百分比3
            {10, 15, 20, 25}, --生命上限(英雄)4
            function(ap) --生命上限(英雄)加成5
                return ap * 0.2
            end,
            {2, 3, 4, 5}, --生命提升(非英雄)6
            0, --已经提升的上限7
        },
        events = {"获得技能", "失去技能", "发动技能", "关闭技能"},
        code = function(this)
            if this.event == "发动技能" then
                Mark(this.unit, "弹道模型", "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl")
                
                local func1 = Event("攻击出手",
                    function(damage)
                        if damage.from == this.unit then
                            local d = GetUnitState(this.unit, UNIT_STATE_LIFE) * this:get(2) * 0.01
                            Damage(this.unit, this.unit, d, true, true, {damageReason = this.name})
                            
                            local x = this:get(3)
                            
                            table.insert(damage.attackfuncs,
                                function(damage)
                                    local d = GetUnitState(damage.to, UNIT_STATE_LIFE) * x * 0.01
                                    local damage = Damage(damage.from, damage.to, d, true, true, {damageReason = this.name})
                                    
                                    local hp = damage.damage
                                    
                                    if hp > 0 then
                                        MoverEx(
                                            {
                                                from = damage.from,
                                                source = damage.to,
                                                target = MovePoint(damage.to, {GetRandomInt(100, 200), GetRandomInt(1, 360)}),
                                                good = true,
                                                modle = "a13_hong.mdx",
                                                size = 1,
                                                speed = GetRandomInt(200, 300),
                                                z = 50,
                                                tz = 0,
                                                high = 150,
                                            },
                                            nil,
                                            nil,
                                            function(move)
                                                move.func2 = function(move)
                                                    if IsUnitAlive(move.target) then
                                                        Heal(move.target, move.target, hp, {healReason = this.name})
                                                    end
                                                end
                                                
                                                move.target = move.from
                                                move.speed = 300
                                                move.z = 0
                                                move.tz = 50
                                                move.func3 = nil
                                                
                                                move.initstep() --重置移动器计算
                                                
                                                return true --阻止移动器结束
                                                
                                            end
                                        )
                                    end
                                end
                            )
                        end
                    end
                )
                
                this.flush = function()
                    Mark(this.unit, "弹道模型", false)
                    Event("-攻击出手", func1)
                end
            elseif this.event == "关闭技能" then
                this.flush()
            elseif this.event == "获得技能" then
                local t = Loop(0.2,
                    function()
                        this.data[1] = GetUnitState(this.unit, UNIT_STATE_LIFE) * this:get(2) * 0.01
                        SetSkillTip(this.unit, this.id)
                    end
                )
                
                local func1 = Event("死亡",
                    function(data)
                        if data.killer == this.unit then
                            local hp
                            if IsHero(data.unit) then
                                hp = this:get(4) + this:get(5)
                            else
                                hp = this:get(6)
                            end
                            hp = math.floor(hp)
                            MoverEx(
                                {
                                    from = this.unit,
                                    source = data.unit,
                                    target = this.unit,
                                    good = true,
                                    modle = "a13_hong.mdx",
                                    size = 2,
                                    speed = 500,
                                    z = 50,
                                    tz = 100,
                                    high = 150,
                                },
                                nil,
                                function(move)
                                    if IsUnitAlive(move.target) then
                                        MaxLife(move.target, hp, true)
                                        this.data[7] = this.data[7] + hp
                                    end
                                end
                            )
                        end
                    end
                )
                
                this.loseflush = function()
                    DestroyTimer(t)
                    Event("-死亡", func1)
                end
            elseif this.event == "失去技能" then
                this.loseflush()
            end
        end
    }
    
    --Alef Bet Dalet
    InitSkill{
        name = "Alef Bet Dalet",
        type = {"开关", },
        art = {"BTNFeedBack.blp", "BTNFeedBack.blp", "BTNWispSplode.blp"}, --左边是学习,右边是普通.不填右边视为左边
        targs = GetTargs("地面,空中,英雄"),
        mana = {75, 100, 125, 150},
        time = 2.5,
        cool = 30,
        tip = [[
|cffff1111%d 生命值|r%s

|cffff00cc对友方:|r
发射一之弹,加快其行动速度.
|cffff00cc对敌方:|r
发射二之弹,减慢其行动速度.

|cffff00cc再次激活:|r
发射四之弹,令其时间倒流,其生命值,法力值与位置回溯到之前的位置

|cff00ffcc技能|r: 英雄目标

|cffffcc00加速(攻击速度与移动速度)|r: %s  %s
|cffffcc00加速(攻击速度与移动速度)|r: %s  %s
|cffffcc00持续时间|r: %s(|cff1111ff+%.2f|r)

|cff888888施法延迟2.5秒,施放失败冷却时间将变为5秒
弹道速度为%s
四之弹所能回溯到的最远时间为你一之弹或二之弹击中他的时间
回溯过程中依然可以收到伤害或治疗,并合并生命值变化
如果四之弹击中对方时,其一之弹或二之弹效果已经结束则四之弹无效]],
        researchtip = "单位被麻痹时受到伤害,数值相当于额外伤害的5倍",
        data = {
            0, --生命值消耗1
            "", --预留2
            {75, 110, 145, 180}, --攻速增加3
            {50, 75, 100, 125}, --移速增加4
            {50, 75, 100, 125}, --攻速降低5
            {30, 45, 60, 75}, --移速降低6
            {2, 3, 4, 5}, --持续时间7
            function(ap) --持续时间加成9
                return ap * 0.05
            end,
        },
        events = {"获得技能", "失去技能", "发动技能", "关闭技能"},
        code = function(this)
        end
    }
    
    --吞噬时间
    InitSkill{
        name = "吞噬时间3",
        type = {"开关"},
        ani = "stand",
        art = {"BTNFeedBack.blp", "BTNFeedBack.blp", "BTNWispSplode.blp"}, --左边是学习,右边是普通.不填右边视为左边
        tip = [[]],
        researchtip = "单位被麻痹时受到伤害,数值相当于额外伤害的5倍",
        data = {
        },
        events = {"获得技能", "失去技能", "发动技能", "关闭技能"},
        code = function(this)
        end
    }
    
    --吞噬时间
    InitSkill{
        name = "吞噬时间4",
        type = {"开关"},
        ani = "stand",
        art = {"BTNFeedBack.blp", "BTNFeedBack.blp", "BTNWispSplode.blp"}, --左边是学习,右边是普通.不填右边视为左边
        tip = [[]],
        researchtip = {
            "单位被麻痹时受到伤害,数值相当于额外伤害的5倍",
            "",
            "",
        },
        data = {
        },
        events = {"获得技能", "失去技能", "发动技能", "关闭技能"},
        code = function(this)
        end
    }
    
