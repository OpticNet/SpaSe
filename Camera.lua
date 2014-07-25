local Camera = { }
local DebugConsole;
local EventSys;
local Vector2 = require("Vector2")

function Camera.SetEvent(event)
	EventSys = event
end


function Camera.PassDebugConsole(console)
	DebugConsole = console
end

function Camera.new()
	local cam = { }
	cam.Position = Vector2.new(0, 0)
	cam.Zoom = Vector2.new(1, 1)
	cam.Size = Vector2.new(love.graphics.getDimensions()) * cam.Zoom-- default size
	--cam.Size = cam.Size-- * .5
	cam.Scale = Vector2.new(love.graphics.getWidth() / cam.Size.X, love.graphics.getHeight() / cam.Size.Y)
--	cam.Size.X = cam.Size.X * 2
--	cam.Size.Y = cam.Size.Y * 2
	cam.Background = nil
	cam.BackgroundScale = Vector2.new(2, 2)
	cam.Starground = love.graphics.newCanvas(love.graphics.getWidth() * 3, love.graphics.getHeight() * 3)
	cam.Starground2 = love.graphics.newCanvas(love.graphics.getWidth() * 3, love.graphics.getHeight() * 3)
	-- create starground canvas
	love.graphics.setCanvas(cam.Starground)
	local origin_color = {love.graphics.getColor()}
	for i = 1, math.random(150, 200) do
		local color_intensity = math.random(100, 255)
		local rec = {
			Size = Vector2.new(5, 5);
			Position = Vector2.new(math.random(cam.Starground:getWidth() - 5), math.random(cam.Starground:getHeight() - 5));
			Color = {color_intensity, color_intensity, color_intensity}
		}
		love.graphics.setColor(unpack(rec.Color))
		love.graphics.rectangle("fill", rec.Position.X, rec.Position.Y, rec.Size.X, rec.Size.Y)
	end

	love.graphics.setColor(unpack(origin_color))

		love.graphics.setCanvas(cam.Starground2)
	local origin_color = {love.graphics.getColor()}
	for i = 1, math.random(150, 200) do
		local color_intensity = math.random(100, 255)
		local rec = {
			Size = Vector2.new(5, 5);
			Position = Vector2.new(math.random(cam.Starground2:getWidth() - 5), math.random(cam.Starground2:getHeight() - 5));
			Color = {color_intensity, color_intensity, color_intensity}
		}
		love.graphics.setColor(unpack(rec.Color))
		love.graphics.rectangle("fill", rec.Position.X, rec.Position.Y, rec.Size.X, rec.Size.Y)
	end

	love.graphics.setColor(unpack(origin_color))

	love.graphics.setCanvas()
	
	function cam:AddBackground(entity)
		--love.graphics.setCanvas(self.Starground)
		if not self.Background then
			self.Background = love.graphics.newCanvas()
		end
		love.graphics.setCanvas(self.Background)
		entity:Draw(
			{
				["Scale"] = self.BackgroundScale;
				["Position"] = Vector2.new(0, 0);
				["Size"] = Vector2.new(love.graphics.getWidth(), love.graphics.getHeight())
			}
		)
		love.graphics.setCanvas()
	end

	function cam:SetZoom(ZoomVec)
		cam.Zoom = ZoomVec
		cam.Size = Vector2.new(love.graphics.getDimensions()) * cam.Zoom
		cam.Scale = Vector2.new(love.graphics.getWidth() / cam.Size.X, love.graphics.getHeight() / cam.Size.Y)
	end

	function cam:DrawOnState(StageObject)
		if not StageObject then return end
		if self.Starground then
			local parallax = self.Position * Vector2.new(-1/(love.graphics.getWidth() / 50), -1/(love.graphics.getHeight() / 50))
			local parallax2 = self.Position * Vector2.new(-1/(love.graphics.getWidth() / 100), -1/(love.graphics.getHeight() / 100))
			love.graphics.push()
			love.graphics.origin()
		--	love.graphics.scale(self.Size.X / cam.Starground:getWidth(), self.Size.Y / cam.Starground:getHeight())
		--	cam.Starground:setWrap("repeat", "repeat")
			love.graphics.draw(self.Starground, parallax.X, parallax.Y, 0, .5, .5) -- STARGROUND 1   -- love.graphics.getWidth() / self.Starground:getWidth()
			love.graphics.draw(self.Starground2, parallax2.X, parallax2.Y, 0, .5, .5) --love.graphics.getWidth(), love.graphics.getHeight()) -- STARGOUND 2 
			love.graphics.pop()
		end
		if self.Background then
			love.graphics.push()
			love.graphics.draw(self.Background, 0, 0, 0, self.BackgroundScale.X, self.BackgroundScale.Y)
			love.graphics.pop()
		end
		love.graphics.push()

		love.graphics.scale(self.Scale.X, self.Scale.Y)
		love.graphics.translate(-self.Position.X, -self.Position.Y)
		StageObject:Draw(self)
		love.graphics.pop()
	end
	return cam
end

return Camera