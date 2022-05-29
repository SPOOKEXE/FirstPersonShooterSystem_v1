
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require( ReplicatedStorage:WaitForChild('Modules') )
local ReplicatedCore = require( ReplicatedStorage:WaitForChild('Core') )

local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require( ServerStorage:WaitForChild('Modules') )
local ServerCore = require( ServerStorage:WaitForChild('Core') )

print("Finished Loading Modules - Server")
