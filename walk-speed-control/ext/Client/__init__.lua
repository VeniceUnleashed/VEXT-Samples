Events:Subscribe('Client:UpdateInput', function(dt)
	-- Get mouse wheel increase or decrease. GetLevel returns an int that can be negative with the
	-- amount of wheel steps (-2, -1, 0, 1, etc) 
	local mouseWheel = InputManager:GetLevel(InputConceptIdentifiers.ConceptFreeCameraSwitchSpeed)
	if mouseWheel == 0.0 then
		return
	end

	-- Send it to server with our custom NetEvent.
	NetEvents:SendLocal('Server:UpdateSpeed', mouseWheel)
end)