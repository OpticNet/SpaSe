-- init libraries
local lib_Entities = require("Entities")
local lib_Camera = require("Camera")
local lib_Controls = require("Controls")
local lib_Character = require("Character")
local lib_Echo = require("Echo")
local lib_Stages = require("Stages")
local Vector2 = require("Vector2")
local lib_Bloom = require("Bloom")
local lib_Glow = require("Glow")
local Assets = require("AssetTree")
local lib_EventSys = require("EventSystem")
-- init control variables
local Fullscreen = false

-- init game variables
local CurrentStage;
local CurrentControl;
local CurrentCamera;
local CurrentState;
local Characters;
local PlayerCharacter;
local DebugConsole;
local Shader;

local function Clamp(num)
	if num==0 then return 0 end
	return (num>0 and 1 or -1)
end

function love.load()

	-- LOVE setup --
	for i = 1, 10 do
		math.random()
	end
	love.keyboard.setKeyRepeat(true)
--	love.window.setTitle("EoA")

	-- Event initialization -- 
	lib_Entities.SetEvent(lib_EventSys)
	lib_Character.SetEvent(lib_EventSys)
	lib_Controls.SetEvent(lib_EventSys)
	lib_Camera.SetEvent(lib_EventSys)
	lib_Stages.SetEvent(lib_EventSys)
	print("LOADING ASSETS")
--	love.timer.sleep(2)
	Assets.Load()
	-- class initialization --
	CurrentStage = lib_Stages.new("Test")
	lib_Entities.SetCurrentState(CurrentStage)
	CurrentStage.Size = Vector2.new(2000, 2000)
	CurrentCamera = lib_Camera.new()
	PlayerCharacter = lib_Character.new(Assets.Ships.HumanMilitary1.Model) 
	PlayerCharacter.Position = Vector2.new(100, 100)
	CurrentStage:AddEntity(PlayerCharacter)

	CurrentControl = lib_Controls.new("OldControls", {
		["w"] = function(tog, kt, h) if tog then PlayerCharacter.MovementDirection.Y = - 1 elseif not h then  PlayerCharacter.MovementDirection.Y =  0 end end;
		["a"] = function(tog, kt, h) if tog then PlayerCharacter.MovementDirection.X = - 1 elseif not h then PlayerCharacter.MovementDirection.X = 0 end end;
		["s"] = function(tog, kt, h) if tog then PlayerCharacter.MovementDirection.Y = 1 elseif not h then PlayerCharacter.MovementDirection.Y = 0 end end;
		["d"] = function(tog, kt, h) if tog then PlayerCharacter.MovementDirection.X = 1 elseif not h then PlayerCharacter.MovementDirection.X = 0 end end;
		["escape"] = function(tog, kt, h) if tog and h then love.window.setFullscreen(not Fullscreen) Fullscreen = not Fullscreen end end;
		[" "] = function(tog, kt, h) if tog and h then PlayerCharacter:FireWeapon() end end;
		}
	)

	CurrentControl = lib_Controls.new("Stage", {
		["w"] = function(tog, kt, h)
			 if tog then 
				PlayerCharacter:Accelerate(1)
			end
		end;
		["a"] = function(tog, kt, h)
			if tog then
				PlayerCharacter.Rotation = PlayerCharacter.Rotation - 3
			end
		end;
		["s"] = function(tog, kt, h)
			if tog then
				PlayerCharacter:Accelerate(-1)
			end
		end;
		["d"] = function(tog, kt, h)
			if tog then
				PlayerCharacter.Rotation = PlayerCharacter.Rotation + 3
			end
		end;
		[" "] = function(tog, kt, h) 
			if tog and h then 
				PlayerCharacter:FireWeapon() 
			end 
		end;
		["q"] = function(tog, kt, h)
			if tog and h then
				PlayerCharacter:Brakes()
			end
		end})

	lib_Controls.TakeControl("Stage")

	--DebugConsole = lib_Echo.new(Vector2.new(0, 44), 10)
	--lib_Controls.PassDebugConsole(DebugConsole)
 
	local earth = lib_Entities.new(Assets.Planets.Planet1.Model)
		earth.CamCutoff = false
		earth.Scale = Vector2.new(2, 2)
		earth.Position = Vector2.new(0, 0)
	CurrentCamera:AddBackground(earth)


	-- POPULATE TEST STAGE --
	local assetlist = {
		Assets.Asteroids.Asteroid1.Model,
		Assets.Asteroids.Asteroid2.Model,
		Assets.Asteroids.Asteroid3.Model,
		Assets.Asteroids.Asteroid4.Model
	}
	for i=1, 40 do
		local rad = lib_Entities.new(assetlist[math.random(#assetlist)])
		rad.Position = Vector2.new(math.random(CurrentStage.Size.X), math.random(CurrentStage.Size.Y))
		CurrentStage:AddEntity(rad)
	end
end

function love.update(dt)
	lib_Controls:Update()
	CurrentStage:Update(dt)
	local X = true
	local Y = true
	local Test = PlayerCharacter.Position + Vector2.new(-CurrentCamera.Size.X/2, -CurrentCamera.Size.Y/2)
	if Test.X<0 or Test.X + ((CurrentCamera.Size.X/2) * CurrentCamera.Scale.X)>CurrentStage.Size.X then -- THE * 2 WAS HERE
		X = false
	end
	if Test.Y<0 or Test.Y + ((CurrentCamera.Size.Y/2) * CurrentCamera.Scale.Y)>CurrentStage.Size.Y then
		Y = false
	end

	CurrentCamera.Position = Vector2.new(
		X and PlayerCharacter.Position.X + ((-CurrentCamera.Size.X/2)) or CurrentCamera.Position.X,
		Y and PlayerCharacter.Position.Y + ((-CurrentCamera.Size.Y/2)) or CurrentCamera.Position.Y)
	--DebugConsole:Print(tostring(PlayerCharacter.Position.X) .. " "..tostring(PlayerCharacter.Position.Y))
end

function love.draw()
	CurrentCamera:DrawOnState(CurrentStage)
	love.graphics.print("FPS: "..tostring(love.timer.getFPS()))
	love.graphics.print("Health: ".. tostring(PlayerCharacter.Health) .. "/" .. tostring(PlayerCharacter.MaxHealth), 0, 11)
	love.graphics.print("Shields: ".. tostring(PlayerCharacter.Shields) .. "/" .. tostring(PlayerCharacter.MaxShields), 0, 22)
	love.graphics.print("Coords: "..tostring(PlayerCharacter.Position.X)..": "..tostring(PlayerCharacter.Position.Y), 0, 33)
	love.graphics.print("CamCoord: "..tostring(CurrentCamera.Position.X)..": "..tostring(CurrentCamera.Position.Y), 0, 44)
	--DebugConsole:Draw()
end