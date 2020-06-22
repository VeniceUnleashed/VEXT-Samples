Events:Subscribe("Partition:Loaded", function(partition)
    if partition == nil then
        return
    end

    for _, instance in pairs(partition.instances) do
		if instance.typeInfo.name == "LevelData" then
			print('Found level data')
            instance:MakeWritable()

            print("made writable")
            local levelDataInstance = LevelData(instance)
            print("got leveldata")
            levelDataInstance.maxVehicleHeight = 9999.9
            print("modified maxVehicleHeight")
        end

        ::continue::
    end
end)
