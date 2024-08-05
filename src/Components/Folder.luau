local Source = script.Parent.Parent
local Packages = Source.Packages
local Components = script.Parent

local React = require(Packages.React)
local NameInputBox = require(Components.NameInputBox)
local ImageButton = require(Components.ImageButton)
local MapComponent = require(Components.Map)
local Functions = require(Source.Functions)
local Config = require(Source.Config)

local PADDING = UDim.new(0, 10)

local e = React.createElement

type Props = {
	instance: Folder,
	maps: { Folder },
}

local function ArrowComponent(props)
	local isExpanded = props.isExpanded
	local setExpanded = props.setExpanded
	return e("ImageButton", {
		Image = "rbxassetid://18818459758",
		Rotation = isExpanded and 90 or 0,
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		
		[React.Event.Activated] = function()
			setExpanded(not isExpanded)
		end,
	})
end

return function(props: Props)
	local isExpanded, setExpanded = React.useState(false)
	local maps, setMaps = React.useState(props.maps)
	local mapsUI = {}
	for index, map in maps do
		mapsUI[tostring(index)] = e(MapComponent, {
			instance = map
		})
	end
	
	React.useEffect(function()
		local removedConnection = props.instance.ChildRemoved:Connect(function(child)
			if not child:GetAttribute("Type") then
				return
			end
			
			setMaps(function(oldMaps)
				local newMaps = table.clone(oldMaps)
				local index = table.find(newMaps, child)
				table.remove(newMaps, index)
				
				return newMaps
			end)
		end)
		
		local addedConnection = props.instance.ChildAdded:Connect(function(child)
			if not child:GetChildren("Type") then
				return
			end
			
			setMaps(function(oldMaps)
				local newMaps = table.clone(oldMaps)
				table.insert(newMaps, child)
				
				return newMaps
			end)
		end)
		
		return function()
			removedConnection:Disconnect()
			addedConnection:Disconnect()
		end
	end)
	
	return e(React.Fragment, nil, {
		Main = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(40, 40, 40),
			Size = UDim2.new(1, 0, 0, 35),
		}, {
			Corner = e("UICorner"),
			Arrow = e(ArrowComponent, {
				isExpanded = isExpanded,
				setExpanded = setExpanded,
			}),

			Padding = e("UIPadding", {
				PaddingTop = PADDING,
				PaddingBottom = PADDING,
				PaddingRight = PADDING,
				PaddingLeft = PADDING,
			}),

			NameInputBox = e(NameInputBox, {
				instance = props.instance,
				config = {
					Size = UDim2.new(1, -68, 1, 0),
					Position = UDim2.fromOffset(25, 0),
				},
			}),

			Actions = e("Frame", {
				Position = UDim2.fromScale(1, .5),
				AnchorPoint = Vector2.new(1, .5),
				BackgroundTransparency = 1,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.fromScale(1, 1),
			}, {
				List = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					Padding = UDim.new(0, 8),
				}),

				Remove = e(ImageButton, {
					Name = "Remove",
					Image = Config.ICON_REMOVE,
					ImageColor3 = Color3.new(1),

					[React.Event.Activated] = function()
						props.instance:Remove()
					end,
				}),

				Add = e(ImageButton, {
					Name = "Add",
					Image = Config.ICON_ADD,

					[React.Event.Activated] = function()
						local map = Functions.newMap()
						map.Name = `Map #{ #maps + 1 }`
						map.Parent = props.instance
					end,
				}),
			}),		
		}),
		
		Container = e("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = isExpanded and #maps > 0,
			Size = UDim2.fromScale(1, 0),
			BackgroundTransparency = 1,
		}, {
			Maps = e(React.Fragment, nil, mapsUI),
			Padding = e("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
			}),

			List = e("UIListLayout", {
				Padding = UDim.new(0, 5),
			}),
		}),
	})
end