local MAX_WALK_SPEED = 1
local MIN_WALK_SPEED = 0.4
local SPEED_INCREMENT = 0.1

local walkingSpeeds = {}

function UpdateSpeed(playerId, speed)
	print('Updating speed, '.. playerId..', '..speed)

	-- Initialize player current speed if needed.
	if walkingSpeeds[playerId] == nil then
		walkingSpeeds[playerId] = MAX_WALK_SPEED
	end

	-- Increase/decrease speed based on the speed increment value. Also, clamp max and min allowed speed.
	walkingSpeeds[playerId] = math.max(MIN_WALK_SPEED, walkingSpeeds[playerId] + speed * SPEED_INCREMENT)
	walkingSpeeds[playerId] = math.min(walkingSpeeds[playerId], MAX_WALK_SPEED)

	print('New walk speed: '..walkingSpeeds[playerId] )
end

-- Subscribe to our custom server event
Events:Subscribe('Shared:UpdateSpeed', function(playerId, speed)
	UpdateSpeed(playerId, speed)
end)

-- Subscribe to our custom client NetEvent
NetEvents:Subscribe('Shared:UpdateSpeed', function(playerId, speed)
	UpdateSpeed(playerId, speed)
end)

-- Subscribe to UpdateInput, as we want to modify the players' walking speed.
Events:Subscribe('Player:UpdateInput', function(player, dt)
	if player == nil or player.input == nil then
		return
	end

	-- Initialize player current speed if needed.
	if walkingSpeeds[player.id] == nil then
		walkingSpeeds[player.id] = MAX_WALK_SPEED
	end

	-- Ignore if player is sprinting.
	if player.input:GetLevel(EntryInputActionEnum.EIASprint) == 1 then
		return
	end

	-- Get current movement levels.
	local throttle = player.input:GetLevel(EntryInputActionEnum.EIAThrottle)
	local brake = player.input:GetLevel(EntryInputActionEnum.EIABrake)
	local strafe = player.input:GetLevel(EntryInputActionEnum.EIAStrafe)

	-- Update each level with the current speed.
	if throttle ~= 0  then
		player.input:SetLevel(EntryInputActionEnum.EIAThrottle, throttle * walkingSpeeds[player.id])
	end

	if brake ~= 0  then
		player.input:SetLevel(EntryInputActionEnum.EIABrake, brake * walkingSpeeds[player.id])
	end

	if strafe ~= 0  then
		player.input:SetLevel(EntryInputActionEnum.EIAStrafe, strafe * walkingSpeeds[player.id])
	end
end)