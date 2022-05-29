
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require( ReplicatedStorage:WaitForChild('Modules') )
local ReplicatedCore = require( ReplicatedStorage:WaitForChild('Core') )

local LocalPlayer = game:GetService('Players').LocalPlayer
local PlayerScripts = LocalPlayer:WaitForChild('PlayerScripts')
local ServerModules = require( PlayerScripts:WaitForChild('Modules') )
local ServerCore = require( PlayerScripts:WaitForChild('Core') )

print("Finished Loading Modules - Client")
