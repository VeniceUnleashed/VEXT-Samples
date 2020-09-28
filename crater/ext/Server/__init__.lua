local craterDepthMultiplier = 1000
local craterWidthMultiplier = 1000
local craterDepthFactor = 2

function onLevelLoaded(map, gameMode, round)
	-- Set terrain settings
	local terrainSettings = ResourceManager:GetSettings("TerrainSettings")
	if terrainSettings ~= nil then
		-- Default values
		terrainSettings = TerrainSettings(terrainSettings)
		terrainSettings.heightQueryCacheSize = 16
		terrainSettings.modifiersEnable = true
		terrainSettings.modifiersCapacity = 5000
		terrainSettings.intersectingModifiersMax = 16
		terrainSettings.modifierSlopeMax = 0.46
		terrainSettings.modifierDepthFactor = craterDepthFactor
	end
end

Events:Subscribe('Partition:Loaded', function(partition)
	if partition == nil then
		return
	end

	local instances = partition.instances
	for _, instance in pairs(instances) do
		if instance ~= nil then
			-- Remove depthtree preventing craters on roads and other areas.
			if instance:Is("DestructionDepthTreeAsset") or instance:Is("RasterQuadtreeNodeData") then
				partition:RemoveInstance(instance)
			end

			-- Set the crater depth
			if instance:Is("MaterialRelationTerrainDestructionData") then -- Levels/LevelName/LevelName/MaterialGrid_Win32/Grid
				local s_Instance = MaterialRelationTerrainDestructionData(instance)
				s_Instance:MakeWritable()
				s_Instance.width = s_Instance.width * craterWidthMultiplier
				s_Instance.depth = s_Instance.depth * craterDepthMultiplier
			end
		end
	end
end)


Events:Subscribe('Server:LevelLoaded', onLevelLoaded)
