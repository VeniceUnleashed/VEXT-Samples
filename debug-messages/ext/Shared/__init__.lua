Events:Subscribe('Engine:Message', function(message)
	local messageType = ""
	local messageCategory = ""
	for k,v in pairs(MessageCategory) do
		if v == message.category then
			messageCategory = k
		end
	end
	for k,v in pairs(MessageType) do
		if v == message.type then
			messageType = k
		end
	end
	print(messageCategory .. " | " .. messageType)
end)