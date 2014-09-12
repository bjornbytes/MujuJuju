BurstHeal = extend(Particle)


function BurstHeal:init(data)
	self.health = 2 + ctx.upgrades.zuju.sanctuary.level
	self.maxHealth = self.health
	self.amount = (ctx.upgrades.zuju.sanctuary.level * 10) * tickRate
	self.depth = 0 + love.math.random()
	Particle.init(self, data)
end

function BurstHeal:update()
	local minions = ctx.target:getMinionsInRange(self, self.radius)
	table.each(minions, function(minion)
		local heal = (not minion.lastSanctuary or minion.lastSanctuary ~= tick) and self.amount or self.amount / 2
		minion.health = math.min(minion.health + heal, minion.maxHealth)
		minion.lastSanctuary = tick
	end)
	self.health = timer.rot(self.health, function()
		ctx.particles:remove(self)
	end)
end

function BurstHeal:draw()
	local g = love.graphics
	g.setColor(20, 180, 20, 80 * math.min(self.health / self.maxHealth, 1))
	g.circle('fill', self.x, self.y, self.radius)
end
