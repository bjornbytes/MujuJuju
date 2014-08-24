Target = class()

function Target:init()
end

function Target:getClosest(source)
	local closestTarget, distance = compareDistance(source,compareDistance(source,ctx.player,ctx.shrine),compareDistance(source,getClosestEnemy(source),getClosestMinion(source)))
	return closestTarget, distance
end

function Target:getClosestEnemy(source)
	local closestEnemy
	local enemyDistance = math.huge
	table.each(ctx.enemies.enemies, function(e)
		local distance = math.abs(source.x - e.x)
		if distance < enemyDistance then
			enemyDistance = distance
			closestEnemy = e
		end
	end)
	return closestEnemy, enemyDistance
end

function Target:getClosestMinion(source)
	local closestMinion
	local minionDistance = math.huge
	table.each(ctx.minions.minions, function(m)
		local distance = math.abs(source.x - m.x)
		if distance < minionDistance then
			minionDistance = distance
			closestMinion = m
		end
	end)
	return closestMinion, minionDistance
end

function Target:getPlayer(source)
	local distance = math.abs(source.x - ctx.player.x)
	return ctx.player, distance
end

function Target:getShrine(source)
	local distance = math.abs(source.x - ctx.shrine.x)
	return ctx.shrine, distance
end

function Target:compareDistance(source, unit1, unit2)
	local unit1Distance = math.abs(source.x - unit1.x)
	local unit2Distance = math.abs(source.x - unit2.x)
	local closerUnit = unit1
	local distance = unit1Distance
	if unit1Distance > unit2Distance then
		closerUnit = unit2
		distance = unit2Distance
	end
	return closerUnit, distance
end
