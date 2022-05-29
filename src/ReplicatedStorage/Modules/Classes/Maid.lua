-- Rewritten by SPOOK_EXE
-- Other one was annoying to look at :-)

type Func = () -> any?
type MaidTask = (RBXScriptConnection | { Destroy : Func } | Func | Instance) -> nil
type Maid = { Cleanup : (nil) -> nil, Give : (MaidTask) -> nil }

local validTypeTask : Func = function(self, _task)
	if _task == self then
		return false
	end
	return
		typeof(_task) == 'RBXScriptConnection' or
		typeof(_task) == 'function' or
		typeof(_task) == "Instance" or
		_task.Destroy
end

local Maid = {ClassName = 'Maid'} :: { New : Func }
Maid.__index = Maid

function Maid.New() : Maid
	return setmetatable( { _tasks = {} } , Maid )
end

function Maid:Give(_task)
	if validTypeTask(self, _task) then
		table.insert(self._tasks, _task)
	end
end

function Maid:Cleanup()
	for _, _task in ipairs(self._tasks) do
		if typeof(_task) == 'RBXScriptConnection' then
			_task:Disconnect()
		elseif typeof(_task) == 'function' then
			task.spawn(_task)
		elseif typeof(_task) == "Instance" then
			_task:Destroy()
		elseif _task.Destroy then
			task.spawn(pcall, _task.Destroy)
		end
	end
	--setmetatable(self, nil)
end
Maid.Destroy = Maid.Cleanup

function Maid:__tostring()
	local taskStrings = { }
	for _, _task in ipairs(self._tasks) do
		table.insert(taskStrings, tostring(_task))
	end
	return string.format( [[
		Maid Class:
			ClassName : Maid,
			Total_Tasks: %s,
			_tasks : { %s },
	]], tostring(#self._tasks), table.concat(taskStrings, ", "))
end

function Maid:__newindex(t, index, value)
	if index == '_tasks' or t == self._tasks then
		error('Cannot edit _tasks table. Use Maid:Give(task)')
	end
	if validTypeTask(self, value) then
		table.insert(self._tasks, value)
	end
end

return Maid