local Packages = script.Parent.Parent.Packages

local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)
local Component = require(script.Parent.Map)
local Functions = require(script.Parent.Parent.Functions)

return function(target: Instance)
	local mapInfo = Functions.newMap()
	local root = ReactRoblox.createRoot(target)
	root:render(
		React.createElement(Component, {
			instance = mapInfo,
			Parent = target,
		})
	)
	
	return function()
		root:unmount()
		mapInfo:Destroy()
	end
end