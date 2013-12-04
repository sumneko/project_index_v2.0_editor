
    Heal = function(from, to, heal, data)
        if IsUnitDead(to) then return end
        local Data = {}
        if data then
            setmetatable(Data, {__index = data})
        end
        Data.from = from
        Data.to = to
        Data.heal = heal
        Data.oheal = heal
        toHeal(Data)
    end
    
    toHeal = function(heal)
        heal.time = GetTime()
        
        toEvent("治疗前", heal)
        
        toEvent("治疗加成", heal)
        
        toEvent("治疗减免", heal)
        
        toEvent("治疗效果", heal)
        
        toEvent("治疗后", heal)
        
        SetUnitState(heal.to, UNIT_STATE_LIFE, GetUnitState(heal.to, UNIT_STATE_LIFE) + heal.heal)
        
        toEvent("治疗结算后", heal)
    end
    
        --记录帮助时间
    Event("治疗后",
        function(heal)
          toHelp(heal.from, heal.to)
        end
    )
    
    --记录游戏中最近的1000次治疗数据
    HealStack = {}
    HealStackTop = 0
    
    Event("治疗后",
        function(this)
            if HealStackTop == 1000 then
                HealStackTop = 1
            else
                HealStackTop = HealStackTop + 1
            end
            HealStack[HealStackTop] = this
            local p = GetOwningPlayer(this.from)
            if this.heal >= 1 then
                for i = HealStackTop + 999, HealStackTop + 1, -1 do --回溯前999次治疗
                    local that = HealStack[i % 1000]
                    if not that then break end
                    local heal = this.heal
                    if this.time - that.time > 0.1 then break end
                    if this.to == that.to and IsUnitAlly(that.from, p) then
                        heal = heal + that.heal
                        if that.text then
                            SetTextTagText(that.text, "+" .. math.floor(heal), 0.023)
                            return
                        end
                    end                    
                end
                this.text = Text{
                    unit = this.to,
                    player = p,
                    word = "+" .. math.floor(this.heal),
                    size = 10,
                    x = -20,
                    z = 20,
                    color = {20, 100, 20, 75},
                    speed = {90, 315},
                    life = {1, 2},
                    show = "友方",
                }
                this.effect = DestroyEffect(AddSpecialEffectTarget(this.modle, this.to, "origin"))
            end
        end
    )
    
