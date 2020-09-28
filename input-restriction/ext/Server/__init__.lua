-- The following function will get called when a player spawns.
Events:Subscribe('Player:Respawn', function(player)
	-- Prevent the player from jumping and sprinting.
	player:EnableInput(EntryInputActionEnum.EIAJump, false)
	player:EnableInput(EntryInputActionEnum.EIASprint, false)
end)