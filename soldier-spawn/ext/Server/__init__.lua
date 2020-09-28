function SpawnPlayer(player)
	if player == nil then
		return
	elseif player.soldier ~= nil then
		-- The player must be dead if we want to spawn him somewhere so if he is already alive...we kill him.
		player.soldier:Kill(true)
	end

	-- We retrieve the weapon and attachment instances by their asset name.
	local weapon0    = ResourceManager:SearchForDataContainer('Weapons/M416/U_M416')
	local weaponAtt0 = ResourceManager:SearchForDataContainer('Weapons/M416/U_M416_ACOG')
	local weaponAtt1 = ResourceManager:SearchForDataContainer('Weapons/M416/U_M416_Silencer')


	local weapon1    = ResourceManager:SearchForDataContainer('Weapons/XP1_L85A2/U_L85A2')
	local weaponAtt2 = ResourceManager:SearchForDataContainer('Weapons/XP1_L85A2/U_L85A2_RX01')
	local weaponAtt3 = ResourceManager:SearchForDataContainer('Weapons/XP1_L85A2/U_L85A2_Silencer')

	
	player:SelectWeapon(WeaponSlot.WeaponSlot_0, weapon0, { weaponAtt0, weaponAtt1 })
	player:SelectWeapon(WeaponSlot.WeaponSlot_1, weapon1, { weaponAtt2, weaponAtt3 })

	-- Setting soldier class and appearance
	local soldierAsset = ResourceManager:SearchForDataContainer('Gameplay/Kits/RURecon')
	local appearance   = ResourceManager:SearchForDataContainer('Persistence/Unlocks/Soldiers/Visual/MP/RU/MP_RU_Recon_Appearance_DrPepper')
	player:SelectUnlockAssets(soldierAsset, { appearance })

	-- Creating soldier
	local soldierBlueprint = ResourceManager:SearchForDataContainer('Characters/Soldiers/MpSoldier')
	
	local transform = LinearTransform(
		Vec3(1, 0, 0),
		Vec3(0, 1, 0),
		Vec3(0, 0, 1),
		Vec3(0, 200, 0)
	)

	local soldier = player:CreateSoldier(soldierBlueprint, transform)

	if soldier == nil then
		print('Failed to create player soldier')
		return
	end

	-- Spawning soldier
	player:SpawnSoldierAt(soldier, transform, CharacterPoseType.CharacterPoseType_Stand)
end

-- The following function "Subscribes" to the Chat event so whenever a message is sent this function will be executed
Events:Subscribe('Player:Chat', function(player, recipientMask, message)
	if message == '!spawn' then
		SpawnPlayer(player)
	end
end)