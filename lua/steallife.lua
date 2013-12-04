   
    --吸血
    Event("伤害效果",
        function(damage)
            if damage.from and not damage.arry and EnemyFilter(GetOwningPlayer(damage.from), damage.to) then
                if damage.attack then
                    local a = Mark(damage.from, "攻击吸血") or 0
                    local b = Mark(damage.from, "攻击吸血2") or 0
                    if a > 0 or b > 0 then
                        Heal(damage.from, damage.from, math.max(damage.damage * a / 100, b), {item = true, healReason = "攻击吸血", modle = "Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl"})
                    end
                else
                    local a = Mark(damage.from, "技能吸血") or 0
                    if a > 0 then
                        if damage.aoe then
                            a = a / 3
                        end
                        Heal(damage.from, damage.from, damage.damage * a / 100, {item = true, healReason = "技能吸血", modle = "Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl"})
                    end
                end
            end
        end
    )
    
    AttackStealLife = function(u, a, b)
        if a then
            Mark(u, "攻击吸血", (Mark(u, "攻击吸血") or 0) + a)
        end
        if b then
            Mark(u, "攻击吸血2", (Mark(u, "攻击吸血2") or 0) + b)
        end
    end
    
    SkillStealLife = function(u, a)
        Mark(u, "技能吸血", (Mark(u, "技能吸血") or 0) + a)
    end
