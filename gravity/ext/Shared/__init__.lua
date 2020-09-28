Events:Subscribe('Partition:Loaded', function(partition)
	for _, instance in pairs(partition.instances) do

		-- The next line checks the type of each instance till it finds the one we wish to modify.
		if instance:Is('SoldierBodyComponentData') then

			-- SoldierBodyComponentData contains data that is linked to the ingame gravity so we create an object from the instance, make it writable and then change it's default values.
			SoldierBodyComponentData(instance):MakeWritable()
			SoldierBodyComponentData(instance).overrideGravity = true
			-- This value must be negative otherwise you will float away like a balloon.
			-- The default value is -9.81
			-- It can be found in /Characters/Soldiers/MpSoldier.txt
			SoldierBodyComponentData(instance).overrideGravityValue = -3.0

		elseif instance:Is('JumpStateData') then

			-- JumpStateData contains data that is linked to the players' jumping so we create an object from the instance, make it writable and then change it's default values.
			JumpStateData(instance):MakeWritable()
			-- Changing the player jump height to better illustrate the new gravity.
			-- The default value is 0.6
			-- It can be found in /Characters/Soldiers/DefaultSoldierPhysics.txt
			JumpStateData(instance).jumpHeight = 8.0

		end
	end
end)