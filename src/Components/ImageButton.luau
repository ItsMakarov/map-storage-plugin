local Source = script.Parent.Parent

local React = require(Source.Packages.React)
local MergeTables = require(Source.Functions).mergeTables

local New = React.createElement

local function ToolTip(props)
	local position, setPosition = React.useState(UDim2.new(0.5, 0, 1, 5))
	local ref = React.useRef(nil)
	React.useEffect(function()
		local toolTip: TextLabel = ref.current
		local pluginWidget = toolTip:FindFirstAncestorOfClass("DockWidgetPluginGui")
		local widgetSize = pluginWidget.AbsoluteSize
		local rightSidePosition = toolTip.AbsolutePosition.X + toolTip.AbsoluteSize.X / 2

		if rightSidePosition > widgetSize.X then
			setPosition(UDim2.new(0.5, -(rightSidePosition - widgetSize.X), 1, 5))
		end
	end)

	return New("TextLabel", {
		ref = ref,
		Text = props.Name,
		TextColor3 = Color3.new(1, 1, 1),
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		Size = UDim2.fromOffset(0, 25),
		AutomaticSize = Enum.AutomaticSize.X,
		Position = position,
		AnchorPoint = Vector2.new(0.5, 0),
		ZIndex = 2,
		BorderSizePixel = 0,
		Visible = props.isHovered,
		FontFace = Font.fromEnum(Enum.Font.GothamBold),
		FontSize = Enum.FontSize.Size14,
	}, {
		Corner = New("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Padding = New("UIPadding", {
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			PaddingTop = UDim.new(0, 5),
			PaddingBottom = UDim.new(0, 5),
		}),
		Stroke = New("UIStroke", {
			Color = Color3.fromRGB(60, 60, 60),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 2,
		}),
	})
end

return function(props)
	local isHovered, setHovered = React.useState(false)

	return New(
		"ImageButton",
		MergeTables(props, {
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = 1,

			[React.Event.MouseEnter] = function()
				setHovered(true)
			end,

			[React.Event.MouseLeave] = function()
				setHovered(false)
			end,
		}),
		props.Name and New(ToolTip, {
			isHovered = isHovered,
			Name = props.Name,
		})
	)
end
