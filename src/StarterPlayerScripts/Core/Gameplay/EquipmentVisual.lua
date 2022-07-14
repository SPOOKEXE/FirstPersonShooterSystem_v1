
local ContextActionService = game:GetService('ContextActionService')

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local RemoteService = ReplicatedModules.Services.RemoteService
local EquipmentFunction = RemoteService:GetRemote('EquipmentFunction', 'RemoteFunction', false)

local EquipmentConfig = ReplicatedModules.Defined.EquipmentConfig
local WeaponsConfig = ReplicatedModules.Defined.WeaponsConfig

local ModelUtility = ReplicatedModules.Utility.Models

local SystemsContainer = {}

-- // Module // --
local Module = {}

-- Equip a certain gun model for a player
-- Changes the model of the current equipped weapon to the
-- model found by this equippedID
local EquippedCache = {}
function Module:SetEquipped( PlayerInstance, equippedID )
	warn('Change model / animations / etc to fit weapon of type : ', equippedID)
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
end

-- run the unequip animation and keep limbs offscreen
-- until equip animation is called
function Module:UnequipAnimation()
	print('unequip animation - lower priority')
end

-- run the equip animation and bring the tool back onto the screen
function Module:EquipAnimation()
	print('equip animation - higher priority')
end

function Module:Equip( keycodeEnum )
	task.spawn(function()
		Module:UnequipAnimation()
	end)
	--[[
		by this point the weapon should be offscreen as "unequipped"
		if it isnt then it'll swap out of the player's current weapon
		that is in their hands.
	]]
	local success, data = EquipmentFunction:InvokeServer(keycodeEnum)
	print(success, data)
	if success then
		Module:SetEquipped( LocalPlayer, data )
	else
		warn('Failed to equip ', keycodeEnum, ' - ', data)
	end
	Module:EquipAnimation()
end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems

	-- Primary, Secondary, Melee, Equipment, Utility Pack, Extra
	local SlotNumbers = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six}

	ContextActionService:BindAction('EquipWeapon', function(actionName, inputState, inputObject)
		if actionName == 'EquipWeapon' and inputState == Enum.UserInputState.Begin then
			Module:Equip( inputObject.KeyCode )
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end, false, unpack(SlotNumbers))

	-- default to the melee
	Module:Equip(Enum.KeyCode.Three)
end

return Module
