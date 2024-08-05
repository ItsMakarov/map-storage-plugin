local Source = script.Parent.Parent
local Packages = script.Parent.Parent.Packages

local React = require(Packages.React)
local Functions = require(Source.Functions)

local e = React.createElement

type Props = {
	instance: Instance,
	config: { [string]: any },
}

return function(props: Props)
	local instance = props.instance
	local borderEnabled, setBorderEnabled = React.useState(false)

	return e("TextBox", Functions.mergeTables(props.config, {
		Size = UDim2.new(1, -64, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.new(1, 1, 1),
		ClearTextOnFocus = false,
		Text = instance.Name,
		LayoutOrder = -1,
		BackgroundTransparency = 1,
		ClipsDescendants = true,

		[React.Event.Focused] = function()
			setBorderEnabled(true)
		end,

		[React.Event.FocusLost] = function(rbx)
			instance.Name = rbx.Text
			setBorderEnabled(false)
		end,
	}), {
		Padding = e("UIPadding", {
			PaddingLeft = UDim.new(0, 5)
		}),

		Corner = e("UICorner"),

		Border = e("UIStroke", {
			Thickness = 1.5,
			Color = Color3.new(1, 1, 1),
			Enabled = borderEnabled,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		})
	})
end