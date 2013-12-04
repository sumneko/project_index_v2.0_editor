    
    --从统计-英雄伤害发起    
    local CreateText = function(damage, i)
        local speed
        if i == 0 then
            damage.textcolor = {100, 0, 100, 75}
            speed = {120, 90}
        elseif i == 1 then
            damage.textcolor = {100, 100, 100, 75}
            speed = {120, 270}
        elseif i == 2 then
            damage.textcolor = {100, 0, 0, 75}
            speed = {120, 105}
        else
            damage.textcolor = {0, 0, 100, 75}
            speed = {120, 75}
        end
        damage.textword = math.floor(damage.damage)
        local show = "自己"
        local x = -20
        damage.textsize = 10
        damage.text = Text{
            unit = damage.to,
            player = GetOwningPlayer(damage.from),
            word = damage.textword,
            size = damage.textsize,
            x = x,
            z = 50,
            color = damage.textcolor,
            speed = speed,
            life = {2, 3},
            show = show,
        }
        if IsUnitInvisible(damage.to, SELFP) then
            SetTextTagVisibility(damage.text, false)
        end
        return damage.text
    end
    
    local CritDamageText = function(damage)
        local a
        damage.textword = "§" .. damage.textword
        SetTextTagVisibility(damage.text, true)
        damage.textcolor[4] = 100
        SetTextTagColor(damage.text, damage.textcolor[1] * 2.55, damage.textcolor[2] * 2.55, damage.textcolor[3] * 2.55, damage.textcolor[4] * 2.55)
        Loop(0.01,
            function()
                if a then
                    if damage.textsize > 15 then
                        damage.textsize = damage.textsize - 0.5
                    else
                        EndLoop()
                    end
                else
                    if damage.textsize < 20 then
                        damage.textsize = damage.textsize + 0.5
                    else
                        a = true
                    end
                end
                SetTextTagText(damage.text, damage.textword, damage.textsize * 0.023 / 10)
            end
        )
    end
    
    local ChangeDamageText = function(nd, ds, crit)
        nd.textword = math.floor(ds)
        if crit then
            nd.textword = "§" .. nd.textword
        end
        SetTextTagText(nd.text, nd.textword, nd.textsize * 0.023 / 10)
    end
    
    local findDamageText = function(p, damage)
        local ds = damage.damage
        local crit
        for i = DamageStackTop + 999, DamageStackTop + 1, -1 do
            local nd = DamageStack[i % 1000]
            if not nd then return end --伤害不存在
            --Debug(damage.time - nd.time)
            if damage.time - nd.time > 0.1 then return end
            if nd.from and damage.to == nd.to and GetOwningPlayer(nd.from) == p and nd.def == damage.def and nd.ant == damage.ant then
                ds = ds + nd.damage
                if nd.crit then
                    crit = true
                end
                if nd.text then
                    return nd, ds, crit
                end
            end
        end
    end
    
    DamageText = function(damage)
        if damage.from and damage.damage >= 5 then
            local p = GetOwningPlayer(damage.from)
            if IsUser(p) then
                local t = 0 --神圣
                if damage.def then
                    if damage.ant then
                        t = 1 --弱化
                    else
                        t = 2 --物理
                    end
                elseif damage.ant then
                    t = 3 --法术
                end
                local nd, ds, crit = findDamageText(p, damage)
                if nd then
                    ChangeDamageText(nd, ds, crit)
                    if damage.crit and not crit then
                        CritDamageText(nd)
                    end
                else
                    --新建漂浮文字
                    CreateText(damage, t)
                    if damage.crit then
                        CritDamageText(damage)
                    end
                end
            end
        end
    end

