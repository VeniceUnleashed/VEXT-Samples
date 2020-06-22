local function onEntityDamage(entity, damageInfo, damageGiverInfo)
    if damageGiverInfo.giver ~= nil and damageGiverInfo.giver.soldier ~= nil then
        local playerDamage = DamageInfo()
        playerDamage.damage = 10

        damageGiverInfo.giver.soldier:ApplyDamage(playerDamage)
    end

    return damageGiverInfo.giver == nil
end

Hooks:Install('EntityFactory:Create', 100, function(hook, data, transform)
    local entity = hook:Call()

    if entity ~= nil and entity:Is('ServerPhysicsEntity') then
        entity = PhysicsEntity(entity)
        entity:RegisterDamageCallback(onEntityDamage)
    end

    hook:Return(entity)
end)
