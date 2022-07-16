
local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local RemoteService = ReplicatedModules.Services.RemoteService
local EquipmentFunction = RemoteService:GetRemote('EquipmentFunction', 'RemoteFunction', false)

local SystemsContainer = {}

local EquipmentCache = {}
local KeyCodeToIndex = {
	[Enum.KeyCode.One] = 'Primary',
	[Enum.KeyCode.Two] = 'Secondary',
	[Enum.KeyCode.Three] = 'Melee',
	[Enum.KeyCode.Four] = 'Equipment',
	[Enum.KeyCode.Five] = 'Utility',
	[Enum.KeyCode.Six] = 'Misc',
	-- [Enum.KeyCode.G] = 'Grenade',
	-- [Enum.KeyCode.F] = 'Flashlight',
}

-- // Module // --
local Module = {}

function Module:SetPlayerLoadout( LocalPlayer, LoadoutData )
	EquipmentCache[LocalPlayer] = LoadoutData
end

function Module:Equip( LocalPlayer, keycodeEnum )
	-- print(LocalPlayer, keycodeEnum)
	local LoadoutIndex = KeyCodeToIndex[keycodeEnum]
	if not LoadoutIndex then
		return false, 'Invalid KeyCode passed.'
	end
	local LoadoutWeaponData = EquipmentCache[LocalPlayer][LoadoutIndex]
	if not LoadoutWeaponData then
		return false, 'No Weapon Data Available'
	end
	-- local WeaponConfigData = ...
	print(LocalPlayer.Name, LoadoutWeaponData.ID)
	return true, LoadoutWeaponData.ID
end

-- do this so the tables aren't linked between all players
-- replicate this data to all clients so they can see each other
-- use something like attributes for performance?
function Module:GetDefaultLoadout()
	return {
		Equipped = 	false, -- nothing
		-- weapons
		Primary = 	{ ID = 'G36C', Ammo = 60, Mag = 320 },
		Secondary = { ID = 'Glock19', Ammo = 16, Mag = 64 },
		Melee = 	{ ID = 'MeleeMace' },
		-- utilities
		Equipment = { ID = 'TurretBurst', Amount = 65 },
		Grenades = 	{ ID = 'Frag', Amount = 3 },
		Utility = 	{ ID = 'AmmoPack', Amount = 3 },
		Misc = 		{ ID = 'Glowsticks', Amount = 12 },
		-- progression
		Items = 	{ 'BULKHEAD_KEY_56' }
	}
end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems

	EquipmentFunction.OnServerInvoke = function(LocalPlayer, KeyCodeEnumItem)
		return Module:Equip(LocalPlayer, KeyCodeEnumItem)
	end

	-- Change this later to get the data from their teleport data or whatever method.
	for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
		Module:SetPlayerLoadout( LocalPlayer, Module:GetDefaultLoadout())
	end

	Players.PlayerAdded:Connect(function(LocalPlayer)
		Module:SetPlayerLoadout( LocalPlayer, Module:GetDefaultLoadout())
	end)
end

return Module
