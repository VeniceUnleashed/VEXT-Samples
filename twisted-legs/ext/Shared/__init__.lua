Events:Subscribe('Player:UpdateInput', function(player, dt)
	if player.input == nil then
		return
	end

	-- On every input update, reverse the player's throttle and strafe inputs.
	-- Throttle is forward and back and strafe is left and right.
	player.input:SetLevel(EntryInputActionEnum.EIAThrottle, player.input:GetLevel(EntryInputActionEnum.EIAThrottle) * -1)
	player.input:SetLevel(EntryInputActionEnum.EIAStrafe, player.input:GetLevel(EntryInputActionEnum.EIAStrafe) * -1)

	-- We also switch shooting and aiming down sights.
	local fireLevel = player.input:GetLevel(EntryInputActionEnum.EIAFire)
	local zoomLevel = player.input:GetLevel(EntryInputActionEnum.EIAZoom)
	player.input:SetLevel(EntryInputActionEnum.EIAFire, zoomLevel)
	player.input:SetLevel(EntryInputActionEnum.EIAZoom, fireLevel)
end)
