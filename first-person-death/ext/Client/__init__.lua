class 'FirstPersonDeathCam'


function FirstPersonDeathCam:__init()
	print("Initializing FirstPersonDeathCam")
	self:RegisterVars()
	self:RegisterEvents()
end


function FirstPersonDeathCam:RegisterVars()
	self.m_Camera = nil
	self.m_CameraData = nil

end


function FirstPersonDeathCam:RegisterEvents()
    self.m_UpdateEvent = Events:Subscribe("UpdateManager:Update", self, self.OnUpdateInput)
end

function FirstPersonDeathCam:ClearCam()
	if(self.m_Camera ~= nil) then
		self.m_Camera:FireEvent("ReleaseControl")
		self.m_Camera:Destroy()
		self.m_Camera = nil
	end	
end

function FirstPersonDeathCam:OnUpdateInput(p_Hook, p_Cache, p_DeltaTime)
	local p_Player = PlayerManager:GetLocalPlayer()

	if (p_Player == nil) then
		return
	end
	if( p_Player.soldier ~= nil) then
		self:ClearCam()
		return
	end
	if(p_Player.corpse == nil) then
		self:ClearCam()
		return
	else
		if(self.m_Camera == nil) then
			-- We're dead or dying, our corpse exists and we're missing the camera. Let's create it.

			-- Create the camera data
			self.m_CameraData = CameraEntityData()
			self.m_CameraData.fov = 90 -- this could/should be dynamic, but 90 is fine. Higher and we might experience clipping issues. Hard to tell.

			-- Spawn the camera entity
			local s_Entity = EntityManager:CreateEntity(self.m_CameraData, LinearTransform())

			if s_Entity == nil then
				print("Could not spawn camera")
				return
			end
			-- Initialize camera
			s_Entity:Init(Realm.Realm_Client, true)
			
			-- store camera
			self.m_Camera = s_Entity

			-- Set the transform to the camera position. This prevents the camera from enabling at 0,0,0
			self.m_CameraData.transform = ClientUtils:GetCameraTransform()
			-- Switch to the created camera.
			self.m_Camera:FireEvent("TakeControl")
		else
			-- Double checking for redundancy. 
			if(p_Player.corpse == nil) then
				return
			end
			local s_Corpse = p_Player.corpse
			if(s_Corpse.ragdollComponent) == nil then
				return
			end

			-- Get the head bone transform
			local transformQuat = s_Corpse.ragdollComponent:GetInterpolatedWorldTransform(46)
			if(transformQuat == nil) then
				return
			end
			-- Set the head scale to 1. 
			transformQuat.transAndScale.w = 1

			-- Rotate camera to solve camera orientation.
			transformQuat.rotation = Normalize(multiply(Vec4(  0.500,0.500, -0.500, 0.500),transformQuat.rotation))
			
			local LT = transformQuat:ToLinearTransform()

			-- camera offset, could need some tweaking
			--LT.trans.y = LT.trans.y + 0.15

			-- If you die in a vehicle explosion, the camera is set to 0,0,0 and moving upwards.
			-- Wwe could check the pos, but I'm not sure if it would work on all maps.
			-- Instead, we raycast down 100 meters. It's only happening while we're dead, so it shouldn't matter.
			local from = LT.trans
			local to = Vec3(LT.trans.x, LT.trans.y - 100, LT.trans.z)

			local s_Raycast = RaycastManager:Raycast(from, to, 2)
			if(s_Raycast == nil) then
				return
			end

			-- Get the head transform
			local transformLocal = s_Corpse.ragdollComponent:GetLocalTransform(45)
			-- Set the scale to 0 
			transformLocal.transAndScale.w = 0
			-- Set the head transform
			s_Corpse.ragdollComponent:SetLocalTransform(45, transformLocal)

			-- Take control over the camera if we haven't already.
			-- Could possibly remove this, but I don't think it matters.
			self.m_Camera:FireEvent("TakeControl")

			-- Set the camera transform
			self.m_CameraData.transform = LT	
		end

	end
end

function multiply(in1, in2)
	local Q1 = in1
	local Q2 = in2
	return Vec4( (Q2.w * Q1.x) + (Q2.x * Q1.w) + (Q2.y * Q1.z) - (Q2.z * Q1.y),
	   (Q2.w * Q1.y) - (Q2.x * Q1.z) + (Q2.y * Q1.w) + (Q2.z * Q1.x),
	   (Q2.w * Q1.z) + (Q2.x * Q1.y) - (Q2.y * Q1.x) + (Q2.z * Q1.w),
	   (Q2.w * Q1.w) - (Q2.x * Q1.x) - (Q2.y * Q1.y) - (Q2.z * Q1.z) )
end

-- Regular normalizing function for quats.
function Normalize(quat)
	local n = quat.x * quat.x + quat.y * quat.y + quat.z * quat.z + quat.w * quat.w
	
	if n ~= 1 and n > 0 then
		n = 1 / math.sqrt(n)
		quat.x = quat.x * n
		quat.y = quat.y * n
		quat.z = quat.z * n
		quat.w = quat.w * n		
	end
	return Quat(quat.x, quat.y, quat.z, quat.w)
end

g_FirstPersonDeathCam = FirstPersonDeathCam()

