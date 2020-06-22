local blacklist = {
	['Levels/XP2_Skybar/XP2_Skybar'] = {
		'invisiblecollision_',
		'floor_',
		'facade_',
		'backdrop_',
		'cloth_',
		'rooftop_',
		'roofmodules',
		'waterplane_',
		'pillar_',
		'stairs_',
		'stairwall_',
		'trellis_',
		'carpet_',
		'decal',
		'debris',
		'destruction',
		'roof_',
		'splineoutside_',
		'beam_',
		'skybarwindows_',
		'rail_',
		'doorframe_',
		'pillarplaster_',
		'wallmodules',
		'smallpillow',
		'barshelves',
		'glasswall',
		'flower',
		'hoteldoor',
		'spotlight',
		'wallprops',
		'light_01',
		'plant_01',
		'bonsai',
		'bushfern',
		'planters_01',
		'skybarsigns',
		'elevator',
		'mousekeyboard',
		'paperpile',
		'ziba_sign',
		'wallsquares',
		'pooltrim',
		'floorvase',
		'ceilingpanel',
		'painting_01',
		'walldecoration_01',
		'doorgeneric',
		'spline',
		'parasol',
		'skybarrooflights',
		'showermodule',
		'palace_nightstand',
		'paintingbig_01',
		'paintingpanel',
		'luxurybed_02',
		'kitchen_ventilation',
		'pergola',
		'railing_',
		'binder_01',
		'sprinkler',
	}
}


local function isMeshWhitelisted(mesh)
	local meshName = mesh.name
	meshName = string.lower(meshName)

	local level = SharedUtils:GetLevelName()

	if level == nil then
		return false
	end

	local blacklistedMeshes = blacklist[level]

	if blacklistedMeshes == nil then
		return false
	end

	for _, blacklistedMesh in pairs(blacklistedMeshes) do
		if string.find(meshName, blacklistedMesh) then
			return false
		end
	end

	return true
end

return isMeshWhitelisted
