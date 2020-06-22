local Bots = require('bots')

Replayer = class('Replayer')

function Replayer:__init(replayData)
	self._data = replayData
	self._currentTick = 0
	self._players = {}
	self._playerIdToReplayId = {}
	self._vehicles = {}
	self._playing = false

	-- We add this to the real bone index when applying damage so our hook can differentiate
	-- between world-applied damage and replay-applied damage. This is a bit hacky but it works.
	self._boneStartIndex = 1337

	if self._data[0] == nil or #self._data[0] == 0 then
		error('Invalid replay data provided.')
		return
	end

	if self._data[0][1].type ~= EventType.RECORDING_STARTED then
		error('Invalid replay data provided.')
		return
	end

	if self._data[0][1].tickrate ~= SharedUtils:GetTickrate() then
		error('Server is running at a different tickrate than what this replay was recorded in.')
		return
	end

	self:_registerEvents()
	self:_registerHooks()

	-- Register our recording event handlers.
	self._eventHandlers = {
		[EventType.RECORDING_STARTED] = self._eventRecordingStarted,
		[EventType.RECORDING_SNAPSHOT] = self._eventRecordingSnapshot,
		[EventType.RECORDING_ENDED] = self._eventRecordingEnded,

		[EventType.PLAYER_CREATED] = self._eventPlayerCreated,
		[EventType.PLAYER_DESTROYED] = self._eventPlayerDestroyed,
		[EventType.PLAYER_SPAWNED] = self._eventPlayerSpawned,
		[EventType.PLAYER_DIED] = self._eventPlayerDied,
		[EventType.PLAYER_INPUT_DELTA] = self._eventPlayerInputDelta,
		[EventType.PLAYER_DAMAGED] = self._eventPlayerDamaged,
		[EventType.PLAYER_ENTER_VEHICLE] = self._eventPlayerEnterVehicle,
		[EventType.PLAYER_EXIT_VEHICLE] = self._eventPlayerExitVehicle,
		[EventType.PLAYER_SWITCH_TEAM] = self._eventPlayerSwitchTeam,
		[EventType.PLAYER_SWITCH_SQUAD] = self._eventPlayerSwitchSquad,
		[EventType.PLAYER_SET_SQUAD_LEADER] = self._eventPlayerSetSquadLeader,

		[EventType.VEHICLE_SPAWNED] = self._eventVehicleSpawned,
		[EventType.VEHICLE_DESTROYED] = self._eventVehicleDestroyed,
		[EventType.VEHICLE_DAMAGED] = self._eventVehicleDamaged,
	}
end

function Replayer:_registerEvents()
	Events:Subscribe('UpdateManager:Update', self, self._onUpdate)
end

function Replayer:_registerHooks()
	Hooks:Install('Soldier:Damage', 999, self, self._onSoldierDamage)
end

function Replayer:_onSoldierDamage(hook, soldier, damageInfo, damageGiverInfo)
	if not self._playing then
		return
	end

	if soldier.player == nil then
		return
	end

	-- We are only interested in replayer-created players.
	local playerId = self._playerIdToReplayId[soldier.player.id]

	if playerId == nil then
		return
	end

	-- Prevent replay soldiers from taking damage unless the replayer applied it.
	if damageInfo.boneIndex < self._boneStartIndex - 1 then
		hook:Return()
		return
	end

	-- Otherwise fixup the bone index and apply.
	damageInfo.boneIndex = damageInfo.boneIndex - self._boneStartIndex
	hook:Pass(soldier, damageInfo, damageGiverInfo)
end

function Replayer:_onUpdate(dt, pass)
	if pass ~= UpdatePass.UpdatePass_PreFrame then
		return
	end

	if not self._playing then
		return
	end

	local currentTickEvents = self._data[self._currentTick]

	if currentTickEvents ~= nil then
		for _, event in pairs(currentTickEvents) do
			local eventHandler = self._eventHandlers[event.type]

			if eventHandler == nil then
				print('No event handler is registered for event ' .. tostring(event.type))
			else
				eventHandler(self, event)
			end
		end
	end

	self._currentTick = self._currentTick + 1
end

function Replayer:_eventRecordingStarted(event)
	-- TODO
end

function Replayer:_eventRecordingSnapshot(event)
	if event.players ~= nil then
		for id, data in pairs(event.players) do
			local player = self._players[id]

			if data.pos ~= nil then
				player.soldier.transform = LinearTransform(data.pos)
			end

			if data.pose ~= nil then
				player.soldier:SetPose(data.pose, true, true)
			end
		end
	end

	if event.vehicles ~= nil then
		for id, data in pairs(event.vehicles) do
			local vehicle = self._vehicles[id]

			if data.hp ~= nil then
				vehicle.internalHealth = data.hp
			end

			if data.lv ~= nil then
				vehicle.physicsEntityBase.linearVelocity = Vec3(data.lv)
			end

			if data.av ~= nil then
				vehicle.physicsEntityBase.angularVelocity = Vec3(data.av)
			end

			if data.pos ~= nil then
				vehicle.transform = LinearTransform(data.pos)
			end
		end
	end
end

function Replayer:_eventRecordingEnded(event)
	self:stop()
end

function Replayer:_eventPlayerCreated(event)
	self._players[event.id] = Bots:createBot(event.name, event.team, event.squad)
	self._playerIdToReplayId[self._players[event.id].id] = event.id

	self._players[event.id].input.flags = EntryInputFlags.AuthoritativeAiming

	if event.leader then
		self._players[event.id]:SetSquadLeader(true, false)
	end
end

function Replayer:_eventPlayerDestroyed(event)
	self._playerIdToReplayId[self._players[event.id]] = nil

	Bots:destroyBot(self._players[event.id])
	self._players[event.id] = nil
end

function Replayer:_eventPlayerSpawned(event)
	local player = self._players[event.id]

	local soldierBp = ResourceManager:SearchForDataContainer('Characters/Soldiers/MpSoldier')
	local customization = ResourceManager:SearchForInstanceByGuid(Guid(event.customization))

	if customization == nil then
		print('Could not find customization for spawning player.')
		return
	end

	local visualUnlocks = {}

	for _, guid in pairs(event.visual) do
		local unlock = ResourceManager:SearchForInstanceByGuid(Guid(guid))

		if unlock == nil then
			print('Could not find visual unlock for spawning player.')
		else
			table.insert(visualUnlocks, unlock)
		end
	end

	-- TODO: Figure out how to set specializations.
	player:SelectUnlockAssets(customization, visualUnlocks)

	-- Create and spawn the soldier for this bot.
	local soldier = player:CreateSoldier(soldierBp, LinearTransform(event.pos))

	player:SpawnSoldierAt(soldier, LinearTransform(event.pos), event.pose)
	player:AttachSoldier(soldier)

	-- Set their weapons and unlocks.
	local customizationData = CustomizeSoldierData()
	customizationData.activeSlot = WeaponSlot.WeaponSlot_0
	customizationData.removeAllExistingWeapons = true

	for i, weaponData in pairs(event.weapons) do
		local weaponAsset = ResourceManager:SearchForInstanceByGuid(Guid(weaponData[1]))

		if weaponAsset == nil then
			print('Could not find data for weapon unlock.')
		else
			local weapon = UnlockWeaponAndSlot()

			weapon.weapon = SoldierWeaponUnlockAsset(weaponAsset)
			weapon.slot = i

			for _, guid in pairs(weaponData[2]) do
				local unlockAsset = ResourceManager:SearchForInstanceByGuid(Guid(guid))

				if unlockAsset == nil then
					print('Could not find unlock asset for weapon.')
				else
					weapon.unlockAssets:add(UnlockAsset(unlockAsset))
				end
			end

			customizationData.weapons:add(weapon)
		end
	end

	soldier:ApplyCustomization(customizationData)
end

function Replayer:_eventPlayerDied(event)
	-- TODO
end

function Replayer:_eventPlayerInputDelta(event)
	local player = self._players[event.id]

	if event.input.yaw ~= nil then
		player.input.authoritativeAimingYaw = event.input.yaw
	end

	if event.input.pitch ~= nil then
		player.input.authoritativeAimingPitch = event.input.pitch
	end

	if event.input.levels ~= nil then
		for action, level in pairs(event.input.levels) do
			player.input:SetLevel(action, level)
		end
	end

	if event.input.pose ~= nil and player.soldier ~= nil then
		player.soldier:SetPose(event.input.pose, true, true)
	end

	if event.input.pendingPose ~= nil and player.soldier ~= nil then
		player.soldier:SetPose(event.input.pendingPose, false, true)
	end
end

function Replayer:_eventPlayerDamaged(event)
	local player = self._players[event.id]

	local damageInfo = DamageInfo()
	damageInfo.damage = event.damage
	damageInfo.position = Vec3(event.pos)
	damageInfo.direction = Vec3(event.dir)
	damageInfo.origin = Vec3(event.origin)
	damageInfo.distributeDamageOverTime = event.distr
	damageInfo.empTime = event.emp
	damageInfo.collisionSpeed = event.speed
	damageInfo.boneIndex = event.bone + self._boneStartIndex
	damageInfo.isDemolitionDamage = event.demo
	damageInfo.includeChildren = event.child
	damageInfo.isExplosionDamage = event.expl
	damageInfo.isBulletDamage = event.bullet

	player.soldier:ApplyDamage(damageInfo)
end

function Replayer:_eventPlayerEnterVehicle(event)
	self._players[event.id]:EnterVehicle(self._vehicles[event.vehicle], event.entry)
end

function Replayer:_eventPlayerExitVehicle(event)
	self._players[event.id]:ExitVehicle(true, true)
end

function Replayer:_eventPlayerSwitchTeam(event)
	self._players[event.id].teamId = event.squad
end

function Replayer:_eventPlayerSwitchSquad(event)
	self._players[event.id].squadId = event.squad
end

function Replayer:_eventPlayerSetSquadLeader(event)
	self._players[event.id]:SetSquadLeader(true, false)
end

function Replayer:_eventVehicleSpawned(event)
	local vehicleBp = ResourceManager:SearchForInstanceByGuid(Guid(event.bp))

	if vehicleBp == nil then
		print('Could not find blueprint for vehicle to spawn.')
		return
	end

	local params = EntityCreationParams()

	params.transform = LinearTransform(event.pos)
	params.networked = true

	local bus = EntityManager:CreateEntitiesFromBlueprint(vehicleBp, params)

	if bus == nil then
		print('Could not spawn vehicle.')
		return
	end

	local vehicle = nil

	for _, entity in pairs(bus.entities) do
		entity:Init(Realm.Realm_ClientAndServer, true)

		if vehicle == nil and entity:Is('ServerVehicleEntity') then
			vehicle = entity
		end
	end

	-- Replicate properties.
	vehicle = ControllableEntity(vehicle)
	vehicle.internalHealth = event.hp
	vehicle.physicsEntityBase.linearVelocity = Vec3(event.lv)
	vehicle.physicsEntityBase.angularVelocity = Vec3(event.av)

	-- Make sure that people can't damage this vehicle.
	vehicle:RegisterDamageCallback(function(entity, damageInfo, damageGiverInfo)
		if damageInfo.boneIndex == 1337 then
			damageInfo.boneIndex = 0
			return true
		end

		return false
	end)

	-- Add to list of tracked vehicles.
	self._vehicles[event.id] = vehicle
end

function Replayer:_eventVehicleDestroyed(event)
	local vehicle = self._vehicles[event.id]

	if vehicle == nil then
		return
	end

	local damageInfo = DamageInfo()
	damageInfo.damage = 999999
	damageInfo.boneIndex = -1 + self._boneStartIndex

	vehicle:ApplyDamage(damageInfo)

	self._vehicles[event.id] = nil
end

function Replayer:_eventVehicleDamaged(event)
	-- TODO
end

function Replayer:play(loadLevel)
	if self._playing then
		return
	end

	if loadLevel then
		-- TODO: Load recording level and start playback once the level has loaded.
		return
	end

	if self._data[0][1].level ~= SharedUtils:GetLevelName() then
		print('Server is running a different level than what this replay was recorded in. This might cause playback issues.')
	end

	if self._data[0][1].mode ~= SharedUtils:GetCurrentGameMode() then
		print('Server is running a different gamemode than what this replay was recorded in. This might cause playback issues.')
	end

	self._currentTick = 0
	self._playing = true
end

function Replayer:stop()
	if not self._playing then
		return
	end

	self._playing = false

	-- Delete all players and vehicles
	for _, player in pairs(self._players) do
		Bots:destroyBot(player)
	end

	for _, vehicle in pairs(self._vehicles) do
		vehicle:Destroy()
	end

	self._players = {}
	self._playerIdToReplayId = {}
	self._vehicles = {}
end
