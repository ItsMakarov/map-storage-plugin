if not plugin then
	return
end

local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
if not RunService:IsClient() then
	return
end

-- paths
local Source = script.Parent
local Packages = Source.Packages
-- modules
local Searcher = require(Packages.Searcher)
local Functions = require(Source.Functions)
local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)
local Promise = require(Packages.Promise)
local Config = require(Source.Config)
-- components
local Components = Source.Components
local MapComponent = require(Components.Map)
local FolderComponent = require(Components.Folder)
-- functions
local useEffect = React.useEffect
local e = React.createElement
-- config
local PLUGIN_NAME = "Map Storage"
local WIDGET_INFO = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, false, false, 500, 500, 400, 400)
-- plugin dock widget
local widget = plugin:CreateDockWidgetPluginGui(PLUGIN_NAME, WIDGET_INFO)
local toolbar = plugin:CreateToolbar(PLUGIN_NAME)
local toggle = toolbar:CreateButton("Maps", "Toggle the widget", "rbxassetid://17595683024")
toggle.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

local function getMaps()
	local filter = Searcher.NewFilter():IsA("Folder"):Attribute("Type", "Map")

	return Searcher.FindAll(filter, Functions.getStorage():GetChildren())
end

local function GameName()
	local gameName, setGameName = React.useState("...")

	useEffect(function()
		Promise.new(function(resolve)
			local info = MarketplaceService:GetProductInfo(game.PlaceId)
			resolve(info)
		end):andThen(function(info)
			setGameName(info.Name)
		end)
	end)

	return e("TextLabel", {
		BackgroundTransparency = 1,
		TextColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(1, 0, 0, 25),
		Text = `{gameName} Maps`,
	})
end

local function Button(props)
	local textColor, setTextColor = React.useState(Color3.new(1, 1, 1))
	local backgroundColor, setBackgroundColor = React.useState(Color3.fromRGB(40, 40, 40))
	return e("TextButton", {
		[React.Event.Activated] = props.onActivate,
		TextColor3 = textColor,
		BackgroundColor3 = backgroundColor,
		Size = UDim2.fromScale(1, 1),
		AutoButtonColor = false,
		TextScaled = true,
		BorderSizePixel = 0,
		FontFace = Font.fromEnum(Enum.Font.GothamBold),
		Text = props.Name,
		LayoutOrder = 1,

		[React.Event.MouseEnter] = function()
			setTextColor(Color3.fromRGB(40, 40, 40))
			setBackgroundColor(Color3.new(1, 1, 1))
		end,

		[React.Event.MouseLeave] = function()
			setTextColor(Color3.new(1, 1, 1))
			setBackgroundColor(Color3.fromRGB(40, 40, 40))
		end,
	}, {
		Padding = e("UIPadding", {
			PaddingLeft = UDim.new(0.1, 0),
			PaddingRight = UDim.new(0.1, 0),
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
		}),
		Corner = e("UICorner"),
	})
end

local function app()
	local maps, setMaps = React.useState(Functions.getStorage():GetChildren())
	local storage = Functions.getStorage()
	useEffect(function()
		local connection = storage.ChildAdded:Connect(function(child)
			if not child:GetAttribute("Type") then
				return
			end

			setMaps(function(oldMaps)
				local newMaps = table.clone(oldMaps)
				table.insert(newMaps, child)

				return newMaps
			end)
		end)

		local destroying = storage.ChildRemoved:Connect(function(child)
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

		return function()
			connection:Disconnect()
			destroying:Disconnect()
		end
	end)

	local list = {}
	for index, instance in maps do
		local _type: "Map" | "Folder" = instance:GetAttribute("Type")
		list[tostring(index)] = _type == "Map" and e(MapComponent, {
			instance = instance,
		}) or e(FolderComponent, {
			instance = instance,
			maps = instance:GetChildren(),
		})
	end

	return e(React.Fragment, nil, {
		GameName = e(GameName),
		List = e("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),

		Padding = e("UIPadding", {
			PaddingTop = Config.LIST_PADDING,
			PaddingBottom = Config.LIST_PADDING,
			PaddingRight = Config.LIST_PADDING,
			PaddingLeft = Config.LIST_PADDING,
		}),

		Scroll = e("ScrollingFrame", {
			Size = UDim2.fromScale(1, 0.9),
			BackgroundTransparency = 1,
			ScrollBarThickness = 8,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, {
			e(React.Fragment, nil, list),
			List = e("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = Config.LIST_PADDING,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}),

			Create = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 45),
				LayoutOrder = 1,
			}, {
				Padding = e("UIPadding", {
					PaddingLeft = UDim.new(0, 5),
					PaddingRight = UDim.new(0, 5),
				}),

				List = e("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Title = e("TextLabel", {
					Text = "Create",
					BackgroundTransparency = 1,
					TextColor3 = Color3.new(1, 1, 1),
					Size = UDim2.new(1, 0, 0, 35),
					TextScaled = true,
					FontFace = Font.fromEnum(Enum.Font.GothamBold),
				}),

				NewMap = e(Button, {
					Name = "Map",
					onActivate = function()
						local maps = getMaps()
						local map = Functions.newMap()
						map.Name = `Map #{#maps + 1}`
						map.Parent = Functions.getStorage()
					end,
				}),

				NewFolder = e(Button, {
					Name = "Folder",
					onActivate = function()
						local filter = Searcher.NewFilter():IsA("Folder"):Attribute("Type", "Folder")
						local folders = Searcher.FindAll(filter, storage:GetChildren())
						local folder = Instance.new("Folder")
						folder:SetAttribute("Type", "Folder")
						folder.Name = `Folder #{#folders + 1}`
						folder.Parent = storage
					end,
				}),
			}),
		}),
	})
end

local root = ReactRoblox.createRoot(widget)
plugin.Unloading:Connect(function()
	root:unmount()
end)

root:render(e(app))
