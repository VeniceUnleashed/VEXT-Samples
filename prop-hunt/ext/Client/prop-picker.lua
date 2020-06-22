local Debug = require('debug')
local Camera = require('camera')
local isMeshWhitelisted = require('__shared/whitelist')

local function getMesh(entity)
	local data = entity.data

	if data == nil then
		return nil
	end

	if data:Is('StaticModelEntityData') then
		data = StaticModelEntityData(data)
		return data.mesh
	end

	if data:Is('RigidMeshEntityData') then
		data = RigidMeshEntityData(data)
		return data.mesh
	end

	if data:Is('CompositeMeshEntityData') then
		data = CompositeMeshEntityData(data)
		return data.mesh
	end

	if data:Is('BreakableModelEntityData') then
		data = BreakableModelEntityData(data)
		return data.mesh
	end

	return nil
end

local function intersect(from, to, aabb, transform, maxDist)
	local tmin = 0.0
	local tmax = maxDist

	local heading = to - from
	local direction = heading:Normalize()

	local delta = transform.trans - from

	local function checkAxis(axis, min, max)
		local e = axis:Dot(delta)
		local f = direction:Dot(axis)

		if math.abs(f) > math.epsilon then
			local t1 = (e + min) / f
			local t2 = (e + max) / f

			if t1 > t2 then
				local temp = t1
				t1 = t2
				t2 = temp
			end

			if t2 < tmax then
				tmax = t2
			end

			if t1 > tmin then
				tmin = t1
			end

			if tmax < tmin then
				return false
			end
		else
			if min - e > 0.0 or max - e < 0.0 then
				return false
			end
		end

		return true
	end

	if not checkAxis(transform.left, aabb.min.x, aabb.max.x) then
		return false
	end

	if not checkAxis(transform.up, aabb.min.y, aabb.max.y) then
		return false
	end

	if not checkAxis(transform.forward, aabb.min.z, aabb.max.z) then
		return false
	end

	return { tmin, tmax }
end

local function pickProp()
	-- Make sure we have a local player.
	local player = PlayerManager:GetLocalPlayer()

	if player == nil or player.soldier == nil then
		return nil
	end

	-- Our prop-picking ray will start at what the camera is looking at and
	-- extend forward by 3.0m.
	local from = Camera:getLookAtPos()
	local target = from - Camera:getTransform().forward * 3.0

	-- Do a spatial raycast and a normal raycast.
	-- We use the spatial raycast to find available propsand the normal raycast
	-- to see if there's anything between us and that prop and also help us select
	-- the prop to pick.
	local entities = RaycastManager:SpatialRaycast(from, target, SpatialQueryFlags.AllGrids)
	local hit = RaycastManager:Raycast(from, target, RayCastFlags.CheckDetailMesh | RayCastFlags.DontCheckWater | RayCastFlags.DontCheckCharacter | RayCastFlags.DontCheckRagdoll)

	local hitDistance = 3.0

	if hit ~= nil then
		hitDistance = from:Distance(hit.position)

		-- Add 1.5cm to account for innacuracies.
		hitDistance = hitDistance + 0.015
	end

	local raycastObjects = {}
	local candidates = {}

	local heading = target - from
	local direction = heading:Normalize()

	local wallHit = from + (direction * hitDistance)
	Debug:setWallHit(wallHit)

	-- Iterate through the entities until we find one we can use.
	for _, entity in pairs(entities) do
		-- We only care about spatial entities.
		if not entity:Is('SpatialEntity') then
			goto continue
		end

		-- If this is a player prop entity then skip it.
		if isPlayerProp(entity) then
			goto continue
		end

		local mesh = getMesh(entity)

		-- If we couldn't get a mesh then it means this isn't a supported entity.
		if mesh == nil then
			goto continue
		end

		-- If this entity is blacklisted then skip it.
		if not isMeshWhitelisted(mesh) then
			goto continue
		end

		-- Now we need to do our own ray-tracing because the entities we get back do
		-- not necessarily intersect with our selection ray.
		local spatialEntity = SpatialEntity(entity)

		local aabb = spatialEntity.aabb
		local aabbTrans = spatialEntity.aabbTransform

		-- Try to get an intersection point between our ray and this entity's OBB.
		local intersection = intersect(from, target, aabb, aabbTrans, 3.0)

		-- No intersection found
		if intersection == false then
			table.insert(raycastObjects, { aabb, aabbTrans, mesh.name, nil, nil, false })
			goto continue
		end

		-- We have an intersection! Add to a list of entities to process.
		table.insert(candidates, { mesh, spatialEntity, intersection })

		-- Add to debug render list.
		local intersectStart = from + (direction * intersection[1])
		local intersectEnd = from + (direction * intersection[2])

		print(intersection[1])

		table.insert(raycastObjects, { aabb, aabbTrans, mesh.name, intersectStart, intersectEnd, false })

		::continue::
	end

	-- Process our candidates to find the best one.
	local selectedProp = nil

	-- Find the prop whose intersection point is closest to the raycast hit.
	for _, candidate in pairs(candidates) do
		local intersectionStart = candidate[3][1]

		if intersectionStart <= hitDistance then
			if selectedProp == nil then
				selectedProp = candidate
			end

			if intersectionStart > selectedProp[3][1] then
				selectedProp = candidate
			end
		end
	end

	-- If we have selected a prop then add it to the debug render list.
	if selectedProp ~= nil then
		local intersectStart = from + (direction * selectedProp[3][1])
		local intersectEnd = from + (direction * selectedProp[3][2])

		table.insert(raycastObjects, { selectedProp[2].aabb, selectedProp[2].aabbTransform, selectedProp[1].name, intersectStart, intersectEnd, true })
	end

	-- Send debug draw commands.
	Debug:setRaycastObjects(raycastObjects)
	Debug:setRaycastLine(from, target)

	-- If we have selected a prop then try to find a blueprint for its mesh.
	if selectedProp ~= nil then
		local bpName = string.lower(selectedProp[1].name)
		bpName = string.gsub(bpName, '_mesh$', '')

		local bp = ResourceManager:LookupDataContainer(ResourceCompartment.ResourceCompartment_Game, bpName)
		return bp
	end

	return nil
end

local elapsedTime = 0.0

Events:Subscribe('Client:UpdateInput', function(delta)
	elapsedTime = elapsedTime + delta

	-- If we're not a prop then we shouldn't be able to pick.
	if not isProp then
		return
	end

	-- Make sure we have a local player and an alive soldier.
	local player = PlayerManager:GetLocalPlayer()

	if player == nil or player.soldier == nil then
		return
	end

	-- If the player is pressing down the prop selection key do a
	-- raycast to find a valid prop. We allow prop selection once every
	-- 250ms to prevent lag.
	if InputManager:IsKeyDown(InputDeviceKeys.IDK_E) and elapsedTime >= 0.25 then
		elapsedTime = 0.0

		-- Find a prop to turn into!
		local bp = pickProp()

		-- If we managed to find one, turn the player into it.
		if bp ~= nil then
			-- First create it (so there's no visual delay) and then inform the server.
			createPlayerProp(player, bp)
			NetEvents:Send(NetMessage.C2S_SET_PROP, Blueprint(bp).name)
		end
	end
end)
