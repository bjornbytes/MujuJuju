Minions = class()

function Minions:init()
	self.minions = {}
end

function Minions:update()
	table.with(self.minions, 'update')
end

function Minions:add(kind, data)
	local minion = kind(data)
	self.minions[minion] = minion
end

function Minions:remove(minion)
	ctx.view:unregister(minion)
	if minion.code == 'zuju' and ctx.upgrades.zuju.burst > 0 then
		local radius = (minion.width / 1.5) + (25 * ctx.upgrades.zuju.burst)
		local damage = 20 * ctx.upgrades.zuju.burst
		ctx.particles:add(Burst, {x = minion.x, y = minion.y, radius = radius})
		local enemiesInRadius = ctx.target:getEnemiesInRange(minion, radius)
		table.each(enemiesInRadius, function(enemy)
			enemy:hurt(damage)
		end)
		if ctx.upgrades.zuju.burst >= 3 then
			ctx.particles:add(BurstSlow, {x = minion.x, y = minion.y, radius = radius})
		end
	end
	self.minions[minion] = nil
end
