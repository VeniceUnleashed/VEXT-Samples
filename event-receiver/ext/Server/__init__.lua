Events:Subscribe('test:1', function() 
	print("Received test 1 event in Receiver mod.")
end)

Events:Subscribe('test:2', function(s) 
	print("Received test 2 event in Receiver mod. String received: " .. s)
end)

Events:Subscribe('test:3', function(guid) 
	print("Received test 3 event in Receiver mod. Guid received: " .. guid)
end)