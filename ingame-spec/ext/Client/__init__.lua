local IngameSpectator = require('ingame-spectator')

Console:Register('Spectate', 'Toggle spectator mode', function(args)
	if IngameSpectator:isEnabled() then
		IngameSpectator:disable()
		return 'Disabled in-game spectator.'
	end

	local localPlayer = PlayerManager:GetLocalPlayer()

	if localPlayer.soldier ~= nil then
		return 'Cannot enable in-game spectator while alive.'
	end

	IngameSpectator:enable()
	return 'Enabled in-game spectator.'
end)
