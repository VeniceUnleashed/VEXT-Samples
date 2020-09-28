class 'DrivableACServer'


function DrivableACServer:__init()
	print("Initializing DrivableACServer")
	self:RegisterEvents()
end



function DrivableACServer:RegisterEvents()
	self.m_PlayerChat = Events:Subscribe('Player:Chat', self, self.PlayerChat)
end

function DrivableACServer:PlayerChat(p_Player, p_RecipientMask, p_Message)
	if message == '' then
		return
	end
	self:SpawnAC(p_Player)
end

function DrivableACServer:SpawnAC( p_Player )
	local trans = p_Player.soldier.transform.trans
	print('Spawning')

	local transform = LinearTransform(
		Vec3(1, 0, 0),
		Vec3(0, 1, 0),
		Vec3(0, 0, 1),
		Vec3(trans.x+10, trans.y + 2, trans.z)
	)
	local params = EntityCreationParams()
	params.transform = transform
	params.networked = true
	local s_Blueprint = ResourceManager:FindInstanceByGUID(Guid('DE5A1D34-981C-11E1-B304-EDC7D93268C6'), Guid('561E82B1-FDB8-CE19-B9B5-79CB5B57E94F'))

	local vehicles = EntityManager:CreateEntitiesFromBlueprint(s_Blueprint, params)
	if(vehicles == nil or #vehicles == 0) then
		print("Failed to spawn AC130")
	else
		for i, entity in ipairs(vehicles) do
			entity:Init(Realm.Realm_ClientAndServer, true)
		end
	end
end

g_DrivableACServer = DrivableACServer()

