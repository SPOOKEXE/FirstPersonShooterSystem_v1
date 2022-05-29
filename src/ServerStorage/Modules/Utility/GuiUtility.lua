local TweenService = game:GetService('TweenService')

local defaultViewportSettings = {
	CameraCFrame = CFrame.new( Vector3.new(0, 0, -4), Vector3.new() ),
	ModelCFrame = CFrame.new()
}

-- // Module // --
local Module = {}

local baseButton = Instance.new('ImageButton')
baseButton.Name = 'Button'
baseButton.AnchorPoint = Vector2.new(0.5, 0.5)
baseButton.Position = UDim2.fromScale(0.5, 0.5)
baseButton.Size = UDim2.fromScale(1, 1)
baseButton.BackgroundTransparency = 1
baseButton.Selectable = true
baseButton.ImageTransparency = 1
baseButton.ZIndex = 50
function Module:CreateActionButton(properties)
	local button = baseButton:Clone()
	if typeof(properties) == 'table' then
		for k, v in pairs(properties) do
			button[k] = v
		end
	end
	return button
end

function Module:SetProperties( Parent, propertiesTable )
	for guiObjectName, labelProperties in pairs( propertiesTable ) do
		local targetGuiObject = Parent:FindFirstChild( guiObjectName )
		if targetGuiObject and targetGuiObject:IsA('Frame') then
			targetGuiObject = targetGuiObject:FindFirstChild('Label')
		end
		if not targetGuiObject then
			continue
		end
		for propertyName, propertyValue in pairs(labelProperties) do
			targetGuiObject[propertyName] = propertyValue
		end
	end
end

local baseTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
function Module:FadeGuiObjects( Parent, endTransparency, customTweenInfo )
	local Objs = Parent:GetDescendants()
	if Parent:IsA('GuiObject') then
		table.insert(Objs, Parent)
	end
	local tweenInfo = (customTweenInfo or baseTweenInfo)
	for _, GuiObject in ipairs( Objs ) do
		if GuiObject:IsA('Frame') then
			TweenService:Create(GuiObject, tweenInfo, { BackgroundTransparency = endTransparency }):Play()
		elseif GuiObject:IsA('TextLabel') then
			TweenService:Create(GuiObject, tweenInfo, { BackgroundTransparency = endTransparency, TextTransparency = endTransparency }):Play()
		elseif GuiObject:IsA('UIStroke') then
			TweenService:Create(GuiObject, tweenInfo, { Transparency = endTransparency}):Play()
		elseif GuiObject:IsA('ImageLabel') or GuiObject:IsA('ImageButton') then
			TweenService:Create(GuiObject, tweenInfo, { BackgroundTransparency = endTransparency, ImageTransparency = endTransparency}):Play()
		end
	end
end

return Module
