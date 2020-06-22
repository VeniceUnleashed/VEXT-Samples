local vehicle = nil

function spawnChopper()
	if vehicle ~= nil then
		vehicle:Destroy()
		vehicle = nil
	end

	local bp = ResourceManager:SearchForDataContainer('Vehicles/Venom/Venom')

	if bp == nil then
		print('Could not find Venom blueprint. Something fucky is going on here.')
		return
	end

	local pos = Vec3(440.207031, 192.954926, 19.943359)
	--local pos = Vec3(5.987305, 174.783981, 18.863281)

	local params = EntityCreationParams()

	params.transform = LinearTransform()
	params.transform.trans = pos
	params.networked = true

	local bus = EntityManager:CreateEntitiesFromBlueprint(bp, params)

	if bus == nil then
		print('Could not spawn Venom.')
		return
	end

	vehicle = nil

	for _, entity in pairs(bus.entities) do
		entity:Init(Realm.Realm_ClientAndServer, true)

		if vehicle == nil and entity:Is('ServerVehicleEntity') then
			vehicle = entity
		end
	end
end

Events:Subscribe('Extension:Unloading', function()
	if vehicle ~= nil then
		vehicle:Destroy()
	end
end)
