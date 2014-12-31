local JujuSex = class()
JujuSex.code = 'jujuSex'

function JujuSex:activate()
  self.prevx = self.x
  self.prevy = self.y
	self.vx = self.vx or love.math.random(-200, 200)
	self.vy = self.vy or (-100 + love.math.random() * -350)
	self.gravity = 1000
	self.size = love.math.random(2, 6)
	self.alpha = .7
  if ctx.effects and ctx.effects:get('bloom') then
    ctx.event:emit('view.unreigster', {object = self})
  end
end

function JujuSex:update()
  self.prevx = self.x
  self.prevy = self.y
	self.vx = math.lerp(self.vx, 0, 2 * tickRate)
	self.vy = self.vy + self.gravity * tickRate
	self.vy = math.lerp(self.vy, 0, 2 * tickRate)
	self.gravity = math.lerp(self.gravity, 0, 2 * tickRate)
	self.alpha = math.lerp(self.alpha, 0, 2 * tickRate)
	if self.alpha < .01 then ctx.particles:remove(self) end
	self.x = self.x + self.vx * tickRate
	self.y = self.y + self.vy * tickRate
end

function JujuSex:draw()
	local g = love.graphics
  local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
	g.setColor(150, 255, 50, self.alpha * 255)
	g.circle('fill', x, y, self.size)

	g.setBlendMode('additive')
	g.setColor(200, 255, 150, self.alpha * 40)
	g.circle('fill', x, y, self.size * 1.5)
	g.setColor(225, 255, 200, self.alpha * 20)
	g.circle('fill', x, y, self.size * 2)
	g.setBlendMode('alpha')
end

return JujuSex
