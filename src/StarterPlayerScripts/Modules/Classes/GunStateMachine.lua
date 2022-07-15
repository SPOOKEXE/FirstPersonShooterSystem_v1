
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local EventClass = ReplicatedModules.Classes.Event
local FiniteStateMachineClass = ReplicatedModules.Classes.FiniteStateMachine

-- // Class // --
local Module = {}

function Module.New()
	local Events = {
		Equip = EventClass.New(),
		Unequip = EventClass.New(),

		Aimed = EventClass.New(),
		Reload = EventClass.New(),
		Inspect = EventClass.New(),
	}

	local FiniteStateInstance = FiniteStateMachineClass.create({
		initial = {state = "unequip", event = "init", defer = true},
		events = {
			-- to unequip state
			{name = "Unequip", from = "unequip", to = "unequip"},
			{name = "Unequip", from = "none", to = "unequip"},
			{name = "Unequip", from = "equip", to = "unequip"},
			{name = "Unequip", from = "idle", to = "unequip"},
			{name = "Unequip", from = "aim", to = "unequip"},
			{name = "Unequip", from = "inspect", to = "unequip"},
			-- to equip state
			{name = "Equipped", from = "equip", to = "equip"},
			{name = "Equipped", from = "none", to = "equip"},
			{name = "Equipped", from = "unequip", to = "equip"},
			-- from any state to idled
			{name = "Idled", from = "idle", to = "idle"},
			{name = "Idled", from = "none", to = "idle"},
			{name = "Idled", from = "equip", to = "idle"},
			{name = "Idled", from = "inspect", to = "idle"},
			{name = "Idled", from = "reload", to = "idle"},
			{name = "Idled", from = "aim", to = "idle"},
			-- from inspect/idle to aim
			{name = "Aimed", from = "reload", to = "aim"},
			{name = "Aimed", from = "idle", to = "aim"},
			-- from aim/idle to reload
			{name = "Reload", from = "aim", to = "reload" },
			{name = "Reload", from = "idle", to = "reload" },
			-- from idle to inspect
			{name = "Inspect", from = "idle", to = "inspect" },
		},
		callbacks = {
			on_Equipped = function(self, event, from, to, msg)
				print('equipped')
				Events.Equipped:Fire(self, event, from, to, msg)
				self.Idled()
			end,
			on_Unequip = function(self, event, from, to, msg)
				print('unequipped')
				Events.Unequip:Fire(self, event, from, to, msg)
			end,
			on_Idled = function(self, event, from, to, msg)
				print('idled')
				Events.Idled:Fire(self, event, from, to, msg)
			end,
			on_Aimed = function(self, event, from, to, msg)
				print('aimed')
				Events.Aimed:Fire(self, event, from, to, msg)
			end,
			on_Reload = function(self, event, from, to, msg)
				print('reload')
				Events.Reload:Fire(self, event, from, to, msg)
			end,
			on_Inspect = function(self, event, from, to, msg)
				print('inspect')
				Events.Inspect:Fire(self, event, from, to, msg)
			end,
		},
	})

	return Events, FiniteStateInstance
end

return Module
