-- This is the debug class that's exported to other classes to use.
class('Debug')

function Debug:__init()
	self.raycastLine = nil
	self.raycastObjects = {}
	self.debugRaycast = false
	self.wallHit = nil

	Events:Subscribe('UI:DrawHud', self, self._render)

	self:_registerCommands()
end

-- Internal functions.
function Debug:_registerCommands()
	Console:Register('DebugRaycast', 'Enable visual debugging of prop picking raycast.', self, self._onDebugRaycastCmd)
end

function Debug:_argToBool(arg)
	local lowerArg = string.lower(arg)

	if lowerArg == '0' or
		lowerArg == 'false' or
		lowerArg == 'off' or
		lowerArg == 'no' then
		return { true, false }
	end

	if lowerArg == '1' or
		lowerArg == 'true' or
		lowerArg == 'on' or
		lowerArg == 'yes' then
		return { true, true }
	end

	return { false, false }
end

function Debug:_onDebugRaycastCmd(args)
	if #args == 0 then
		return 'result: ' .. tostring(self.debugRaycast)
	end

	if #args == 1 then
		local arg = self:_argToBool(args[1])

		if not arg[1] then
			return 'Invalid argument. Expected a boolean value.'
		end

		if self.debugRaycast ~= arg[2] then
			if self.debugRaycast then
				print('Disabling raycast debugging.')
			else
				print('Enabling raycast debugging.')
			end
		end

		self.debugRaycast = arg[2]
		return 'result: ' .. tostring(self.debugRaycast)
	end

	return 'Usage: prop-hunt.DebugRaycast [enabled:bool]'
end

function Debug:_render()
	if self.debugRaycast then
		if self.raycastLine ~= nil then
			DebugRenderer:DrawLine(self.raycastLine[1], self.raycastLine[2], Vec4(1, 0, 0, 1), Vec4(1, 0, 0, 1))
		end

		for _, object in pairs(self.raycastObjects) do
			local color = Vec4(0, 1, 0, 1)

			local aabb = object[1]
			local aabbTrans = object[2]
			local meshName = object[3]
			local intersectEnter = object[4]
			local intersectExit = object[5]
			local selectedObject = object[6]

			if intersectEnter ~= nil then
				color = Vec4(0, 0, 1, 1)

				DebugRenderer:DrawSphere(intersectEnter, 0.05, Vec4(0, 1, 1, 1), true, false)
				DebugRenderer:DrawSphere(intersectExit, 0.05, Vec4(1, 1, 0, 1), true, false)
			end

			if selectedObject then
				color = Vec4(1, 0, 0, 1)
			end

			DebugRenderer:DrawOBB(aabb, aabbTrans, color)

			local screenPos = ClientUtils:WorldToScreen(aabbTrans.trans)

			if screenPos ~= nil then
				if selectedObject then
					DebugRenderer:DrawText2D(screenPos.x, screenPos.y, meshName, Vec4(0, 1, 0, 1), 1.0)
				else
					DebugRenderer:DrawText2D(screenPos.x, screenPos.y, meshName, Vec4(1, 1, 1, 1), 1.0)
				end
			end
		end

		if self.wallHit ~= nil then
			DebugRenderer:DrawSphere(self.wallHit, 0.035, Vec4(1, 0, 1, 1), true, true)
		end
	end
end

-- Public functions.
function Debug:setRaycastObjects(objects)
	self.raycastObjects = objects
end

function Debug:setRaycastLine(from, to)
	self.raycastLine = { from, to }
end

function Debug:setWallHit(pos)
	self.wallHit = pos
end

if g_Debug == nil then
	g_Debug = Debug()
end

return g_Debug
