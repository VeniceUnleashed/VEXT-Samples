-- As soon as a player spawns disable their ability to toggle their parachute.
Events:Subscribe('Player:Respawn', function(player)
	player:EnableInput(EntryInputActionEnum.EIAToggleParachute, false)
end)
