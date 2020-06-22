Events:Subscribe('Partition:Loaded', function(partition)
	local soldierBp = nil
	local propBp = nil

	for _, instance in pairs(partition.instances) do
		if instance.instanceGuid == Guid('261E43BF-259B-41D2-BF3B-9AE4DDA96AD2') then
			soldierBp = SoldierBlueprint(instance)
		end

		if instance.instanceGuid == Guid('261E43BF-259B-41D2-BF3B-9AE4DDA96AD3') then
			propBp = instance
		end
	end

	if soldierBp == nil then
		return
	end

	if propBp ~= nil then
		return
	end

	print('Creating soldier bp')

	propBp = SoldierBlueprint(soldierBp:Clone(Guid('261E43BF-259B-41D2-BF3B-9AE4DDA96AD3')))
	propBp.name = 'Characters/Soldiers/PropSoldier'

	partition:AddInstance(propBp)
end)

Events:Subscribe('Level:RegisterEntityResources', function()
	print('Registering blueprint with registry.')

	local registry = RegistryContainer()
	registry.blueprintRegistry:add(propBp)

	ResourceManager:AddRegistry(registry, ResourceCompartment.ResourceCompartment_Game)
end)
