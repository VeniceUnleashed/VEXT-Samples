local playerPropNames = {}
local playerProps = {}
local playerPropPositions = {}

NetEvents:Subscribe(NetMessage.C2S_SET_PROP, function(player, bpName)
    -- Check if this bp exists.
    print('Setting prop for player')
    print(bpName)
	print(player)

	-- Make sure the player is alive and on the right team.
	if player.soldier == nil then
		return
	end

	if player.teamId ~= TeamId.Team2 then
		return
	end

    local bp = ResourceManager:LookupDataContainer(ResourceCompartment.ResourceCompartment_Game, bpName)

    if bp == nil then
        return
    end

    -- Set the prop for this player.
    local oldProp = playerPropNames[player.id]

    -- If it has not changed then do nothing.
	if oldProp == bpName then
		return
	end

	-- If we have an old prop, delete it.
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
	for _, entity in pairs(bus.entities) do
		entity:Init(Realm.Realm_Server, true)
	end

	playerPropNames[player.id] = bpName
	playerPropPositions[player.id] = player.soldier.transform
    playerProps[player.id] = bus

	NetEvents:Broadcast(NetMessage.S2C_PROP_CHANGED, player.id, bpName)
end)

Events:Subscribe('Engine:Update', function()
	for id, bus in pairs(playerProps) do
        local player = PlayerManager:GetPlayerById(id)

        if player == nil or player.soldier == nil then
            goto continue
		end

		local transform = player.soldier.transform

		if playerPropPositions[player.id] == transform then
			goto continue
		end

		playerPropPositions[player.id] = transform

		local entity = SpatialEntity(bus.entities[1])
		entity.transform = transform
		entity:FireEvent('Disable')
		entity:FireEvent('Enable')

        ::continue::
    end
end)

NetEvents:Subscribe(NetMessage.C2S_CLIENT_READY, function(player)
	-- Sync existing props to connecting clients.
	for id, bpName in pairs(playerPropNames) do
		NetEvents:Broadcast(NetMessage.S2C_PROP_CHANGED, id, bpName)
	end
end)

local function destroyPropForPlayer(player)
	local bus = playerProps[player.id]

	if bus == nil then
		return
	end

	bus.entities[1]:Destroy()

	playerProps[player.id] = nil
	playerPropNames[player.id] = nil
	playerPropPositions[player.id] = nil

	NetEvents:Broadcast(NetMessage.S2C_REMOVE_PROP, player.id)
end

Events:Subscribe('Player:Destroyed', function(player)
	destroyPropForPlayer(player)
end)

-- TODO: Optimize this with a precomputed lookup table.
Hooks:Install('Entity:ShouldCollideWith', 100, function(hook, entityA, entityB)
	for id, bus in pairs(playerProps) do
		for _, entity in pairs(bus.entities) do
			if entity:Is('ServerPhysicsEntity') and PhysicsEntity(entity).physicsEntityBase.instanceId == entityB.instanceId then
				local player = PlayerManager:GetPlayerById(id)

				if player.soldier and player.soldier.physicsEntityBase.instanceId == entityA.instanceId then
					hook:Return(false)
					return
				end
			end
		end
	end
end)

function makePlayerProp(player)
	player.soldier.forceInvisible = true

	-- TODO: Set default prop for player.

	player:EnableInput(EntryInputActionEnum.EIAFire, false)
	player:EnableInput(EntryInputActionEnum.EIAZoom, false)
	player:EnableInput(EntryInputActionEnum.EIAProne, false)
	player:EnableInput(EntryInputActionEnum.EIAReload, false)
	player:EnableInput(EntryInputActionEnum.EIAMeleeAttack, false)
	player:EnableInput(EntryInputActionEnum.EIAThrowGrenade, false)
	player:EnableInput(EntryInputActionEnum.EIAToggleParachute, false)

	NetEvents:SendTo(NetMessage.S2C_MAKE_PROP, player)
end

function makePlayerSeeker(player)
	player.soldier.forceInvisible = false

	player:EnableInput(EntryInputActionEnum.EIAFire, true)
	player:EnableInput(EntryInputActionEnum.EIAZoom, true)
	player:EnableInput(EntryInputActionEnum.EIAProne, true)
	player:EnableInput(EntryInputActionEnum.EIAReload, true)
	player:EnableInput(EntryInputActionEnum.EIAMeleeAttack, false)
	player:EnableInput(EntryInputActionEnum.EIAThrowGrenade, false)
	player:EnableInput(EntryInputActionEnum.EIAToggleParachute, false)

	NetEvents:SendTo(NetMessage.S2C_MAKE_SEEKER, player)
end
