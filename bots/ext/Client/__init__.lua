Console:Register('spawn', 'Spawns a bot.', function(args)
	-- Print usage instructions if we got an invalid number of arguments.
	if #args ~= 6 then
		return 'Usage: _bots.spawn_ <*name*> <*team*> <*squad*> <*x*> <*y*> <*z*>'
	end

	-- Parse and validate the arguments.
	local name = args[1]
	local team = args[2]
	local squad = args[3]
	local x = tonumber(args[4])
	local y = tonumber(args[5])
	local z = tonumber(args[6])

	if #name == 0 then
		return 'Error: **Name must be at least 1 character long.**'
	end

	local teamId = TeamId[team]

	if teamId == nil then
		return 'Error: **Invalid team id specified.**'
	end

	local squadId = SquadId[squad]

	if squadId == nil then
		return 'Error: **Invalid squad id specified.**'
	end

	if x == nil or y == nil or z == nil then
		return 'Error: **Spawn coordinates must be numeric.**'
	end

	-- Notify server so it can spawn a bot.
	NetEvents:SendLocal('Bots:Spawn', name, teamId, squadId, Vec3(x, y, z))

	return nil
end)

Console:Register('kick', 'Kicks a bot.', function(args)
	-- Print usage instructions if we got an invalid number of arguments.
	if #args ~= 1 then
		return 'Usage: _bots.kick_ <*name*>'
	end

	-- Parse and validate arguments.
	local name = args[1]

	if #name == 0 then
		return 'Error: **Name must be at least 1 character long.**'
	end

	-- Notify server so it can kick the bot.
	NetEvents:SendLocal('Bots:Kick', name)

	return nil
end)

Console:Register('kickAll', 'Kicks all bots.', function()
	-- Notify server so it can kick all bots.
	NetEvents:SendLocal('Bots:KickAll', name)
end)
