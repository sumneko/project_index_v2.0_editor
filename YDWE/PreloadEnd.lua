--自动预读地图中用到的图片与模型    之后会修改

library PreloadEnd initializer Init
    <?
        local PreloadAllFilename = {}
        for name in pairs(filepreload) do
            table.insert(PreloadAllFilename, "Preloader(\"" .. name .. "\")")
        end
    ?>
    
    void PreloadAllFilename(){
        <?=table.concat(PreloadAllFilename, "\n")?>
        DestroyTimer(GetExpiredTimer())
    }
    
    private void Init(){
        TimerStart(CreateTimer(), 1, false, function PreloadAllFilename)
    }
endlibrary