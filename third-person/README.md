# Third Person Camera

This mod implements a third person player camera with support for free-look and ray-traced collision detection (which means it won't clip through walls).

## Usage

To try the camera load the mod on your server, connect and spawn, and type `third-person.Toggle3p` in the in-game console. This will enable the third person. You can use the command again to disable it. While in 3p view, you can hold `Alt` to lock the camera in place and look freely around your soldier.

## API

If you want to use this camera in your mods simply copy the `camera.lua` script to your mod and require it from your own scripts. The script returns an object that has the following methods:

| Method | Description |
| ------ | ----------- |
| `void enable()` | Enables the third person camera. |
| `void disable()` | Disables the third person camera. |
| `bool isActive()` | Returns `true` if the camera is currently active, `false` otherwise. |
| `bool isFreelooking()` | Returns `true` if the camera is currently in free-look mode, `false` otherwise. |
| `InputDeviceKeys getFreelookKey()` | Gets the key the player needs to press to free-look. Defaults to `InputDeviceKeys.IDK_LeftAlt`. |
| `void setFreelookKey(InputDeviceKeys key)` | Sets the key the player needs to press to free-look. You can use `InputDeviceKeys.IDK_None` to disable free-look. |
| `float getDistance()` | Gets the maximum distance between the camera and the soldier. Defaults to `2.0` meters. |
| `void setDistance(float distance)` | Sets the maximum distance between the camera and the soldier. |
| `float getHeight()` | Gets the height of the camera target, relative to the soldier's feet. Defaults to `1.5` meters. |
| `void setHeight(float height)` | Sets the height of the camera target, relative to the soldier's feet. |
| `LinearTransform getTransform()` | Gets the current transform of the third person camera. Will be `nil` if the camera is not active. |
| `Vec3 getLookAtPos()` | Gets the position of what the camera is currently looking at. Will be `nil` if the camera is not active. |

Keep in mind that requiring the class from multiple scripts will still return the same instance. Also keep in mind that the camera will get automatically de-activated after level restarts or transitions.

### Example usage:

```lua
local ThirdPersonCamera = require('camera')

-- Set the free-look activation key to "Q".
ThirdPersonCamera:setFreelookKey(InputDeviceKeys.IDK_Q)

-- Set the max camera distance to 3 meters.
ThirdPersonCamera:setDistance(3.0)

-- Enable the third-person camera.
ThirdPersonCamera:enable()
```
