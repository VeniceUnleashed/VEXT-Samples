-- Load the BFV visual identity.
require('visual-identity')

local explosionEntityData = nil

-- Get or create the exposion entity data.
local function getExplosionEntityData()
	-- If we already have it then return it.
	if explosionEntityData ~= nil then
		return explosionEntityData
	end

	-- Otherwise we need to create it.

	-- First, find the explosion we're basing this on.
	-- This is the Weapons/Gadgets/M224/M224_Projectile explosion effect.
	local original = ResourceManager:SearchForInstanceByGUID(Guid('4827959A-8A3B-4C9F-994E-E54150AA565F'))

	if original == nil then
		print('Could not find explosion template')
		return nil
	end

	-- Next, clone it, store it, and make it a lot more powerful.
	explosionEntityData = VeniceExplosionEntityData(original:Clone())

	explosionEntityData.innerBlastRadius = 10
	explosionEntityData.blastRadius = 30
	explosionEntityData.blastDamage = 1000
	explosionEntityData.blastImpulse = 1000
	explosionEntityData.hasStunEffect = true
	explosionEntityData.shockwaveRadius = 55
	explosionEntityData.shockwaveTime = 0.75
	explosionEntityData.shockwaveDamage = 10
	explosionEntityData.shockwaveImpulse = 200
	explosionEntityData.cameraShockwaveRadius = 10

	return explosionEntityData
end

-- Listen for BFV:Kabook netevents from the server.
-- Every time we get one, spawn an explosion at the provided position.
NetEvents:Subscribe('BFV:Kaboom', function(position)
	local data = getExplosionEntityData()

	if data == nil then
		print('Could not get explosion data')
		return
	end

	-- Create the entity at the provided position.
	local transform = LinearTransform()
	transform.trans = position

	local entity = EntityManager:CreateEntity(data, transform)

	if entity == nil then
		print('Could not create entity.')
		return
	end

	-- Spawn the explosion.
	-- Keep in mind that this explosion is client-side and won't do any damage.
	entity = ExplosionEntity(entity)
	entity:Detonate(transform, Vec3(0, 1, 0), 1.0, nil)
end)

-- When the level reloads clear any previously created entity data.
Events:Subscribe('Level:LoadResources', function()
	explosionEntityData = nil
end)
