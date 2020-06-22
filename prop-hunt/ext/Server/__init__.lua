require('__shared/net')
require('__shared/round-state')

require('config')
require('prop-damage')
require('player-props')
require('spawning')
require('rounds')
require('teams')
require('spectating')

Events:Subscribe('Player:Chat', function(player, recipientMask, message)
	if message == '' or player == nil then
		return
	end

	print('Chat: ' .. message)

    if message == 'fadein' then
        print('Sending fade in event.')
		NetEvents:SendTo(NetMessage.S2C_FADE, player, true)
	end

	if message == 'fadeout' then
        print('Sending fade out event.')
		NetEvents:SendTo(NetMessage.S2C_FADE, player, false)
    end

    if message == 'prop' then
        if player.soldier ~= nil then
        	player.soldier.forceInvisible = true
        end

		print('Sending prop event')
		player.teamId = TeamId.Team2
        NetEvents:SendTo(NetMessage.S2C_MAKE_PROP, player)
    end

    if message == 'seeker' then
        if player.soldier ~= nil then
        	player.soldier.forceInvisible = false
        end

        print('Sending seeker event')
		player.teamId = TeamId.Team1
        NetEvents:SendTo(NetMessage.S2C_MAKE_SEEKER, player)
    end

    if message == 'pos' then
        if player.soldier == nil then
            return
        end

        print(player.soldier.transform)
    end
end)

