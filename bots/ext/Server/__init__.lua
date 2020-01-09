local Bots = require('bots')

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
	local soldierBlueprint = ResourceManager:SearchForInstanceByGUID(Guid('261E43BF-259B-41D2-BF3B-9AE4DDA96AD2'))
	local soldierKit = ResourceManager:SearchForInstanceByGUID(Guid('A15EE431-88B8-4B35-B69A-985CEA934855'))

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

-- Listen for bot update events and update their input so that
-- they always turn around in circles. You can make them do anything
-- else you want here, from shooting to jumping, etc.
Events:Subscribe('Bot:Update', function(bot, dt)
    bot.input:SetLevel(EntryInputActionEnum.EIAThrottle, 1.0)
    bot.input:SetLevel(EntryInputActionEnum.EIAYaw, 0.75)
end)
