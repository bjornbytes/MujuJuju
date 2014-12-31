local Spark = class()
Spark.code = 'spark'

Spark.depth = -12

function Spark:activate()
	self.direction = love.math.random() * -math.pi
	self.speed = love.math.random(180, 700)
	self.alpha = .9
	self.length = love.math.random(4, 12)
  ctx.event:emit('view.register', {object = self})
end

function Spark:deactivate()
  ctx.event:emit('view.unreigster', {object = self})
end

function Spark:update()
	self.x = self.x + math.dx(self.speed, self.direction) * tickRate
	self.y = self.y + math.dy(self.speed, self.direction) * tickRate
	self.speed = math.lerp(self.speed, 100, 5 * tickRate)
	self.alpha = math.lerp(self.alpha, 0, 16 * tickRate)
	self.direction = self.direction + love.math.randomNormal(.05 * tickRate)
	if self.alpha < .01 then ctx.particles:remove(self) end
end

function Spark:draw()
	local g = love.graphics

	g.setBlendMode('additive')
	g.setColor(250, 250, 220, 255 * self.alpha)
	g.setLineWidth(1.5)
	g.line(self.x, self.y, self.x + math.dx(self.length, self.direction + math.pi), self.y + math.dy(self.length, self.direction + math.pi))
	g.setBlendMode('alpha')
	g.setLineWidth(1)
end

return Spark
