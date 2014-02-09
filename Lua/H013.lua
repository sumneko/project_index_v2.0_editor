    
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
|cffffcc00暴击率|r: %s\
|cff888888减速效果可以驱散",
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
                this._effect = AddSpecialEffectTarget("Abilities\\Spells\\Other\\Tornado\\Tornado_Target.mdl", this.unit, "hand right")
                this._crit = this:get(7)
                Crit(this.unit, this._crit)
            elseif this.event == "升级技能" then
                local up = this:get(7) - this._crit
                this._crit = this:get(7)
                Crit(this.unit, up)
            elseif this.event == "发动技能" then
            elseif this.event == "关闭技能" then
            elseif this.event == "失去技能" then
                if this._effect then
                    DestroyEffect(this._effect)
                end
                Crit(this.unit, - this._crit)
            end
        end
    }
    
