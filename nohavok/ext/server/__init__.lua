require('havok')

local currentLevel = nil

-- We are sending the required havok transforms to clients when the level
-- changes or when someone joins for the first time.

-- NOTE: This may not work over high latency connections, as the client
-- might already be loading the level by the time they receive the event.

Events:Subscribe('Level:LoadResources', function(levelName)
	local lowerName = levelName:lower()
	currentLevel = lowerName

	for assetName, transforms in pairs(HavokTransforms) do
		if assetName:find(lowerName) == 1 then
			print('Sending transforms for "' .. assetName .. '" to all clients.')
			NetEvents:Broadcast('nohavok:transforms', assetName, transforms)
		end
	end
end)

Events:Subscribe('Player:Authenticated', function(player)
	if currentLevel == nil then
		return
	end

	for assetName, transforms in pairs(HavokTransforms) do
		if assetName:find(currentLevel) == 1 then
			print('Sending transforms for "' .. assetName .. '" to "' .. player.name .. '".')
			NetEvents:Broadcast('nohavok:transforms', assetName, transforms)
		end
	end
end)
