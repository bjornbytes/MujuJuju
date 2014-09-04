BurstHeal = extend(Particle)

function BurstHeal:init(data)
	self.health = 3 + ctx.upgrades.zuju.sanctuary.level
	self.amount = (30 + (ctx.upgrades.zuju.sanctuary.level * 10)) * tickRate
	self.dept = self.depth + love.math.random()
	Particle.init(self, data)
end

function BurstHeal:update()
	local minions = ctx.target:getMinionsInRange(self, self.radius)
	table.each(minions, function(minion)
		minion.health = math.min(minion.health + self.amount, minion.maxHealth)
	end)
	self.health = timer.rot(self.health, function()
		ctx.particles:remove(self)
	end)
end

function BurstHeal:draw()
	local g = love.graphics
	g.setColor(20, 180, 20, 80 * math.min(self.health / BurstHeal.health, 1))
	g.circle('fill', self.x, self.y, self.radius)
end
