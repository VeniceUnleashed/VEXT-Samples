local infectedVision = nil
local colorCorrection = nil
local shaderParams = nil
local outdoorLight = nil
local vignette = nil
local fog = nil

function setInfectedVision()
	if infectedVision ~= nil then
		return
	end

	local infectedVisionData = VisualEnvironmentEntityData()
	infectedVisionData.enabled = true
	infectedVisionData.visibility = 1.0
	infectedVisionData.priority = 999999

	local shaderParams = ShaderParamsComponentData()
	shaderParams.value = Vec4(1.0, 1.0, 1.0, 1.0)
	shaderParams.parameterName = 'FLIRData'

	local outdoorLight = OutdoorLightComponentData()
	outdoorLight.enable = true
	outdoorLight.sunColor = Vec3(0.15, 0.15, 0.15)
	outdoorLight.skyColor = Vec3(0.01, 0.01, 0.01)
	outdoorLight.groundColor = Vec3(0.01, 0.01, 0.01)

	local colorCorrection = ColorCorrectionComponentData()
	colorCorrection.enable = true
	colorCorrection.brightness = Vec3(2.0, 2.0, 2.0)
	colorCorrection.contrast = Vec3(1.1, 1.1, 1.1)
	colorCorrection.saturation = Vec3(0.4, 0.04, 0.03)
	colorCorrection.hue = 0.0
	colorCorrection.colorGradingTexture = TextureAsset(ResourceManager:SearchForInstanceByGuid(Guid('E79F27A1-7B97-4A63-8ED8-372FE5012A31')))
	colorCorrection.colorGradingEnable = true

	local vignette = VignetteComponentData()
	vignette.enable = true
	vignette.scale = Vec2(2.5, 2.5)
	vignette.exponent = 2.0
	vignette.color = Vec3(0.12, 0.0, 0.0)
	vignette.opacity = 0.4

	local fog = FogComponentData()
	fog.enable = true
	fog.fogDistanceMultiplier = 1.0
	fog.fogGradientEnable = true
	fog.start = 5.0
	fog.endValue = 15.0
	fog.curve = Vec4(3.108949, -4.2201934, 2.0970724, -0.001664313)
	fog.fogColorEnable = true
	fog.fogColor = Vec3(1.0, 1.0, 1.0)
	fog.fogColorStart = 0.0
	fog.fogColorEnd = 1000.0
	fog.fogColorCurve = Vec4(4.8581696, -6.213437, 3.202797, -0.026411323)
	fog.transparencyFadeStart = -500.0
	fog.transparencyFadeEnd = 1500.0
	fog.transparencyFadeClamp = 1.0

	infectedVisionData.components:add(shaderParams)
	infectedVisionData.runtimeComponentCount = infectedVisionData.runtimeComponentCount + 1

	infectedVisionData.components:add(outdoorLight)
	infectedVisionData.runtimeComponentCount = infectedVisionData.runtimeComponentCount + 1

	infectedVisionData.components:add(colorCorrection)
	infectedVisionData.runtimeComponentCount = infectedVisionData.runtimeComponentCount + 1

	infectedVisionData.components:add(vignette)
	infectedVisionData.runtimeComponentCount = infectedVisionData.runtimeComponentCount + 1

	--infectedVisionData.components:add(fog)
	--infectedVisionData.runtimeComponentCount = infectedVisionData.runtimeComponentCount + 1

	infectedVision = EntityManager:CreateEntity(infectedVisionData, LinearTransform())

	if infectedVision ~= nil then
		infectedVision:Init(Realm.Realm_Client, true)
	end

	--[[infectedVision = VisualEnvironmentState()
	infectedVision.visibility = 1.0
	infectedVision.priority = 99999

	shaderParams = ShaderParamsData()
	shaderParams.value = Vec4(1.0, 1.0, 1.0, 1.0)
	shaderParams.parameterName = 'FLIRData'

	outdoorLight = OutdoorLightData()
	outdoorLight.enable = true
	outdoorLight.sunColor = Vec3(0.15, 0.15, 0.15)
	outdoorLight.skyColor = Vec3(0.01, 0.01, 0.01)
	outdoorLight.groundColor = Vec3(0.01, 0.01, 0.01)

	colorCorrection = ColorCorrectionData()
	colorCorrection.enable = true
	colorCorrection.brightness = Vec3(2.0, 2.0, 2.0)
	colorCorrection.contrast = Vec3(1.1, 1.1, 1.1)
	colorCorrection.saturation = Vec3(0.4, 0.04, 0.03)
	colorCorrection.hue = 0.0
	colorCorrection.colorGradingTexture = TextureAsset(ResourceManager:SearchForInstanceByGuid(Guid('E79F27A1-7B97-4A63-8ED8-372FE5012A31')))
	colorCorrection.colorGradingEnable = true

	vignette = VignetteData()
	vignette.enable = true
	vignette.scale = Vec2(2.5, 2.5)
	vignette.exponent = 2.0
	vignette.color = Vec3(0.12, 0.0, 0.0)
	vignette.opacity = 0.4

	fog = FogData()
	fog.enable = true
	fog.fogDistanceMultiplier = 1.0
	fog.fogGradientEnable = true
	fog.start = 5.0
	fog.endValue = 15.0
	fog.curve = Vec4(3.108949, -4.2201934, 2.0970724, -0.001664313)
	fog.fogColorEnable = true
	fog.fogColor = Vec3(1.0, 1.0, 1.0)
	fog.fogColorStart = 0.0
	fog.fogColorEnd = 1000.0
	fog.fogColorCurve = Vec4(4.8581696, -6.213437, 3.202797, -0.026411323)
	fog.transparencyFadeStart = -500.0
	fog.transparencyFadeEnd = 1500.0
	fog.transparencyFadeClamp = 1.0

	-- Add components to VE state.
	infectedVision.colorCorrection = colorCorrection
	infectedVision.outdoorLight = outdoorLight
	infectedVision.vignette = vignette
	infectedVision.fog = fog
	infectedVision:AddShaderParams(shaderParams)

	-- Add state to VE manager.
	VisualEnvironmentManager:AddState(infectedVision)]]

	WebUI:ExecuteJS('showInfectedOverlay()')
end

function removeInfectedVision()
	--[[if infectedVision ~= nil then
		VisualEnvironmentManager:RemoveState(infectedVision)
		infectedVision = nil
	end]]

	if infectedVision ~= nil then
		infectedVision:Destroy()
		infectedVision = nil
	end

	WebUI:ExecuteJS('hideInfectedOverlay()')
end

-- Remove the VE state when the mod is unloading.
Events:Subscribe('Extension:Unloading', function()
	removeInfectedVision()
end)
