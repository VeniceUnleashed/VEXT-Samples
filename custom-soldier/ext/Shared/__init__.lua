-- This is a custom GUID we'll assign to our custom soldier blueprint.
local customSoldierGuid = Guid('261E43BF-259B-41D2-BF3B-0000DEADBEEF')

Events:Subscribe('Partition:Loaded', function(partition)
	local originalSoldierBp = nil

	for _, instance in pairs(partition.instances) do
		-- Look for the original multiplayer soldier blueprint.
		if instance:Is('SoldierBlueprint') then
			local bp = SoldierBlueprint(instance)

			if bp.name == 'Characters/Soldiers/MpSoldier' then
				originalSoldierBp = bp
			end
		end

		-- If we already created a custom soldier then no need to do anything.
		if instance.instanceGuid == customSoldierGuid then
			return
		end
	end

	if originalSoldierBp == nil then
		return
	end

	-- Clone the original soldier blueprint and assign it our custom GUID and name.
	local customSoldierBp = SoldierBlueprint(originalSoldierBp:Clone(customSoldierGuid))
	customSoldierBp.name = 'Characters/Soldiers/CustomSoldier'

	-- We also need to clone the original SoldierEntityData and replace all references to it.
	local originalSoldierData = customSoldierBp.object
	local customSoldierData = SoldierEntityData(originalSoldierData:Clone())

	customSoldierBp.object = customSoldierData

	for _, connection in pairs(customSoldierBp.propertyConnections) do
		if connection.source == originalSoldierData then
			connection.source = customSoldierData
		end

		if connection.target == originalSoldierData then
			connection.target = customSoldierData
		end
	end

	for _, connection in pairs(customSoldierBp.linkConnections) do
		if connection.source == originalSoldierData then
			connection.source = customSoldierData
		end

		if connection.target == originalSoldierData then
			connection.target = customSoldierData
		end
	end

	for _, connection in pairs(customSoldierBp.eventConnections) do
		if connection.source == originalSoldierData then
			connection.source = customSoldierData
		end

		if connection.target == originalSoldierData then
			connection.target = customSoldierData
		end
	end

	-- Change the soldier's max health.
	customSoldierData.maxHealth = 69420

	-- Add our new soldier blueprint to the partition.
	-- This will make it so we can later look it up by its GUID.
	partition:AddInstance(customSoldierBp)
end)

Events:Subscribe('Level:RegisterEntityResources', function()
	-- In order for our custom soldier to be usable we need to register it with the engine.
	-- This means that during this event we need to create a new registry container and add
	-- all relevant datacontainers to the respective arrays.
	local registry = RegistryContainer()

	-- Locate the custom soldier BP, get its data, and add to the registry container.
	-- You can fetch the BP in the same way when you want to spawn a player with it.
	local customSoldierBp = SoldierBlueprint(ResourceManager:SearchForInstanceByGUID(customSoldierGuid))
	local soldierData = customSoldierBp.object

	registry.blueprintRegistry:add(customSoldierBp)
	registry.entityRegistry:add(soldierData)

	-- And then add the registry to the game compartment.
	ResourceManager:AddRegistry(registry, ResourceCompartment.ResourceCompartment_Game)
end)
