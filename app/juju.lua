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
end

function Juju:update()
  local p = ctx.player

	self.prevx = self.x
	self.prevy = self.y

	if self.dead then
		local tx, ty = 866, 18
		self.x, self.y = math.lerp(self.x, tx, 10 * ls.tickrate), math.lerp(self.y, ty, 10 * ls.tickrate)
		self.scale = math.lerp(self.scale, .1, 5 * ls.tickrate)
		if math.distance(self.x, self.y, tx, ty) < 16 then
			ctx.jujus:remove(self)
      p:addJuju(self.amount)
      ctx.event:emit('juju.collected', {juju = self})
			ctx.hud.status.jujuScale = 2
      ctx.hud.status.jujuAngle = 0
      ctx.particles:emit('jujusex', self.x, self.y, 40)
		end
    local dis, dir = math.vector(self.x, self.y, self.prevx, self.prevy)
    for i = 1, 5 do
      local d = love.math.random() * dis
      ctx.particles:emit('jujudrop', self.x + math.dx(d, dir), self.y + math.dy(d, dir), 1)
    end
		return
	end

	self.vx = math.lerp(self.vx, 0, ls.tickrate)
	self.vy = math.lerp(self.vy, 0, 2 * ls.tickrate)
	self.x = self.x + self.vx * ls.tickrate
	self.y = self.y + self.vy * ls.tickrate
	if self.vy > -.1 then
		self.y = self.y - 10 * ls.tickrate
	end

  if love.math.random() < 3 * ls.tickrate then
    local sizes = love.math.random() < .5 and {.2, 0} or {.2, .4}
    ctx.particles:emit('jujudrop', self.x, self.y, 1, {sizes = sizes})
  end

	if p.deathTimer > 0 then
		local ghost = p.ghost

    local distance, direction = math.vector(self.x, self.y, ghost.x, ghost.y)
    local threshold = self.amount + 90
    local exponent = ctx.player:hasShruju('absorb') and .5 or .1
    if ctx.player:hasShruju('absorb') then threshold = threshold * 2 end
    local factor = math.clamp((threshold - distance) / threshold, 0, 1)
    local speed = threshold * (factor ^ exponent) * ls.tickrate * 4
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

	self.angle = self.angle + (math.sin(tick * ls.tickrate) * math.cos(tick * ls.tickrate)) / love.math.random(9, 11)
	self.scale = math.lerp(self.scale, .15 + (math.min(self.amount, 200) / 200), 2 * ls.tickrate)
	self.alpha = math.lerp(self.alpha, p.ded and 1 or .5, 10 * ls.tickrate)

	self.x = math.clamp(self.x, self.amount * 2, ctx.map.width - self.amount * 2)
end

function Juju:draw()
	local g = love.graphics
  local image = data.media.graphics.juju
	local x, y = math.lerp(self.prevx, self.x, ls.accum / ls.tickrate), math.lerp(self.prevy, self.y, ls.accum / ls.tickrate)
	local wave = math.sin(tick * ls.tickrate * 4)

	ctx.jujus.spriteBatch:setColor(255, 255, 255, 255 * self.alpha)
  ctx.jujus.spriteBatch:add(self.x, self.y + 3 * wave, self.angle, self.scale, self.scale, image:getWidth() / 2, image:getHeight() / 2)
end
