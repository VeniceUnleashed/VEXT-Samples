Events:Subscribe('br:play', function(data)
	local replayer = Replayer(deserializeRecordingDataFromBase64(data))
	replayer:play()
end)
