local Entity = { }
local Images = { }
local DebugConsole;
local Vector2 = require("Vector2")
local CurrentState;
local EventSys;

function Entity.PassDebugConsole(console)
	DebugConsole = console
end

function Entity.SetCurrentState(State)
	CurrentState = State
end

function Entity.SetEvent(event)
	EventSys = event
end

function Entity.LoadImage(path)
	if Images[path]==nil then
		Images[path] = love.graphics.newImage(path)
	end
	return Images[path]
end

function Entity.Collides(gui1, gui2)
	return (
		(gui1.Position.X < gui2.Position.X + gui2.Size.X and 
			gui1.Position.X + gui1.Size.X > gui2.Position.X) and 
		(gui1.Position.Y > gui2.Position.Y and 
			gui1.Position.Y < gui2.Position.Y + gui2.Size.Y)) or 
	((gui2.Position.X < gui1.Position.X + gui1.Size.X and 
		gui2.Position.X + gui2.Size.X > gui1.Position.X) and 
	(gui2.Position.Y > gui1.Position.Y and 
		gui2.Position.Y < gui1.Position.Y + gui1.Size.Y))
end

function Entity.new(Image) --Image is optional
	--Lets make all squares for now k?
	local Object = { }
	Object.Size = Vector2.new(0, 0)
	Object.Position = Vector2.new(0, 0)
	Object.Rotation = 0 -- right
	Object.Scale = Vector2.new(1, 1)
	Object.Children = { }

	-- Object.Image
	-- Object.Update
	-- Object.Draw
	if Image then
		if type(Image)=="string" then
			Object.Image = Entity.LoadImage(Image)
		else
			Object.Image = Image
		end
		local wid = Object.Image:getWidth()
		local hei = Object.Image:getHeight()
		--wid, hei = Object.Image:getDimensions()
		Object.Size.X = wid
		Object.Size.Y = hei
		Object.ImageDirection = 1
	end
	Object.Enabled = true
	Object.CamCutoff = true
	Object.State = CurrentState
	Object.Color = {0, 0, 0}
	Object.Transparency = 0
	local Updates = { }

	function Object:AddChild(child)
		self.Children[child] = child
	end

	function Object:Delete()
		for _, v in pairs(self) do
			self[_] = nil
		end
	end

	function Object:RemoveChild(child)
		self.Children[child] = nil
	end

	function Object:CollidesWith(gui2)
		return (
		(self.Position.X < gui2.Position.X + gui2.Size.X and 
			self.Position.X + self.Size.X > gui2.Position.X) and 
		(self.Position.Y > gui2.Position.Y and 
			self.Position.Y < gui2.Position.Y + gui2.Size.Y)) or 
		((gui2.Position.X < self.Position.X + self.Size.X and 
			gui2.Position.X + gui2.Size.X > self.Position.X) and 
		(gui2.Position.Y > self.Position.Y and 
			gui2.Position.Y < self.Position.Y + self.Size.Y))
	end
	
	function Object:AddUpdate(id, func)
		if Updates[id] then 
			error(tostring(id) .. " already exists for "..tostring(Image))
		end
		Updates[id] = func
	end

	function Object:RemoveUpdate(id)
		Updates[id] = nil
	end

	function Object:Update(dt)
		for _, v in pairs(Updates) do
			v(self, dt)
		end
	end

	function Object:Draw(Camera)
		local Scale = self.Scale
		if Camera and self.CamCutoff==true then
			--Scale = Camera.Scale
			if self.Position.X + self.Size.X/2<0  or
				self.Position.X - self.Size.X/2>Camera.Position.X + Camera.Size.X or
				self.Position.Y + self.Size.Y/2<0 or
				self.Position.Y - self.Size.Y/2>Camera.Position.Y + Camera.Size.Y then
			--	error("Off of camera!")
				return 
			end
		end
		if self.Image then
			love.graphics.draw(self.Image, self.Position.X, self.Position.Y, self.Rotation~=0 and math.rad(self.Rotation) or nil, self.ImageDirection * self.Scale.X, self.Scale.Y, self.ImageDirection and self.Size.X/2, self.ImageDirection and self.Size.Y/2)
		else
			local store = {love.graphics.getColor()}
			love.graphics.setColor(self.Color[1], self.Color[2], self.Color[3], 255 - (255 * self.Transparency))
			love.graphics.polygon("fill",
				self.Position.X - ((self.Size.X/2) * Scale.X),
				self.Position.Y - ((self.Size.Y/2) * Scale.Y),

				self.Position.X + ((self.Size.X/2) * Scale.X),
				self.Position.Y - ((self.Size.Y/2) * Scale.Y),

				self.Position.X - ((self.Size.X/2) * Scale.X),
				self.Position.Y + ((self.Size.Y/2) * Scale.Y),

				self.Position.X + ((self.Size.X/2) * Scale.X),
				self.Position.Y + ((self.Size.Y/2) * Scale.Y)
			)
			love.graphics.setColor(store)
		end
		for _, v in pairs(self.Children) do
			v:Draw(Camera)
		end
	end
	return Object
end

return Entity