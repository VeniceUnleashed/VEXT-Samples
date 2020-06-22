local spawnedFlares = {}

local function spawnFlare(pos)
	local flareBp = ResourceManager:SearchForDataContainer('FX/Ambient/Warfare/SignalFlare/Prefab_SignalFlare_Red_NoAuto')

	if flareBp == nil then
		error('Could not find flare blueprint.')
		return
	end

	local up = pos:Clone()
	up.y = up.y + 1

	local transform = LinearTransform()
	transform:LookAtTransform(pos, up)
	transform.trans.y = transform.trans.y + 0.10

	local bus = EntityManager:CreateEntitiesFromBlueprint(flareBp, transform)

	if bus == nil then
		error('Could not spawn flare.')
		return
	end

	for _, entity in pairs(bus.entities) do
		entity:Init(Realm.Realm_Client, false)
		entity:FireEvent('Start')

		table.insert(spawnedFlares, entity)
	end
end

NetEvents:Subscribe(NetMessage.S2C_EXTRACTION_STARTED, function(extractionData)
	for _, flare in pairs(extractionData.flares) do
		spawnFlare(flare)
	end
end)


Events:Subscribe('Extension:Unloading', function()
	for _, flare in pairs(spawnedFlares) do
		flare:Destroy()
	end

	spawnedFlares = {}
end)
