
local MAX_STAMINA = 10
local SPRINTING_REENABLE_TRESHOLD = 0.3 -- Percentage of stamina needed to re-enable sprinting.

-- Table with players' stamina level and sprinting state, with player ids as index.
local staminas = {}

Events:Subscribe('Player:UpdateInput', function(player, dt)
	if player == nil or player.input == nil then
		return
	end

	-- Create default player stamina data.
	if staminas[player.id] == nil then
		staminas[player.id] = { stamina = MAX_STAMINA, sprintEnabled = true }
	end

	local playerStamina = staminas[player.id]

	-- Decrease or increase stamina based on sprint input. Limit max and min stamina level.
	if player.input:GetLevel(EntryInputActionEnum.EIASprint) == 1 then
		playerStamina.stamina = math.max(playerStamina.stamina - dt, 0)
	else
		playerStamina.stamina = math.min(playerStamina.stamina + dt, MAX_STAMINA)
	end

	-- Disable sprint if it reaches 0
	if playerStamina.stamina == 0 then
		print(player.name .. ' is out of breath, disabling sprint')
		player:EnableInput(EntryInputActionEnum.EIASprint, false)
		playerStamina.sprintEnabled = false 

	-- Enable sprint if enough stamina has been regained.
	elseif playerStamina.stamina >= MAX_STAMINA * SPRINTING_REENABLE_TRESHOLD and not playerStamina.sprintEnabled then
		print(player.name .. '\'s breath regained, enabling stamina')
		player:EnableInput(EntryInputActionEnum.EIASprint, true)
		playerStamina.sprintEnabled = true
	end
end)