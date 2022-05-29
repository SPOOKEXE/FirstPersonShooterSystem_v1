
local RunService = game:GetService('RunService')

local EventClass = require(script.Parent.Event)

local Timers = {}

RunService.Heartbeat:Connect(function()
	local newClock = os.clock()
	for i, timerClass in pairs(Timers) do
		if timerClass._destroyed then
			table.remove(Timers, i)
			break
		end
		local deltaTime = (newClock - timerClass._lastTick)
		if deltaTime >= timerClass.Interval then
			timerClass._lastTick = newClock
			timerClass.Signal:Fire()
		end
	end
end)

-- // Class // --
local Class = {}

function Class.New(Properties)

	local self = {
		Active = true,
		Interval = 1,
		Signal = EventClass.New(),

		_lastTick = -1,
		_destroyed = false,
	}

	if typeof(Properties) == 'table' then
		for propName, propValue in pairs(Properties) do
			self[propName] = propValue
		end
	end

	setmetatable(self, Class)

	table.insert(Timers, self)

	return self

end

function Class:Destroy()
	self.Active = false
	self._destroyed = true
	self.Signal:Disconnect()
end

return Class

