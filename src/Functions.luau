local ServerStorage = game:GetService("ServerStorage")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Source = script.Parent
local Packages = Source.Packages

local LightingAPI = require(Source.LightingAPI)
local TerrainAPI = require(Source.TerrainAPI)
local Searcher = require(Packages.Searcher)

local STORAGE_NAME = "Maps"

local module = {}

function module.getStorage(): Folder
	local filter = Searcher.NewFilter()
	:IsA("Folder")
	:Named(STORAGE_NAME)

	local instance = Searcher.FindOne(filter, ServerStorage:GetChildren())
	if not instance then
		instance = Instance.new("Folder")
		instance.Name = STORAGE_NAME
		instance.Parent = ServerStorage
	end

	return instance
end

function module.newMap()
	local folder = Instance.new("Folder")
	Instance.new("Folder", folder).Name = "Instances"
	Instance.new("Folder", folder).Name = "Lighting"
	folder:SetAttribute("Type", "Map")
	task.spawn(module.saveMap, folder)
	
	return folder
end

function module.mergeTables(src, dest)
	for key, value in src do
		dest[key] = value
	end
	return dest
end

function module.saveMap(folder)
	local filter = Searcher.NewFilter()
	:Not():IsA("Camera")
	:Not():IsA("Terrain")
	
	for _, instance in folder.Instances:GetChildren() do
		instance:Remove()
	end
	
	for _, instance in Searcher.FindAll(filter, workspace:GetChildren()) do
		instance:Clone().Parent = folder.Instances
	end
	
	local oldTerrain = folder:FindFirstChild("SavedTerrain")
	if oldTerrain then
		oldTerrain:Destroy()
	end
	TerrainAPI.Save().Parent = folder
	
	local oldLighting = folder:FindFirstChild("Lighting")
	if oldLighting then
		oldLighting:Destroy()
	end
	LightingAPI.Save().Parent = folder
	
	ChangeHistoryService:SetWaypoint(`Map storage saved {folder.Name}`)
end

return module
