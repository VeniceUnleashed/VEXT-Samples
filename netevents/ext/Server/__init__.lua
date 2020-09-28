-- Function to handle on player join
function OnPlayerAuthenticated(player)
    NetEvents:SendToLocal('TestNetEvents', player) -- trigger the net event for the 'player' client without any arguments
    -- we can as well send the event to everyone else
    -- broadcast the event to everyone present in the server and pass the player name as an argument
    NetEvents:BroadcastLocal('NotifyAllOnPlayerJoin', player.name) -- no target argument its broadcast event
end

function ConfirmrNetEventDelivery(player)
    print("[SERVER]: "..player.name.." has recevied the event, and now its confirmed to the server")
end

-- Subscribe to the native event of player joining a server
Events:Subscribe('Player:Authenticated', OnPlayerAuthenticated)

-- Subscribe to the NetEvent of receving confirmation from the client
NetEvents:Subscribe('ConfirmToServerNetEventDelivery', ConfirmrNetEventDelivery)