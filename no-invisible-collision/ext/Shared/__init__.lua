function OnBlueprintCreate(hook, blueprint, transform, variation, parent)
	local instance = Blueprint(blueprint)
	
	if string.find(instance.name:lower(), "invis") then
		print("Skipped: " .. instance.name)
		-- Pass an empty blueprint to the hook
		hook:Pass(Blueprint(), transform, variation, parent)
	end
end

Hooks:Install('ServerEntityFactory:CreateFromBlueprint', 999, OnBlueprintCreate)
Hooks:Install('ClientEntityFactory:CreateFromBlueprint', 999, OnBlueprintCreate)

