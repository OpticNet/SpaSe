local State = { }
local Vector2 = require("Vector2")
State.States = { }
function State.new(id)
	if State.States[id]==nil then

		local StateObject = { } -- Public class
		StateObject.Objects = { } -- Private table
		StateObject.Characters = { } -- Somewhat private table
		StateObject.Enabled = true

		function StateObject:AddEntity(Object)
			self.Objects[Object] = Object
			Object.State = self
		end

		function StateObject:AddCharacter(Char)
			self.Objects[Char] = Char
			self.Characters[Char] = Char
			Char.State = self
		end

		function StateObject:RemoveCharacter(Char)
			self.Objects[Char] = nil
			self.Characters[Char] = nil
			Char.State = nil
		end

		function StateObject:RemoveEntity(Object)
			self.Objects[Object] = nil
			Object.State = nil
		end

		function StateObject:Update(dt)
			if not self.Enabled then return end
			for _, v in pairs(self.Objects) do
				if v.Enabled and v.Update then
					v:Update(dt)
				end
			end
		end

		function StateObject:Draw(Camera)
			if not self.Enabled then return end
			for _, v in pairs(self.Objects) do
				if v.Draw and v.Enabled then
					v:Draw(Camera)
				end
			end
		end

		State.States[id] = StateObject
		return StateObject
	else
		error("Attempt to add state with id "..tostring(id).." when id already existed")
	end
end
return State