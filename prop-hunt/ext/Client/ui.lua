local function onUIAction(hook, actionKey)
    -- Prevent normal UI actions.
    if actionKey == MathUtils:FNVHash('SelectSpawnPoint') or
        actionKey == MathUtils:FNVHash('Spawn') or
        actionKey == MathUtils:FNVHash('SetCustomization') or
        actionKey == MathUtils:FNVHash('SetWeaponCustomization') or
        actionKey == MathUtils:FNVHash('StorePrimaryWeaponAccessories') or
        actionKey == MathUtils:FNVHash('StoreVehicleAccessories') or
        actionKey == MathUtils:FNVHash('SelectTeam') or
        actionKey == MathUtils:FNVHash('SquadAction') or
        actionKey == MathUtils:FNVHash('Suicide') then
        hook:Return()
        return
    end
end

Events:Subscribe('Extension:Loaded', function()
    -- Register events / hooks.
    --Hooks:Install('UI:PushScreen', 100, onPushScreen)
    --Hooks:Install('UI:CreateAction', 100, onUIAction)
end)


Events:Subscribe('UI:DrawHud', function()
	-- If we're a prop then render a crosshair.
	if isProp then
		local windowSize = ClientUtils:GetWindowSize()
		local cx = math.floor(windowSize.x / 2.0 + 0.5)
		local cy = math.floor(windowSize.y / 2.0 + 0.5)

		DebugRenderer:DrawLine2D(Vec2(cx - 7, cy - 1), Vec2(cx + 6, cy - 1), Vec4(1, 1, 1, 0.5))
		DebugRenderer:DrawLine2D(Vec2(cx - 7, cy), Vec2(cx + 6, cy), Vec4(1, 1, 1, 0.5))
		DebugRenderer:DrawLine2D(Vec2(cx - 7, cy + 1), Vec2(cx + 6, cy + 1), Vec4(1, 1, 1, 0.5))

		DebugRenderer:DrawLine2D(Vec2(cx - 1, cy - 7), Vec2(cx - 1, cy - 2), Vec4(1, 1, 1, 0.5))
		DebugRenderer:DrawLine2D(Vec2(cx, cy - 7), Vec2(cx, cy - 2), Vec4(1, 1, 1, 0.5))
		DebugRenderer:DrawLine2D(Vec2(cx + 1, cy - 7), Vec2(cx + 1, cy - 2), Vec4(1, 1, 1, 0.5))

		DebugRenderer:DrawLine2D(Vec2(cx - 1, cy + 1), Vec2(cx - 1, cy + 6), Vec4(1, 1, 1, 0.5))
		DebugRenderer:DrawLine2D(Vec2(cx, cy + 1), Vec2(cx, cy + 6), Vec4(1, 1, 1, 0.5))
		DebugRenderer:DrawLine2D(Vec2(cx + 1, cy + 1), Vec2(cx + 1, cy + 6), Vec4(1, 1, 1, 0.5))
	end
end)
