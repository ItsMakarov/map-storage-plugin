local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Source = script.Parent.Parent
local Components = script.Parent
local Packages = Source.Packages

local TerrainAPI = require(Source.TerrainAPI)
local LightingAPI = require(Source.LightingAPI)
local React = require(Packages.React)
local Searcher = require(Packages.Searcher)
local Functions = require(Source.Functions)
local ImageButton = require(Components.ImageButton)
local NameInputBox = require(Components.NameInputBox)
local Config = require(Source.Config)

local SaveMap = Functions.saveMap

local New = React.createElement

type Props = {
	instance: Folder,
}

return function(props: Props)
	local map = props.instance
	local isHovering, setIsHovering = React.useState(false)

	return New("Frame", {
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = Color3.fromRGB(0, 102, 204),
		BackgroundTransparency = isHovering and 0 or 1,
		[React.Event.MouseEnter] = function()
			setIsHovering(true)
		end,

		[React.Event.MouseLeave] = function()
			setIsHovering(false)
		end,
	}, {
		Padding = New("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 15),
			PaddingLeft = UDim.new(0, 15),
		}),

		List = New("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		}),

		Corner = New("UICorner"),

		Name = New(NameInputBox, {
			instance = map,
			config = {
				Size = UDim2.new(1, -64, 1, 0),
			},
		}),

		Remove = New(ImageButton, {
			ImageColor3 = Color3.new(1),
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Image = Config.ICON_REMOVE,
			Name = "Remove",

			[React.Event.Activated] = function()
				map:Remove()
				ChangeHistoryService:SetWaypoint(`Removed {map.Name} map`)
			end,
		}),

		Load = New(ImageButton, {
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = 1,
			Image = Config.ICON_LOAD,
			Name = "Load",

			[React.Event.Activated] = function()
				task.spawn(function()
					TerrainAPI.Load(map.SavedTerrain)
					LightingAPI.Load(map.Lighting)

					task.wait()

					local filter = Searcher.NewFilter():Not():IsA("Camera"):Not():IsA("Terrain")

					for _, instance: Instance in Searcher.FindAll(filter, workspace:GetChildren()) do
						instance:Remove()
					end

					task.wait()

					for _, instance in map.Instances:GetChildren() do
						instance:Clone().Parent = workspace
					end

					task.wait()

					ChangeHistoryService:SetWaypoint(`Loaded {map.Name} map`)
				end)
			end,
		}),

		Save = New(ImageButton, {
			Image = Config.ICON_SAVE,
			Name = "Save",

			[React.Event.Activated] = function()
				SaveMap(map)
			end,
		}),
	})
end
