local Lifesteal = class()
Lifesteal.code = 'lifesteal'

function Lifesteal:activate()
	self.vx = love.math.random(-100, 100)
	self.vy = love.math.random(-300, -150)
	self.alpha = 1
  ctx.event:emit('view.register', {object = self})
end

function Lifesteal:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Lifesteal:update()
	self.x = self.x + self.vx * tickRate
	self.y = self.y + self.vy * tickRate
	self.vy = self.vy + 1000 * tickRate
	self.alpha = math.lerp(self.alpha, 0, 3 * tickRate)
	if self.alpha < .05 then ctx.particles:remove(self) end
end

function Lifesteal:draw()
	local g = love.graphics
	g.setColor(0, 255, 0, 255 * self.alpha)
	g.circle('fill', self.x, self.y, 4)
end

return Lifesteal
