require('__shared/net')
require('__shared/round-state')

require('config')
require('spawning')
require('damage')
require('teams')
require('chopper')
require('gamelogic')
require('extraction')

local Bots = require('bots')

NetEvents:Subscribe('infect', function(player, playerName)
	local player = PlayerManager:GetPlayerByName(playerName)

	if player == nil then
		print('Could not find player to infect')
		return
	end

	spawnInfected(player)
end)

NetEvents:Subscribe('human', function(player, playerName)
	local player = PlayerManager:GetPlayerByName(playerName)

	if player == nil then
		print('Could not find player to humanize')
		return
	end

	spawnHuman(player)
end)

NetEvents:Subscribe('chopper', function(player)
	spawnChopper()
end)

local bot = nil

NetEvents:Subscribe('bot', function(player)
	if bot ~= nil then
		return
	end

	bot = Bots:createBot('Botman', TeamId.Team1, SquadId.Squad1)
end)

NetEvents:Subscribe('extract', function()
	startExtraction()
end)

