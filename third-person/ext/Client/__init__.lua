local ThirdPersonCamera = require('camera')

Console:Register('Toggle3p', 'Toggles the third person camera.', function()
	if ThirdPersonCamera:isActive() then
		ThirdPersonCamera:disable()
		return 'Disabled third person camera.'
	else
		ThirdPersonCamera:enable()
		return 'Enabled third person camera.'
	end
end)
