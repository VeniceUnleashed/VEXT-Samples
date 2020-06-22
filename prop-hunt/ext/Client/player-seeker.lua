local Camera = require('Camera')

NetEvents:Subscribe(NetMessage.S2C_MAKE_SEEKER, function()
	isProp = false
	Camera:disable()
end)
