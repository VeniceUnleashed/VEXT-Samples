Hooks:Install('Soldier:Damage', 100, function(hook, soldier, info, giverInfo)
	-- Don't modify healing damage.
	if info.damage < 0 then
		return
	end

	local infected = isInfected(soldier.player)

	if not infected then
		if soldier.health - info.damage <= 0 then
			infectPlayer(soldier.player)
			hook:Return()
		end

		return
	end

	local isHeadshot = info.boneIndex == 1

	-- 10 players vs 1 zombie. All 10 players need to shoot at zombie for 10 seconds to kill it.
	-- 15 bullets per second for LMG.
	-- 10 seconds at 150 hits / second
	-- 1500 hits

	local baseDamage = 10
	local headshotMultiplier = 1.125

	local infectedToPlayersRatio = getInfectedCount() / getHumanCount()

	local finalDamage = (baseDamage * infectedToPlayersRatio)

	if isHeadshot then
		finalDamage = finalDamage * headshotMultiplier
	end

	info.damage = finalDamage
	hook:Pass(soldier, info)
end)
