Events:Subscribe('Level:LoadResources', function()
	ResourceManager:MountSuperBundle('SpChunks')
	ResourceManager:MountSuperBundle('Xp1Chunks')
	ResourceManager:MountSuperBundle('Levels/XP1_002/XP1_002')
	ResourceManager:MountSuperBundle('Levels/SP_Bank/SP_Bank')
end)

-- Inject the XP4_Quake bundles when our level is loading unless the
-- level itself is in XP4. We will get custom character models from there.
Hooks:Install('ResourceManager:LoadBundles', 100, function(hook, bundles, compartment)
	if #bundles == 1 and bundles[1] == SharedUtils:GetLevelName() and SharedUtils:GetLevelName():find('Levels/XP1_') == nil then
		print('Injecting XP4 bundles.')

		bundles = {
			'Levels/SP_Bank/SP_Bank',
			'Levels/SP_Bank/Passage_CUTSCENE',
			'Levels/XP1_002/XP1_002',
			'Levels/XP1_002/CQ_S',
			bundles[1],
		}

		hook:Pass(bundles, compartment)
	end
end)

-- Add the XP4_Quake SQDM registry when the level loads so we can use
-- assets from it (namely the character models).
Events:Subscribe('Level:RegisterEntityResources', function(levelData)
	local xp1cqlRegistry = RegistryContainer(ResourceManager:SearchForInstanceByGuid(Guid('4CA67086-4270-BDEC-C570-A5A709959189')))
	ResourceManager:AddRegistry(xp1cqlRegistry, ResourceCompartment.ResourceCompartment_Game)

	-- Also add the flare.
	local customRegistry = RegistryContainer()
	customRegistry.blueprintRegistry:add(ResourceManager:SearchForInstanceByGuid(Guid('80474BF8-52BD-45FF-B2C0-5742E928F0FE')))
	ResourceManager:AddRegistry(customRegistry, ResourceCompartment.ResourceCompartment_Game)
end)

Events:Subscribe('Partition:Loaded', function(partition)
	for _, instance in pairs(partition.instances) do
		if instance.instanceGuid == Guid('705967EE-66D3-4440-88B9-FEEF77F53E77') then
			-- Disable spawn protection.
			local healthData = VeniceSoldierHealthModuleData(instance)
			healthData:MakeWritable()

			healthData.immortalTimeAfterSpawn = 0.0
		elseif instance:Is('LevelData') then
			local levelData = LevelData(instance)
			levelData:MakeWritable()
			levelData.maxVehicleHeight = 99999
		end
	end
end)
