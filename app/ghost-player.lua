GhostPlayer = class()

GhostPlayer.radius = 48
GhostPlayer.first = true

function GhostPlayer:init(owner)
  self.owner = owner
	self.x = owner.x
	self.y = owner.y + owner.height
	self.vx = 0
	self.vy = -600
	self.magnetRange = 15
	self.prevx = self.x
	self.prevy = self.y
	self.image = data.media.graphics.spiritMuju

	self.angle = -math.pi / 2
	self.maxRange = 500

	local maxJuju = 7
	self.maxDis = math.lerp(self.maxRange, 0, (1 - (self.owner.deathTimer / maxJuju)) ^ 3)

	local sound = ctx.sound:play({sound = 'spirit'})
	if sound then sound:setVolume(.12) end

	ctx.view:register(self)
end

function GhostPlayer:update()
	local maxJuju = 7

	self.prevx = self.x
	self.prevy = self.y

	local px, py = self.owner.x, self.owner.y + self.owner.height

	local speed = 140

	local gx, gy = 0, 0
	if self.owner.gamepad then
		gx, gy = self.owner.gamepad:getGamepadAxis('leftx'), self.owner.gamepad:getGamepadAxis('lefty')
		if math.abs(gx) < .1 then gx = 0 end
		if math.abs(gy) < .1 then gy = 0 end
	end

	if gx ~= 0 or gy ~= 0 then
		self.vx = math.lerp(self.vx, speed * gx, 8 * tickRate)
		self.vy = math.lerp(self.vy, speed * gy, 8 * tickRate)
		if gx < 0 then
			self.angle = math.anglerp(self.angle, -math.pi / 2 - (math.pi / 7 * (self.vx / -speed)), 12 * tickRate)
		elseif gx > 0 then
			self.angle = math.anglerp(self.angle, -math.pi / 2 + (math.pi / 7 * (self.vx / speed)), 12 * tickRate)
		end
	else
		if love.keyboard.isDown('left', 'a') then
			self.vx = math.lerp(self.vx, -speed, 8 * tickRate)
			self.angle = math.anglerp(self.angle, -math.pi / 2 - (math.pi / 7 * (self.vx / -speed)), 12 * tickRate)
		elseif love.keyboard.isDown('right', 'd') then
			self.vx = math.lerp(self.vx, speed, 8 * tickRate)
			self.angle = math.anglerp(self.angle, -math.pi / 2 + (math.pi / 7 * (self.vx / speed)), 12 * tickRate)
		else
			self.vx = math.lerp(self.vx, 0, 2 * tickRate)
		end

		if love.keyboard.isDown('up', 'w') then
			self.vy = math.lerp(self.vy, -speed, 8 * tickRate)
		elseif love.keyboard.isDown('down', 's') then
			self.vy = math.lerp(self.vy, speed, 8 * tickRate)
		else
			self.vy = math.lerp(self.vy, 0, 2 * tickRate)
		end
	end

	local len = (self.vx ^ 2 + self.vy ^ 2) ^ .5
	if len > 0 and self.owner.deathTimer < maxJuju - 1 then
		self.vx = (self.vx / len) * math.min(len, speed)
		self.vy = (self.vy / len) * math.min(len, speed)
	end

	self.x = self.x + self.vx * tickRate
	self.y = self.y + self.vy * tickRate

	self.maxDis = math.lerp(self.maxRange, 0, (1 - (self.owner.deathTimer / maxJuju)) ^ 3)
	if math.distance(self.x, self.y, px, py) > self.maxDis then
		local angle = math.direction(px, py, self.x, self.y)
		self.x = math.lerp(self.x, px + math.dx(self.maxDis, angle), 8 * tickRate)
		self.y = math.lerp(self.y, py + math.dy(self.maxDis, angle), 8 * tickRate)
	end

	self.x = math.clamp(self.x, self.radius, love.graphics.getWidth() - self.radius)
	self.y = math.clamp(self.y, self.radius, love.graphics.getHeight() - self.radius - ctx.map.groundHeight)

	local scale = math.min(self.owner.deathTimer, 2) / 2
	local maxJuju = 7
	if maxJuju - self.owner.deathTimer < 1 then
		scale = maxJuju - self.owner.deathTimer
	end
	scale = .4 + scale * .4
	self.radius = 40 * scale
end

function GhostPlayer:despawn()
	GhostPlayer.first = false
	ctx.view:unregister(self)
end

function GhostPlayer:draw()
	local g = love.graphics
	local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)

	local scale = math.min(self.owner.deathTimer, 2) / 2
	local maxJuju = 7
	if maxJuju - self.owner.deathTimer < 1 then
		scale = maxJuju - self.owner.deathTimer
	end
	scale = .4 + scale * .4
	local alphaScale = math.min(self.owner.deathTimer * 6 / maxJuju, 1)
	g.setColor(255, 255, 255, 30 * alphaScale)
	g.draw(self.image, x, y, self.angle, 1 * scale, 1 * scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
	g.setColor(255, 255, 255, 75 * alphaScale)
	g.draw(self.image, x, y, self.angle, .75 * scale, .75 * scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
	g.setColor(255, 255, 255, 200 * alphaScale)
	g.draw(self.image, x, y, self.angle, .6 * scale, .6 * scale, self.image:getWidth() / 2, self.image:getHeight() / 2)

	g.setColor(255, 255, 255, 10)
	g.circle('fill', self.owner.x, self.owner.y + self.owner.height, self.maxDis)
end
