class('IngameSpectator')

function IngameSpectator:__init()
	self._allowSpectateAll = true
	self._spectatedPlayer = nil
	self._firstPerson = true
	self._freecamTrans = LinearTransform()

	-- TODO: Third person camera

	Events:Subscribe('Extension:Unloading', self, self.disable)
	Events:Subscribe('Player:Respawn', self, self._onPlayerRespawn)
	Events:Subscribe('Player:Killed', self, self._onPlayerKilled)
	Events:Subscribe('Player:Deleted', self, self._onPlayerDeleted)
end

function IngameSpectator:_onPlayerRespawn(player)
	if not self:isEnabled() then
		return
	end

	-- Disable spectator when the local player spawns.
	local localPlayer = PlayerManager:GetLocalPlayer()

	if localPlayer == player then
		self:disable()
		return
	end

	-- If we have nobody to spectate and this player is spectatable
	-- then switch to them.
	if self._spectatedPlayer == nil then
		if not self._allowSpectateAll and player.teamId ~= localPlayer.teamId then
			return
		end

		self:spectatePlayer(player)
	end
end

function IngameSpectator:_onPlayerKilled(player)
	if not self:isEnabled() then
		return
	end

	-- Handle death of player being spectated.
	if player == self._spectatedPlayer then
		self:spectateNextPlayer()
	end
end

function IngameSpectator:_onPlayerDeleted(player)
	if not self:isEnabled() then
		return
	end

	-- Handle disconnection of player being spectated.
	if player == self._spectatedPlayer then
		self:spectateNextPlayer()
	end
end

function IngameSpectator:_findFirstPlayerToSpectate()
	local playerToSpectate = nil
	local players = PlayerManager:GetPlayers()
	local localPlayer = PlayerManager:GetLocalPlayer()

	for _, player in pairs(players) do
		-- We don't want to spectate the local player.
		if player == localPlayer then
			goto continue_enable
		end

		-- We don't want to spectate players who are dead.
		if player.soldier == nil then
			goto continue_enable
		end

		-- If we don't allow spectating everyone we should check the
		-- player's team to determine if we can spectate them.
		if not self._allowSpectateAll and player.teamId ~= localPlayer.teamId then
			goto continue_enable
		end

		-- Otherwise we're good to spectate this player.
		playerToSpectate = player
		break

		::continue_enable::
	end

	return playerToSpectate
end

function IngameSpectator:getFreecamTransform()
	return self._freecamTrans
end

function IngameSpectator:setFreecamTransform(trans)
	self._freecamTrans = trans

	if self:isEnabled() and self._spectatedPlayer == nil then
		SpectatorManager:SetFreecameraTransform(self._freecamTrans)
	end
end

function IngameSpectator:getAllowSpectateAll()
	return self._allowSpectateAll
end

function IngameSpectator:setAllowSpectateAll(allowSpectateAll)
	local prevSpectateAll = self._allowSpectateAll
	self._allowSpectateAll = allowSpectateAll

	-- If we no longer allow spectating everyone we will need to make sure
	-- that the player we're currently spectating is in the same team as us.
	if prevSpectateAll ~= allowSpectateAll and self:isEnabled() and not allowSpectateAll then
		local localPlayer = PlayerManager:GetLocalPlayer()

		-- If they're not we'll try to find one we can spectate and switch
		-- to them. If we can't, we'll just switch to freecam.
		if localPlayer.teamId ~= self._spectatedPlayer.teamId then
			local playerToSpectate = self:_findFirstPlayerToSpectate()

			if playerToSpectate == nil then
				self:switchToFreecam()
			else
				self:spectatePlayer(playerToSpectate)
			end
		end
	end
end

function IngameSpectator:getFirstPerson()
	return self._firstPerson
end

function IngameSpectator:setFirstPerson(firstPerson)
	local prevFirstPerson = self._firstPerson
	self._firstPerson = firstPerson

	-- If we're enabled and we switched modes then we also need to switch
	-- spectating modes. We do this just by calling the spectatePlayer
	-- function and it should handle the rest automatically.
	if prevFirstPerson ~= firstPerson and self:isEnabled() and self._spectatedPlayer ~= nil then
		self:spectatePlayer(self._spectatedPlayer)
	end
end

function IngameSpectator:enable()
	if self:isEnabled() then
		return
	end

	-- If we're alive we don't allow spectating.
	local localPlayer = PlayerManager:GetLocalPlayer()

	if localPlayer.soldier ~= nil then
		return
	end

	SpectatorManager:SetSpectating(true)

	local playerToSpectate = self:_findFirstPlayerToSpectate()

	if playerToSpectate ~= nil then
		self:spectatePlayer(playerToSpectate)
		return
	end

	-- If we found no player to spectate then just do freecam.
	self:switchToFreecam()
end

function IngameSpectator:disable()
	if not self:isEnabled() then
		return
	end

	SpectatorManager:SetSpectating(false)

	self._spectatedPlayer = nil
end

function IngameSpectator:spectatePlayer(player)
	if not self:isEnabled() then
		return
	end

	if player == nil then
		self:switchToFreecam()
		return
	end

	local localPlayer = PlayerManager:GetLocalPlayer()

	-- We can't spectate the local player.
	if localPlayer == player then
		return
	end

	-- If we don't allow spectating everyone make sure that this player
	-- is in the same team as the local player.
	if not self._allowSpectateAll and localPlayer.teamId ~= player.teamId then
		return
	end

	print('Spectating player')
	print(player)

	self._spectatedPlayer = player
	SpectatorManager:SpectatePlayer(self._spectatedPlayer, self._firstPerson)
end

function IngameSpectator:spectateNextPlayer()
	if not self:isEnabled() then
		return
	end

	-- If we are not spectating anyone just find the first player to spectate.
	if self._spectatedPlayer == nil then
		local playerToSpectate = self:_findFirstPlayerToSpectate()

		if playerToSpectate ~= nil then
			self:spectatePlayer(playerToSpectate)
		end

		return
	end

	-- Find the index of the current player.
	local currentIndex = 0
	local players = PlayerManager:GetPlayers()
	local localPlayer = PlayerManager:GetLocalPlayer()

	for i, player in players do
		if player == self._spectatedPlayer then
			currentIndex = i
			break
		end
	end

	-- Increment so we start from the next player.
	currentIndex = currentIndex + 1

	if currentIndex > #players then
		currentIndex = 1
	end

	-- Find the next player we can spectate.
	local nextPlayer = nil

	for i = 1, #players do
		local playerIndex = (i - 1) + currentIndex

		if playerIndex > #players then
			playerIndex = playerIndex - #players
		end

		local player = players[playerIndex]

		if player.soldier ~= nil and player ~= localPlayer and (self._allowSpectateAll or player.teamId == localPlayer.teamId) then
			nextPlayer = player
			break
		end
	end

	-- If we didn't find any players to spectate then switch to freecam.
	if nextPlayer == nil then
		self:switchToFreecam()
	else
		self:spectatePlayer(nextPlayer)
	end
end

function IngameSpectator:spectatePreviousPlayer()
	if not self:isEnabled() then
		return
	end

	-- If we are not spectating anyone just find the first player to spectate.
	if self._spectatedPlayer == nil then
		local playerToSpectate = self:_findFirstPlayerToSpectate()

		if playerToSpectate ~= nil then
			self:spectatePlayer(playerToSpectate)
		end

		return
	end

	-- Find the index of the current player.
	local currentIndex = 0
	local players = PlayerManager:GetPlayers()
	local localPlayer = PlayerManager:GetLocalPlayer()

	for i, player in players do
		if player == self._spectatedPlayer then
			currentIndex = i
			break
		end
	end

	-- Decrement so we start from the previous player.
	currentIndex = currentIndex - 1

	if currentIndex <= 0 then
		currentIndex = #players
	end

	-- Find the previous player we can spectate.
	local nextPlayer = nil

	for i = #players, 1, -1 do
		local playerIndex = (i - (#players - currentIndex))

		if playerIndex <= 0 then
			playerIndex = playerIndex + #players
		end

		local player = players[playerIndex]

		if player.soldier ~= nil and player ~= localPlayer and (self._allowSpectateAll or player.teamId == localPlayer.teamId) then
			nextPlayer = player
			break
		end
	end

	-- If we didn't find any players to spectate then switch to freecam.
	if nextPlayer == nil then
		self:switchToFreecam()
	else
		self:spectatePlayer(nextPlayer)
	end
end

function IngameSpectator:switchToFreecam()
	if not self:isEnabled() then
		return
	end

	print('Switching to freecam.')

	self._spectatedPlayer = nil

	SpectatorManager:SetCameraMode(SpectatorCameraMode.FreeCamera)
	SpectatorManager:SetFreecameraTransform(self._freecamTrans)
end

function IngameSpectator:isEnabled()
	return SpectatorManager:GetSpectating()
end

if g_IngameSpectator == nil then
	g_IngameSpectator = IngameSpectator()
end

return g_IngameSpectator
