--该文件位于所有lua触发器之前,用于重载YDWE的lua插件
  
	local old = import
	--local load
	local luanames = {}
	local luascripts = {}

	import = function(filename)
		if string.sub(filename, -4) ~= ".lua" then
			filename = filename .. ".lua"
		end
		return function(script)
			--重载匿名函数好麻烦啊~
			--load(script)
			table.insert(luanames, "require \"" .. filename .. "\"")
			old(filename)(script)
			luascripts[filename] = script
		end
	end

	--不再预读文件了,感觉都差不多
	if false then
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
	end
