

local IsServer = game:GetService('RunService'):IsServer()

local function SplitName(Parent, subNumber)
	local split = string.split(Parent:GetFullName(), ".")
	return split[subNumber or 1].."/"..split[#split]
end

local function HasInitMethod(tbl)
	return tbl.Init or (getmetatable(tbl) and getmetatable(tbl).Init)
end

local warn = function(...)
	-- warn(...)
end

local print = function(...)
	-- print(...)
end

warn([[
																	   
	.oooooo..o ooooooooo.     .oooooo.     .oooooo.   oooo    oooo     
	d8P'    `Y8 `888   `Y88.  d8P'  `Y8b   d8P'  `Y8b  `888   .8P'     
	Y88bo.       888   .d88' 888      888 888      888  888  d8'       
	 `"Y8888o.   888ooo88P'  888      888 888      888  88888[         
		 `"Y88b  888         888      888 888      888  888`88b.       
	oo     .d8P  888         `88b    d88' `88b    d88'  888  `88b.     
	8""88888P'  o888o         `Y8bood8P'   `Y8bood8P'  o888o  o888o    
																	   
]])

local Cache = { }

local function Preload( Parent, n )

	if not Cache[Parent] then

		local T = { }

		for i, ModuleScript in ipairs( Parent:GetChildren() ) do
			if ModuleScript:IsA('ModuleScript') then
				print( ModuleScript.Name, ' has been required' )
				T[ModuleScript.Name] = require(ModuleScript)
			end
		end

		for preLoadedName, preLoaded in pairs( T ) do
			if preLoaded.Initialised or (not HasInitMethod(preLoaded)) then
				continue
			end
			local accessibles = { ParentSystems = Cache[Parent.Parent] }
			for otherLoadedName, differentLoaded in pairs( T ) do
				if preLoadedName ~= otherLoadedName then
					accessibles[otherLoadedName] = differentLoaded
				end
			end
			preLoaded.Initialised = true
			preLoaded:Init(accessibles)
		end

		Parent.ChildAdded:Connect(function(ModuleScript)
			if ModuleScript:IsA("ModuleScript") then
				T[ModuleScript.Name] = require(ModuleScript)
				if HasInitMethod( T[ModuleScript.Name] ) then
					local accessibles = { ParentSystems = Cache[Parent.Parent] }
					for otherLoadedName, differentLoaded in pairs(T) do
						if ModuleScript.Name ~= otherLoadedName then
							accessibles[otherLoadedName] = differentLoaded
						end
					end
					T[ModuleScript.Name]:Init(accessibles)
				end
			end
		end)

		Cache[Parent] = T

	end

	return Cache[Parent]

end

task.delay(2, function()
	warn("Anything past this point (which errors / warns) is considered a bug/problem. Please report it to the developers via discord!")
end)

local Module = { }
Module.Setup = function( ... )
	return Preload( ... )
end
return Module
