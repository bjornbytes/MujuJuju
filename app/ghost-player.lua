GhostPlayer = class()

GhostPlayer.radius = 48
GhostPlayer.first = true

function GhostPlayer:init(owner)
  self.owner = owner
	self.x = owner.x
	self.y = owner.y + owner.height
  self.alpha = 0
	self.vx = 0
	self.vy = -600
	self.prevx = self.x
	self.prevy = self.y
  self.prevalpha = self.alpha
	self.image = data.media.graphics.spiritMuju

	self.angle = -math.pi / 2
	self.maxRange = ctx.map.height - ctx.map.groundHeight

	self.maxDis = math.lerp(self.maxRange, 0, (1 - (self.owner.deathTimer / self.owner.deathDuration)) ^ 5)

	local sound = ctx.sound:play('spirit')
	if sound then sound:setVolume(.12) end

	if not ctx.effects.active then ctx.view:register(self) end
end

function GhostPlayer:update()
	self.prevx = self.x
	self.prevy = self.y
  self.prevalpha = self.alpha

	local px, py = self.owner.x, self.owner.y + self.owner.height

  if math.distance(self.x, self.y, px, py) < self.radius + 16 and self.owner:hasShruju('diffuse') and self.owner.deathDuration - self.owner.deathTimer > 1 then
    self.owner:spawn()
    return
  end

	local speed = 140 * self.owner.ghostSpeedMultiplier

	local gx, gy = 0, 0
	if self.owner.joystick then
		gx, gy = self.owner.joystick:getGamepadAxis('leftx'), self.owner.joystick:getGamepadAxis('lefty')
		if math.abs(gx) < .1 then gx = 0 end
		if math.abs(gy) < .1 then gy = 0 end
	end

	if gx ~= 0 or gy ~= 0 then
		self.vx = math.lerp(self.vx, speed * gx, 8 * ls.tickrate)
		self.vy = math.lerp(self.vy, speed * gy, 8 * ls.tickrate)
		if gx < 0 then
			self.angle = math.anglerp(self.angle, -math.pi / 2 - (math.pi / 7 * (self.vx / -speed)), 12 * ls.tickrate)
		elseif gx > 0 then
			self.angle = math.anglerp(self.angle, -math.pi / 2 + (math.pi / 7 * (self.vx / speed)), 12 * ls.tickrate)
		end
	else
		if love.keyboard.isDown('left', 'a') then
			self.vx = math.lerp(self.vx, -speed, 8 * ls.tickrate)
			self.angle = math.anglerp(self.angle, -math.pi / 2 - (math.pi / 7 * (self.vx / -speed)), 12 * ls.tickrate)
		elseif love.keyboard.isDown('right', 'd') then
			self.vx = math.lerp(self.vx, speed, 8 * ls.tickrate)
			self.angle = math.anglerp(self.angle, -math.pi / 2 + (math.pi / 7 * (self.vx / speed)), 12 * ls.tickrate)
		else
			self.vx = math.lerp(self.vx, 0, 2 * ls.tickrate)
		end

		if love.keyboard.isDown('up', 'w') then
			self.vy = math.lerp(self.vy, -speed, 8 * ls.tickrate)
		elseif love.keyboard.isDown('down', 's') then
			self.vy = math.lerp(self.vy, speed, 8 * ls.tickrate)
		else
			self.vy = math.lerp(self.vy, 0, 2 * ls.tickrate)
		end
	end

	local len = (self.vx ^ 2 + self.vy ^ 2) ^ .5
	if len > 0 and self.owner.deathTimer < self.owner.deathDuration - 1 then
		self.vx = (self.vx / len) * math.min(len, speed)
		self.vy = (self.vy / len) * math.min(len, speed)
	end

	self.x = self.x + self.vx * ls.tickrate
	self.y = self.y + self.vy * ls.tickrate

  local contained = false
	self.maxDis = math.lerp(self.maxRange, 0, (1 - (self.owner.deathTimer / self.owner.deathDuration)) ^ 5)
	if math.distance(self.x, self.y, px, py) + self.radius > self.maxDis then
		local angle = math.direction(px, py, self.x, self.y)
		self.x = math.lerp(self.x, px + math.dx(self.maxDis - self.radius, angle), 1)
		self.y = math.lerp(self.y, py + math.dy(self.maxDis - self.radius, angle), 1)
    contained = true
	end

	self.x = math.clamp(self.x, self.radius, ctx.map.width - self.radius)
	self.y = math.clamp(self.y, self.radius, ctx.map.height - self.radius - ctx.map.groundHeight)

	local scale = math.min(self.owner.deathTimer, 2) / 2
	if self.owner.deathDuration - self.owner.deathTimer < 1 then
		scale = self.owner.deathDuration - self.owner.deathTimer
	end
  if ctx.tutorial.active then scale = 1 end
	scale = .4 + scale * .4
	self.radius = 40 * scale
  self.alpha = math.min(self.alpha + ls.tickrate, 1)

  ctx.particles:emit('ghosttrail', self.x, self.y, math.min(math.round(len / speed, 1) + (contained and 1 or 0)), {
    linearAcceleration = {-self.vx * 1, -self.vy * 1, -self.vx * 1.5, -self.vy * 1.5}
  })
end

function GhostPlayer:despawn()
	GhostPlayer.first = false
	if not ctx.effects.active then ctx.view:unregister(self) end
end

function GhostPlayer:draw()
	local g = love.graphics
	local x, y = math.lerp(self.prevx, self.x, ls.accum / ls.tickrate), math.lerp(self.prevy, self.y, ls.accum / ls.tickrate)
  local alpha = math.lerp(self.prevalpha, self.alpha, ls.accum / ls.tickrate)

	local scale = math.min(self.owner.deathTimer, 2) / 2
	if self.owner.deathDuration - self.owner.deathTimer < 1 then
		scale = self.owner.deathDuration - self.owner.deathTimer
	end
  if ctx.tutorial.active then scale = 1 end
	scale = .4 + scale * .4
	local alphaScale = math.min(self.owner.deathTimer * 6 / self.owner.deathDuration, 1)
  local color = {128, 0, 255}
  color = table.interpolate(color, {255, 255, 255}, .8)
  color[4] = 200 * alpha * alphaScale
	g.setColor(color)
	g.draw(self.image, x, y, self.angle, .6 * scale, .6 * scale, self.image:getWidth() / 2, self.image:getHeight() / 2)

  g.setBlendMode('additive')
  color[4] = 75 * alpha * alphaScale
	g.setColor(color)
	g.draw(self.image, x, y, self.angle, .75 * scale, .75 * scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
  color[4] = 30 * alpha * alphaScale
	g.setColor(color)
	g.draw(self.image, x, y, self.angle, 1 * scale, 1 * scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
  g.setBlendMode('alpha')

	g.setColor(255, 255, 255, 15)
	g.arc('fill', self.owner.x, self.owner.y + self.owner.height, self.maxDis, 0, -math.pi, self.maxDis / 2)
end
