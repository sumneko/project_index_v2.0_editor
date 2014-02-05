    
    HeroName[11] = "御坂20001"
    HeroMain[11] = "智力"
    HeroType[11] = |Hjai|
    RDHeroType[11] = |h00U|
    HeroTypePic[11] = "ReplaceableTextures\\CommandButtons\\BTNlo.blp"
    HeroSize[11] = 1.1
    LearnSkillId = {|A19N|, |A19O|, |A19P|, |A19Q|}

    
    --范围电击
    InitSkill{
        name = "范围电击",
        type = {"主动", 2, 3},
        ani = "spell",
        art = {"BTNMonsoon.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {100, 110, 120, 130},
        cool = 15,
        rng = 800,
        area = 150,
        dur = {1, 1.5, 2, 2.5},
        cast = 0.3,
        tip = "\
释放一道闪电击中目标区域,对附近的单位造成伤害并|cffffcc00麻痹|r.\n\
|cff00ffcc技能|r: 点目标\
|cff00ffcc伤害|r: 法术\n\
|cffffcc00伤害|r: %s(|cff0000ff+%d|r)\n\
|cff888888闪电被截断则在截断处生效|r",
        researchtip = "被闪电贯穿的单位也受到同样效果,闪电宽度为200",
        data = {
            {60, 120, 180, 240}, --伤害1
            function(ap, ad) --伤害加成2
                return ap * 1
            end,
        },
        events = {"发动技能"},
        code = function(this)
            if this.event == "发动技能" then
                --技能效果
                local d = this:get(1) + this:get(2)
                local t = this:get("dur")
                local g = {}
                local se = function(u)
                    if g[u] then return end
                    g[u] = true
                    SkillEffect{
                        from = this.unit,
                        to = u,
                        name = this.name,
                        data = this,
                        aoe = true,
                        code = function(data)
                            --麻痹
                            BenumbUnit{
                                from = data.from,
                                to = data.to,
                                time = t,
                                aoe = true,
                            }
                            --伤害
                            Damage(this.unit, u, d, false, true, {aoe = true, damageReason = this.name})
                        end
                    }
                end
                --先创建闪电效果
                local l = Lightning{
                    from = this.unit,
                    name = 'CLPB',
                    check = true,
                    x1 = GetUnitX(this.unit),
                    y1 = GetUnitY(this.unit),
                    z1 = GetUnitZ(this.unit) + 75,
                    x2 = GetLocationX(this.target),
                    y2 = GetLocationY(this.target),
                    z2 = GetLocationZ(this.target) + 75,
                    cut = true,
                    time = 0.5
                }
                local target = {l.x2, l.y2}
                TempEffect(target, "Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl")
                forRange(target, this:get("area"),
                    function(u)
                        if EnemyFilter(this.player, u) then
                            se(u)
                        end
                    end
                )
                if this.research then
                    forSeg(this.unit, target, 200,
                        function(u)
                            if EnemyFilter(this.player, u) then
                                se(u)
                            end
                        end
                    )
                end
            end
        end
    }
    
    --静电力场
    InitSkill{
        name = "静电力场",
        type = {"开关"},
        ani = "stand",
        art = {"BTNFeedBack.blp", "BTNFeedBack.blp", "BTNWispSplode.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = 150,
        dur = 60,
        area = 600,
        tip = "\
产生大范围的静电力场,降低附近单位的移动速度并麻痹初次受到影响的单位.受到静电力场作用的单位将会承受额外伤害.\n\
|cff00ffcc技能|r: 无目标\
|cff00ffcc伤害|r: 法术\n\
|cffffcc00移速降低|r: %s\
|cffffcc00麻痹时间|r: %s\
|cffffcc00额外伤害|r: %s(|cff0000ff+%d|r)\n\
|cff888888可以提前关闭\n单次受到的伤害大于20点才会触发额外伤害\n该技能的冷却时间等同于开启的时间,最小5秒,最大60秒",
        researchtip = "单位被麻痹时受到伤害,数值相当于额外伤害的5倍",
        data = {
            {50, 75, 100, 125}, --移速降低1
            {0.5, 0.75, 1, 1.25}, --麻痹时间2
            {10, 20, 30, 40}, --额外伤害3
            function(ap) --额外伤害加成4
                return ap * 0.2
            end
        },
        events = {"发动技能", "关闭技能"},
        code = function(this)
            if this.event == "发动技能" then
                local area = this:get("area")
                this.opentime = GetTime()
                this.effect = AddSpecialEffectTarget("Abilities\\Spells\\Orc\\LightningShield\\LightningShieldTarget.mdl", this.unit, "origin")
                this.units = {}
                this.timer = Loop(0.25,
                    function()
                        local t = this:get(2)
                        local ms = this:get(1)
                        local g = {}
                        forRange(this.unit, area,
                            function(u)
                                if EnemyFilter(this.player, u) then
                                    if this.units[u] == nil then
                                        --表示是初次受到影响
                                        SkillEffect{
                                            name = this.name .. "(麻痹)",
                                            from = this.unit,
                                            to = u,
                                            data = this,
                                            aoe = true,
                                            code = function(data)
                                                --麻痹
                                                BenumbUnit{
                                                    from = data.from,
                                                    to = data.to,
                                                    time = t,
                                                    aoe = true,
                                                }
                                                --伤害
                                                if this.research then
                                                    Damage(data.from, data.to, 5 * (this:get(3) + this:get(4)), false, true, {aoe = true, damageReason = this.name})
                                                end
                                            end
                                        }
                                        this.units[u] = 0
                                    end
                                    if ms > this.units[u] then
                                        MoveSpeed(u, this.units[u] - ms)
                                        this.units[u] = ms
                                    end
                                    g[u] = true
                                end
                            end
                        )
                        --移除离开区域单位的负面效果
                        for u, ms in pairs(this.units) do
                            if not g[u] then
                                MoveSpeed(u, ms)
                                this.units[u] = 0
                            end
                        end
                    end
                )
                --额外伤害
                this.skillfunc = Event("伤害效果",
                    function(damage)
                        if damage.damageReason ~= this.name and damage.damage > 20 and this.units[damage.to] and this.units[damage.to] > 0 then
                            DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\ChimaeraLightningMissile\\ChimaeraLightningMissile.mdl", damage.to, "chest"))
                            Damage(this.unit, damage.to, this:get(3) + this:get(4), false, true, {aoe = true, damageReason = this.name})
                        end
                    end
                )
            elseif this.event == "关闭技能" then
                for u, ms in pairs(this.units) do
                    MoveSpeed(u, ms)
                end
                DestroyTimer(this.timer)
                DestroyEffect(this.effect)
                Event("-伤害效果", this.skillfunc)
                this.freshcool = math.min(60, math.max(5, GetTime() - this.opentime))
            end
        end
    }
    
    --御坂网络代理演算
    InitSkill{
        name = "御坂网络代理演算",
        type = {"被动"},
        art = {"BTNBrilliance.blp"},
        area = "全地图",
        tip = "\
连接近1万个御坂妹妹的网络,永久增加自己的法力恢复与技能强度,并为友方英雄提供法力恢复与技能强度加成,数值正比于你自己的法力恢复与技能强度.\n\
|cff00ffcc技能|r: 被动\n\
|cffffcc00法力恢复|r: %s\
|cffffcc00技能强度|r: %s\
|cffffcc00友方法力恢复|r: %s%% (|cffffcc00%.2f|r)\
|cffffcc00友方技能强度|r: %s%% (|cffffcc00%.2f|r)\n\
|cff888888死亡状态时光环效果失效",
        researchtip = "不再为队友提供法力恢复,提供的技能强度翻倍",
        data = {
            {0.75, 1.5, 2.25, 3}, --法力恢复1
            {10, 20, 30, 40}, --技能强度2
            {10, 15, 20, 25}, --友方法力恢复3
            0, --友方法力恢复显示4
            {6, 8, 10, 12}, --友方技能强度5
            0, --友方技能强度显示6
        },
        count = 0,
        events = {"获得技能", "失去技能", "升级技能"},
        code = function(this)
            if this.event == "获得技能" then
                UnitAddAbility(this.unit, |A19R|)
                UnitMakeAbilityPermanent(this.unit, true, |A19R|)
                
                local mp, ap = this:get(1), this:get(2)
                Recover(this.unit, 0, mp)
                AddAP(this.unit, ap)
                this.ups = {mp, ap}
                
                this.units = {}
                this.timer = Loop(1,
                    function()
                        local ps = GetAllyUsers(this.player)
                        local mp, ap = 0, 0
                        if IsUnitAlive(this.unit) then
                            _, mp = GetRecover(this.unit)
							mp = mp * this:get(3) / 100
                            ap = GetAP(this.unit) * this:get(5) / 100
                        end
                        if this.research then
							mp = 0
							ap = ap * 2
						end
                        this.data[4], this.data[6] = mp, ap
                        for _, p in ipairs(ps) do
                            if this.player ~= p then
                                local i = GetPlayerId(p)
                                local hero = Hero[i]
                                if hero then
                                    local data = this.units[hero]
                                    if data == nil then
                                        data = {0, 0}
                                        this.units[hero] = data
                                    end
                                    --回蓝
                                    if data[1] ~= mp then
                                        Recover(hero, 0, mp - data[1])
                                        data[1] = mp
                                    end
                                    --法伤
                                    if data[2] ~= ap then
                                        AddAP(hero, ap - data[2])
                                        data[2] = ap
                                    end
                                end
                            end
                        end
                        SetSkillTip(this.unit, this.name)
                        RefreshTips(this.unit)
                    end
                )
            elseif this.event == "升级技能" then
                local mp, ap = this:get(1), this:get(2)
                Recover(this.unit, 0, mp - this.ups[1])
                AddAP(this.unit, ap - this.ups[2])
                this.ups = {mp, ap}
            elseif this.event == "失去技能" then
                UnitRemoveAbility(this.unit, |A19R|)
                DestroyTimer(this.timer)
                for u, data in pairs(this.units) do
                    Recover(u, 0, - data[1])
                    AddAP(u, - data[2])
                end
            end
        end
    }
    
    --御坂网络终端命令
    InitSkill{
        name = "御坂网络终端命令",
        type = {"主动"},
        ani = "spell 2",
        art = {"BTN__landvin__3.blp"}, --左边是学习,右边是普通.不填右边视为左边
        mana = {150, 300, 450},
        area = 125,
        cool = 150,
        tip = "\
向其他御坂妹妹求援,潜伏在战场的御坂妹妹们将分别狙击一个敌方英雄,对一条直线上的单位造成伤害.被重复击中时受到的伤害减半.\n\
|cff00ffcc技能|r: 无目标\n|cff00ffcc伤害|r: 物理\n\
|cffffcc00造成伤害|r: %s(|cff0000ff+%d|r)\n\
|cff888888御坂妹妹在距离敌方英雄%s距离处进行狙击\n狙击总射程为%s,弹道速度为%s",
        researchtip = {
            "被重复击中也要受到全额伤害",
            "被击中的单位麻痹1.5秒",
            "最后之作的生命值每损失1%,造成的伤害就提高1%"
        },
        data = {
            {200, 400, 600}, --伤害1
			function(ap) --伤害加成2
				return ap * 2
			end,
			1500, --狙击距离3
			3000, --狙击射程4
			3000, --弹道速度5
        },
        events = {"发动技能"},
        code = function(this)
			if this.event == "发动技能" then
                StartSound(gg_snd_lo_dazhao)
                local l = this:get(3)
                local speed = this:get(5)
                local distance = this:get(4)
                local area = this:get("area")
                local d = this:get(1) + this:get(2)
                local re = this.research and this.research[2]
                if this.research and this.research[3] then
                    local r = GetUnitState(this.unit, UNIT_STATE_LIFE) / GetUnitState(this.unit, UNIT_STATE_MAX_LIFE)
                    r = 2 - r
                    d = d * r
                end
                --记录重复击中
                local units = {}
				--先搜寻敌方英雄
                for i = 1, 10 do
                    local id = GetPlayerId(P[i])
                    local hero = Hero[id]
                    if hero and IsUnitEnemy(hero, this.player) then
                        local point
                        for _i = 1, 10 do
                            local p = MovePoint(hero, {l, GetRandomInt(1, 360)})
                            if not IsTerrainPathable(p[1], p[2], PATHING_TYPE_FLYABILITY) then
                                point = p
                                break --如果随机到的地面为空中可通行则跳出
                            end
                        end
                        if point then
                            local angle = GetBetween(point, hero,true)
                            local u = CreateUnitAtLoc(this.player, |h005|, point, angle)
                            SetUnitAnimation(u, "attack")
                            Wait(1,
                                function()
                                    RemoveUnit(u)
                                end
                            )
                            Wait(0.5,
                                function()
                                    Mover({
                                            from = this.unit,
                                            source = u,
                                            z = 75,
                                            speed = speed,
                                            distance = distance,
                                            angle = angle,
                                            modle = "Abilities\\Weapons\\RocketMissile\\RocketMissile.mdl",
                                            size = 1,
                                            aoe = true
                                        },
                                        function(move)
                                            if move.count % 2 == 0 then --每0.04秒,即120距离判定一次
                                                forRange(move.unit, area,
                                                    function(u)
                                                        if EnemyFilter(this.player, u) then
                                                            local d = d
                                                            if not (this.research and this.research[1]) and units[u] then
                                                                d = d / 2
                                                            end
                                                            units[u] = true
                                                            SkillEffect{
                                                                name = this.name,
                                                                from = move.from,
                                                                to = u,
                                                                data = this,
                                                                aoe = true,
                                                                code = function(data)
                                                                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", data.to, "chest"))
                                                                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\RocketMissile\\RocketMissile.mdl", data.to, "chest"))
                                                                    --麻痹目标
                                                                    if re then
                                                                        BenumbUnit{
                                                                            from = data.from,
                                                                            to = data.to,
                                                                            time = 1.5,
                                                                            aoe = true,
                                                                        }
                                                                    end
                                                                    --造成伤害
                                                                    Damage(data.from, data.to, d, true, false, {aoe = true, damageReason = this.name})
                                                                end
                                                            }
                                                        end
                                                    end
                                                )
                                            end
                                        end
                                    )
                                end
                            )
                        else
                            print(("<ERROR>%s:%s"):format(this.name, "没有找到马甲创建位置"))
                        end
                    end
                end
			end
		end
	}
    
