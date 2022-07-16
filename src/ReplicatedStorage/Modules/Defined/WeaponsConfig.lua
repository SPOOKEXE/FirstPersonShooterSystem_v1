
local function CreateAnimationsFromBase(Overwrite)
	local Default = {
		Equipped = 'rbxassetid://0',
		Idled = 'rbxassetid://0',
		Walk = 'rbxassetid://0',
		Ran = 'rbxassetid://0',
		Unequip = 'rbxassetid://0',

		Aimed = 'rbxassetid://0',
		Reload = 'rbxassetid://0',
		Inspect = 'rbxassetid://0',
		Shoot = 'rbxassetid://0',
	}
	for k, v in pairs(Overwrite) do
		Default[k] = v
	end
	return Default
end

-- // Module // --
local Module = { }

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

		Animations = CreateAnimationsFromBase({ }),
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

		Animations = CreateAnimationsFromBase({ }),
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

		Animations = CreateAnimationsFromBase({ }),
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

