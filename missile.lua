    
    Event("伤害判定",
        function(damage)
            if damage.missile or not damage.weapon then return end
            
            local u1 = getObj(slk.unit, GetUnitTypeId(damage.from))
            
            if not u1.Missileart or u1.Missileart == ".mdl" then return end
            
            local u2 = getObj(slk.unit, GetUnitTypeId(damage.to))
            
            local tz = u2.impactZ or 0
            
            local size1 = GetModleSize(damage.from)
            local size2 = GetModleSize(damage.to)
            
            local x, y = u1.launchX or 0, u1.launchY or 0
            
            local launchXY = (x * x + y * y) ^ 0.5
            local launchA = Atan2(y, x) + GetUnitFacing(damage.from)
            
            damage.missile = true
            
            local move = {
                modle = Mark(damage.from, "弹道模型") or u1.Missileart,
                from = damage.from,
                target = damage.to,
                x = launchXY * Cos(launchA),
                y = launchXY * Sin(launchA),
                z = (u1.launchZ or 0) * size1,
                tz = tz * size2,
                high = GetBetween(damage.from, damage.to) * (u1.Missilearc or 0),
                size = size1,
                speed = u1.Missilespeed or 100,
                attack = true,
                data = {damage = damage},
                code = function(move)
                    Damage(move.from, move.target, move.data.damage.sdamage, true, false, move.data.damage)
                end
            }
            
            damage.mover = move
            
            MoverEx(table.copy(move), nil, move.code)
            
            toEvent("远程攻击弹道", move)

            return true --取消此次伤害
        end
    )    
    
