    
    HeroName[13] = "阿尔托莉亚"
    HeroMain[13] = "力量"
    HeroType[13] = |Ewrd|
    RDHeroType[13] = |h017|
    HeroTypePic[13] = "ReplaceableTextures\\CommandButtons\\BTNSaber.blp"
    HeroSize[13] = 0.93
    LearnSkillId = {|A1A1|, |A1A2|, |A1A3|, |A1A4|}
    
    --解放真名
    InitSkill{
        name = "解放真名",
        type = {"开关"},
        ani = "stand",
        art = {"BTNFeedBack.blp", "BTNFeedBack.blp", "BTNWispSplode.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = 75,
        dur = 30,
        area = 600,
        tip = "\
|cffff00cc主动:|r解放石中剑的真名,使你可以使用更加强大的技能,但是失去该技能的被动效果.如果你在风王结界状态下维持了至少%s秒的时间,你将对周围的单位造成伤害并|cffffcc00减速|r.\
|cffff00cc被动:|r风暴隐藏了你的武器,使你更加容易的击中敌人的要害,获得暴击率的提升.\
|cff00ffcc技能|r: 无目标\
|cff00ffcc伤害|r: 法术\n\
|cffffcc00造成伤害|r: %s(|cff0000ff+%d|r)\
|cffffcc00降低攻速|r: %s%%\
|cffffcc00降低移速|r: %s%%\
|cffffcc00减速持续|r: %s\
|cffffcc00暴击率|r: %s\n\
|cff888888风王结界爆发延迟1.5秒\n减速效果可以驱散\n2种技能共享冷却时间",
        untip = "\
重新使用风王结界隐藏你的武器,使你获得被动的暴击率提升,但是将不能使用强大的技能.",
        undata = {},
        researchtip = "单位被麻痹时受到伤害,数值相当于额外伤害的5倍",
        data = {
            {12, 11, 10, 9}, --积攒时间1
            {70, 140, 210, 280}, --爆发伤害2
            function(ap) --爆发伤害加成3
                return ap * 1 
            end,
            {30, 50, 70, 90}, --降低攻速4
            {20, 25, 30, 35}, --降低移速5
            {2, 3, 4, 5}, --持续时间6
            {5, 10, 15, 20} --暴击率7
        },
        events = {"获得技能", "升级技能", "发动技能", "关闭技能", "失去技能"},
        code = function(this)
            if this.event == "获得技能" then
                this._crit = this:get(7)
                Crit(this.unit, this._crit)
                local state = 0
                this._pasfunc = function()
                    state = 1
                    this.tipname = nil
                    DestroyEffect(this._effect)
                    this._effect = AddSpecialEffectTarget("Abilities\\Spells\\Other\\Tornado\\Tornado_Target.mdl", this.unit, "hand right")
                    local timer = Wait(this:get(1),
                        function()
                            state = 2
                            DestroyEffect(this._effect)
                            this._effect = AddSpecialEffectTarget("CycloneShield.mdx", this.unit, "hand right")
                        end
                    )
                    this._pasflush = function()
                        DestroyTimer(timer)
                        DestroyEffect(this._effect)
                        this._effect = nil
                        return state
                    end
                end
                this._pasfunc()
            elseif this.event == "升级技能" then
                local up = this:get(7) - this._crit
                this._crit = this:get(7)
                Crit(this.unit, up)
            elseif this.event == "发动技能" then
                local state = this._pasflush()
                this.tipname = "风王结界"
                this._effect = AddSpecialEffectTarget("war3mapImported\\shizhongjian.mdx", this.unit, "hand right")
                if state == 2 then
                    --风王结界爆发
                    local modle = CreateModle("CycloneShield.mdx", this.unit, {z = 50, time = 2, size = 3})
                    local d = this:get(2) + this:get(3)
                    local as, ms = this:get(4), this:get(5)
                    local t = this:get(6)
                    Wait(1.5,
                        function()
                            forRange(this.unit, this:get("area"),
                                function(u)
                                    if EnemyFilter(this.player, u) then
                                        SkillEffect{
                                            from = this.unit,
                                            to = u,
                                            name = this.name,
                                            data = this,
                                            aoe = true,
                                            code = function(data)
                                                SlowUnit{
                                                    from = data.from,
                                                    to = data.to,
                                                    attack = as,
                                                    move = ms,
                                                    time = t,
                                                    aoe = true,
                                                }
                                                Damage(data.from, data.to, d, false, true, {aoe = true, damageReason = this.name})
                                            end
                                        }
                                    end
                                end
                            )
                        end
                    )
                end
            elseif this.event == "关闭技能" then
                this._pasfunc()
            elseif this.event == "失去技能" then
                DestroyEffect(this._effect)
                Crit(this.unit, - this._crit)
            end
        end
    }
    
    --魔力放出
    InitSkill{
        name = "魔力放出",
        _tipname = "远离尘世的理想乡",
        type = {"主动"},
        ani = "morph",
        _ani = "spell four",
        art = {"BTNHeartOfAszune.blp"}, --左边是学习,右边是普通.不填右边视为左边
        cast = 0.3,
        mana = {120, 130, 140, 150},
        _mana = {150, 160, 170, 180},
        cool = 30,
        _cool = 60,
        dur = 15,
        _dur = {4.5, 5, 5.5, 6},
        tip = "\
放射出魔法构建铠甲,吸收受到的伤害.当铠甲存在时,你的攻击附带额外的法术伤害,数值正比于你的铠甲的剩余能量.\n\
|cff00ffcc技能|r: 无目标\n|cff00ffcc伤害|r: 法术\n\
|cffffcc00铠甲能量|r: %s(|cff0000ff+%d|r)\
|cffffcc00额外伤害|r: %s%%"
        researchtip = "结晶体优先攻击英雄",
        data = {
            {150, 200, 250, 300}, --铠甲能量1
            function(ap)
                return ap * 1.5
            end,
            {10, 15, 20, 25} --伤害系数3
        },
        _tip = "\
获得极高的魔法抗性与生命恢复速度.持续期间内你处于|cffffcc00霸体|r状态.\n\
|cff00ffcc技能|r: 无目标\n\
|cffffcc00魔法抗性|r: %s\
|cffffcc00生命恢复|r: %s(|cff0000ff+%d|r)\n\
|cff888888霸体状态下免疫晕眩,变羊,吹风等令你无法控制的负面效果",
        _data = {
            {50, 75, 100, 125}, --魔抗1
            {30, 40, 50, 60}, --生命恢复2
            function(ap)
                return ap * 0.3
            end
        },
        events = {"获得技能", "发动技能", "失去技能"},
        code = function(this)
            if this.event == "发动技能" then
            elseif this.event == "获得技能" then
            elseif this.event == "失去技能" then
            end            
        end
    }
    
