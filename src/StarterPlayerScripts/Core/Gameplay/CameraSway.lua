
local ContextActionService = game:GetService('ContextActionService')
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local ShiftLockedValue = LocalPlayer:WaitForChild('ShiftLocked')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local MaidInstance = ReplicatedModules.Classes.Maid.New()
local CameraSpring = ReplicatedModules.Classes.Spring.new(12, 150)

local Interface = LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('Interface')

local CurrentCamera = workspace.CurrentCamera

local SystemsContainer = {}

-- walking / running
local UpdateSpeed = 8
local xAmp = 0.2
local yAmp = 2.5
local SpeedDivisor = 36

local Humanoid, HumanoidSpeed = false, 1

-- jump power
local zAmp = -0.8 -- negative = up direction first
local jumpForceAmp = 0.95
local jumpForceDecay = 0.955
local activeJumpShove = 0

local function UpdateLocalSway(dt)
	if Humanoid and Humanoid.Health > 0 and (Humanoid.MoveDirection.Magnitude > 0 or activeJumpShove > 0) then
		local xDelta = xAmp * math.sin(time() * UpdateSpeed) * dt * (HumanoidSpeed / SpeedDivisor)
		local yDelta = yAmp * math.cos(time() * UpdateSpeed) * dt * (HumanoidSpeed / SpeedDivisor)
		local zDelta = zAmp * math.sin(time() * UpdateSpeed) * dt * (activeJumpShove / jumpForceAmp)
		activeJumpShove *= jumpForceDecay
		CameraSpring.shove( Vector3.new(xDelta, yDelta, zDelta) )
	end
	local update = CameraSpring.update(dt)
	TweenService:Create(CurrentCamera, TweenInfo.new(dt * 1.45), {CFrame = CurrentCamera.CFrame * CFrame.Angles(update.Z, update.X, update.Y)}):Play()
end

-- // Module // --
local Module = { CameraBobberEnabled = false }

function Module:LockCamera()
	MaidInstance:Give(RunService.RenderStepped:Connect(UpdateLocalSway))
	MaidInstance:Give(ShiftLockedValue.Changed:Connect(function()
		ShiftLockedValue.Value = true
	end))
	Module.CameraBobberEnabled = true
	ShiftLockedValue.Value = true
	UserInputService.MouseIconEnabled = false
	LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
end

function Module:UnlockCamera()
	MaidInstance:Cleanup()
	LocalPlayer.CameraMode = Enum.CameraMode.Classic
	UserInputService.MouseIconEnabled = true
	ShiftLockedValue.Value = false
	Interface.WhiteDot.Visible = false
	Module.CameraBobberEnabled = false
end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems

	local function CharacterAdded( newCharacter )
		Humanoid = newCharacter and newCharacter:WaitForChild('Humanoid', 3)
		if Humanoid then
			Humanoid.Died:Connect(task.delay, 3, function()
				Module:UnlockCamera()
			end)
			Humanoid.Running:Connect(function(speed)
				HumanoidSpeed = speed
			end)
			Humanoid:GetPropertyChangedSignal('Jump'):Connect(function()
				if Humanoid.Jump then
					activeJumpShove = jumpForceAmp
				end
			end)
			Module:LockCamera()
		end
	end

	task.defer(CharacterAdded, LocalPlayer.Character)
	LocalPlayer.CharacterAdded:Connect(CharacterAdded)

	ContextActionService:BindAction('toggleLock', function(actionName, inputState, _)
		if actionName == 'toggleLock' and inputState == Enum.UserInputState.Begin then
			if Module.CameraBobberEnabled then
				Module:UnlockCamera()
			else
				Module:LockCamera()
			end
		end
	end, false, Enum.KeyCode.X)

	ContextActionService:BindAction('ShiftToSprint', function(actionName, inputState, _)
		if actionName == 'ShiftToSprint' and Humanoid then
			local startedRunning = (inputState == Enum.UserInputState.Begin)
			Humanoid.WalkSpeed = startedRunning and 26 or 16
			xAmp = startedRunning and 0.4 or 0.2
		end
	end, false, Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift)

end

return Module
