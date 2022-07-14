
local Module = { }

Module.Config = {

	Animations = {
		-- placeable equipment
		TurretCarry = 'rbxassetid://9219668154',
		TurretPlace = 'rbxassetid://0',
		-- grenades
		GrenadeHold = 'rbxassetid://0',
		GrenadeThrow = 'rbxassetid://0',
		-- equipment packs
		PackHold = 'rbxassetid://0',
		PackUse = 'rbxassetid://0',
	},

}

Module.Equipment = {
	{
		ID = 'TurretBurst',
		Model = 'TurretBurst',
		Slot = 4, -- equipment slot
		Type = 'Equipment',
	},
	{
		ID = 'AmmoPack',
		Model = 'AmmoPack',
		Slot = 5, -- ammo pack slot
		Type = 'Utility',
	},
	{
		ID = 'Glowsticks',
		Model = 'Glowsticks',
		Slot = 6, -- misc slot
		Type = 'Misc',
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
