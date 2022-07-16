
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

		Aimed = EventClass.New(),
		Reload = EventClass.New(),
		Inspect = EventClass.New(),
	}

	local FiniteStateInstance = FiniteStateMachineClass.create({

		initial = { state = "unequip", event = "init", defer = true },

		events = {
			-- to unequip state
			{name = "Unequipped", from = "unequip", to = "unequip"},
			{name = "Unequipped", from = "none", to = "unequip"},
			{name = "Unequipped", from = "equip", to = "unequip"},
			{name = "Unequipped", from = "idle", to = "unequip"},
			{name = "Unequipped", from = "aim", to = "unequip"},
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
			{name = "Idled", from = "aim", to = "idle"},
			-- -- from idle/aim/reload/run to run
			-- {name = "Ran", from = "idle", to = "run"},
			-- {name = "Ran", from = "inspect", to = "run"},
			-- {name = "Ran", from = "reload", to = "run"},
			-- {name = "Ran", from = "aim", to = "run"},
			-- {name = "Ran", from = "walk", to = "run"},
			-- -- from idle/aim/reload/run to walk
			-- {name = "Walk", from = "idle", to = "walk"},
			-- {name = "Walk", from = "inspect", to = "walk"},
			-- {name = "Walk", from = "reload", to = "walk"},
			-- {name = "Walk", from = "aim", to = "walk"},
			-- {name = "Walk", from = "run", to = "walk"},
			-- from inspect/idle to aim
			{name = "Aimed", from = "reload", to = "aim"},
			{name = "Aimed", from = "idle", to = "aim"},
			--{name = "Aimed", from = "run", to = "aim"},
			--{name = "Aimed", from = "walk", to = "aim"},
			-- from aim/idle to reload
			{name = "Reload", from = "aim", to = "reload" },
			{name = "Reload", from = "idle", to = "reload" },
			--{name = "Reload", from = "run", to = "reload"},
			--{name = "Reload", from = "walk", to = "reload"},
			-- from idle to inspect
			{name = "Inspect", from = "idle", to = "inspect" },
			--{name = "Inspect", from = "run", to = "inspect"},
			--{name = "Inspect", from = "walk", to = "inspect"},
		},

		callbacks = {
			on_Equipped = function(self, event, from, to, msg)
				print('equipped')
				Events.Equipped:Fire(self, event, from, to, msg)
				self.Idled()
			end,
			on_Unequipped = function(self, event, from, to, msg)
				print('unequipped')
				Events.Unequipped:Fire(self, event, from, to, msg)
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
			-- on_Walk = function(self, event, from, to, msg)
			-- 	print('walk')
			-- 	Events.Walk:Fire(self, event, from, to, msg)
			-- end,
			-- on_Ran = function(self, event, from, to, msg)
			-- 	print('run')
			-- 	Events.Ran:Fire(self, event, from, to, msg)
			-- end,
		},

	})

	return Events, FiniteStateInstance
end

return Module
