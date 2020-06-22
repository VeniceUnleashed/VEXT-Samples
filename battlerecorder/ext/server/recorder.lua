Recorder = class('Recorder')

StartRecordingResult = {
	STARTED = 0,
	ALREADY_RECORDING = 1,
	NO_LEVEL = 2,
}

function Recorder:__init()
	self._recording = false
	self._currentTick = 0
	self._playerIdCounter = 0
	self._recordedEvents = {}
	self._trackedPlayers = {}
	self._snapshotTimer = 0
	self._lastPlayerInputs = {}
	self._trackedVehicles = {}

	self:_registerEvents()
	self:_registerHooks()
end

function Recorder:_registerEvents()
	Events:Subscribe('UpdateManager:Update', self, self._onUpdate)
	Events:Subscribe('Player:Respawn', self, self._onPlayerSpawn)
	Events:Subscribe('Player:SetSquadLeader', self, self._onPlayerSetSquadLeader)
	Events:Subscribe('Player:SquadChange', self, self._onPlayerSquadChange)
	Events:Subscribe('Player:TeamChange', self, self._onPlayerTeamChange)
	Events:Subscribe('Vehicle:SpawnDone', self, self._onVehicleSpawned)
	Events:Subscribe('Vehicle:Enter', self, self._onVehicleEntered)
	Events:Subscribe('Vehicle:Exit', self, self._onVehicleExited)
	Events:Subscribe('Vehicle:Destroyed', self, self._onVehicleDestroyed)

	-- TODO: Stop recording when level is unloading.
end

function Recorder:_registerHooks()
	Hooks:Install('Soldier:Damage', 999, self, self._onSoldierDamage)
end

function Recorder:_onSoldierDamage(hook, soldier, damageInfo, damageGiverInfo)
	if not self._recording then
		return
	end

	if soldier.player == nil then
		return
	end

	local playerId = self._trackedPlayers[soldier.player.id]

	if playerId == nil then
		return
	end

	self:_record(EventType.PLAYER_DAMAGED, {
		id = playerId,
		damage = damageInfo.damage,
		pos = damageInfo.position:Clone(),
		dir = damageInfo.direction:Clone(),
		origin = damageInfo.origin:Clone(),
		distr = damageInfo.distributeDamageOverTime,
		emp = damageInfo.empTime,
		speed = damageInfo.collisionSpeed,
		bone = damageInfo.boneIndex,
		demo = damageInfo.isDemolitionDamage,
		child = damageInfo.includeChildren,
		expl = damageInfo.isExplosionDamage,
		bullet = damageInfo.isBulletDamage,
	})
end

function Recorder:_onVehicleDestroyed(vehicle)
	if not self._recording then
		return
	end

	vehicle = ControllableEntity(vehicle)

	if self._trackedVehicles[vehicle.instanceId] == nil then
		return
	end

	self._trackedVehicles[vehicle.instanceId] = nil

	self:_record(EventType.VEHICLE_DESTROYED, {
		id = vehicle.instanceId,
	})
end

function Recorder:_onVehicleEntered(vehicle, player)
	if not self._recording then
		return
	end

	vehicle = ControllableEntity(vehicle)

	if self._trackedVehicles[vehicle.instanceId] == nil then
		return
	end

	-- Find the entry this player is in.
	local foundEntryId = nil

	for entryId = 0, vehicle.entryCount - 1 do
		if vehicle:GetPlayerInEntry(entryId) == player then
			foundEntryId = entryId
			break
		end
	end

	if foundEntryId == nil then
		print('Could not find the entry this player is in.')
		return
	end

	self:_record(EventType.PLAYER_ENTER_VEHICLE, {
		id = self._trackedPlayers[player.id],
		vehicle = vehicle.instanceId,
		entry = foundEntryId,
	})
end

function Recorder:_onVehicleExited(vehicle, player)
	if not self._recording then
		return
	end

	vehicle = ControllableEntity(vehicle)

	if self._trackedVehicles[vehicle.instanceId] == nil then
		return
	end

	self:_record(EventType.PLAYER_EXIT_VEHICLE, {
		id = self._trackedPlayers[player.id],
		vehicle = vehicle.instanceId,
	})
end

function Recorder:_onVehicleSpawned(vehicle)
	if not self._recording then
		return
	end

	--[[if vehicle.bus == nil or vehicle.bus.parentRepresentative == nil then
		print(vehicle.bus)
		print(vehicle.bus.parentRepresentative)
		print('A vehicle was spawned without a bus or parent representative.')
		return
	end

	local vehicleBp = nil

	if vehicle.bus.parentRepresentative:Is('ReferenceObjectData') then
		vehicleBp = ReferenceObjectData(vehicle.bus.parentRepresentative).blueprint
	elseif vehicle.bus.parentRepresentative:Is('VehicleBlueprint') then
		vehicleBp = Blueprint(vehicle.bus.parentRepresentative)
	else
		print('Unrecognized parent data for spawned vehicle.')
		print(vehicle.bus.parentRepresentative)
		return
	end

	if vehicleBp.instanceGuid == nil then
		print('Vehicle spawned without an instance GUID.')
		return
	end]]

	if vehicle.data == nil then
		print('Vehicle has no data.')
		return
	end

	local partition = vehicle.data.partition

	if partition == nil then
		print('Vehicle data does not belong to a partition.')
		return
	end

	local primaryInstance = partition.primaryInstance

	if not primaryInstance:Is('VehicleBlueprint') then
		print('Could not find vehicle blueprint for a vehicle that just spawned.')
		return
	end

	local vehicleBp = Blueprint(primaryInstance)

	-- Cast to the right type and start tracking it.
	vehicle = ControllableEntity(vehicle)
	self._trackedVehicles[vehicle.instanceId] = vehicle

	-- Record spawn event.
	self:_record(EventType.VEHICLE_SPAWNED, {
		id = vehicle.instanceId,
		bp = vehicleBp.instanceGuid:Clone(),
		hp = vehicle.internalHealth,
		lv = vehicle.physicsEntityBase.linearVelocity,
		av = vehicle.physicsEntityBase.angularVelocity,
		pos = vehicle.transform:Clone(),
	})
end

function Recorder:_onPlayerSetSquadLeader(player)
	if not self._recording then
		return
	end

	self:_record(EventType.PLAYER_SET_SQUAD_LEADER, {
		id = self._trackedPlayers[player.id],
	})
end

function Recorder:_onPlayerSquadChange(player, squadId)
	if not self._recording then
		return
	end

	self:_record(EventType.PLAYER_SWITCH_SQUAD, {
		id = self._trackedPlayers[player.id],
		squad = squadId,
	})
end

function Recorder:_onPlayerTeamChange(player, teamId)
	if not self._recording then
		return
	end

	self:_record(EventType.PLAYER_SWITCH_TEAM, {
		id = self._trackedPlayers[player.id],
		team = teamId,
	})
end

function Recorder:_onPlayerSpawn(player)
	if not self._recording then
		return
	end

	if player.customization == nil then
		print('Player spawned with no customization. Cannot record.')
		return
	end

	if player.customization.instanceGuid == nil then
		print('Player spawned with unregistered customization asset. Cannot record.')
		return
	end

	-- Collect unlock GUIDs.
	local playerUnlocks = {}
	local visualUnlocks = {}
	local weapons = {}

	for _, unlock in pairs(player.selectedUnlocks) do
		if unlock.instanceGuid ~= nil then
			table.insert(playerUnlocks, unlock.instanceGuid:Clone())
		end
	end

	for _, unlock in pairs(player.visualUnlocks) do
		if unlock.instanceGuid ~= nil then
			table.insert(visualUnlocks, unlock.instanceGuid:Clone())
		end
	end

	for i, weapon in pairs(player.weapons) do
		if weapon == nil or weapon.instanceGuid == nil then
			weapons[i] = nil
		else
			local weaponUnlocks = {}

			for _, unlock in pairs(player.weaponUnlocks[i]) do
				if unlock.instanceGuid ~= nil then
					table.insert(weaponUnlocks, unlock.instanceGuid:Clone())
				end
			end

			weapons[i] = {
				weapon.instanceGuid:Clone(),
				weaponUnlocks,
			}
		end
	end

	-- TODO: Record health
	self:_record(EventType.PLAYER_SPAWNED, {
		id = self._trackedPlayers[player.id],
		customization = player.customization.instanceGuid:Clone(),
		unlocks = playerUnlocks,
		visual = visualUnlocks,
		weapons = weapons,
		pos = player.soldier.transform:Clone(),
		pose = player.soldier.pose,
	})
end

function Recorder:_recordPlayerCreated(player)
	local recordingPlayerId = self._playerIdCounter
	self._playerIdCounter = self._playerIdCounter + 1

	self._trackedPlayers[player.id] = recordingPlayerId

	self:_record(EventType.PLAYER_CREATED, {
		name = player.name,
		id = recordingPlayerId,
		team = player.teamId,
		squad = player.squadId,
		leader = player.isSquadLeader,
	})

	self._lastPlayerInputs[recordingPlayerId] = {
		levels = {},
		yaw = 0.0,
		pitch = 0.0,
		pose = CharacterPoseType.CharacterPoseType_Stand,
		pendingPose = CharacterPoseType.CharacterPoseType_Stand,
	}

	for i = EntryInputActionEnum.EIAThrottle, EntryInputActionEnum.EIAQuicktimeCrouchDuck do
		self._lastPlayerInputs[recordingPlayerId].levels[i] = 0.0
	end

	if player.soldier ~= nil then
		self:_onPlayerSpawn(player)
	end

	if player.input ~= nil then
		self:_processPlayerInput(player)
	end

	-- TODO: If this player is inside a vehicle record an enter event.
end

function Recorder:_recordPlayerDestroyed(playerId)
	self:_record(EventType.PLAYER_DESTROYED, {
		id = self._trackedPlayers[playerId],
	})

	self._trackedPlayers[playerId] = nil
end

function Recorder:_processPlayersJoiningLeaving()
	local players = PlayerManager:GetPlayers()

	-- Create any players we haven't seen before.
	for _, player in pairs(players) do
		if self._trackedPlayers[player.id] == nil then
			self:_recordPlayerCreated(player)
		end
	end

	-- Destroy any players that have left.
	for id, recordingId in pairs(self._trackedPlayers) do
		if recordingId ~= nil and PlayerManager:GetPlayerById(id) == nil then
			self:_recordPlayerDestroyed(id)
		end
	end
end

function Recorder:_processPlayerInput(player)
	if player.input == nil then
		return
	end

	local recordingPlayerId = self._trackedPlayers[player.id]

	local inputsChanged = false
	local levelsChanged = false
	local changedInputs = {
		levels = {},
	}

	local prevInputs = self._lastPlayerInputs[recordingPlayerId]

	if player.soldier ~= nil and player.soldier.pendingPose ~= prevInputs.pendingPose then
		changedInputs.pendingPose = player.soldier.pendingPose
		prevInputs.pendingPose = changedInputs.pendingPose
		inputsChanged = true
	end

	if player.soldier ~= nil and player.soldier.pose ~= prevInputs.pose then
		changedInputs.pose = player.soldier.pose
		prevInputs.pose = changedInputs.pose
		inputsChanged = true
	end

	if not MathUtils:Approximately(player.input.authoritativeAimingYaw, prevInputs.yaw) then
		changedInputs.yaw = player.input.authoritativeAimingYaw
		prevInputs.yaw = changedInputs.yaw
		inputsChanged = true
	end

	if not MathUtils:Approximately(player.input.authoritativeAimingPitch, prevInputs.pitch) then
		changedInputs.pitch = player.input.authoritativeAimingPitch
		prevInputs.pitch = changedInputs.pitch
		inputsChanged = true
	end

	for i = EntryInputActionEnum.EIAThrottle, EntryInputActionEnum.EIAQuicktimeCrouchDuck do
		local currentLevel = player.input:GetLevel(i)

		if not MathUtils:Approximately(prevInputs.levels[i], currentLevel) then
			changedInputs.levels[i] = currentLevel
			prevInputs.levels[i] = currentLevel
			inputsChanged = true
			levelsChanged = true
		end
	end

	if not inputsChanged then
		return
	end

	if not levelsChanged then
		changedInputs.levels = nil
	end

	self:_record(EventType.PLAYER_INPUT_DELTA, {
		id = recordingPlayerId,
		input = changedInputs,
	})
end

function Recorder:_processInputDelta()
	for id, recordingId in pairs(self._trackedPlayers) do
		local player = PlayerManager:GetPlayerById(id)
		self:_processPlayerInput(player)
	end
end

function Recorder:_performSnapshot()
	local snapshot = {
		players = {},
		vehicles = {},
	}

	local hasPlayerData = false
	local hasVehicleData = false

	for id, vehicle in pairs(self._trackedVehicles) do
		snapshot.vehicles[id] = {
			hp = vehicle.internalHealth,
			lv = vehicle.physicsEntityBase.linearVelocity,
			av = vehicle.physicsEntityBase.angularVelocity,
			pos = vehicle.transform:Clone(),
		}

		hasVehicleData = true
	end

	for id, recordingId in pairs(self._trackedPlayers) do
		local playerData = {}

		local player = PlayerManager:GetPlayerById(id)

		if player.soldier ~= nil then
			playerData.pos = player.soldier.transform
			playerData.pose = player.soldier.pose
		end

		snapshot.players[recordingId] = playerData
		hasPlayerData = true
	end

	if not hasPlayerData and not hasVehicleData then
		return
	end

	if not hasPlayerData then
		snapshot.players = nil
	end

	if not hasVehicleData then
		snapshot.vehicles = nil
	end

	self:_record(EventType.RECORDING_SNAPSHOT, snapshot)
end

function Recorder:_onUpdate(dt, pass)
	if pass ~= UpdatePass.UpdatePass_PostFrame then
		return
	end

	if not self._recording then
		return
	end

	self:_processPlayersJoiningLeaving()
	self:_processInputDelta()

	self._snapshotTimer = self._snapshotTimer + dt

	if self._snapshotTimer >= 1.0 then
		self._snapshotTimer = 0.0
		self:_performSnapshot()
	end

	self._currentTick = self._currentTick + 1
end

function Recorder:_record(eventType, eventData)
	if eventData == nil then
		eventData = {}
	end

	eventData.type = eventType

	if self._recordedEvents[self._currentTick] == nil then
		self._recordedEvents[self._currentTick] = {}
	end

	table.insert(self._recordedEvents[self._currentTick], eventData)
end

-- Public API

function Recorder:startRecording()
	if self._recording then
		return StartRecordingResult.ALREADY_RECORDING
	end

	local levelName = SharedUtils:GetLevelName()
	local gameMode = SharedUtils:GetCurrentGameMode()

	if levelName == nil or gameMode == nil then
		return StartRecordingResult.NO_LEVEL
	end

	self._currentTick = 0
	self._trackedPlayers = {}
	self._recordedEvents = {}
	self._recording = true
	self._playerIdCounter = 0
	self._snapshotTimer = 0
	self._lastPlayerInputs = {}
	self._trackedVehicles = {}

	self:_record(EventType.RECORDING_STARTED, {
		level = levelName,
		mode = gameMode,
		tickrate = SharedUtils:GetTickrate(),
	})

	-- Spawn all vehicles currently in the level.
	local iterator = EntityManager:GetIterator('ServerVehicleEntity')

	local vehicle = iterator:Next()

	while vehicle ~= nil do
		self:_onVehicleSpawned(vehicle)
		vehicle = iterator:Next()
	end

	return StartRecordingResult.STARTED
end

function Recorder:stopRecording()
	if not self._recording then
		return false
	end

	self:_record(EventType.RECORDING_ENDED)

	self._recording = false

	return true
end

function Recorder:getRecordedEvents()
	return self._recordedEvents
end

function Recorder:isRecording()
	return self._recording
end
