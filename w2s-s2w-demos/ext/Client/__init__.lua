--[[
	World to screen position is displayed in WebUI: Pressing F1 (when soldier is alive) will transform current soldier position to 
	screen cordinates which are later sent to web. Pressing F2 will remove the current W2S marker.

	Screen to world position is displayed with DebugRenderer: Pressing F3 will transform mouse coordinates to world coordinates. To
	try this enable mouse (for example pressing ESC) and press F3 at different mouse positions. These world coords are used to spawn
	a sphere. To remove the current S2W marker press F4.
--]]

local w2sMarkerPos = nil
local s2wMarkerPos = nil

-- Initialize and show WebUI when the mod loads.
Events:Subscribe('Extension:Loaded', function()
	WebUI:Init()
	WebUI:Show()
end)

Events:Subscribe('Client:UpdateInput', function(delta) 
	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F1) then
		local localPlayer = PlayerManager:GetLocalPlayer()

		if localPlayer == nil then
			return
		end

		-- Get local player's soldier.
		local soldier = localPlayer.soldier
		if soldier == nil then
			return
		end

		-- Get the soldier current position and store it.
		w2sMarkerPos = soldier.transform.trans
		print("Showing W2S marker at current player position: ".. tostring(w2sMarkerPos))
		
		-- Show marker in WebUI.
		WebUI:ExecuteJS('ShowMarker(true)')
	end

	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F2) then
		print('W2S marker hidden')

		-- Hide marker and clear marker position.
		w2sMarkerPos = nil
		WebUI:ExecuteJS('ShowMarker(false)')
	end

	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F3) then
		local mousePos = InputManager:GetCursorPosition()
		s2wMarkerPos = ClientUtils:ScreenToWorld(mousePos)

		print("Showing S2W marker at current mouse position: ".. tostring(mousePos)..", world position: ".. tostring(s2wMarkerPos))
	end

	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F4) then
		print('S2W marker hidden')
		s2wMarkerPos = nil
	end
end)

-- Here we update the WebUI marker.
Events:Subscribe('Engine:Update', function(delta, simulationDelta) 
	if w2sMarkerPos == nil then 
		return
	end
	
	-- Translate world position to screen position.
	local worldToScreen = ClientUtils:WorldToScreen(w2sMarkerPos)

	if worldToScreen == nil then
		return
	end

	-- Update WebUI marker.
	WebUI:ExecuteJS('UpdateMarker('.. worldToScreen.x ..','.. worldToScreen.y..')' )
end)

-- Here we draw the debug sphere.
Events:Subscribe('UI:DrawHud', function()
	if s2wMarkerPos ~= nil then
		DebugRenderer:DrawSphere(s2wMarkerPos, 0.01, Vec4(1, 0, 1, 1), true, false)
	end
end)