
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer

local SystemsContainer = {}

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

function Module:SetupHumanoidConnections()
	
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

