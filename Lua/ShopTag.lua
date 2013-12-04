    do return end
    ShopTag = {}

    for bj_forLoopAIndex = 0, 13 do
        ShopTag[bj_forLoopAIndex] = CreateTextTag()
        SetTextTagPermanent( ShopTag[bj_forLoopAIndex], true )
        if SN then
            SetTextTagVisibility( ShopTag[bj_forLoopAIndex], false )
        end
    end
    SetTextTagText( ShopTag[0], "铁匠", ( 0.03 / 1.00 ) )
    SetTextTagText( ShopTag[1], "服饰", ( 0.03 / 1.00 ) )
    SetTextTagText( ShopTag[2], "宝石", ( 0.03 / 1.00 ) )
    SetTextTagText( ShopTag[3], "禁忌", ( 0.03 / 1.00 ) )
    SetTextTagText( ShopTag[4], "饰品", ( 0.03 / 1.00 ) )
    SetTextTagText( ShopTag[5], "补给", ( 0.03 / 1.00 ) )
    SetTextTagText( ShopTag[6], "服装设计", ( 0.03 / 1.00 ) )
    SetTextTagText( ShopTag[7], "武器设计", ( 0.03 / 1.00 ) )
    SetTextTagText( ShopTag[8], "补给晋级", ( 0.03 / 1.00 ) )
    SetTextTagText( ShopTag[9], "铁器晋级", ( 0.03 / 1.00 ) )
    SetTextTagText( ShopTag[10], "灵装晋级", ( 0.03 / 1.00 ) )
    SetTextTagText( ShopTag[11], "防具晋级", ( 0.03 / 1.00 ) )
    SetTextTagText( ShopTag[12], "端木若瑜", ( 0.03 / 1.00 ) )
    SetTextTagText( ShopTag[13], "御坂19209", ( 0.03 / 1.00 ) )
    if GetPlayerTeam(SELFP) == 0 then
        SetTextTagPos( ShopTag[0], ( GetUnitX(gg_unit_e002_0099) - 50.00 ), GetUnitY(gg_unit_e002_0099), 50.00 )
        SetTextTagPos( ShopTag[1], ( GetUnitX(gg_unit_e00B_0101) - 50.00 ), GetUnitY(gg_unit_e00B_0101), 50.00 )
        SetTextTagPos( ShopTag[2], ( GetUnitX(gg_unit_e000_0100) - 50.00 ), GetUnitY(gg_unit_e000_0100), 50.00 )
        SetTextTagPos( ShopTag[3], ( GetUnitX(gg_unit_e023_0045) - 50.00 ), GetUnitY(gg_unit_e023_0045), 50.00 )
        SetTextTagPos( ShopTag[4], ( GetUnitX(gg_unit_e007_0152) - 50.00 ), GetUnitY(gg_unit_e007_0152), 50.00 )
        SetTextTagPos( ShopTag[5], ( GetUnitX(gg_unit_e00E_0202) - 50.00 ), GetUnitY(gg_unit_e00E_0202), 50.00 )
        SetTextTagPos( ShopTag[6], ( GetUnitX(gg_unit_e001_0098) - 50.00 ), GetUnitY(gg_unit_e001_0098), 50.00 )
        SetTextTagPos( ShopTag[7], ( GetUnitX(gg_unit_e026_0055) - 50.00 ), GetUnitY(gg_unit_e026_0055), 50.00 )
        SetTextTagPos( ShopTag[8], ( GetUnitX(gg_unit_e00A_0187) - 50.00 ), GetUnitY(gg_unit_e00A_0187), 50.00 )
        SetTextTagPos( ShopTag[9], ( GetUnitX(gg_unit_e009_0186) - 50.00 ), GetUnitY(gg_unit_e009_0186), 50.00 )
        SetTextTagPos( ShopTag[10], ( GetUnitX(gg_unit_e01S_0105) - 50.00 ), GetUnitY(gg_unit_e01S_0105), 50.00 )
        SetTextTagPos( ShopTag[11], ( GetUnitX(gg_unit_e027_0181) - 50.00 ), GetUnitY(gg_unit_e027_0181), 50.00 )
    else
        SetTextTagPos( ShopTag[0], ( GetUnitX(gg_unit_e002_0103) - 50.00 ), GetUnitY(gg_unit_e002_0103), 50.00 )
        SetTextTagPos( ShopTag[1], ( GetUnitX(gg_unit_e00B_0102) - 50.00 ), GetUnitY(gg_unit_e00B_0102), 50.00 )
        SetTextTagPos( ShopTag[2], ( GetUnitX(gg_unit_e000_0104) - 50.00 ), GetUnitY(gg_unit_e000_0104), 50.00 )
        SetTextTagPos( ShopTag[3], ( GetUnitX(gg_unit_e023_0046) - 50.00 ), GetUnitY(gg_unit_e023_0046), 50.00 )
        SetTextTagPos( ShopTag[4], ( GetUnitX(gg_unit_e007_0153) - 50.00 ), GetUnitY(gg_unit_e007_0153), 50.00 )
        SetTextTagPos( ShopTag[5], ( GetUnitX(gg_unit_e00E_0203) - 50.00 ), GetUnitY(gg_unit_e00E_0203), 50.00 )
        SetTextTagPos( ShopTag[6], ( GetUnitX(gg_unit_e001_0119) - 50.00 ), GetUnitY(gg_unit_e001_0119), 50.00 )
        SetTextTagPos( ShopTag[7], ( GetUnitX(gg_unit_e026_0057) - 50.00 ), GetUnitY(gg_unit_e026_0057), 50.00 )
        SetTextTagPos( ShopTag[8], ( GetUnitX(gg_unit_e00A_0116) - 50.00 ), GetUnitY(gg_unit_e00A_0116), 50.00 )
        SetTextTagPos( ShopTag[9], ( GetUnitX(gg_unit_e009_0117) - 50.00 ), GetUnitY(gg_unit_e009_0117), 50.00 )
        SetTextTagPos( ShopTag[10], ( GetUnitX(gg_unit_e01S_0217) - 50.00 ), GetUnitY(gg_unit_e01S_0217), 50.00 )
        SetTextTagPos( ShopTag[11], ( GetUnitX(gg_unit_e027_0182) - 50.00 ), GetUnitY(gg_unit_e027_0182), 50.00 )
    end
    SetTextTagPos( ShopTag[12], ( GetUnitX(gg_unit_e00C_0190) - 50.00 ), GetUnitY(gg_unit_e00C_0190), 50.00 )
    SetTextTagPos( ShopTag[13], ( GetUnitX(gg_unit_e019_0213) - 50.00 ), GetUnitY(gg_unit_e019_0213), 50.00 )
