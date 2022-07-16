
local Module = { }

Module.Animations = {
	--[[
		-- maybe do in class?
		-- some other method of opening/closing turrets, shooting, etc
		Turrets = {
			Auto = {

			},
			Burst = {

			},
			Shotgun = {

			},
			Sniper = {

			},
			Flamethrower = {

			},
		},
	]]

	Player = {
		Turrets = {
			Carry = 'rbxassetid://9219668154',
			Place = 'rbxassetid://0',
		},
		Grenade = {
			Arm = 'rbxassetid://0',
			Cook = 'rbxassetid://0',
			Throw = 'rbxassetid://0',
		},
		ResourcePacks = {
			Hold = 'rbxassetid://0',
			Use = 'rbxassetid://0',
		},
		Glowsticks = {
			Hold = 'rbxassetid://0',
			Use = 'rbxassetid://0',
		},
	},
}

Module.Equipment = {
	{
		ID = 'TurretBurst',
		Model = 'TurretBurst',
		Slot = 4, -- equipment slot
		Type = 'Equipment',

		-- Animations = Module.Animations.Player.Turrets,
	},
	{
		ID = 'AmmoPack',
		Model = 'AmmoPack',
		Slot = 5, -- ammo pack slot
		Type = 'Utility',

		Animations = Module.Animations.Player.ResourcePacks,
	},
	{
		ID = 'Glowsticks',
		Model = 'Glowsticks',
		Slot = 6, -- misc slot
		Type = 'Misc',

		Animations = Module.Animations.Player.Glowsticks
	},
	{
		ID = 'SemtexGrenade',
		Model = 'Semtex',
		Slot = false, -- grenade slot is handled via keybind
		Type = 'Grenade',

		Animations = Module.Animations.Player.Grenade,
	}
}

function Module:GetConfigByID( equipmentID )
	for i, Data in ipairs( Module.Equipment ) do
		if Data.ID == equipmentID then
			return Data, i
		end
	end
	return nil, nil
end

return Module
