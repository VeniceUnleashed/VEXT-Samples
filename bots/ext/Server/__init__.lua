local Bots = require('bots')

-- These NetEvents are triggered by client-side console commands.
-- Refer to the client __init__.lua script for more information.
NetEvents:Subscribe('Bots:Spawn', function(player, name, teamId, squadId, trans)
	local existingPlayer = PlayerManager:GetPlayerByName(name)
	local bot = nil

	if existingPlayer ~= nil then
		-- If a player with this name exists and it's not a bot then error out.
		if not Bots:isBot(existingPlayer) then
			return
		end

		-- If it is a bot, then store it and we'll call the spawn function for it after.
		-- This will respawn the bot (killing it if it's already alive).
		bot = existingPlayer

		-- We should also update its team and squad, just in case.
		bot.teamId = teamId
		bot.squadId = squadId
	else
		-- Otherwise, create a new bot. This returns a new Player object.
		bot = Bots:createBot(name, teamId, squadId)
	end

	-- Get the default MpSoldier blueprint and the US assault kit.
	local soldierBlueprint = ResourceManager:SearchForInstanceByGuid(Guid('261E43BF-259B-41D2-BF3B-9AE4DDA96AD2'))
	local soldierKit = ResourceManager:SearchForInstanceByGuid(Guid('A15EE431-88B8-4B35-B69A-985CEA934855'))

	-- Create the transform of where to spawn the bot at.
	local transform = LinearTransform()
	transform.trans = trans

	-- And then spawn the bot. This will create and return a new SoldierEntity object.
	Bots:spawnBot(bot, transform, CharacterPoseType.CharacterPoseType_Stand, soldierBlueprint, soldierKit, {})
end)

NetEvents:Subscribe('Bots:Kick', function(player, name)
	-- Try to get a player by the specified name.
	local player = PlayerManager:GetPlayerByName(name)

	-- Check if they exists.
	if player == nil then
		return
	end

	-- And if they do check if they're a bot.
	if not Bots:isBot(player) then
		return
	end

	-- If they are, destroy them.
	Bots:destroyBot(player)
end)

NetEvents:Subscribe('Bots:KickAll', function(player)
	Bots:destroyAllBots()
end)

-- We maintain some timers here that we use to have our bots move smoothly.
local elapsedPitchTime = 0
local elapsedYawTime = 0

Events:Subscribe('Engine:Update', function(dt)
	-- We keep track of pitch and yaw time separately here because we want
	-- the bots to turn and look at different rates.
	elapsedPitchTime = elapsedPitchTime + dt

	while elapsedPitchTime >= 0.7 do
		elapsedPitchTime = elapsedPitchTime - 0.7
	end

	elapsedYawTime = elapsedYawTime + dt

	while elapsedYawTime >= 1.5 do
		elapsedYawTime = elapsedYawTime - 1.5
	end
end)

-- Listen for bot update events and update their input to make them move.
-- You can make them do anything else you want here, from shooting to
-- aiming, and proning, etc.
Events:Subscribe('Bot:Update', function(bot, dt)
	-- Make the bots move forward.
    bot.input:SetLevel(EntryInputActionEnum.EIAThrottle, 0.5)

	-- Have bots jump with a 1.5% chance per frame.
	local shouldJump = MathUtils:GetRandomInt(0, 1000)

	if shouldJump <= 15 then
		bot.input:SetLevel(EntryInputActionEnum.EIAJump, 1.0)
	else
		bot.input:SetLevel(EntryInputActionEnum.EIAJump, 0.0)
	end

	-- We also take control over their aiming and make them look up and down
	-- and go around in circles.
	bot.input.flags = EntryInputFlags.AuthoritativeAiming

	local pitch = (((elapsedPitchTime / 0.7) - 1.0) * math.pi) + 0.5
	local yaw = ((elapsedYawTime / 1.5) * math.pi * 2.0)

	bot.input.authoritativeAimingPitch = pitch
	bot.input.authoritativeAimingYaw = yaw
end)
