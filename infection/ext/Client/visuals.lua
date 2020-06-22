--[[local colorCorrectionGuid = Guid('F670B6EE-170C-4A60-9649-C681CE73C594', 'D')
local skyGuid = Guid('7698A253-581D-4C10-A820-C9E310C4C957', 'D')
local outdoorLightGuid = Guid('A08624E0-E43F-47D0-9A4F-45D8563D5C04', 'D')
local enlightenGuid = Guid('02BBC2D0-B335-42BD-97AB-BD1E20E51720', 'D')
local fogGuid = Guid('8A4FA865-CC7C-4E7F-8787-3F79CCD261C4', 'D')
local sunFlareGuid = Guid('AC779F06-BB37-4150-BE7E-2B87882E38B5', 'D')
]]

local colorCorrectionGuid = Guid('8597D698-7EF5-462E-AD90-3719E2FF9F0C', 'D')
local skyGuid = Guid('A6D1C9BF-0C64-4009-8D61-105429F13E08', 'D')
local outdoorLightGuid = Guid('C5F49BD1-41CD-4A28-B5CF-87EEC866D8A1', 'D')
local enlightenGuid = Guid('2422B27D-693F-4B66-A869-C873AF04FE42', 'D')
local fogGuid = Guid('37D8977A-9D12-445A-8214-757752E02108', 'D')
local sunFlareGuid = Guid('314DFD9A-C8D6-4249-AE32-92FDD1F5E07C', 'D')
local characterLightingGuid = Guid('A04E9F4F-463F-4309-87FD-72B71F0DD90B', 'D')

local flashLight1PGuid = Guid('995E49EE-8914-4AFD-8EF5-59125CA8F9CD', 'D')
local flashLight3PGuid = Guid('5FBA51D6-059F-4284-B5BB-6E20F145C064', 'D')

local function patchCharacterLighting(instance)
	if instance == nil then
		return
	end

	local lighting = CharacterLightingComponentData(instance)
	lighting:MakeWritable()

	lighting.characterLightEnable = false
	lighting.topLight = Vec3(0, 0, 0)

	print('Patching characterlight')
end

local function patchColorCorrection(instance)
	if instance == nil then
		return
	end

	local cc = ColorCorrectionComponentData(instance)
	cc:MakeWritable()

	cc.brightness = Vec3(0.9, 0.9, 0.9)
	cc.contrast = Vec3(1.15, 1.15, 1.15)
	cc.saturation = Vec3(0.7, 0.7, 0.74)
	cc.colorGradingEnable = false
	cc.enable = false

	print('Patching cc')
end

local function patchSky(instance)
	if instance == nil then
		return
	end

	local sky = SkyComponentData(instance)
	sky:MakeWritable()

	sky.sunSize = 0.005
	sky.brightnessScale = 0.001
	sky.sunScale = 0.005
	sky.staticEnvmapScale = 0
	sky.sunScale = 19

	print('Patching sky')
end

local function patchOutdoorLight(instance)
	if instance == nil then
		return
	end

	local outdoorLight = OutdoorLightComponentData(instance)
	outdoorLight:MakeWritable()

	outdoorLight.sunColor = Vec3(0.002, 0.002, 0.002)
	outdoorLight.skyColor = Vec3(0.002, 0.002, 0.003)
	outdoorLight.groundColor = Vec3(0.008, 0.008, 0.010)
	outdoorLight.sunSpecularScale = 0.452
	outdoorLight.skyEnvmapShadowScale = 0.191

	print('Patching outdoorLight')
end

local function patchEnlighten(instance)
	if instance == nil then
		return
	end

	local enlighten = EnlightenComponentData(instance)
	enlighten:MakeWritable()

	enlighten.enable = false

	print('Patching enlighten')
end

local function patchFog(instance)
	if instance == nil then
		return
	end

	local fog = FogComponentData(instance)
	fog:MakeWritable()

	fog.start = 20
	fog.endValue = 2500

	fog.enable = false
	fog.fogColorEnable = false

	print('Patching fog')
end

local function patchSunFlare(instance)
	if instance == nil then
		return
	end

	local sunFlare = SunFlareComponentData(instance)
	sunFlare:MakeWritable()

	sunFlare.enable = true
	sunFlare.element1Enable = false
	sunFlare.element2Enable = false
	sunFlare.element3Enable = false
	sunFlare.element4Enable = false
	sunFlare.element5Enable = false

	print('Patching sunflare')
end

local function patchFlashLight(instance)
	if instance == nil then
		return
	end

	local spotLight = SpotLightEntityData(instance)
	instance:MakeWritable()

	spotLight.radius = 100
	spotLight.intensity = 2
	spotLight.coneOuterAngle = 80
	spotLight.orthoWidth = 5
	spotLight.orthoHeight = 5
	spotLight.frustumFov = 50
	spotLight.castShadowsEnable = true
	spotLight.castShadowsMinLevel = QualityLevel.QualityLevel_Low

	print('Patching flashlight')
end

Events:Subscribe('Partition:Loaded', function(partition)
	for _, instance in pairs(partition.instances) do
		if instance.instanceGuid == colorCorrectionGuid then
			patchColorCorrection(instance)
		elseif instance.instanceGuid == skyGuid then
			patchSky(instance)
		elseif instance.instanceGuid == outdoorLightGuid then
			patchOutdoorLight(instance)
		elseif instance.instanceGuid == enlightenGuid then
			patchEnlighten(instance)
		elseif instance.instanceGuid == fogGuid then
			patchFog(instance)
		elseif instance.instanceGuid == sunFlareGuid then
			patchSunFlare(instance)
		elseif instance.instanceGuid == flashLight1PGuid then
			patchFlashLight(instance)
		elseif instance.instanceGuid == flashLight3PGuid then
			patchFlashLight(instance)
		elseif instance.instanceGuid == characterLightingGuid then
			patchCharacterLighting(instance)
		end
	end
end)

Events:Subscribe('Extension:Loaded', function()
	patchColorCorrection(ResourceManager:SearchForInstanceByGuid(colorCorrectionGuid))
	patchSky(ResourceManager:SearchForInstanceByGuid(skyGuid))
	patchOutdoorLight(ResourceManager:SearchForInstanceByGuid(outdoorLightGuid))
	patchEnlighten(ResourceManager:SearchForInstanceByGuid(enlightenGuid))
	patchFog(ResourceManager:SearchForInstanceByGuid(fogGuid))
	patchSunFlare(ResourceManager:SearchForInstanceByGuid(sunFlareGuid))
	patchFlashLight(ResourceManager:SearchForInstanceByGuid(flashLight1PGuid))
	patchFlashLight(ResourceManager:SearchForInstanceByGuid(flashLight3PGuid))
	patchCharacterLighting(ResourceManager:SearchForInstanceByGuid(characterLightingGuid))

	VisualEnvironmentManager:SetDirty(true)
end)
