
local PhysicsService = game:GetService('PhysicsService')

-- // Module // --
local Module = {}

function Module:SetCollisionGroup(Object, CollisionGroup)
	if Object:IsA('BasePart') then
		return pcall(function() PhysicsService:SetPartCollisionGroup(Object, CollisionGroup) end)
	end
	return false, 'Invalid Object.'
end

function Module:SetModelGroup(Model, CollisionGroup, checkObject)
	for index, part in ipairs(Model:GetDescendants()) do
		if part:IsA('BasePart') and ((not checkObject) or checkObject(part)) then
			Module:SetCollisionGroup(part, CollisionGroup)
		end
	end
end

function Module:SetModelGroupWithClassWhitelist(Model, CollisionGroup, whitelistClasses)
	Module:SetModelGroup(Model, CollisionGroup, function(part)
		return table.find(whitelistClasses, part.ClassName)
	end)
end

function Module:SetModelGroupWithClassBlacklist(Model, CollisionGroup, blacklistClasses)
	assert(typeof(blacklistClasses) == 'table', 'Whitelist Classes must be a table.')
	Module:SetModelGroup(Model, CollisionGroup, function(part)
		return not table.find(blacklistClasses, part.ClassName)
	end)
end

return Module
