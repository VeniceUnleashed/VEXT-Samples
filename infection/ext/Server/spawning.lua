local startingSpawns = {
	Vec3(8.411133, 174.783981, 12.074219),
	Vec3(4.420898, 174.783981, 12.619141),
	Vec3(0.973633, 174.783981, 12.679688),
	Vec3(0.604492, 174.783981, 15.330078),
	Vec3(0.346680, 174.783981, 17.389648),
	Vec3(-0.537109, 174.783981, 19.846680),
	Vec3(3.312500, 174.783981, 21.451172),
	Vec3(6.285156, 174.783981, 19.385742),
	Vec3(8.267578, 174.783981, 16.473633),
	Vec3(17.282227, 174.778122, 16.716797),
	Vec3(18.734375, 174.783981, 13.456055),
	Vec3(21.324219, 174.783981, 17.725586),
	Vec3(20.374023, 174.753708, 21.375977),
	Vec3(20.301758, 174.798630, 26.605469),
	Vec3(17.233398, 174.798630, 25.684570),
	Vec3(14.247070, 174.806442, 25.782227),
	Vec3(12.339844, 174.806442, 27.223633),
	Vec3(9.010742, 174.806442, 27.239258),
	Vec3(19.381836, 174.829880, 30.116211),
	Vec3(25.473633, 174.826950, 31.007813),
	Vec3(31.248047, 174.783981, 22.708008),
	Vec3(34.916016, 174.782059, 22.880859),
	Vec3(24.441406, 175.066238, -1.053711),
	Vec3(8.951172, 174.792770, 6.980469),
	Vec3(5.687500, 174.792770, 7.344727),
	Vec3(9.173828, 174.792770, 1.340820),
	Vec3(-8.776367, 174.783981, 24.555664),
	Vec3(-8.310547, 174.842575, 10.413086),
	Vec3(3.417969, 177.561325, 31.780273),
	Vec3(16.948242, 174.761520, 1.848633),
}

local infectedSpawns = {
	Vec3(9.149414, 174.783005, 17.848633),
	Vec3(11.160156, 174.839645, -32.341797),
	Vec3(1.242188, 176.051559, -73.188477),
	Vec3(-23.529297, 174.924606, -20.969727),
	Vec3(-39.224609, 175.347458, -0.551758),
	Vec3(-107.467789, 176.167770, 19.810528),
	Vec3(-98.983398, 174.822067, -19.773438),
	Vec3(-85.648438, 177.477341, -57.364258),
	Vec3(-107.502930, 169.815231, -73.352539),
	Vec3(-77.094727, 175.175583, -87.832031),
	Vec3(-25.852539, 174.923630, -95.207031),
	Vec3(-56.777344, 178.786911, -26.558594),
	Vec3(-74.102539, 177.508591, -2.583984),
	Vec3(-100.847656, 177.510544, 36.534180),
	Vec3(-63.958984, 175.157028, 40.089844),
}

function spawnInfected(player, position)
    print('Spawning infected ' .. player.name)

	local hiderSoldier = ResourceManager:SearchForDataContainer('Gameplay/Kits/RUEngineer_XP4')
	local engiAppearance = ResourceManager:SearchForDataContainer('Persistence/Unlocks/Soldiers/Visual/MP/RU/MP_RU_Engi_Appearance01_XP4')

	local mpSoldierBp = ResourceManager:SearchForDataContainer('Characters/Soldiers/MpSoldier')

    -- TODO: Select spawn point randomly from predetermined list.
	local spawnTransform = LinearTransform()

	if position == nil then
		position = infectedSpawns[MathUtils:GetRandomInt(1, #infectedSpawns)]
	end

	spawnTransform.trans = position

	player:SelectUnlockAssets(hiderSoldier, { engiAppearance })

	if player.soldier == nil then
		local soldier = player:CreateSoldier(mpSoldierBp, spawnTransform)
		player:SpawnSoldierAt(soldier, spawnTransform, CharacterPoseType.CharacterPoseType_Stand)
	end

	local knife = ResourceManager:SearchForDataContainer('Weapons/Knife/U_Knife')

	-- Create the infection customization
	hiderCustomization = CustomizeSoldierData()
	hiderCustomization.activeSlot = WeaponSlot.WeaponSlot_5
	hiderCustomization.removeAllExistingWeapons = true
	hiderCustomization.overrideCriticalHealthThreshold = 1.0

	local unlockWeapon = UnlockWeaponAndSlot()
	unlockWeapon.weapon = SoldierWeaponUnlockAsset(knife)
	unlockWeapon.slot = WeaponSlot.WeaponSlot_5

	hiderCustomization.weapons:add(unlockWeapon)

	player.soldier:ApplyCustomization(hiderCustomization)
	player.soldier.health = 100

	player.teamId = TeamId.Team2
end

function spawnHuman(player)
	print('Spawning human ' .. player.name)

	-- Gameplay/Kits/RUEngineer_XP4
	local hiderSoldier = ResourceManager:SearchForDataContainer('Gameplay/Kits/USSupport_XP4')

	local assaultAppearance = ResourceManager:SearchForDataContainer('Persistence/Unlocks/Soldiers/Visual/MP/Us/MP_US_Assault_Appearance01_XP4')
	local engiAppearance = ResourceManager:SearchForDataContainer('Persistence/Unlocks/Soldiers/Visual/MP/Us/MP_US_Engi_Appearance01_XP4')
	local reconAppearance = ResourceManager:SearchForDataContainer('Persistence/Unlocks/Soldiers/Visual/MP/Us/MP_US_Recon_Appearance01_XP4')
	local supportAppearance = ResourceManager:SearchForDataContainer('Persistence/Unlocks/Soldiers/Visual/MP/Us/MP_US_Support_Appearance01_XP4')

	local appearances = {
		assaultAppearance,
		engiAppearance,
		reconAppearance,
		supportAppearance,
	}

	local mpSoldierBp = ResourceManager:SearchForDataContainer('Characters/Soldiers/MpSoldier')

    -- TODO: Select spawn point randomly from predetermined list.
	local spawnTransform = LinearTransform()
	spawnTransform.trans = startingSpawns[MathUtils:GetRandomInt(1, #startingSpawns)]

	-- bots.spawn Bot1 Team2 Squad2 -100.150360 37.779110 -62.015625
	local randomAppearance = appearances[MathUtils:GetRandomInt(1, #appearances)]

	player:SelectUnlockAssets(hiderSoldier, { randomAppearance })

	if player.soldier == nil then
		local soldier = player:CreateSoldier(mpSoldierBp, spawnTransform)
		player:SpawnSoldierAt(soldier, spawnTransform, CharacterPoseType.CharacterPoseType_Stand)
	end

	local knife = ResourceManager:SearchForDataContainer('Weapons/Knife/U_Knife')

	local p90 = ResourceManager:SearchForDataContainer('Weapons/P90/U_P90')
	local p90Attachments = { 'Weapons/P90/U_P90_Kobra', 'Weapons/P90/U_P90_Targetpointer' }

	local mp7 = ResourceManager:SearchForDataContainer('Weapons/MP7/U_MP7')
	local mp7Attachments = { 'Weapons/MP7/U_MP7_Kobra', 'Weapons/MP7/U_MP7_ExtendedMag' }

	local m249 = ResourceManager:SearchForDataContainer('Weapons/M249/U_M249')
	local m249Attachments = { 'Weapons/M249/U_M249_Eotech', 'Weapons/M249/U_M249_Bipod' }

	local m1014 = ResourceManager:SearchForDataContainer('Weapons/M1014/U_M1014')
	local spas12 = ResourceManager:SearchForDataContainer('Weapons/XP2_SPAS12/U_SPAS12')
	local asval = ResourceManager:SearchForDataContainer('Weapons/ASVal/U_ASVal')

	local function setAttachments(unlockWeapon, attachments)
		for _, attachment in pairs(attachments) do
			local unlockAsset = UnlockAsset(ResourceManager:SearchForDataContainer(attachment))
			unlockWeapon.unlockAssets:add(unlockAsset)
		end
	end

	local m1911 = ResourceManager:SearchForDataContainer('Weapons/M1911/U_M1911_Tactical')

	-- Create the infection customization
	hiderCustomization = CustomizeSoldierData()
	hiderCustomization.activeSlot = WeaponSlot.WeaponSlot_0
	hiderCustomization.removeAllExistingWeapons = true
	hiderCustomization.overrideCriticalHealthThreshold = 1.0

	local primaryWeapon = UnlockWeaponAndSlot()
	primaryWeapon.weapon = SoldierWeaponUnlockAsset(m249)
	primaryWeapon.slot = WeaponSlot.WeaponSlot_0
	setAttachments(primaryWeapon, m249Attachments)

	local secondaryWeapon = UnlockWeaponAndSlot()
	secondaryWeapon.weapon = SoldierWeaponUnlockAsset(m1911)
	secondaryWeapon.slot = WeaponSlot.WeaponSlot_1

	local meleeWeapon = UnlockWeaponAndSlot()
	meleeWeapon.weapon = SoldierWeaponUnlockAsset(knife)
	meleeWeapon.slot = WeaponSlot.WeaponSlot_5

	hiderCustomization.weapons:add(primaryWeapon)
	hiderCustomization.weapons:add(secondaryWeapon)
	hiderCustomization.weapons:add(meleeWeapon)

	player.soldier:ApplyCustomization(hiderCustomization)

	player.teamId = TeamId.Team1

	NetEvents:BroadcastLocal('human', player.name)
end

local spawnCheckTimer = 0.0

Events:Subscribe('Engine:Update', function(deltaTime)
	spawnCheckTimer = spawnCheckTimer + deltaTime

	if spawnCheckTimer >= 0.25 then
		spawnCheckTimer = 0.0

		for _, player in pairs(PlayerManager:GetPlayers()) do
			-- TODO: Check if player is ready.
			if player.soldier == nil and player.corpse ~= nil and player.teamId == TeamId.Team2 then
				spawnInfected(player)
			end
		end
	end
end)
