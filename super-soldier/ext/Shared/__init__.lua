local jumpMultiplier = 6
local moveVelocityMultiplier = 1.5
local sprintMultiplier = 1.5
local freeFallVelocityMultiplier = 3
local damageVelocityMultiplier = 0

Events:Subscribe('Partition:Loaded', function(partition)
	if partition == nil then
		return
	end

	local instances = partition.instances
	for _, instance in pairs(instances) do
		if instance ~= nil then
			-- Set the jumpheight
			if instance:Is("JumpStateData") then
				local instance = JumpStateData(instance)
				instance:MakeWritable()
				instance.jumpHeight = instance.jumpHeight * jumpMultiplier
			end

			-- Set movement multipliers
			if instance:Is("CharacterStatePoseInfo") then
				local instance = CharacterStatePoseInfo(instance)
				instance:MakeWritable()
				if instance.sprintMultiplier ~= 0 then 
					instance.sprintMultiplier = instance.sprintMultiplier * sprintMultiplier
				end
				instance.velocity = instance.velocity * moveVelocityMultiplier
			end

			-- Make parachute undeployable
			if instance:Is("ParachuteStateData") then
				local instance = ParachuteStateData(instance)
				instance:MakeWritable()
				instance.deployTime = 0
			end	

			-- Set freefall velocity
			if instance:Is("InAirStateData") then 
				local instance = InAirStateData(instance)
				instance:MakeWritable()
				instance.freeFallVelocity = instance.freeFallVelocity * freeFallVelocityMultiplier
			end

			-- Set correct 
			if instance.instanceGuid == Guid('5917C5BE-142C-498F-9EA0-CCC6211746D2') then -- Characters/Soldiers/MpSoldier
				print("cd")
				local instance = CollisionData(instance)
				instance:MakeWritable()
				for i = 1,5 do
					instance.damageAtVerticalVelocity:get(i).x = instance.damageAtVerticalVelocity:get(i).x * damageVelocityMultiplier
					instance.damageAtHorizVelocity:get(i).x = instance.damageAtVerticalVelocity:get(i).x * damageVelocityMultiplier
				end
			end

			-- Remove the jump penalty
			if instance.instanceGuid == Guid('A10FF2AA-F3CF-416B-A79B-E8C5416A9EBC') then -- Characters/Soldiers/Defaultsoldierphysics/
				local instance = CharacterPhysicsData(instance)
				instance:MakeWritable()
				instance.jumpPenaltyTime = 0
				instance.jumpPenaltyFactor = 0
			end
		end
	end
end) -- Remember closing it