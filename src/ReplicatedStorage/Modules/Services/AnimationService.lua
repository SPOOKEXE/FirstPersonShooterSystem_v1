
local RunService = game:GetService('RunService')

local _LoadedCache = {}
local _AnimObjCache = {}

local Module = { LoadedAnimationCache = _LoadedCache, AnimObjectCache = _AnimObjCache }

function Module:AssertAnimationPlayer(AnimationDevice )
	assert(typeof(AnimationDevice) == 'Instance', 'AnimationDevice must be an Instance.')
	assert(AnimationDevice:IsA('AnimationController') or AnimationDevice:IsA('Humanoid') or AnimationDevice:IsA("Animator"), 'AnimationDevice must be a Humanoid/AnimationController/Animator.')
end

function Module:AssertAnimation(Animation)
	Animation = Module:AnimationInput(Animation)
	assert(typeof(Animation) == "Instance" and Animation:IsA("Animation"), "Animation is not a valid Animation.")
	return Animation
end

function Module:GetModelAnimator(Model, bypassGenerate)
	local AutoAnimator = Model and Model:FindFirstChildOfClass("Humanoid") or Model:FindFirstChildOfClass("AnimationController")
	local Animator = AutoAnimator and AutoAnimator:FindFirstChildOfClass("Animator") or Model:FindFirstChildOfClass("Animator")
	if (not Animator) and (bypassGenerate or RunService:IsServer()) then
		Animator = Instance.new("Animator")
		if not AutoAnimator then
			AutoAnimator = Instance.new("AnimationController")
			AutoAnimator.Parent = Model
		end
		Animator.Parent = AutoAnimator
	end
	return Animator
end

function Module:AnimationInput(InputValue, _original)
	if not _original then
		if _AnimObjCache[InputValue] then
			return _AnimObjCache[InputValue]
		end
		_original = InputValue
	end
	if typeof(InputValue) == 'string' or typeof(InputValue) == 'number' then
		if typeof(InputValue) == 'number' then
			InputValue = 'rbxassetid://'..InputValue
		end
		local animationObject = Instance.new('Animation')
		animationObject.Name = tostring(_original)
		animationObject.AnimationId = InputValue
		animationObject.Parent = script
		return Module:AnimationInput(animationObject, _original)
	elseif typeof(InputValue) == "Instance" then
		if InputValue:IsA('Animation') then
			Module.AnimObjectCache[_original] = InputValue
			return InputValue
		elseif InputValue:IsA('KeyframeSequenceProvider') then
			warn('Avoid Loading KeyFrame Sequences. Only works in studio.')
			if RunService:IsStudio() then
				local Provider = game:GetService('KeyframeSequenceProvider')
				local AssetID = Provider:GetKeyframeSequenceAsync(InputValue, _original)
				Module.AnimObjectCache[_original] = AssetID
				return AssetID
			end
		end
	end
	return InputValue
end

function Module:GetPredeterminedAnimations( InputAnimationTable )
	local OutputTable = { }
	for animName, animID in pairs( InputAnimationTable ) do
		local inputType = Module:AnimationInput( animID )
		if typeof(inputType) == "Instance" and inputType:IsA("Animation") then
			OutputTable[animName] = inputType
		end
	end
	return OutputTable
end

function Module:GetAnimationTrack(AnimationPlayer, Animation, createAnimator, animationProperties)

	Module:AssertAnimationPlayer(AnimationPlayer)
	Animation = Module:AssertAnimation(Animation)

	if not Module.LoadedAnimationCache[AnimationPlayer] then
		Module.LoadedAnimationCache[AnimationPlayer] = {}
		-- On died/destroyed, remove animations.
		if AnimationPlayer:IsA("Humanoid") then
			AnimationPlayer.Died:Connect(function()
				Module.LoadedAnimationCache[AnimationPlayer] = nil
			end)
		elseif AnimationPlayer:IsA("AnimationController") or AnimationPlayer:IsA("Animator") then
			AnimationPlayer.Destroying:Connect(function()
				Module.LoadedAnimationCache[AnimationPlayer] = nil
			end)
		end
	end

	-- Allows the passer to determine whether to generate animations or not.
	if Module.LoadedAnimationCache[AnimationPlayer][Animation] then
		return Module.LoadedAnimationCache[AnimationPlayer][Animation]
	end

	local Animator = AnimationPlayer:IsA('Animator') and AnimationPlayer or AnimationPlayer:FindFirstChildOfClass("Animator")
	if (not Animator) then
		if (RunService:IsServer() or createAnimator) then
			Animator = Instance.new("Animator")
			Animator.Parent = AnimationPlayer
		else
			return nil
		end
	end

	local LoadedAnimation = Animator:LoadAnimation(Animation)
	Module.LoadedAnimationCache[AnimationPlayer][Animation] = LoadedAnimation
	if typeof(animationProperties) == 'table' then
		for k, v in pairs(animationProperties) do
			LoadedAnimation[k] = v
		end
	end
	return LoadedAnimation

end

function Module:RunAnimation(AnimationPlayer, Animation, Properties)
	Properties = Properties or {}
	local LoadedAnimation = Module:GetAnimation(AnimationPlayer, Animation, true, Properties)
	if not LoadedAnimation then
		return nil
	end
	LoadedAnimation:Play(Properties.Play)
	return LoadedAnimation
end

function Module:StopAnimation(AnimationObject, SpecificAnimationPlayer)
	AnimationObject = Module:AnimationInput(AnimationObject)
	assert(typeof(AnimationObject) == "Instance" and AnimationObject:IsA("Animation"), "Invalid Animation Input.")
	for animPlayerObj, animTable in pairs(Module.LoadedAnimationCache) do
		if (not SpecificAnimationPlayer) or animPlayerObj == SpecificAnimationPlayer then
			for animObj, loaded in pairs(animTable) do
				if animObj == AnimationObject then
					loaded:Stop()
				end
			end
		end
	end
end

function Module:HasAnimationRunning(AnimationPlayer, AnimationObject)
	Module:AssertAnimationPlayer(AnimationPlayer)
	AnimationObject = Module:AnimationInput(AnimationObject)
	assert(typeof(AnimationObject) == "Instance" and AnimationObject:IsA("Animation"), "Invalid Animation Input.")
	local Animator = AnimationPlayer:IsA("Animator") and AnimationPlayer or Module:GetModelAnimator(AnimationPlayer, false)
	if Animator then
		for index, loadedAnimation in pairs(Animator:GetPlayingAnimationTracks()) do
			if string.find(loadedAnimation.Animation.AnimationId, AnimationObject.AnimationId) then
				return true
			end
		end
	end
	return false
end

return Module