Target = class()

function Target:init()
end

function Target:getClosestTarget(source)
	local closestTarget, distance
	local kind = getmetatable(source).__index
	local super = getmetatable(kind).__index
	if super == Enemy or super == Minion then
  		kind = super
	end
	if (kind == Enemy) then
		closestTarget, distance = self:compareDistance(source,self:compareDistance(source,ctx.player,ctx.shrine),self:getClosestMinion(source))
	elseif (kind == Minion) then
		closestTarget, distance = self:compareDistance(source,self:compareDistance(source,ctx.player,ctx.shrine),self:getClosestEnemy(source))
	elseif (kind == Player) then
		closestTarget, distance = self:compareDistance(source,ctx.shrine,self:compareDistance(source,self:getClosestEnemy(source),self:getClosestMinion(source)))
	else
		closestTarget, distance = self:compareDistance(source,self:compareDistance(source,ctx.player,ctx.shrine),self:compareDistance(source,self:getClosestEnemy(source),self:getClosestMinion(source)))
	end
	return closestTarget, distance
end

function Target:getClosestNPC(source)
	local closestTarget, distance
	local kind = getmetatable(source).__index
	local super = getmetatable(kind).__index
	if super == Enemy or super == Minion then
  		kind = super
	end
	if (kind == Enemy) then
		closestTarget, distance = self:compareDistance(source,ctx.shrine,self:getClosestMinion(source))
	elseif (kind == Minion) then
		closestTarget, distance = self:compareDistance(source,ctx.shrine,self:getClosestEnemy(source))
	else
		closestTarget, distance = self:compareDistance(source,ctx.shrine,self:compareDistance(source,self:getClosestEnemy(source),self:getClosestMinion(source)))
	end
	return closestTarget, distance
end

function Target:getClosestEnemy(source)
	if not next(ctx.enemies.enemies) then
		return nil
	end
	local closestEnemy
	local enemyDistance = math.huge
	table.each(ctx.enemies.enemies, function(e)
		if e ~= source and not e.dead then
			local distance = math.abs(source.x - e.x)
			if distance < enemyDistance then
				enemyDistance = distance
				closestEnemy = e
			end
		end
	end)
	return closestEnemy, enemyDistance
end

function Target:getClosestMinion(source)
	if not next(ctx.minions.minions) then
		return nil
	end
	local closestMinion
	local minionDistance = math.huge
	table.each(ctx.minions.minions, function(m)
		if source ~= m and not m.dead then
			local distance = math.abs(source.x - m.x)
			if distance < minionDistance then
				minionDistance = distance
				closestMinion = m
			end
		end
	end)
	return closestMinion, minionDistance
end

function Target:getMinionsInRange(source, range)
	local minions = {}
	table.each(ctx.minions.minions, function(m)
		local dif = math.abs(source.x - m.x)
		if dif <= range + m.width / 2 then
			table.insert(minions, m)
		end
	end)
	return minions
end

function Target:getEnemiesInRange(source, range)
	if not next(ctx.enemies.enemies) then
		return nil
	end
	local enemiesInRange = {}
	table.each(ctx.enemies.enemies, function(e)
		local distance = math.abs(source.x - e.x)
		if e ~= source and distance <= range + e.width / 2 then
			table.insert(enemiesInRange,e)
		end
	end)
	return enemiesInRange
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
	if unit1 == nil then
		return unit2
	end
	if unit2 == nil then
		return unit1
	end
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
