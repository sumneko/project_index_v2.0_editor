    
    Event("发动英雄技能",
        function(data)
            Text {
                unit = data.unit,
                x = -30,
                z = 50,
                word = data.tipname or data.name,
                size = 10,
                color = {100, 0, 0},
                speed = {58, 90},
                life = {2, 3},
                show = "友方",
            }
        end
    )
    
    luaDone()
