class('ThirdPersonCamera')

function ThirdPersonCamera:__init()
	-- The distance between the camera and the player.
	self._distance = 2.0

	-- The height of the camera relative to the player's feet.
	self._height = 1.5

	-- The free-look key.
	self._freelookKey = InputDeviceKeys.IDK_LeftAlt

	-- Precompute values we'll use often later.
	-- These specifically are the min / max aiming angles.
	-- These exactly match the min / max soldier aiming angles
	-- and should probably not be changed.
	self._maxPitch = 85.0 * (math.pi / 180.0)
	self._minPitch = -70.0 * (math.pi / 180.0)

	self._twoPi = math.pi * 2

	self._lockedCameraYaw = 0.0
	self._lockedCameraPitch = 0.0

	self._isLocked = false
	self._data = nil
	self._entity = nil
	self._active = false
	self._lookAtPos = nil

	-- Subscribe to relevant events and install necessary hooks.
	Hooks:Install('Input:PreUpdate', 100, self, self._onInputPreUpdate)

	Events:Subscribe('Engine:Update', self, self._onUpdate)
	Events:Subscribe('Level:Destroy', self, self._onLevelDestroy)
end

function ThirdPersonCamera:_createCameraData()
	if self._data ~= nil then
		return
	end

	-- Create data for our camera entity.
	-- We set the priority very high so our game gets forced to use this camera.
	self._data = CameraEntityData()
	self._data.fov = 100
	self._data.enabled = true
	self._data.priority = 99999
	self._data.nameId = 'third-person-cam'
	self._data.transform = LinearTransform()
end

function ThirdPersonCamera:_createCamera()
	if self._entity ~= nil then
		return
	end

	-- First ensure that we have create our camera data.
	self:_createCameraData()

	-- And then create the camera entity.
	self._entity = EntityManager:CreateEntity(self._data, self._data.transform)
	self._entity:Init(Realm.Realm_Client, true)
end

function ThirdPersonCamera:_onLevelDestroy()
	-- When the level is getting destroyed we should disable the camera.
	-- This will release control and destroy our entity.
	self:disable()
end

function ThirdPersonCamera:_destroyCamera()
	if self._entity == nil then
		return
	end

	-- Destroy the camera entity.
	self._entity:Destroy()
	self._entity = nil
	self._lookAtPos = nil
end

function ThirdPersonCamera:_takeControl()
	-- By firing the "TakeControl" event on the camera entity we make the
	-- current player switch to this camera from their first person camera.
	self._active = true
	self._entity:FireEvent('TakeControl')
end

function ThirdPersonCamera:_releaseControl()
	-- By firing the "ReleaseControl" event on the camera entity we return
	-- the player to whatever camera they were supposed to be using.
	self._active = false

	if self._entity ~= nil then
		self._entity:FireEvent('ReleaseControl')
	end
end

function ThirdPersonCamera:_onInputPreUpdate(hook, cache, dt)
	-- Don't do anything if the camera is not active.
	if not self._active then
		return
	end

	local player = PlayerManager:GetLocalPlayer()

	if player == nil then
		return
	end

	-- Check if the player is locking the camera.
	if self._freelookKey ~= InputDeviceKeys.IDK_None and InputManager:IsKeyDown(self._freelookKey) then
		-- If we're not already locked then save the initial position.
		if not self._locked and player.input ~= nil then
			self._locked = true

			self._lockedCameraYaw = player.input.authoritativeAimingYaw
			self._lockedCameraPitch = player.input.authoritativeAimingPitch
		end
	elseif self._locked then
		-- If we were previously locked then unlock.
		self._locked = false
	end

	-- If we are locking then prevent the player from looking around.
	if self._locked then
		player:EnableInput(EntryInputActionEnum.EIAYaw, false)
		player:EnableInput(EntryInputActionEnum.EIAPitch, false)
	else
		player:EnableInput(EntryInputActionEnum.EIAYaw, true)
		player:EnableInput(EntryInputActionEnum.EIAPitch, true)
	end

	-- If we're locked then we need to update the yaw and pitch manually.
	if self._locked then
		-- 1.916686 is a magic number we use to somewhat match the rotation speed
		-- with the actual soldier rotation speed.

		-- Get the yaw and pitch movement values and multiply by it to figure out
		-- how much to rotate the camera.
		local rotateYaw = cache[InputConceptIdentifiers.ConceptYaw] * 1.916686
		local rotatePitch = cache[InputConceptIdentifiers.ConceptPitch] * 1.916686

		-- And then just rotate!
		self._lockedCameraYaw = self._lockedCameraYaw + rotateYaw
		self._lockedCameraPitch = self._lockedCameraPitch + rotatePitch

		-- Limit the pitch to the actual min / max viewing angles.
		if self._lockedCameraPitch > self._maxPitch then
			self._lockedCameraPitch = self._maxPitch
		end

		if self._lockedCameraPitch < self._minPitch then
			self._lockedCameraPitch = self._minPitch
		end

		-- Limit the yaw to [0, pi * 2].
		while self._lockedCameraYaw < 0 do
			self._lockedCameraYaw = self._twoPi + self._lockedCameraYaw
		end

		while self._lockedCameraYaw > self._twoPi do
			self._lockedCameraYaw = self._lockedCameraYaw - self._twoPi
		end
	end
end

function ThirdPersonCamera:_onUpdate(delta, simDelta)
	-- Don't update if the camera is not active.
	if not self._active then
		return
	end

	-- Don't update if we don't have a player with an alive soldier.
	local player = PlayerManager:GetLocalPlayer()

	if player == nil or player.soldier == nil or player.input == nil then
		return
	end

	-- Get the soldier's aiming angles.
	local yaw = player.input.authoritativeAimingYaw
	local pitch = player.input.authoritativeAimingPitch

	-- If the camera is locked then we use custom angles.
	if self._locked then
		yaw = self._lockedCameraYaw
		pitch = self._lockedCameraPitch
	end

	-- Fix angles so we're looking at the right thing.
	yaw = yaw - math.pi / 2
	pitch = pitch + math.pi / 2

	-- Set the look at position above the soldier's feet.
	self._lookAtPos = player.soldier.transform.trans:Clone()
	self._lookAtPos.y = self._lookAtPos.y + self._height

	-- Calculate where our camera has to be base on the angles.
	local cosfi = math.cos(yaw)
	local sinfi = math.sin(yaw)

	local costheta = math.cos(pitch)
	local sintheta = math.sin(pitch)

	local cx = self._lookAtPos.x + (self._distance * sintheta * cosfi)
	local cy = self._lookAtPos.y + (self._distance * costheta)
	local cz = self._lookAtPos.z + (self._distance * sintheta * sinfi)

	local cameraLocation = Vec3(cx, cy, cz)

	-- Raycast from the look at position backwards to the camera position
	-- to find if there's anything that intersects.
	local hit = RaycastManager:Raycast(self._lookAtPos, cameraLocation, RayCastFlags.DontCheckWater | RayCastFlags.DontCheckCharacter | RayCastFlags.DontCheckRagdoll)

	-- If something does, then change the camera location to it.
	if hit ~= nil then
		cameraLocation = hit.position

		-- Move it just a bit forward so we're not actually inside geometry.
		local heading = self._lookAtPos - cameraLocation
		local direction = heading:Normalize()

		cameraLocation = cameraLocation + (direction * 0.1)
	end

	-- Calculate the LookAt transform.
	self._data.transform:LookAtTransform(cameraLocation, self._lookAtPos)

	-- Flip the camera angles so we're looking at the player.
	self._data.transform.left = self._data.transform.left * -1
	self._data.transform.forward = self._data.transform.forward * -1
end

-- Enables the third person camera.
function ThirdPersonCamera:enable()
	self:_createCamera()
	self:_takeControl()
end

-- Disables the third person camera.
function ThirdPersonCamera:disable()
	self:_releaseControl()
	self:_destroyCamera()
end

-- Gets the current transform of the third person camera.
-- Will be `nil` if the camera is not active.
function ThirdPersonCamera:getTransform()
	if not self._active or self._data == nil then
		return nil
	end

	-- We clone here so anyone who calls this can't modify it.
	return self._data.transform:Clone()
end

-- Returns `true` if the camera is currently in free-look mode, `false` otherwise.
function ThirdPersonCamera:isFreelooking()
	return self._locked
end

-- Returns `true` if the camera is currently active, `false` otherwise.
function ThirdPersonCamera:isActive()
	return self._active
end

-- Gets the key the player needs to press to free-look.
function ThirdPersonCamera:getFreelookKey()
	return self._freelookKey
end

-- Sets the key the player needs to press to free-look.
-- You can use `InputDeviceKeys.IDK_None` to disable free-look.
function ThirdPersonCamera:setFreelookKey(key)
	self._freelookKey = key
end

-- Gets the maximum distance between the camera and the soldier.
function ThirdPersonCamera:getDistance()
	return self._distance
end

-- Sets the maximum distance between the camera and the soldier.
function ThirdPersonCamera:setDistance(distance)
	self._distance = distance
end

-- Gets the height of the camera target, relative to the soldier's feet.
function ThirdPersonCamera:getHeight()
	return self._height
end

-- Sets the height of the camera target, relative to the soldier's feet.
function ThirdPersonCamera:setHeight(height)
	self._height = height
end

-- Gets the position of what the camera is currently looking at.
-- Will be `nil` if the camera is not active.
function ThirdPersonCamera:getLookAtPos()
	return self._lookAtPos
end

-- Singleton.
if g_ThirdPersonCamera == nil then
	g_ThirdPersonCamera = ThirdPersonCamera()
end

return g_ThirdPersonCamera
