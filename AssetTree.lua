local AssetTree = { }
local lfs = love.filesystem
-- BUILD DIRECTORY OF ASSETS

AssetTree.Loaded = false

function AssetTree.Load()
	for _, v in pairs(lfs.getDirectoryItems("/Assets")) do
		if v~="OLD" then
			AssetTree[v] = { }
		--	print(v)
			for __, vv in pairs(lfs.getDirectoryItems("/Assets/"..v)) do
				local path = ("/Assets/%s/%s"):format(v, vv)
				AssetTree[v][vv] = { }
		--		print("	"..vv)
				for ___, vvv in pairs(lfs.getDirectoryItems(path)) do
					local filename, filetype = vvv:match("(%w*)%.(.*)")
					local filepath = ("%s/%s"):format(path, vvv)
					print(vvv, filename, filetype, filepath)


					if filetype=="png" or filetype=="bmp" or filetype=="gif" then

						AssetTree[v][vv][filename] = love.graphics.newImage(filepath)


					elseif filetype:lower()=="ecf" and filename=="assetconfig" then
						for line in love.filesystem.lines(filepath) do
							local ind, var = line:match("(%w*)=([%p%w ]+)")
							local loadst = line:match("%w*=ls:([%p%w ]+)")
							if ind and var then 
								if loadst then
									AssetTree[v][vv][ind] = loadstring(loadst)()
								else
									if tonumber(var) then var = tonumber(var) end
									AssetTree[v][vv][ind] = var
								end
							end
						end
					elseif filetype=="map" then
						-- LOAD MAPS
					end


				end
			end
		end
	end
	AssetTree.Loaded = true
end

return AssetTree