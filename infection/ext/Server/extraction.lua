local extractionReplays = require('replays/xp4_quake')

local flarePos1 = Vec3(18.635742, 174.783005, 11)
local flarePos2 = Vec3(18.635742, 174.783005, 19)
local extractionPoint = Vec3(18.635742, 174.783005, 15)

function startExtraction()

	NetEvents:Broadcast(NetMessage.S2C_EXTRACTION_STARTED, {
		flares = { flarePos1, flarePos2 },
		point = extractionPoint
	})

	-- Start extraction sequence
	Events:Dispatch('br:play', extractionReplays[1])
end

function finishExtraction()
	-- We need to figure out which of the humans are inside the extraction point.
	-- Those are the humans that we consider as having survived.
	local survivors = {}

	for _, player in pairs(PlayerManager:GetPlayers()) do
		if isHuman(player) and not isBot(player) and player.soldier ~= nil then
			-- Check if the player is inside our extraction radius.
			local distance = player.soldier.transform.trans:Distance(extractionPoint)

			if distance <= 4.5 then
				table.insert(survivors, player.id)
			end
		end
	end

	NetEvents:Broadcast(NetMessage.S2C_GAME_ENDED, survivors)
end
