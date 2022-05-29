

local Module = {}

Module.Regions = {}

function Module:GetConfigFromID( regionID )
	for i, regionData in ipairs( Module.Regions ) do
		if regionData.ID == regionID then
			return regionData, i
		end
	end
	return nil, nil
end

return Module
