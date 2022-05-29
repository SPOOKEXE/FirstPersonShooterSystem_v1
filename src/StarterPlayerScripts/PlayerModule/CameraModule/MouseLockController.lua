--[[
	MouseLockController - Replacement for ShiftLockController, manages use of mouse-locked mode
	2018 Camera Update - AllYourBlox
--]]

--[[ Constants ]]--
local DEFAULT_MOUSE_LOCK_CURSOR = "rbxassetid://1386173173"
local CAMERA_OFFSET = Vector3.new(4, 0, 0)

local CONTEXT_ACTION_NAME = "MouseLockSwitchAction"
local MOUSELOCK_ACTION_PRIORITY = Enum.ContextActionPriority.Default.Value

local Util = require(script.Parent:WaitForChild("CameraUtils"))

--[[ Services ]]--
local PlayersService = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Settings = UserSettings()	-- ignore warning
local GameSettings = Settings.GameSettings
local Mouse = PlayersService.LocalPlayer:GetMouse()

--[[ Variables ]]

--[[ The Module ]]--
local MouseLockController = {}
MouseLockController.__index = MouseLockController

function MouseLockController.new()
	local self = setmetatable({}, MouseLockController)

	local allowLocking = Instance.new("BoolValue")
	allowLocking.Name = "AllowShiftLock"
	allowLocking.Value = true
	allowLocking.Parent = PlayersService.LocalPlayer
	self.allowLocking = allowLocking

	local lockedBoolean = Instance.new('BoolValue')
	lockedBoolean.Name = 'ShiftLocked'
	lockedBoolean.Changed:Connect(function()
		self:OnMouseLockToggled(lockedBoolean.Value)
	end)
	lockedBoolean.Parent = PlayersService.LocalPlayer
	self.isMouseLocked = lockedBoolean

	self.savedMouseCursor = nil
	self.boundKeys = {Enum.KeyCode.LeftControl, Enum.KeyCode.RightControl} -- defaults

	self.mouseLockToggledEvent = Instance.new("BindableEvent")

	local function HandleInput(Name, State, InputObject)
		if Name == 'ToggleShift' and State == Enum.UserInputState.Begin and allowLocking.Value then
			lockedBoolean.Value = not lockedBoolean.Value
		end
	end
	ContextActionService:BindAction('ToggleShift', HandleInput, false, unpack(self.boundKeys))
	
	-- Watch for changes to user's ControlMode and ComputerMovementMode settings and update the feature availability accordingly
	GameSettings.Changed:Connect(function(property)
		if property == "ControlMode" or property == "ComputerMovementMode" then
			self:UpdateMouseLockAvailability()
		end
	end)

	-- Watch for changes to DevEnableMouseLock and update the feature availability accordingly
	PlayersService.LocalPlayer:GetPropertyChangedSignal("DevEnableMouseLock"):Connect(function()
		self:UpdateMouseLockAvailability()
	end)

	-- Watch for changes to DevEnableMouseLock and update the feature availability accordingly
	PlayersService.LocalPlayer:GetPropertyChangedSignal("DevComputerMovementMode"):Connect(function()
		self:UpdateMouseLockAvailability()
	end)

	self:UpdateMouseLockAvailability()

	return self
end

function MouseLockController:GetIsMouseLocked()
	return self.isMouseLocked.Value
end

function MouseLockController:GetBindableToggleEvent()
	return self.mouseLockToggledEvent.Event
end

function MouseLockController:GetMouseLockOffset()
	return CAMERA_OFFSET
end

function MouseLockController:UpdateMouseLockAvailability(Forced)
	local Available = (Forced or false)
	if Forced == nil then
		local devAllowsMouseLock = PlayersService.LocalPlayer.DevEnableMouseLock
		local devMovementModeIsScriptable = PlayersService.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.Scriptable
		local userHasMouseLockModeEnabled = GameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch
		local userHasClickToMoveEnabled =  GameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove
		Available = (devAllowsMouseLock and userHasMouseLockModeEnabled and not userHasClickToMoveEnabled and not devMovementModeIsScriptable)
	end
	self:EnableMouseLock(Available)
end

--[[ Local Functions ]]--
function MouseLockController:OnMouseLockToggled(Force)
	self.isMouseLocked.Value = (Force == nil and (not self.isMouseLocked.Value) or Force)
	if self.isMouseLocked.Value then
		local cursorImageValueObj = script:FindFirstChild("CursorImage")
		if cursorImageValueObj and cursorImageValueObj:IsA("StringValue") and cursorImageValueObj.Value then
			self.savedMouseCursor = Mouse.Icon
			Mouse.Icon = cursorImageValueObj.Value
		else
			if cursorImageValueObj then
				cursorImageValueObj:Destroy()
			end
			cursorImageValueObj = Instance.new("StringValue")
			cursorImageValueObj.Name = "CursorImage"
			cursorImageValueObj.Value = DEFAULT_MOUSE_LOCK_CURSOR
			cursorImageValueObj.Parent = script
			self.savedMouseCursor = Mouse.Icon
			Mouse.Icon = DEFAULT_MOUSE_LOCK_CURSOR
		end
	else
		if self.savedMouseCursor then
			Mouse.Icon = self.savedMouseCursor
			self.savedMouseCursor = nil
		end
	end
	self.mouseLockToggledEvent:Fire()
end

function MouseLockController:IsMouseLocked()
	return self.enabled and self.isMouseLocked.Value
end

function MouseLockController:EnableMouseLock(enable)
	self.allowLocking.Value = enable
	if not self.allowLocking.Value then
		self.isMouseLocked.Value = false
	end
end

return MouseLockController
