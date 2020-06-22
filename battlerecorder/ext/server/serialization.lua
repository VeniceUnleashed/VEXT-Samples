local StringBuilder = class('StringBuilder')
local msgpack = require('msgpack')
local base64 = require('base64')
local libdeflate = require('libdeflate')

msgpack.set_number('float')
msgpack.set_string('string')

msgpack.packers['userdata'] = function(buffer, value)
	if value.__type.name == 'VeniceEXT::Classes::Shared::Guid' then
		msgpack.packers['string'](buffer, value:ToString('D'))
	elseif value.__type.name == 'VeniceEXT::Classes::Shared::Vec3' then
		msgpack.packers['table'](buffer, { x = value.x, y = value.y, z = value.z })
	elseif value.__type.name == 'VeniceEXT::Classes::Shared::LinearTransform' then
		msgpack.packers['table'](buffer, {
			left = { x = value.left.x, y = value.left.y, z = value.left.z },
			up = { x = value.up.x, y = value.up.y, z = value.up.z },
			forward = { x = value.forward.x, y = value.forward.y, z = value.forward.z },
			trans = { x = value.trans.x, y = value.trans.y, z = value.trans.z },
		})
	else
		error('Unsupported userdata type: ' .. value.__type.name)
	end
end

function StringBuilder:__init()
	self._lines = {}
end

function StringBuilder:write(string)
	table.insert(self._lines, string)
end

function StringBuilder:writeln(string)
	table.insert(self._lines, string .. '\n')
end

function StringBuilder:writeTable(data)
	self:write('{')

	local didFirstField = false

	for field, value in pairs(data) do
		if didFirstField then
			self:write(',')
		end

		didFirstField = true

		if type(field) == 'number' then
			self:writef('[%d]', field)
		else
			self:write(field)
		end

		self:write('=')

		local valueType = type(value)

		if valueType == 'number' or valueType == 'boolean' or valueType == 'nil' then
			self:write(tostring(value))
		elseif valueType == 'string' then
			self:writef('[[%s]]', value)
		elseif valueType == 'table' then
			self:writeTable(value)
		elseif valueType == 'userdata' then
			if value.__type.name == 'VeniceEXT::Classes::Shared::Guid' then
				self:writef('"%s"', value:ToString('D'))
			elseif value.__type.name == 'VeniceEXT::Classes::Shared::Vec3' then
				self:writeTable({ x = value.x, y = value.y, z = value.z })
			elseif value.__type.name == 'VeniceEXT::Classes::Shared::LinearTransform' then
				self:writeTable({
					left = { x = value.left.x, y = value.left.y, z = value.left.z },
					up = { x = value.up.x, y = value.up.y, z = value.up.z },
					forward = { x = value.forward.x, y = value.forward.y, z = value.forward.z },
					trans = { x = value.trans.x, y = value.trans.y, z = value.trans.z },
				})
			else
				error('Unsupported userdata type: ' .. value.__type.name)
			end
		else
			error('Unsupported recording event value: ' .. valueType)
		end
	end

	self:write('}')
end

function StringBuilder:writef(fmt, ...)
	table.insert(self._lines, fmt:format(...))
end

function StringBuilder:build()
	return table.concat(self._lines)
end

function serializeRecordingDataToLua(data)
	local builder = StringBuilder()

	builder:write('{')

	local didFirstTick = false

	for tick, events in pairs(data) do
		if didFirstTick then
			builder:write(',')
		end

		didFirstTick = true

		builder:writef('[%d]={', tick)

		local didFirstEvent = false

		for _, event in pairs(events) do
			if didFirstEvent then
				builder:write(',')
			end

			didFirstEvent = true

			builder:writeTable(event)
		end

		builder:write('}')
	end

	builder:write('}')

	return builder:build()
end

function serializeRecordingDataToBase64(data)
	-- Pack the data in msgpack format.
	local packed = msgpack.pack(data)

	-- Compress using zlib.
	local compressed = libdeflate:CompressZlib(packed)

	-- Encode to base-64.
	return base64.encode(compressed)
end

function deserializeRecordingDataFromBase64(data)
	-- Decode from base64.
	local decoded = base64.decode(data)

	-- Decompress using zlib.
	local decompressed = libdeflate:DecompressZlib(decoded)

	-- Unpack from msgpack.
	return msgpack.unpack(decompressed)
end
