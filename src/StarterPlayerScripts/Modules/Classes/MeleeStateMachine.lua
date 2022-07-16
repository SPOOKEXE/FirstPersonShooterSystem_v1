
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local EventClass = ReplicatedModules.Classes.Event
local FiniteStateMachineClass = ReplicatedModules.Classes.FiniteStateMachine

-- // Class // --
local Module = {}

function Module.New()
	local Events = {
		-- movement (handled elsewhere)
		-- Walk = EventClass.New(),
		-- Ran = EventClass.New(),
		-- actions
		Equip = EventClass.New(),
		Unequipped = EventClass.New(),
		Idled = EventClass.New(),

		Charge = EventClass.New(),
		Swing = EventClass.New(),
		Inspect = EventClass.New(),
	}

	local FiniteStateInstance = FiniteStateMachineClass.create({
		initial = {state = "unequip", event = "init", defer = true},
		events = {
			-- to unequip state
			{name = "Unequipped", from = "unequip", to = "unequip"},
			{name = "Unequipped", from = "none", to = "unequip"},
			{name = "Unequipped", from = "equip", to = "unequip"},
			{name = "Unequipped", from = "idle", to = "unequip"},
			{name = "Unequipped", from = "inspect", to = "unequip"},
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
			{name = "Idled", from = "charge", to = "idle"},
			-- from inspect/idle to aim
			{name = "Charge", from = "inspect", to = "aim"},
			{name = "Charge", from = "idle", to = "aim"},
			-- from aim/idle to reload
			{name = "Swing", from = "charge", to = "swing" },
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
				Events.Unequipped:Fire(self, event, from, to, msg)
			end,
			on_Idled = function(self, event, from, to, msg)
				print('idled')
				Events.Idled:Fire(self, event, from, to, msg)
			end,
			on_Charged = function(self, event, from, to, msg)
				print('charge')
				Events.Charge:Fire(self, event, from, to, msg)
			end,
			on_Swing = function(self, event, from, to, msg)
				print('swing')
				Events.Swing:Fire(self, event, from, to, msg)
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
