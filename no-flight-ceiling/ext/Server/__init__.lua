Events:Subscribe('Partition:Loaded', function(partition)
	for _, instance in pairs(partition.instances) do
		if instance:Is("LevelData") then
			local instance = LevelData(instance)
			instance:MakeWritable()
			instance.maxVehicleHeight = 9999999
		end
	end
end)

