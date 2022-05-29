
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local SystemsContainer = {}

local MaidInstance = ReplicatedModules.Classes.Maid.New()
local CameraSpring = ReplicatedModules.Classes.Spring.new(2, 150)
local CurrentCamera = workspace.CurrentCamera

local humanoid = nil

-- updates the camera's sway
local updateSpeed = 6
local xAmp = 0.8
local yAmp = 10
--script:SetAttribute('xAmp', xAmp)
--script:SetAttribute('yAmp', yAmp)
--script:SetAttribute('updateSpeed', updateSpeed)
local function UpdateLocalSway(dt)
	--xAmp = script:GetAttribute('xAmp')
	--yAmp = script:GetAttribute('yAmp')
	--updateSpeed = script:GetAttribute('updateSpeed')
	if humanoid and humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0 then
		local xDelta = xAmp * math.sin(time() * updateSpeed)  * dt
		local yDelta = yAmp * math.cos(time() * updateSpeed) * dt
		CameraSpring.shove( Vector3.new(xDelta, yDelta, 0) )
	end
	local update = CameraSpring.update(dt)
	TweenService:Create(CurrentCamera, TweenInfo.new(dt * 1.5), {CFrame = CurrentCamera.CFrame * CFrame.Angles(0, update.X, update.Y)}):Play()
end

-- // Module // --
local Module = { CameraBobberEnabled = false }

-- release the sway function
function Module:_Release()
	MaidInstance:Cleanup()
end

-- Connect the camera with a swaying function for renderstepped
function Module:_Connect()
	Module:_Release() -- make sure there is no doubling up
	MaidInstance:Give(RunService.RenderStepped:Connect(UpdateLocalSway))
end

-- is the swaying enabled
function Module:IsEnabled()
	return Module.CameraBobberEnabled
end

-- enable the swaying
function Module:Enable()
	Module.CameraBobberEnabled = true
	Module:_Connect()
end

-- disable the swaying
function Module:Disable()
	Module.CameraBobberEnabled = false
	Module:_Release()
end

-- initializer
function Module:Init( otherSystems )
	SystemsContainer = otherSystems

	local function CharacterAdded( newCharacter )
		humanoid = newCharacter and newCharacter:WaitForChild('Humanoid', 3)
		if humanoid then
			humanoid.Died:Connect(task.delay, 3, function()
				Module:Disable()
			end)
			Module:Enable()
		end
	end

	task.spawn(CharacterAdded, LocalPlayer.Character)
	LocalPlayer.CharacterAdded:Connect(CharacterAdded)
end

return Module
