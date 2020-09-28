function TestNetEvent()
    print("[CLIENT]: I recevied the event.") -- print to demonstrate that the client recevied the event
    
    local localPlayer = PlayerManager:GetLocalPlayer() -- get the local client player
    NetEvents:SendLocal('ConfirmToServerNetEventDelivery', localPlayer) -- Client side way of sending net events to the server, passing as an argument the local player
end

function OnPlayerJoin(name)
    print("[CLIENT]: "..name.." Joined the server") -- print to demonstrate that the client recevied the event
end

-- Subscribe to the net event so the function given in the second argument handle it
NetEvents:Subscribe('NotifyAllOnPlayerJoin', OnPlayerJoin)

-- Subscribe to the net event so the function given in the second argument handle it
NetEvents:Subscribe('TestNetEvents', TestNetEvent)