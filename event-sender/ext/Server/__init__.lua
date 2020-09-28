Events:Subscribe('Player:Chat', function(player, mask, message)
	if message == "test1" then
		Events:Dispatch('test:1')

	-- Events can send parameters.
	elseif message == "test2" then
		Events:Dispatch('test:2', 'test string')

	elseif message == "test3" then
		-- Events:Dispatch throws an event that can be catched by all loaded mods.
		Events:Dispatch('test:3', Guid('8D3FAB68-B78E-11E0-A405-EA03C5FF7246'))
		
	-- Events can be sent with more than one parameter.
	elseif message == "test4" then
		-- Events:DispatchLocal throws an event that can only be catched by the same mod that triggers it.
		Events:DispatchLocal('test:4', 'local mod event', Guid('8D3FAB68-B78E-11E0-A405-EA03C5FF7246'))

	elseif message == "test5" then
		Events:DispatchLocal('test:5', { 'test string', key = { guid = Guid('8D3FAB68-B78E-11E0-A405-EA03C5FF7246') }})
	end
end)

Events:Subscribe('test:3', function(guid)
	print('Received test 3 event in Sender mod. Guid received: '.. tostring(guid))
end)

Events:Subscribe('test:4', function(s, guid)
	print('Received test 4 local event in Sender mod. String received: ' .. s .. ', guid received: ' .. tostring(guid))
end)

Events:Subscribe('test:5', function(t)
	print('Received test 5 local event in Sender mod. Table received: ')
	print(t)
end)