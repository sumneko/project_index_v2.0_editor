--该文件位于所有lua触发器之前,用于重载YDWE的lua插件

string.gfind = string.gmatch
    
local old = import
local load
local luanames = {}

--自动生成FileList.lua
import = function(filename)
	if string.sub(filename, -4) ~= ".lua" then
		filename = filename .. ".lua"
	end
	return function(script)
		--重载匿名函数好麻烦啊~
		load(script)
		table.insert(luanames, "require \"" .. filename .. "\"")
		old(filename)(script)
		old("FileList.lua")(table.concat(luanames, "\n"))
	end
end

--预读所有以mdl, mdx, blp为扩展名的文件
local filepreload = {}

load = function(script)
	for filename in string.gfind(script, [["(.-)"]]) do
		local name2 = string.sub(filename, -4)
		if name2 == ".mdl" or name2 == ".mdx" or name2 == ".blp" then
			filepreload[filename] = true
		end
	end
end