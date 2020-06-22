local Camera = require('Camera')

local playerPropBps = {}
local playerProps = {}

function createPlayerProp(player, bp)
    -- We are already this prop.
    if playerPropBps[player.id] == bp then
        return
    end

    -- Delete the old prop.
	if playerProps[player.id] ~= nil then
		playerProps[player.id].entities[1]:Destroy()
        playerProps[player.id] = nil
    end

    local realBp = Blueprint(bp)
    print('Creating player prop with BP: ' .. realBp.name)

    -- Create the new player prop.
    local bus = EntityManager:CreateEntitiesFromBlueprint(bp, player.soldier.transform)

    if bus == nil or #bus.entities == 0 then
        print('Failed to create prop entity for client.')
        return
    end

    -- Cast and initialize the entity.
	playerPropBps[player.id] = bp

	for _, entity in pairs(bus.entities) do
		entity:Init(Realm.Realm_Client, true)
	end

    playerProps[player.id] = bus
end

function isPlayerProp(otherEntity)
	for _, bus in pairs(playerProps) do
		for _, entity in pairs(bus.entities) do
			if entity.instanceId == otherEntity.instanceId then
				return true
			end
		end
	end

	return false
end

Events:Subscribe('Engine:Update', function(delta, simDelta)
    for id, bus in pairs(playerProps) do
        local player = PlayerManager:GetPlayerById(id)

        if player == nil or player.soldier == nil then
            goto continue
        end

		local entity = SpatialEntity(bus.entities[1])

		entity.transform = player.soldier.transform
		entity:FireEvent('Disable')
		entity:FireEvent('Enable')

        ::continue::
    end
end)

NetEvents:Subscribe(NetMessage.S2C_PROP_CHANGED, function(playerId, bpName)
    local player = PlayerManager:GetPlayerById(playerId)

    if player == nil or player.soldier == nil then
        return
    end

    local bp = ResourceManager:LookupDataContainer(ResourceCompartment.ResourceCompartment_Game, bpName)

    if bp == nil then
        return
    end

    createPlayerProp(player, bp)
end)

NetEvents:Subscribe(NetMessage.S2C_MAKE_PROP, function()
	isProp = true
	Camera:enable()
end)

NetEvents:Subscribe(NetMessage.S2C_REMOVE_PROP, function(playerId)
	local bus = playerProps[playerId]

	if bus == nil then
		return
	end

	bus.entities[1]:Destroy()

	playerProps[playerId] = nil
	playerPropBps[playerId] = nil
end)

-- TODO: Optimize this with a more efficient lookup table.
Hooks:Install('Entity:ShouldCollideWith', 100, function(hook, entityA, entityB)
	--[[for id, bus in pairs(playerProps) do
		for _, entity in pairs(bus.entities) do
			if entity:Is('ClientPhysicsEntity') and PhysicsEntity(entity).physicsEntityBase.instanceId == entityB.instanceId then
				local player = PlayerManager:GetPlayerById(id)

				if player.soldier and player.soldier.physicsEntityBase.instanceId == entityA.instanceId then
					hook:Return(false)
					return
				end
			end
		end
	end]]
end)
