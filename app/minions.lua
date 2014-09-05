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
	if minion.code == 'zuju' and ctx.upgrades.zuju.burst.level > 0 then
		local radius = (minion.width / 2) + 50
		local damage = 20 * ctx.upgrades.zuju.burst.level
		ctx.particles:add(Burst, {x = minion.x, y = minion.y, radius = radius})
		local enemiesInRadius = ctx.target:getEnemiesInRange(minion, radius)
		table.each(enemiesInRadius, function(enemy)
			enemy:hurt(damage)
		end)
		if math.abs(ctx.player.x - minion.x) < radius + ctx.player.width / 2 then
			ctx.player:hurt(damage / 2)
		end
		if ctx.upgrades.zuju.sanctuary.level > 0 then
			ctx.particles:add(BurstHeal, {x = minion.x, y = minion.y, radius = radius})
		end
	end
	if ctx.upgrades.muju.harvest.level > 0 then
		local x = love.math.random(1 + ctx.upgrades.muju.harvest.level, 3 + ctx.upgrades.muju.harvest.level * 2)
		if love.math.random() > .5 then
			ctx.jujus:add({amount = x, x = enemy.x, y = enemy.y, vx = love.math.random(-35, 35)})
		else
			ctx.jujus:add({amount = x / 2, x = enemy.x, y = enemy.y, vx = love.math.random(0, 45)})
			ctx.jujus:add({amount = x / 2, x = enemy.x, y = enemy.y, vx = love.math.random(-45, 0)})
		end
	end
	self.minions[minion] = nil
end
