-- Spaceship class extends Entities class

local Character = { }
local Vector2 = require("Vector2")
local Entities = require("Entities")
local EventSys;

local SpaceshipDirections = {
	["10"] = function(ent) ent.Rotation = 0 ent.ImageDirection = 1 end;-- Right
	["-10"] = function(ent) ent.Rotation = 0 ent.ImageDirection = -1 end; -- Left
	["01"] = function(ent) ent.Rotation = 90 ent.ImageDirection = 1 end; -- Up
	["0-1"] = function(ent) ent.Rotation = -90 ent.ImageDirection = 1 end; -- Down
	["-11"] = function(ent) ent.Rotation = -45 ent.ImageDirection = -1 end; -- Up Left
	["11"] = function(ent) ent.Rotation = 45 ent.ImageDirection = 1 end; -- Down Right
	["1-1"] = function(ent) ent.Rotation = -45 ent.ImageDirection = 1 end; -- Up Right
	["-1-1"] = function(ent) ent.Rotation = 45 ent.ImageDirection = -1 end -- Up Left
}

function Character.SetEvent(event)
	EventSys = event
end

function Character.new(imagepath)

	-- Init vars
	local Char = Entities.new(imagepath)
	Char.MovementDirection = Vector2.new(0, 0)
	Char.FacingDirection = Vector2.new(1, 0)
	Char.Velocity = Vector2.new(0, 0)
	Char.Speed = 0
	Char.Health = 100
	Char.ImageDirection = 1
	Char.MaxHealth = 100
	Char.Shields = 100
	Char.MaxShields = 100
	Char.MaxSpeed = 5
	Char.Acceleration = .1
	Char.Decceleration = .05

	local Last_Shot = 0

	function Char:FireWeapon()
		-- TEST FIRING
		if Last_Shot>0 then return end
		Last_Shot = .2
		local shot = { }
		shot.Size = Vector2.new(10, 3)
		shot.Position = self.Position + (self.FacingDirection * 5)
		shot.Color = {255, 0, 0}
		local s2 = love.graphics.newCanvas(shot.Size.X, shot.Size.Y)
		love.graphics.setCanvas(s2)
		local col = {love.graphics.getColor()}
		love.graphics.setColor(shot.Color)
		love.graphics.rectangle('fill', 0, 0, shot.Size.X, shot.Size.Y)
		love.graphics.setColor(col)
		love.graphics.setCanvas()
		love.graphics.newImage(s2:getImageData())
		shot = Entities.new(s2)
		shot.Rotation = self.Rotation
		shot.ImageDirection = self.ImageDirection
		shot.MovementDirection = Vector2.new(math.cos(math.rad(shot.Rotation)), math.sin(math.rad(shot.Rotation))) * 5
		shot.Velocity = Vector2.new(math.floor((Char.Velocity.X)), math.floor((Char.Velocity.Y)))
		shot.Position = Vector2.new(self.Position.X, self.Position.Y) + (shot.MovementDirection * 2)
		shot.Expiration = 5
		shot.IsShot = true
		self:AddChild(shot)
		EventSys.FireEvent("fire", self, shot)
	end

	Char:AddUpdate("ShotsUpdate", function(self, dt)
		if Last_Shot - dt>-1 then
			Last_Shot = Last_Shot - dt
		end
		--print("SHOTUPDATE")
	--	print(#self.Children)
		for _, v in pairs(self.Children) do
			if v.IsShot then
			--	print('1', v.Position.X, v.Position.Y)
				v.Position = v.Position + (v.MovementDirection * 5) + (v.Velocity)-- * .75)
			--	print("Movement", v.MovementDirection.X, v.MovementDirection.Y)
				v.Expiration = v.Expiration - dt
				--print(v.Expiration, dt)
				if v.Expiration<=0 then
					self:RemoveChild(v)
					v:Delete()
				end
			end
		end
	end)

	function Char:Brakes()
		self.Velocity = self.Velocity + (Vector2.new(math.floor(self.Velocity.X), math.floor(self.Velocity.Y)) * -(self.Decceleration))
	end

	function Char:DirectionFromMovement() -- {1, 0} = Right
		if self.MovementDirection.X==0 and self.MovementDirection.Y==0 then return false end
		local s = tostring(self.MovementDirection.X) .. tostring(self.MovementDirection.Y)
		local Dir = SpaceshipDirections[s]
		if Dir==nil then
			error(tostring(self.MovementDirection.X) .. tostring(self.MovementDirection.Y) .. " does not exist for char anim!")
		end
		Dir(self)
		return true
	end

	function Char:Accelerate(Dir)
		--if self.speed + self.accel > self.maxspeed then return end
		self.Velocity = self.Velocity + (Vector2.new(math.cos(math.rad(self.Rotation)), math.sin(math.rad(self.Rotation))) * (self.Acceleration * Dir))
		if self.Velocity.X>self.MaxSpeed or self.Velocity.X<-self.MaxSpeed then
			self.Velocity.X = self.MaxSpeed * (self.Velocity.X / math.abs(self.Velocity.X))
		end

		if self.Velocity.Y>self.MaxSpeed or self.Velocity.Y<-self.MaxSpeed then
			self.Velocity.Y = self.MaxSpeed * (self.Velocity.Y / math.abs(self.Velocity.Y))
		end

	end


	Char:AddUpdate("CharacterMovementUpdate", 
		function(self, dt)
			local check = self.Position + Vector2.new(math.floor(self.Velocity.X), math.floor(self.Velocity.Y))
			if check.X>self.State.Size.X - self.Size.X/2 or check.X<self.Size.X/2 then check.X = self.Position.X  self.Velocity.X = -self.Velocity.X end
			if check.Y>self.State.Size.Y - self.Size.Y/2 or check.Y<self.Size.Y/2 then check.Y = self.Position.Y  self.Velocity.Y = -self.Velocity.Y end
			self.Position = check
		end)

	function Char:Draw(Camera)
		local Scale = Vector2.new(1, 1)
		--error("DRAWING!")
		for _, v in pairs(self.Children) do
			--print("Drawing child", tostring(v), "for character")
			v:Draw(Camera)
		end
		if Camera then
		--	Scale = Camera.Scale
			if self.Position.X + self.Size.X/2<0  or
				self.Position.X - self.Size.X/2>Camera.Position.X + Camera.Size.X or
				self.Position.Y + self.Size.Y/2<0 or
				self.Position.Y - self.Size.Y/2>Camera.Position.Y + Camera.Size.Y then
			--	error("Off of camera!")
				return 
			end
		end
		love.graphics.draw(self.Image, self.Position.X, self.Position.Y, self.Rotation~=0 and math.rad(self.Rotation) or nil, self.ImageDirection * self.Scale.X, self.Scale.Y, self.ImageDirection and self.Size.X/2, self.ImageDirection and self.Size.Y/2)
	end
	EventSys.FireEvent("newchar", Char)
	return Char
end
return Character