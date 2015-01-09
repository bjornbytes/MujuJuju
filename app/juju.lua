Juju = class()

Juju.maxHealth = 100
Juju.moveSpeed = 10
Juju.depth = -6

function Juju:init(data)
	self.x = 100
	self.y = 100
	self.prevx = self.x
	self.prevy = self.y
	self.angle = love.math.random() * 2 * math.pi
	self.depth = self.depth + love.math.random()
	self.vy = love.math.random(-300, -100)
	self.scale = 0
	self.alpha = 0
	self.dead = false
	table.merge(data, self)

  ctx.particles:emit('jujusex', self.x, self.y, 30)
end

function Juju:update()
  local p = ctx.player

	self.prevx = self.x
	self.prevy = self.y
	
	if self.dead then
		local tx, ty = 866, 18
		self.x, self.y = math.lerp(self.x, tx, 10 * tickRate), math.lerp(self.y, ty, 10 * tickRate)
		self.scale = math.lerp(self.scale, .1, 5 * tickRate)
		if math.distance(self.x, self.y, tx, ty) < 16 then
			ctx.jujus:remove(self)
      p:addJuju(self.amount)
			ctx.hud.status.jujuScale = 2
      ctx.hud.status.jujuAngle = 0
      ctx.particles:emit('jujusex', self.x, self.y, 30, {speed = {80, 100}})
		end
    ctx.particles:emit('jujusex', self.x, self.y, 3)
		return
	end

	self.vx = math.lerp(self.vx, 0, tickRate)
	self.vy = math.lerp(self.vy, 0, 2 * tickRate)
	self.x = self.x + self.vx * tickRate
	self.y = self.y + self.vy * tickRate
	if self.vy > -.1 then
		self.y = self.y - 10 * tickRate
	end
	
  if love.math.random() < 3 * tickRate then
    ctx.particles:emit('jujusex', self.x, self.y, 1, {speed = {60, 80}})
  end

	if p.deathTimer > 0 then
		local ghost = p.ghost

    local distance, direction = math.vector(self.x, self.y, ghost.x, ghost.y)
    local threshold = self.amount + 90
    local factor = math.clamp((threshold - distance) / threshold, 0, 1)
    local speed = threshold * (factor ^ .1) * tickRate * 4
    self.x = self.x + math.dx(speed, direction)
    self.y = self.y + math.dy(speed, direction)

		if math.distance(ghost.x, ghost.y, self.x, self.y) < self.amount + ghost.radius then
			ctx.sound:play('juju1')
			self.dead = true
		end
	end

	if self.y < -self.scale * data.media.graphics.juju:getWidth() then
		ctx.jujus:remove(self)
	end

	self.angle = self.angle + (math.sin(tick * tickRate) * math.cos(tick * tickRate)) / love.math.random(9, 11)
	self.scale = math.lerp(self.scale, .15 + (math.min(self.amount, 200) / 200), 2 * tickRate)
	self.alpha = math.lerp(self.alpha, p.ded and 1 or .5, 10 * tickRate)

	self.x = math.clamp(self.x, self.amount * 2, love.graphics.getWidth() - self.amount * 2)
end

function Juju:draw()
	local g = love.graphics
  local image = data.media.graphics.juju
	local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
	local wave = math.sin(tick * tickRate * 4)

	g.setColor(255, 255, 255, 255 * self.alpha)
	g.draw(image, self.x, self.y + 5 * wave, self.angle, self.scale, self.scale, image:getWidth() / 2, image:getHeight() / 2)

	g.setBlendMode('additive')
	g.setColor(255, 255, 255, 40 * self.alpha)
	g.draw(image, self.x, self.y + 5 * wave, self.angle, self.scale * (1.5 + wave / 12), self.scale * (1.5 + wave / 12), image:getWidth() / 2, image:getHeight() / 2)
	g.setBlendMode('alpha')
end
