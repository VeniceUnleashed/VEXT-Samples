local veState = nil
local cc = nil
local dof = nil
local vignette = nil
local filmGrain = nil

-- As soon as our extension gets loaded create our custom VE state.
Events:Subscribe('Extension:Loaded', function()
    print('Extension loaded')
    veState = VisualEnvironmentState('BattlefieldV')
    veState.visibility = 1.0
    veState.priority = 99999

    -- Create color correction data.
    cc = ColorCorrectionData()
    cc.enable = true
    cc.colorGradingEnable = false
    cc.brightness = Vec3(1.0, 1.0, 1.0)
    cc.contrast = Vec3(1.5, 1.5, 1.5)
    cc.saturation = Vec3(1.2, 1.0, 1.5)

    -- Create dof data.
    dof = DofData()
    dof.enable = true
    dof.focusDistance = 0.8
    dof.blurFilter = BlurFilter.BfGaussian31Pixels
    dof.blurFilterDeviation = 5.0
    dof.nearDistanceScale = -1
    dof.farDistanceScale = 1
    dof.scale = 1
    dof.blurAdd = 0.0

    -- Create vignette data.
    vignette = VignetteData()
    vignette.enable = true
    vignette.scale = Vec2(2, 2)
    vignette.color = Vec3(0, 0, 0)
    vignette.opacity = 0.6
    vignette.exponent = 1.5

    -- Create film grain data.
    filmGrain = FilmGrainData()
    filmGrain.enable = true
    filmGrain.textureScale = Vec2(0.8, 0.8)
    filmGrain.colorScale = Vec3(0.3, 0.3, 0.3)
    filmGrain.linearFilteringEnable = false
    filmGrain.randomEnable = true
    filmGrain.texture = ResourceManager:LookupDataContainer(ResourceCompartment.ResourceCompartment_Game, 'Systems/PostProcess/FilmGrainNoise')

    -- Add components to VE state.
    veState.colorCorrection = cc
    veState.dof = dof
    veState.vignette = vignette
    veState.filmGrain = filmGrain
    
    -- Add state to VE manager.
    VisualEnvironmentManager:AddState(veState)
end)

-- Add the VE state as soon as the level has loaded.
Events:Subscribe('Client:LevelLoaded', function()
    VisualEnvironmentManager:AddState(veState)
end)

-- Remove the VE state when the mod is unloading.
Events:Subscribe('Extension:Unloading', function()
    if veState ~= nil then
        VisualEnvironmentManager:RemoveState(veState)
    end
end)
