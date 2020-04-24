-- This is a global table that will be populated on-demand by
-- the server via NetEvents on the client-side, or overriden
-- with the real data on the server-side.
HavokTransforms = {}

local objectVariations = {}
local pendingVariations = {}

local customRegistry = nil

function processStaticGroup(instance)
	local smgeData = StaticModelGroupEntityData(instance)
	local havokAsset = GroupHavokAsset(smgeData.physicsData.asset)
	local havokTransforms = HavokTransforms[havokAsset.name:lower()]

	-- If we don't have any transform data for this asset then skip.
	if havokTransforms == nil then
		print('No havok transforms found for "' .. havokAsset.name .. '".')
		return nil
	end

	print('Processing static group "' .. havokAsset.name .. '".')

	-- Create some WorldPartData. This will hold all of the entities
	-- we'll extract from the static group.
	local worldPartData = WorldPartData()
	worldPartData.enabled = true

	-- Also add it to our registry for proper replication support.
	customRegistry.blueprintRegistry:add(worldPartData)

	local transformIndex = 1

	for j, member in pairs(smgeData.memberDatas) do
		-- For every static model we'll create an object blueprint
		-- and set its object to the static model entity. We will
		-- also add it to our custom registry for replication support.
		local blueprint = ObjectBlueprint()

		customRegistry.blueprintRegistry:add(blueprint)

		-- If the entity data is lazy loaded then we'll need to come
		-- back and hotpatch it once it is loaded.
		if member.memberType.isLazyLoaded then
			member.memberType:RegisterLoadHandlerOnce(function(ctr)
				blueprint.object = GameObjectData(ctr)
			end)
		else
			blueprint.object = member.memberType
		end

		-- Set the relevant flag if this entity needs a network ID,
		-- which is when the range value is not uint32::max.
		if member.networkIdRange.first ~= 0xffffffff then
			blueprint.needNetworkId = true
		end

		for i = 1, member.instanceCount do
			-- We will create one new referenceobject with our previously
			-- created blueprint for all instances of this static model.
			-- We'll also give it a blueprint index that's above any other
			-- blueprint index currently in-use by the engine (this is
			-- currently hardcoded but could be improved). This will allow
			-- for proper network replication.
			local object = ReferenceObjectData()

			object.blueprint = blueprint
			object.indexInBlueprint = #worldPartData.objects + 30001
			object.isEventConnectionTarget = Realm.Realm_None
			object.isPropertyConnectionTarget = Realm.Realm_None

			customRegistry.referenceObjectRegistry:add(object)

			if #member.instanceTransforms > 0 then
				-- If this member contains its own transforms then we get the
				-- transform from there.
				object.blueprintTransform = member.instanceTransforms[i]
			else
				-- Otherwise, we'll need to calculate the transform using the
				-- extracted havok data.
				local scale = 1.0

				-- FIXME: Any scale other than 1.0 currently crashes the server.
				--[[if i <= #member.instanceScale then
					scale = member.instanceScale[i]
				end]]

				local transform = havokTransforms[transformIndex]

				-- At index 1 we have the rotation and at index 2 we have the position.
				local quatTransform = QuatTransform(
					Quat(transform[1][1], transform[1][2], transform[1][3], transform[1][4]),
					Vec4(transform[2][1], transform[2][2], transform[2][3], scale)
				)

				object.blueprintTransform = quatTransform:ToLinearTransform()
			end

			object.castSunShadowEnable = true

			if i <= #member.instanceCastSunShadow then
				object.castSunShadowEnable = member.instanceCastSunShadow[i]
			end

			if i <= #member.instanceObjectVariation and member.instanceObjectVariation[i] ~= 0 then
				local variationHash = member.instanceObjectVariation[i]
				local variation = objectVariations[variationHash]

				-- If we don't have this variation loaded yet we'll set this
				-- aside and we'll hotpatch it when the variation gets loaded.
				if variation == nil then
					if pendingVariations[variationHash] == nil then
						pendingVariations[variationHash] = {}
					end

					table.insert(pendingVariations[variationHash], object)
				else
					object.objectVariation = variation
				end
			end

			worldPartData.objects:add(object)

			transformIndex = transformIndex + 1
		end

		::continue::
	end

	-- Finally, we'll create a worldpart reference which we'll use
	-- to replace the original static model group.
	local worldPartReferenceObjectData = WorldPartReferenceObjectData()
	worldPartReferenceObjectData.blueprint = worldPartData
	worldPartReferenceObjectData.indexInBlueprint = smgeData.indexInBlueprint
	worldPartReferenceObjectData.isEventConnectionTarget = Realm.Realm_None
	worldPartReferenceObjectData.isPropertyConnectionTarget = Realm.Realm_None

	customRegistry.referenceObjectRegistry:add(worldPartReferenceObjectData)

	return worldPartReferenceObjectData
end

function patchWorldData(instance, groupsToReplace)
	local data = SubWorldData(instance)
	data:MakeWritable()

	if data.registryContainer ~= nil then
		data.registryContainer:MakeWritable()
	end

	for group, replacement in pairs(groupsToReplace) do
		local groupIndex = data.objects:index_of(group)

		if groupIndex ~= -1 then
			-- We found the static group. Replace it with our world part reference.
			data.objects[groupIndex] = replacement
		end
	end
end

Events:Subscribe('Partition:Loaded', function(partition)
	local groupsToReplace = {}
	local hasToReplace = false

	for _, instance in pairs(partition.instances) do
		-- We look for all static model groups to convert them into separate entities.
		if instance:Is('StaticModelGroupEntityData') then
			local replacement = processStaticGroup(instance)

			if replacement ~= nil then
				hasToReplace = true
				groupsToReplace[StaticModelGroupEntityData(instance)] = replacement
			end
		elseif instance:Is('ObjectVariation') then
			-- Store all variations in a map.
			local variation = ObjectVariation(instance)
			objectVariations[variation.nameHash] = variation

			if pendingVariations[variation.nameHash] ~= nil then
				for _, object in pairs(pendingVariations[variation.nameHash]) do
					object.objectVariation = variation
				end

				pendingVariations[variation.nameHash] = nil
			end
		end
	end

	-- If we found a group we'll go through the instances once more so we can
	-- patch the level / subworld data. These should always be within the same
	-- partition.
	if hasToReplace then
		for _, instance in pairs(partition.instances) do
			if instance:Is('SubWorldData') then
				patchWorldData(instance, groupsToReplace)
			end
		end
	end
end)

Events:Subscribe('Level:Destroy', function()
	objectVariations = {}
	pendingVariations = {}
	customRegistry = nil
end)

Events:Subscribe('Level:LoadResources', function()
	objectVariations = {}
	pendingVariations = {}
	customRegistry = RegistryContainer()
end)

Events:Subscribe('Level:RegisterEntityResources', function(levelData)
	ResourceManager:AddRegistry(customRegistry, ResourceCompartment.ResourceCompartment_Game)
end)
