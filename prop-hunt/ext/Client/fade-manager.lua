local fadeEntityData = nil
local fadeEntity = nil
local levelLoaded = false
local fadePending = false
local fadedIn = true

local function createFadeEntity()
    -- Skip if the entity is already created.
    if fadeEntity ~= nil then
        return
    end

    -- Create the entity data if we haven't already.
    if fadeEntityData == nil then
        fadeEntityData = FadeEntityData()
        fadeEntityData.fadeTime = 0.1
        fadeEntityData.maxWaitFadedWhileStreamingTime = 0
        fadeEntityData.fadeScreen = true
        fadeEntityData.fadeUI = false
        fadeEntityData.fadeAudio = true
        fadeEntityData.fadeMovie = false
        fadeEntityData.startFaded = false
    end

    -- Create the entity.
    fadeEntity = EntityManager:CreateEntity(fadeEntityData, LinearTransform())
    fadeEntity:Init(Realm.Realm_Client, true)
end

local function destroyFadeEntity()
    if fadeEntity == nil then
        return
    end

    fadeEntity:Destroy()
    fadeEntity = nil
end

local function fade(fadeIn)
    fadedIn = fadeIn

    if fadeIn then
        fadeEntity:FireEvent('FadeIn')
    else
        fadeEntity:FireEvent('FadeOut')
    end
end

NetEvents:Subscribe(NetMessage.S2C_FADE, function(fadeIn)
    -- If the level is not loaded yet queue the fade.
    if not levelLoaded then
        fadePending = true
        fadedIn = fadeIn
        return
    end

    -- Create fade entity if it doesn't exist.
    createFadeEntity()

    -- Fade.
    fade(fadeIn)
end)

Events:Subscribe('Level:Destroy', function()
    -- Destroy the fade entity
    destroyFadeEntity()
    levelLoaded = false
end)

Events:Subscribe('Level:Loaded', function()
    levelLoaded = true

    -- If we have a fade pending then do it!
    if fadePending then
        fadePending = false
        createFadeEntity()
        fade(fadedIn)
    end
end)
