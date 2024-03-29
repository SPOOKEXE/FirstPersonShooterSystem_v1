
local ContextActionService = game:GetService('ContextActionService')

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local LocalModules = require(LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Modules'))

local GunStateMachineClass = LocalModules.Classes.GunStateMachine
local MeleeStateMachineClass = LocalModules.Classes.MeleeStateMachine
local CharacterStateMachineClass = LocalModules.Classes.CharacterStateMachine

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')
local ReplicatedCore = require(ReplicatedStorage:WaitForChild('Core'))
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local ReplicatedData = ReplicatedCore.ReplicateData

local RemoteService = ReplicatedModules.Services.RemoteService
local EquipmentFunction = RemoteService:GetRemote('EquipmentFunction', 'RemoteFunction', false)

local EquipmentConfig = ReplicatedModules.Defined.EquipmentConfig
local WeaponsConfig = ReplicatedModules.Defined.WeaponsConfig
local ModelUtility = ReplicatedModules.Utility.Models

local SystemsContainer = {}

local EquippedID = false
local EquippedConfig = false

local ActiveStateMachineEvents = false
local ActiveStateMachineInstance = false

local Humanoid = false

local AnimationMachineEvents = false
local CharacterAnimationMachineInstance = false

local LoadedAnimations = {}

local function GetCachedAnimationObject( AnimationId )
	local animObj = script:FindFirstChild(AnimationId)
	if not animObj then
		animObj = Instance.new('Animation')
		animObj.Name = AnimationId
		animObj.Parent = script
	end
	return animObj
end

-- // Module // --
local Module = {}

function Module:LoadAnimation( AnimationName, AnimationID )
	if AnimationID == 'rbxassetid://0' or AnimationID == 'rbxassetid://' then
		return false
	end
	local LoadedAnimation = LoadedAnimations[AnimationName]
	if not LoadedAnimation then
		local AnimObj = GetCachedAnimationObject( AnimationID )
		LoadedAnimation = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(AnimObj)
		LoadedAnimations[AnimationName] = LoadedAnimation
	end
	return LoadedAnimation
end

--[[
	Run the unequip animation and keep limbs off screen
	until equip animation is called.
]]
function Module:SetupStateMachineEvents()
	if (not ActiveStateMachineEvents) or (not EquippedConfig) then
		warn('No active state machine events')
		return
	end
	-- print(ActiveStateMachineEvents, EquippedConfig)
	for animationName, animID in pairs( EquippedConfig.Animations ) do
		Module:LoadAnimation( animationName, animID )
	end

	if ActiveStateMachineInstance then
		ActiveStateMachineInstance.init()
	end
end

--[[
	reset the current state machine entirely,
	updates the state machine to match for what type of
	item is equipped.
]]
function Module:ResetStateMachine()
	print('reset the state machine')
	if not EquippedID then
		warn('No Equipment Equipped. Cannot create animation state machine.')
		return
	end

	print(EquippedID)
	local equipmentConfig = WeaponsConfig:GetConfigByID(EquippedID) or EquipmentConfig:GetConfigByID(EquippedID)
	if not equipmentConfig then
		warn('Invalid equipment given ID ; ', EquippedID)
		return
	end

	EquippedConfig = equipmentConfig
	ActiveStateMachineInstance, ActiveStateMachineEvents = nil, nil

	-- print(equipmentConfig.Type)
	if equipmentConfig.Type == 'Gun' then
		print('gun state machine')
		ActiveStateMachineInstance, ActiveStateMachineEvents = GunStateMachineClass.New()
	elseif equipmentConfig.Type == 'Melee' then
		print('melee state machine')
		ActiveStateMachineInstance, ActiveStateMachineEvents = MeleeStateMachineClass.New()
	elseif equipmentConfig.Type == 'Equipment' then
		print('equipment state machine')
	elseif equipmentConfig.Type == 'Utility' then
		print('utility state machine')
	elseif equipmentConfig.Type == 'Misc' then
		print('misc state machine')
	end

	if ActiveStateMachineInstance and ActiveStateMachineEvents then
		print('setup state machine events')
		Module:SetupStateMachineEvents()
	end
end

--[[
	Try set the state machine state so that animations
	match with the action the user is trying to do
]]
function Module:AttemptSetStateMachineState(setState)
	if not ActiveStateMachineInstance then
		warn('No active state machine')
		return
	end
	print('try set machine state ', setState)
end

--[[
	Equip a certain gun model for a player
	Changes the model of the current equipped weapon to the
	model found by this equippedID
]]
local EquippedCache = {}
function Module:SetEquipped( PlayerInstance, equippedID )
	local configTable = WeaponsConfig:GetConfigByID(equippedID) or EquipmentConfig:GetConfigByID(equippedID)
	if not configTable then
		warn('No Config can be found for ID ', equippedID)
		return
	end

	local ModelInstance = configTable.Model and ModelUtility:FindFirstDescendant(ReplicatedAssets, configTable.Model)
	if not ModelInstance then
		warn('Could not find model under ReplicatedStorage -> Assets ;; ', configTable.Model)
		return
	end

	if EquippedCache[PlayerInstance] then
		EquippedCache[PlayerInstance]:Destroy()
		EquippedCache[PlayerInstance] = nil
	end

	-- temporary solution for testing
	local rotationCFrame = configTable.HandleRotation or CFrame.identity
	ModelInstance = ModelInstance:Clone()
	ModelInstance:SetPrimaryPartCFrame(PlayerInstance.Character.RightHand.CFrame * rotationCFrame)
	ModelUtility:WeldConstraint(ModelInstance.PrimaryPart, PlayerInstance.Character.RightHand)
	ModelInstance.Parent = PlayerInstance.Character
	EquippedCache[PlayerInstance] = ModelInstance

	if PlayerInstance == LocalPlayer then
		EquippedID = equippedID
		Module:ResetStateMachine()
	end
end

function Module:Equip( keycodeEnum )
	Module:AttemptSetStateMachineState('unequip')
	--[[
		by this point the weapon should be offscreen as "unequipped"
		if it isnt then it'll swap out of the player's current weapon
		that is in their hands.
	]]
	local success, data = EquipmentFunction:InvokeServer(keycodeEnum)
	-- print(success, data)
	if success then
		Module:SetEquipped( LocalPlayer, data )
	else
		warn('Failed to equip ', keycodeEnum, ' - ', data)
	end
	Module:AttemptSetStateMachineState('equip')
end

function Module:AttemptSetCharacterState(newState)
	print(CharacterAnimationMachineInstance and CharacterAnimationMachineInstance.current, newState)
	if CharacterAnimationMachineInstance and CharacterAnimationMachineInstance.can(newState) then
		CharacterAnimationMachineInstance[newState]()
	else
		warn('can not go from current character animation state to ', newState)
	end
end

function Module:CharacterAdded( NewCharacter )
	LoadedAnimations = {}
	CharacterAnimationMachineInstance, AnimationMachineEvents = CharacterStateMachineClass.New()

	

	task.wait()

	Module:Equip(Enum.KeyCode.Three) -- default to the melee
end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems

	task.defer(function()
		Module:CharacterAdded( LocalPlayer.Character )
	end)

	-- Primary, Secondary, Melee, Equipment, Utility Pack, Extra
	local SlotNumbers = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six}
	ContextActionService:BindAction('EquipWeapon', function(actionName, inputState, inputObject)
		if actionName == 'EquipWeapon' and inputState == Enum.UserInputState.Begin then
			Module:Equip( inputObject.KeyCode )
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end, false, unpack(SlotNumbers))

	LocalPlayer.CharacterAdded:Connect(function( NewCharacter )
		Module:CharacterAdded( NewCharacter )
	end)

end

return Module
