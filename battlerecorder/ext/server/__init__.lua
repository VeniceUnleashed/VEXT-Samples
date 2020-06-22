require('event-type')
require('recorder')
require('replayer')
require('serialization')
require('api')

g_BattleRecorder = Recorder()
g_BattleReplayer = nil

RCON:RegisterCommand('battlerecorder.record', RemoteCommandFlag.RequiresLogin, function(_, args)
	if #args ~= 0 then
		return { 'InvalidArguments' }
	end

	local result = g_BattleRecorder:startRecording()

	if result == StartRecordingResult.STARTED then
		print('Recording has started!')
		return { 'OK' }
	elseif result == StartRecordingResult.NO_LEVEL then
		print('Cannot start recording. No level is currently loaded.')
		return { 'NoLevel' }
	elseif result == StartRecordingResult.ALREADY_RECORDING then
		print('Cannot start recording. A recording is already in-progress.')
		return { 'AlreadyRecording' }
	end
end)

RCON:RegisterCommand('battlerecorder.stop', RemoteCommandFlag.RequiresLogin, function(_, args)
	if #args ~= 0 then
		return { 'InvalidArguments' }
	end

	if not g_BattleRecorder:stopRecording() then
		return { 'NotRecording' }
	end

	print('Recording has ended.')
	return { 'OK' }
end)

RCON:RegisterCommand('battlerecorder.save', RemoteCommandFlag.RequiresLogin, function(_, args)
	if #args ~= 1 then
		return { 'InvalidArguments' }
	end

	local demoName = args[1]

	if #demoName == 0 then
		return { 'InvalidArguments' }
	end

	if g_BattleRecorder:isRecording() then
		return { 'CurrentlyRecording' }
	end

	local recordingData = g_BattleRecorder:getRecordedEvents()

	print(serializeRecordingDataToBase64(recordingData))

	return { 'OK' }
end)

RCON:RegisterCommand('battlerecorder.replay', RemoteCommandFlag.RequiresLogin, function(_, args)
	if g_BattleRecorder:isRecording() then
		return { 'CurrentlyRecording' }
	end

	local recordingData = g_BattleRecorder:getRecordedEvents()

	local serializedData = serializeRecordingDataToBase64(recordingData)
	local deserializedData = deserializeRecordingDataFromBase64(serializedData)

	g_BattleReplayer = Replayer(deserializedData)
	g_BattleReplayer:play()

	return { 'OK' }
end)

