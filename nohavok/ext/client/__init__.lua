NetEvents:Subscribe('nohavok:transforms', function(assetName, transforms)
	print('Received transforms for "' .. assetName .. '".')
	HavokTransforms[assetName] = transforms
end)
