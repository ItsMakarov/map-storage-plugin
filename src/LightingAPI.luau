local Lighting = game:GetService("Lighting")

local LIGHTING_PROPS = {
	"Ambient",
	"Brightness",
	"ColorShift_Bottom",
	"ColorShift_Top",
	"EnvironmentDiffuseScale",
	"EnvironmentSpecularScale",
	"GlobalShadows",
	"OutdoorAmbient",
	"ShadowSoftness",
	"ClockTime",
	"GeographicLatitude",
	"TimeOfDay",
	"ExposureCompensation"
}

local module = {}

function module.Save()
	local folder = Instance.new("Folder")
	folder.Name = "Lighting"
	for _, propName in LIGHTING_PROPS do
		folder:SetAttribute(propName, Lighting[propName])
	end
	
	for _, instance in Lighting:GetChildren() do
		instance:Clone().Parent = folder
	end
	
	return folder
end

function module.Load(info)
	for index, value in info:GetAttributes() do
		Lighting[index] = value
	end
	
	for _, instance in Lighting:GetChildren() do
		instance:Remove()
	end
	
	for _, instance in info:GetChildren() do
		instance:Clone().Parent = Lighting
	end
end

return module
