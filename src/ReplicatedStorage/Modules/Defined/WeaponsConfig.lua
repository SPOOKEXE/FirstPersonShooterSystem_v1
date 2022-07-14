
local Module = { }

Module.Config = {

	Animations = {
		ADS_Animation = 'rbxassetid://9219668154',
		Run_Animation = 'rbxassetid://9224250342',
		Reload_Animation = 'rbxassetid://9228833409',
	},

}

Module.Weapons = {
	{
		ID = 'G36C',
		Model = 'G36C',
		Type = 'Gun',

		Slot = 1, -- Primary Gun
		HandleRotation = CFrame.Angles( math.rad(-90), 0, 0 ),

		-- Bullet Damage
		Damage = {
			Head = 35,
			UpperTorso = 20,
			LowerTorso = 15,
			Default = 10,
		},

		Firing = {
			Velocity = 500, -- Studs / Second
			Spread = 0.05,
			Firerate = 30, -- Bullets/second
			BulletsCount = 100, -- Bullets in each shot
		},

		Ammo = {
			Magazine = 1500,
			Capacity = 12000,
			ReloadTime = 2,
		},

		Sounds = {
			Equip = 0,
			Unequip = 0,
			Aim = 0,
			Reload = 0,
			Shoot = 0,
		},

	},
	{
		ID = 'Glock19',
		Model = 'Glock19',
		Type = 'Gun',

		Slot = 2, -- secondary
		HandleRotation = CFrame.Angles( math.rad(-90), math.rad( 90 ), 0 ),

		-- Bullet Damage
		Damage = {
			Head = 25,
			UpperTorso = 15,
			LowerTorso = 10,
			Default = 5,
		},

		Firing = {
			Velocity = 500, -- Studs / Second
			Spread = 0.15,
			Firerate = 25, -- Bullets/second
			BulletsCount = 200, -- Bullets in each shot
		},

		Ammo = {
			Magazine = 1500,
			Capacity = 12000,
			ReloadTime = 2,
		},

		Sounds = {
			Equip = 0,
			Unequip = 0,
			Aim = 0,
			Reload = 0,
			Shoot = 0,
		},

	},
	{
		ID = 'MeleeMace',
		Model = 'MeleeMace',
		Type = 'Melee',

		Slot = 3, -- melee
		HandleRotation = CFrame.Angles( math.rad(-90), math.rad( 90 ), 0 ),

		-- Melee Damage {min charge, max charge} : rounded to nearest
		Damage = {
			Head = {5, 25},
			UpperTorso = {5, 15},
			LowerTorso = {5, 10},
			Default = {5, 8},
		},

		Melee = {
			ChargeTime = 2, -- charging time
			Reach = 2, -- studs of reach
			Cooldown = 0.5, -- cooldown in-between attacks
		},

		Sounds = {
			Equip = 0,
			Unequip = 0,
			Charge = 0,
			Hit = 0,
		},
	},
}

function Module:GetConfigByID( weaponID )
	for i, Data in ipairs( Module.Weapons ) do
		if Data.ID == weaponID then
			return Data, i
		end
	end
	return nil, nil
end

return Module

