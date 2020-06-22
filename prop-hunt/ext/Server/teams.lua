readyPlayers = {}

NetEvents:Subscribe(NetMessage.C2S_CLIENT_READY, function(player)
	table.insert(readyPlayers, player)

	-- If the game has already started then just set the player as a spectator.
	if roundActive then
		setPlayerSpectating(player, true)
		return
	end

	-- Otherwise, set the player to Team1 and spawn them.
	setPlayerSpectating(player, false)
    player.teamId = TeamId.Team1

    -- Spawn the player.
    spawnPlayer(player)
end)

-- Remove player from list of ready players when they disconnect.
Events:Subscribe('Player:Destroyed', function(player)
	for i, readyPlayer in pairs(readyPlayers) do
		if readyPlayer == player then
			table.remove(readyPlayers, i)
			break
		end
	end
end)

-- Clear all ready players when a new level is loading.
Events:Subscribe('Level:LoadResources', function()
	readyPlayers = {}
end)

function assignTeams()
	-- Randomly assign teams to players.
	local players = PlayerManager:GetPlayers()

	-- We want half the players to be seekers and half to be props.
	local halfPlayers = #players / 2

	if halfPlayers == 0 then
		halfPlayers = 1
	end

	local seekerPlayers = 0

	-- First we assign everyone to neutral.
	for _, player in pairs(players) do
		player.teamId = TeamId.TeamNeutral
	end

	-- Then we start going through everyone, randomly selecting seekers
	-- until we have filled our quota.
	while seekerPlayers < halfPlayers do
		for _, player in pairs(players) do
			if seekerPlayers >= halfPlayers then
				goto assign_continue
			end

			if player.teamId ~= TeamId.TeamNeutral then
				goto assign_continue
			end

			if MathUtils:GetRandomInt(0, 1) == 1 then
				player.teamId = TeamId.Team1
				seekerPlayers = seekerPlayers + 1
			end

			::assign_continue::
		end
	end

	-- Set everyone that's left to the prop team.
	for _, player in pairs(players) do
		if player.teamId == TeamId.TeamNeutral then
			player.teamId = TeamId.Team2
		end
	end
end
