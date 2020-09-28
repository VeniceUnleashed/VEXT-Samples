
-- Subscribe to our custom NetEvent.
NetEvents:Subscribe('Server:UpdateSpeed', function(player, speed)
	if player == nil then
		return
	end
	-- As the shared script is both run on server and client, we have to
	-- send them differently. For clients we use a NetEvent and for server 
	-- a normal event, as we are in a server script already.

	-- Send to all clients (shared script)
	NetEvents:BroadcastLocal('Shared:UpdateSpeed', player.id, speed)

	-- Send to server (shared script)
	Events:DispatchLocal('Shared:UpdateSpeed', player.id, speed)
end)
