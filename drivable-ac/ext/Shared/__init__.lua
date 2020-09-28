class 'DrivableACShared'


function DrivableACShared:__init()
	print("Initializing DrivableACShared")
	self:RegisterVars()
	self:RegisterEvents()
end


function DrivableACShared:RegisterVars()
	self.m_AC130 = nil
	self.m_F18 = nil

end


function DrivableACShared:RegisterEvents()
	Events:Subscribe('ExtensionLoaded', self, self.OnModify)
   	Events:Subscribe('Engine:Message', self, self.OnEngineMessage)
   	Events:Subscribe('Level:Destroy', self, self.RegisterVars)
end


function DrivableACShared:OnEngineMessage(p_Message)
	if p_Message.type == MessageType.ClientLevelFinalizedMessage or p_Message.type == MessageType.ServerLevelLoadedMessage then
		self:OnModify()
	end
end


function DrivableACShared:OnModify()
	print("modify")
	if(self.m_AC130 == nil) then


		if(ResourceManager:FindInstanceByGUID(Guid('DE5A1D34-981C-11E1-B304-EDC7D93268C6'), Guid('561E82B1-FDB8-CE19-B9B5-79CB5B57E94F')) == nil) then
			print("Failed to get AC130, probably loading for the first time...")
			return
		end

		self.m_AC130 = VehicleBlueprint(ResourceManager:FindInstanceByGUID(Guid('DE5A1D34-981C-11E1-B304-EDC7D93268C6'), Guid('561E82B1-FDB8-CE19-B9B5-79CB5B57E94F')))
		self.m_F18 = VehicleBlueprint(ResourceManager:FindInstanceByGUID(Guid('3EABB4EF-4003-11E0-8ACA-C41D37DB421C'), Guid('C81F8757-E6D2-DF2D-1CFE-B72B4F74FE98')))

		-- If any of these are missing, we're gonna get an error. Neat.
	end

	local s_AC130 = VehicleEntityData(self.m_AC130.object)
	s_AC130:MakeWritable()
	local s_AC130Chassis = ChassisComponentData(s_AC130.components:get(1))
	s_AC130Chassis:MakeWritable()
	local s_AC130DriverEntry = PlayerEntryComponentData(s_AC130Chassis.components:get(2))  
	s_AC130DriverEntry:MakeWritable()

	local s_F18 = VehicleEntityData(self.m_F18.object)
	local s_F18Chassis = ChassisComponentData(s_F18.components:get(1))
	local s_F18DriverEntry = PlayerEntryComponentData(s_F18Chassis.components:get(2))  
	print("Modifying chassis")

	s_AC130Chassis.alwaysFullThrottle = false 

	s_AC130.runtimeComponentCount = s_AC130.runtimeComponentCount + 60

	s_AC130Chassis.components:add(ClearPartsFromComponents(s_F18Chassis.components:get(10):Clone()))
	s_AC130Chassis.components:add(ClearPartsFromComponents(s_F18Chassis.components:get(11):Clone()))
	s_AC130Chassis.components:add(ClearPartsFromComponents(s_F18Chassis.components:get(12):Clone()))
	s_AC130Chassis.components:add(ClearPartsFromComponents(s_F18Chassis.components:get(13):Clone()))
	s_AC130Chassis.components:add(ClearPartsFromComponents(s_F18Chassis.components:get(14):Clone()))

	print("Modifying entry")
	s_AC130DriverEntry.forbiddenForHuman = false

	s_AC130DriverEntry.inputConceptDefinition 	= s_F18DriverEntry.inputConceptDefinition 
	s_AC130DriverEntry.inputMapping				= s_F18DriverEntry.inputMapping

	s_AC130DriverEntry.inputCurves:clear()
	s_AC130DriverEntry.inputCurves:add(s_F18DriverEntry.inputCurves:get(1))
	s_AC130DriverEntry.inputCurves:add(s_F18DriverEntry.inputCurves:get(2))
	s_AC130DriverEntry.inputCurves:add(s_F18DriverEntry.inputCurves:get(3))
	s_AC130DriverEntry.inputCurves:add(s_F18DriverEntry.inputCurves:get(4))

	s_AC130DriverEntry.isAllowedToExitInAir = true
	s_AC130DriverEntry.isAllowedToExitInAir = true
	s_AC130DriverEntry.isAllowedToExitInAir = true 

	s_AC130DriverEntry.entryRadius = 10
	s_AC130DriverEntry.entryOrderNumber = 0
	print("Modified entry") 

	-- Visual stuff
	s_AC130DriverEntry.components:set(2, CameraComponentData(ResourceManager:FindInstanceByGUID(Guid('3EABB4EF-4003-11E0-8ACA-C41D37DB421C'), Guid('D7A2D4BF-994B-43E7-AC1B-BBAD5F0C619F'))))
	s_AC130DriverEntry.transform.trans.y = 2

	
	local s_Engine = EngineComponentData(s_AC130Chassis.components:get(3))
	s_Engine:MakeWritable()

	s_Engine.transform.left = Vec3(1,0,0)
	s_Engine.transform.up = Vec3(0,1,0)
	s_Engine.transform.forward = Vec3(0,0,1)

	local s_JetEngineConfig = JetEngineConfigData(ResourceManager:FindInstanceByGUID(Guid('3EABB4EF-4003-11E0-8ACA-C41D37DB421C'), Guid('881DC5C3-E95A-4A0D-9D76-9DFCD9082D05')):Clone()) -- Some jet engine
	s_Engine.config = s_JetEngineConfig

	s_JetEngineConfig.boost.forwardStrength = 10  


	local s_VehicleConfig = VehicleConfigData(s_AC130Chassis.vehicleConfig)
	local s_AeroDynamics = AeroDynamicPhysicsData(s_VehicleConfig.aeroDynamicPhysics)
	s_AeroDynamics:MakeWritable()
	s_AeroDynamics.bodyDrag = Vec3(0.035,0.08,0.00375)


end


function ClearPartsFromComponents( p_Instance )
	local s_TypeInfo = p_Instance.typeInfo
	local s_Instance = _G[s_TypeInfo.name](p_Instance)
	if(s_Instance.healthStates ~= nil) then
		for k,v in ipairs(s_Instance.healthStates) do
			local s_HealthState = HealthStateData(v)
			s_HealthState:MakeWritable()
			print("Removing healthstate" .. s_HealthState.partIndex)
			s_HealthState.partIndex = 4294967295
		end
	end
	if(s_Instance.components ~= nil) then
		for k,v in ipairs(s_Instance.components) do
			s_Instance.components[k] = ClearPartsFromComponents(v:Clone())
		end
	end
	return s_Instance
end
g_DrivableACShared = DrivableACShared()

