JujuSex = extend(Particle)

function JujuSex:init(data)
	self.vx = love.math.random(-200, 200)
	self.vy = -100 + love.math.random() * -350
	self.gravity = 1000
	self.size = love.math.random(2, 6)
	self.alpha = .7
	Particle.init(self, data)
end

function JujuSex:update()
	self.vx = math.lerp(self.vx, 0, 2 * tickRate)
	self.vy = self.vy + self.gravity * tickRate
	self.vy = math.lerp(self.vy, 0, 2 * tickRate)
	self.gravity = math.lerp(self.gravity, 0, 2 * tickRate)
	self.alpha = math.lerp(self.alpha, 0, 2 * tickRate)
	if self.alpha < .04 then ctx.particles:remove(self) end
	self.x = self.x + self.vx * tickRate
	self.y = self.y + self.vy * tickRate
end

function JujuSex:draw()
	local g = love.graphics
	g.setColor(50, 255, 50, self.alpha * 255)
	g.circle('fill', self.x, self.y, self.size)

	g.setBlendMode('additive')
	g.setColor(180, 255, 150, self.alpha * 40)
	g.circle('fill', self.x, self.y, self.size * 1.5)
	g.setColor(240, 255, 200, self.alpha * 20)
	g.circle('fill', self.x, self.y, self.size * 2)
	g.setBlendMode('alpha')
end
