UpgradeParticle = extend(Particle)

function UpgradeParticle:init(data)
	self.vx = love.math.randomNormal(100)
	self.vy = -100 + love.math.random() * -350
	self.gravity = love.math.randomNormal(100, 1000)
	self.gravityDecay = 1 + love.math.random() * 1
	self.size = love.math.random(2, 6)
	self.alpha = 1
	table.merge(data, self)
	ctx.view:register(self, 'gui')
end

function UpgradeParticle:update()
	self.vx = math.lerp(self.vx, 0, 2 * tickRate)
	self.vy = self.vy + self.gravity * tickRate
	self.vy = math.lerp(self.vy, 0, 2 * tickRate)
	self.gravity = math.lerp(self.gravity, 0, self.gravityDecay * tickRate)
	self.alpha = math.lerp(self.alpha, 0, 2 * tickRate)
	if self.alpha < .01 then ctx.particles:remove(self) end
	self.x = self.x + self.vx * tickRate
	self.y = self.y + self.vy * tickRate
end

function UpgradeParticle:gui()
	local g = love.graphics
	g.setColor(200, 255, 50, self.alpha * 255)
	g.circle('fill', self.x, self.y, self.size)

	g.setBlendMode('additive')
	g.setColor(220, 255, 150, self.alpha * 40)
	g.circle('fill', self.x, self.y, self.size * 1.5)
	g.setColor(255, 255, 200, self.alpha * 20)
	g.circle('fill', self.x, self.y, self.size * 2)
	g.setBlendMode('alpha')
end
