
    Event("伤害前",
        function(damage)
            if damage.attack and not IsUnitType(damage.to, UNIT_TYPE_STRUCTURE) then
                local bjl = Mark(damage.from, "暴击率")
                if bjl and GetRandomInt(0, 99) < bjl then
                    local bjxs = (Mark(damage.from, "暴击系数") or 0) * 0.01 + 2
                    --Debug("crit")
                    --Debug(damage.damage)
                    damage.odamage = damage.odamage * bjxs
                    damage.damage = damage.damage * bjxs
                    --Debug(damage.damage)
                    damage.crit = true
                end
            end
        end
    )

