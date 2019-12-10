-- When a player gets killed send a event to all players to spawn
-- an explosion effect on the location the player died at.
Events:Subscribe('Player:Killed', function(player)
  NetEvents:BroadcastLocal('BFV:Kaboom', player.soldier.worldTransform.trans)
end)
