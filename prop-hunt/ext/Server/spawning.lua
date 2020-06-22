local seekerSoldier = nil
local hiderSoldier = nil
local m416 = nil
local knife = nil
local mpSoldierBp = nil
local propSoldierBp = nil
local noSpecialization = nil
local customization = nil
local hiderCustomization = nil

Events:Subscribe('Level:Destroy', function()
    seekerSoldier = nil
    hiderSoldier = nil
    m416 = nil
    knife = nil
    mpSoldierBp = nil
    propSoldierBp = nil
    noSpecialization = nil
    customization = nil
    hiderCustomization = nil
end)

local function configureUnlocks(parts, allowed)
    local unlockParts = CustomizationUnlockParts(parts)
    unlockParts:MakeWritable()

    for i = #unlockParts.selectableUnlocks, 1, -1 do
        local unlock = unlockParts.selectableUnlocks[i]

        local skip = false

        for _, name in pairs(allowed) do
            if name == unlock.name then
                skip = true
                break
            end
        end

        if not skip then
            unlockParts.selectableUnlocks:erase(i)
        end

        ::continue::
    end

    if #unlockParts.selectableUnlocks == 0 then
        unlockParts.selectableUnlocks:add(UnlockAssetBase(noSpecialization))
    end
end

local function getInstance(guid)
    local instance = ResourceManager:SearchForInstanceByGuid(Guid(guid))

    if instance == nil then
        print('Could not find instance with ID ' .. guid)
    end

    return instance
end

local function ensureData()
    if hiderSoldier ~= nil then
        return
    end

    -- Gameplay/Kits/RURecon
    hiderSoldier = getInstance('84A4BE20-B110-42E5-9588-365643624525')

    -- Gameplay/Kits/USAssault
    seekerSoldier = getInstance('A15EE431-88B8-4B35-B69A-985CEA934855')

    m416 = ResourceManager:LookupDataContainer(ResourceCompartment.ResourceCompartment_Game, 'Weapons/M416/U_M416')
    knife = ResourceManager:LookupDataContainer(ResourceCompartment.ResourceCompartment_Game, 'Weapons/Knife/U_Knife')
    mpSoldierBp = getInstance('261E43BF-259B-41D2-BF3B-9AE4DDA96AD2')
    propSoldierBp = getInstance('261E43BF-259B-41D2-BF3B-9AE4DDA96AD3')
    noSpecialization = getInstance('1F60E538-7DF1-4E2A-82F5-DF9921A525F9')

    -- Patch the customization assets to ensure we can use the proper weapons.
    -- Hider:
    configureUnlocks(getInstance('6E702304-F316-481E-B358-80083A2DE799'), {}) -- primary
    configureUnlocks(getInstance('161BDDDF-D2BE-425F-8F07-82358D64272D'), { 'Weapons/Knife/U_Knife' }) -- knife
    configureUnlocks(getInstance('42EE7299-53FC-4A0C-A14E-7A787FE96815'), {}) -- grenade
    configureUnlocks(getInstance('A19A5E3C-DFB5-43E9-A571-159006B71C42'), {}) -- gadget 2
    configureUnlocks(getInstance('5B06BF90-DD48-42ED-B7C3-F875533E6B61'), {}) -- gadget 1
    configureUnlocks(getInstance('EE8418E2-4F7E-45B0-8252-5B901C5BE880'), {}) -- secondary
    configureUnlocks(getInstance('674FB2C8-2B8E-4417-8332-E504F525A18E'), {}) -- specialization

    -- Seeker:
    -- Primary
    configureUnlocks(getInstance('67594D93-0911-49D8-8482-7D2FD48BF6AE'), {
        'Weapons/M416/U_M416'
    })

    -- Gadget 1
    configureUnlocks(getInstance('750EDB85-DA53-4C60-86F4-69F7A5C502DA'), {
        'weapons/xp4_crossbow_prototype/u_crossbow_scoped_cobra'
    })

    -- Category Gadget 1
    configureUnlocks(getInstance('EE967206-5A55-4A78-9333-2C8E0432DC1A'), {})

    -- Gadget 2
    configureUnlocks(getInstance('C2591733-65BC-447C-ADB1-8C7A1A75F55D'), {})

    -- Knife
    configureUnlocks(getInstance('5A089CE5-775C-4869-8990-E6C8B5CC613F'), {
        'Weapons/Knife/U_Knife'
    })

    -- Specialization
    configureUnlocks(getInstance('B83BC8D5-00A7-4FBF-A744-42BB0A4A532D'), {})

    -- Create the infection customization
    hiderCustomization = CustomizeSoldierData()
    hiderCustomization.overrideMaxHealth = 10000.0
    hiderCustomization.activeSlot = WeaponSlot.WeaponSlot_5
    hiderCustomization.removeAllExistingWeapons = true
    hiderCustomization.overrideCriticalHealthThreshold = 1.0

    local unlockWeapon = UnlockWeaponAndSlot()
    unlockWeapon.weapon = SoldierWeaponUnlockAsset(knife)
    unlockWeapon.slot = WeaponSlot.WeaponSlot_5

	hiderCustomization.weapons:add(unlockWeapon)

	if propSoldierBp == nil then
		print('Could not find prop soldier bp')
	end
end

local function setupHider(player)
	player:SelectUnlockAssets(hiderSoldier, { })
end

local function setupSeeker(player)
    -- TODO: Randomly select weapon and attachments
    player:SelectWeapon(WeaponSlot.WeaponSlot_0, m416, { })
    player:SelectUnlockAssets(seekerSoldier, { })
end

local function customizeHider(player)
    ensureData()

    if player.soldier == nil then
        return
    end

    player.soldier:ApplyCustomization(hiderCustomization)
end

function spawnPlayer(player)
    if player.soldier ~= nil then
        return
    end

    print('Spawning player ' .. player.name)

	ensureData()

	local bp = mpSoldierBp

	setupSeeker(player)
    --[[if player.teamID == TeamId.Team1 then
        setupSeeker(player)
    else
		setupHider(player)
		bp = propSoldierBp
    end]]

    -- TODO: Select spawn point randomly from predetermined list.
    local spawnTransform = LinearTransform(
        Vec3(-0.966302, 0.000000, -0.257410),
        Vec3(0.000000, 1.000000, 0.000000),
        Vec3(0.257410, 0.000000, -0.966302),
        Vec3(21.154095, 10.881368, 8.301152)
    )

    local soldier = player:CreateSoldier(bp, spawnTransform)
    player:SpawnSoldierAt(soldier, spawnTransform, CharacterPoseType.CharacterPoseType_Stand)
end

function spawnAllPlayers()
	local players = PlayerManager:GetPlayers()

	for _, player in pairs(players) do
		spawnPlayer(player)
	end
end
