BurstSlow = extend(Particle)

BurstSlow.health = 3

function BurstSlow:init(data)
	self.health = BurstSlow.health
	self.amount = .3 + (ctx.upgrades.zuju.burst == 5 and .3 or 0)
	Particle.init(self, data)
end

function BurstSlow:update()
	local enemies = ctx.target:getEnemiesInRange(self, self.radius)
	table.each(enemies, function(enemy)
		enemy.slow = self.amount
	end)
	self.health = timer.rot(self.health, function()
		ctx.particles:remove(self)
	end)
end

function BurstSlow:draw()
	local g = love.graphics
	g.setColor(0, 0, 0, 80 * math.min(self.health / BurstSlow.health, 1))
	g.circle('fill', self.x, self.y, self.radius)
end
