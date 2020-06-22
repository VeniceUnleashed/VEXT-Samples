Hooks:Install('Input:PreUpdate', 100, function()
	-- If we're a prop disable various inputs.
	local enabled = not isProp

	local player = PlayerManager:GetLocalPlayer()

	if player == nil then
		return
	end

	player:EnableInput(EntryInputActionEnum.EIAFire, enabled)
	player:EnableInput(EntryInputActionEnum.EIAZoom, enabled)
	player:EnableInput(EntryInputActionEnum.EIAProne, enabled)
	player:EnableInput(EntryInputActionEnum.EIAReload, enabled)
	player:EnableInput(EntryInputActionEnum.EIAMeleeAttack, enabled)
	player:EnableInput(EntryInputActionEnum.EIAThrowGrenade, enabled)
	player:EnableInput(EntryInputActionEnum.EIAToggleParachute, enabled)
end)
