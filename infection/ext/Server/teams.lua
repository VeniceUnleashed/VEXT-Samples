function isInfected(player)
	return player.teamId == TeamId.Team2
end

function isHuman(player)
	return player.teamId == TeamId.Team1
end

function isBot(player)
	return player.onlineId == 0
end

-- Returns the amount of alive humans.
function getHumanCount()
	local humanCount = 0

	for _, player in pairs(PlayerManager:GetPlayersByTeam(TeamId.Team1)) do
		-- Ignore bots
		if player.onlineId ~= 0 then
			humanCount = humanCount + 1
		end
	end

	return humanCount
end

-- Returns the amount of infected.
function getInfectedCount()
	local infectedCount = 0

	for _, player in pairs(PlayerManager:GetPlayersByTeam(TeamId.Team2)) do
		-- Ignore bots
		if player.onlineId ~= 0 then
			infectedCount = infectedCount + 1
		end
	end

	return infectedCount
end

local readyPlayers = 0

function getReadyPlayers()
	return readyPlayers
end

NetEvents:Subscribe(NetMessage.C2S_CLIENT_READY, function(player)
	spawnHuman(player)
end)

NetEvents:Subscribe('ready', function(player)
	readyPlayers = readyPlayers + 1
end)
