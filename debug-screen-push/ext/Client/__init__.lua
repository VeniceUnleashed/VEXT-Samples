Hooks:Install('UI:PushScreen', 999, function(hook, screen, graphPriority, parentGraph)
	screen = UIScreenAsset(screen)
	print(string.format("Pushing screen '%s'", screen.name))
	hook:Next()
end)

