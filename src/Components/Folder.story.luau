local Source = script.Parent.Parent
local Packages = Source.Packages

local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)
local Config = require(Source.Config)
local component = require(script.Parent.Folder)

return function(target: Instance)
	local folder = Instance.new("Folder")
	local root = ReactRoblox.createRoot(target)
	root:render(
		React.createElement(React.Fragment, nil, {
			Main = React.createElement(component, {
				instance = folder,
				maps = {}
			}),
			
			List = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = Config.LIST_PADDING,
			}),
		})
	)
	
	return function()
		root:unmount()
		folder:Destroy()
	end
end