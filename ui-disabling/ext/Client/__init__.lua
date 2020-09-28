--[[
	You can find the list of screens in an EBX dump, in UI/Flow/Screen. Each screen contains an array of nodes.
--]]
Hooks:Install('UI:PushScreen', 999, function(hook, screen, graphPriority, parentGraph)
	-- We cast the screen to be able to access its fields.
	local screen = UIGraphAsset(screen)

	if screen.name == 'UI/Flow/Screen/PreRoundWaitingScreen' then
		print('Removing waiting for players message')

		-- With :Return() we change the return value of the hook call. In this case, passing nil will make this screen not show.
		hook:Return(nil)
		return
	end

	-- Now we want to emove only some nodes. 
	if 	screen.name == 'UI/Flow/Screen/Weapon/CrosshairCircle' or
			screen.name == 'UI/Flow/Screen/Weapon/CrosshairCircleHideOnZoom' or
			screen.name == 'UI/Flow/Screen/Weapon/CrosshairDefault' or
			screen.name == 'UI/Flow/Screen/Weapon/CrosshairDot' or
			screen.name == 'UI/Flow/Screen/Weapon/CrosshairGrenadeLauncher' or
			screen.name == 'UI/Flow/Screen/Weapon/CrosshairGrenadeLauncherHideOnZoom' then

		-- If we find any of these screens we clone the screen in order to modify it and pass it to the hook  instead of the original.
		local clone = screen:Clone(screen.instanceGuid)
		-- Cast the copy.
		local screenClone = UIGraphAsset(clone)

		-- Loop through the nodes in reverse order, as we are going to delete some members.
		for i = #screen.nodes, 1, -1 do
			local node = screen.nodes[i]
			-- Remove the ones we don't need.
			if node ~= nil then
				if node.name == 'CrosshairCircle' or
						node.name == 'CrosshairDefault' or
						node.name == 'CrosshairDot' or
						node.name == 'CrosshairGrenadeLauncher' or
						node.name == 'Crosshair' then
					print('Erasing Crosshair')
					-- Remove element i from the array.
					screenClone.nodes:erase(i)
				end
			end
		end

		-- Finally pass the clone to the hook instead of the original screen.
		hook:Pass(screenClone, graphPriority, parentGraph)
		return
	end
end)