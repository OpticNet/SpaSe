local Vector2 = { }

function Vector2.new(x, y)
	local vec = {["X"] = x, ["Y"] = y, ['class'] = "Vector2"}
	vec = setmetatable(vec, {
		__add = function(tab, value)
			local sum = {0, 0}
		--	error(tostring(tab) .. " and "..tostring(value))
			if type(value)=='table' then
				if value.class=="Vector2" then
					sum[1] = tab.X + value.X
					sum[2] = tab.Y + value.Y
				end
			elseif type(value)=='number' then
				sum[1] = tab.X + value
				sum[2] = tab.Y + value
			end
			return Vector2.new(sum[1], sum[2])
		end;
		__mul = function(tab, value)
			local sum = {0, 0}
			if type(value)=="table" then
				if value.class=="Vector2" then
					sum[1] = tab.X * value.X
					sum[2] = tab.Y * value.Y
				end
			elseif type(value)=="number" then
				sum[1] = tab.X * value
				sum[2] = tab.Y * value
			end
			return Vector2.new(sum[1], sum[2])
		end
	})
	return vec
end
return Vector2