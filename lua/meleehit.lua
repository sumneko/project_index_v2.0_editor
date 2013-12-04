    
    Event("伤害后",
        function(damage)
            if damage.attack --是物理攻击
            and IsHeroUnitId(GetUnitTypeId(damage.from)) then --是英雄类型
                local unit = getObj(slk.unit, GetUnitTypeId(damage.from))
                if unit and unit.Missileart then return end
                SetUnitTimeScale(damage.from, 0.1)
                local t = math.min(0.1, damage.damage/GetUnitState(damage.to, UNIT_STATE_MAX_LIFE))
                local u = damage.from
                Wait(t,
                    function()
                        SetUnitTimeScale(u, 1.)
                    end
                )
            end
        end
    )
    
    luaDone()
