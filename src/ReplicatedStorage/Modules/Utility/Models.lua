local searchObjects = {'Humanoid', 'HumanoidRootPart', 'Head'}

local Module = {}

function Module:WaitForChildOfProperties(Parent, Properties)

	local Ignore = { }
	local function MatchesProperties(Inst)
		for propName, propValue in pairs(Properties) do
			local success, _ = pcall(function()
				if Inst[propName] ~= propValue then
					error("invalid")
				end
			end)
			if not success then
				return false
			end
		end
		return true
	end

	for _, Obj in ipairs( Parent:GetChildren() ) do
		if MatchesProperties(Obj) then
			return Obj
		end
		table.insert(Ignore, Obj)
	end

	local Object = nil
	local Yielder = Instance.new("BindableEvent")
	local addedConnection; addedConnection = Parent.ChildAdded:Connect(function(Obj)
		if not table.find(Ignore, Obj) then
			if MatchesProperties(Obj) then
				addedConnection:Disconnect()
				addedConnection = nil
				Object = Obj
				Yielder:Fire()
			end
			table.insert(Ignore, Obj)
		end
	end)

	if not Object then
		Yielder.Event:Wait()
	end

	return Object
end

function Module:WaitForChildOfClass(Parent, class)
	local Result = nil
	task.delay(5, function()
		if not Result then
			warn("Infinite WaitForChildOfClass : ", class, " inside ", Parent:GetFullName())
		end
	end)
	Result = Module:WaitForChildOfProperties(Parent, {ClassName = class})
	return Result
end

function Module:WaitForChildOfNameAndClass(Parent, name, class)
	local Result = nil
	task.delay(5, function()
		if not Result then
			warn("Infinite WaitForChildOfNameAndClass : ", name, class, " inside ", Parent:GetFullName())
		end
	end)
	Result = Module:WaitForChildOfProperties(Parent, {Name = name, ClassName = class})
	return Result
end

function Module:FindFirstDescendant(Parent, descendantName)
	for _ , item in ipairs(Parent:GetChildren()) do
		if item.Name == descendantName then
			return item
		end
	end
	for _, child in ipairs(Parent:GetChildren()) do
		local target = Module:FindFirstDescendant(child, descendantName)
		if target then
			return target
		end
	end
	return nil
end

function Module:FindFirstDescendantOfClass(Parent, className)
	for _, Part in ipairs(Parent:GetDescendants()) do
		if Part:IsA(className) then
			return Part
		end
	end
	return nil
end

function Module:FindDescendantOfNameAndClass(Parent, descendantName, descendantClass)
	for _, item in ipairs(Parent:GetDescendants()) do
		if item.Name == descendantName and item.ClassName == descendantClass then
			return item
		end
	end
	return nil
end

function Module:GetHumanoidModelData(Character)
	local Objects = {}
	for _, str in ipairs(searchObjects) do
		local obj = Character:FindFirstChild(str)
		if obj then
			Objects[obj.Name] = obj
		end
	end
	return Objects
end

-- Get Character CFrame
function Module:GetCharacterCFrame(Character)
	local HumanoidRootPart = Character and Character:FindFirstChild('HumanoidRootPart')
	return HumanoidRootPart and HumanoidRootPart.CFrame
end

function Module:GetPlayerCFrame(LocalPlayer : Player?)
	return LocalPlayer and Module:GetCharacterCFrame(LocalPlayer.Character)
end

-- Get Character Position
function Module:GetCharacterPosition(Character) : Vector3?
	local CF = Module:GetCharacterCFrame(Character)
	return CF and CF.Position
end

function Module:GetPlayerPosition(LocalPlayer : Player?) : Vector3?
	local CF = Module:GetPlayerCFrame(LocalPlayer)
	return CF and CF.Position
end

function Module:ScaleModel(Model, scale)
	local primary = Model and Model.PrimaryPart
	if not primary then
		warn("No Primary Part Set.")
		return
	end
	local primaryCF = primary.CFrame
	for _, v in pairs(Model:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Size *= scale
			if (v == primary) then
				continue
			end
			v.CFrame = (primaryCF + (primaryCF:Inverse() * v.Position * scale))
		end
	end
end

function Module:CallbackDescendantBaseParts(Model, Callback)
	for _, Part in ipairs(Model:GetDescendants()) do
		if Part:IsA('BasePart') then
			task.defer(Callback, Part)
		end
	end
end

function Module:SetModelNonCollidable(Model)
	Module:CallbackDescendantBaseParts(Model, function(BasePart)
		BasePart.CanCollide = false
	end)
end

function Module:WeldConstraint(WeldMe, ToThis)
	local constraint = Instance.new('WeldConstraint')
	constraint.Part0 = WeldMe
	constraint.Part1 = ToThis
	constraint.Parent = ToThis
	return constraint
end

local TweenService = game:GetService('TweenService')
local tweenCache = {}
function Module:TweenModel(Model, endCFrame, tweenInfo, Yield)

	local cfValue = Instance.new('CFrameValue')
	cfValue.Value = Model:GetPrimaryPartCFrame()
	cfValue.Changed:Connect(function()
		Model:SetPrimaryPartCFrame(cfValue.Value)
	end)

	local Tween = tweenCache[Model]
	if Tween then
		Tween:Cancel()
		tweenCache[Model] = nil
	end

	Tween = TweenService:Create(cfValue, tweenInfo or TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Value = endCFrame})

	Tween.Completed:Connect(function()
		if tweenCache[Model] == Tween then
			tweenCache[Model] = nil
		end
		cfValue:Destroy()
	end)

	Tween:Play()

	if Yield then
		Tween.Completed:Wait()
	end

end

return Module
