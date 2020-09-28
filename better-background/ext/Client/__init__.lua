Events:Subscribe('Partition:Loaded', function(partition)
	for _, instance in pairs(partition.instances) do
		if instance.instanceGuid == Guid('9CDAC6C3-9D3E-48F1-B8D9-737DB28AE936') then -- menu UI/Assets/MenuVisualEnvironment
			local s_Instance = ColorCorrectionComponentData(instance)
			s_Instance:MakeWritable()
			s_Instance.enable = false
			s_Instance.brightness = Vec3(1, 1, 1)
			s_Instance.contrast = Vec3(1.2, 1.2, 1.2)
			s_Instance.saturation = Vec3(1, 1, 1)
		end
		if instance.instanceGuid == Guid('46FE1C37-5B7E-490C-8239-2EB2D6045D7B') then -- oob FX/VisualEnviroments/OutofCombat/OutofCombat
			local s_Instance = ColorCorrectionComponentData(instance)
			s_Instance:MakeWritable()
			s_Instance.enable = false
			s_Instance.brightness = Vec3(0.8, 0.8, 0.8)
			s_Instance.contrast = Vec3(1, 1, 1)
			s_Instance.saturation = Vec3(1, 1, 1)
		end

		if instance.instanceGuid == Guid('36C2CEAE-27D2-45F3-B3F5-B831FE40ED9B') then -- FX/VisualEnviroments/OutofCombat/OutofCombat
			local s_Instance = FilmGrainComponentData(instance)
			s_Instance:MakeWritable()
			s_Instance.enable = false
		end
	end
end)