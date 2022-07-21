
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer

local SystemsContainer = {}

local Humanoid = false :: Humanoid

-- // Module // --
local Module = {}

-- reset state
-- tries to reset state back to idle if possible, returns boolean whether it can
function Module:ResetState() : boolean
	
end

-- find the next state from the current state
-- returns that state string
function Module:FindNextState( currentState ) : string
	
end

function Module:ToState( stateString )
	
end

-- can sprint, check if state is jumping or not
function Module:CanSprint()
	
end

-- check if currently jumping, otherwise yes, cancel reload too
function Module:CanJump()
	
end

-- check if currently jumping, etc..
-- exit gun state to idle and stop sprinting, etc
function Module:CanReload()
	
end

function Module:ToWalkState()
	
end

function Module:ToRunState()
	
end

function Module:ToJumpState()
	
end

function Module:ToCrouchState()
	
end

function Module:SetupHumanoidConnections( NewCharacter )

	for eventName, eventSignal in pairs(AnimationMachineEvents) do

		print(eventName, tostring(eventSignal))
		eventSignal:Connect(function()
			print(eventName, ' is the new state of the character')
		end)

	end

	Humanoid = NewCharacter:WaitForChild('Humanoid') :: Humanoid

	Humanoid.Died:Connect(function()
		CharacterAnimationMachineInstance = false
		AnimationMachineEvents = false
		Humanoid = false
	end)

	Humanoid.Running:Connect(function(speed)
		if speed > 0 then
			Module:AttemptSetCharacterState(speed > 6 and 'run' or 'walk')
		else
			Module:AttemptSetCharacterState('idle')
		end
	end)

end

function Module:CharacterAdded( NewCharacter )
	if not NewCharacter then
		return
	end

end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems

	-- character added
	Module:CharacterAdded(LocalPlayer.Character)
	LocalPlayer.CharacterAdded:Connect(function(character)
		Module:CharacterAdded(character)
	end)
end

return Module

