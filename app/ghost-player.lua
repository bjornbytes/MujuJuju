GhostPlayer = class()

GhostPlayer.radius = 48

function GhostPlayer:init()
	self.x = ctx.player.x
	self.y = ctx.player.y + ctx.player.height
	self.vx = 0
	self.vy = -600
	self.magnetRange = 15
	self.prevx = self.x
	self.prevy = self.y
	self.image = love.graphics.newImage('media/graphics/spiritmuju.png')

	self.angle = -math.pi / 2
	self.maxRange = 500

	local maxJuju = 7
	self.maxDis = math.lerp(self.maxRange, 0, (1 - (ctx.player.jujuRealm / maxJuju)) ^ 3)

	local sound = ctx.sound:play({sound = 'spirit'})
	if sound then sound:setVolume(.15) end

	ctx.view:register(self)
end

function GhostPlayer:update()
	local maxJuju = 7

	self.prevx = self.x
	self.prevy = self.y

	local px, py = ctx.player.x, ctx.player.y + ctx.player.height

	local speed = 140 + (28 * ctx.upgrades.muju.zeal.level)

	local gx, gy = 0, 0
	if ctx.player.gamepad then
		gx, gy = ctx.player.gamepad:getGamepadAxis('leftx'), ctx.player.gamepad:getGamepadAxis('lefty')
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
	if len > 0 and ctx.player.jujuRealm < maxJuju - 1 then
		self.vx = (self.vx / len) * math.min(len, speed)
		self.vy = (self.vy / len) * math.min(len, speed)
	end

	self.x = self.x + self.vx * tickRate
	self.y = self.y + self.vy * tickRate

	self.maxDis = math.lerp(self.maxRange, 0, (1 - (ctx.player.jujuRealm / maxJuju)) ^ 3)
	if math.distance(self.x, self.y, px, py) > self.maxDis then
		local angle = math.direction(px, py, self.x, self.y)
		self.x = math.lerp(self.x, px + math.dx(self.maxDis, angle), 8 * tickRate)
		self.y = math.lerp(self.y, py + math.dy(self.maxDis, angle), 8 * tickRate)
	end

	self.x = math.clamp(self.x, self.radius, love.graphics.getWidth() - self.radius)
	self.y = math.clamp(self.y, self.radius, love.graphics.getHeight() - self.radius - ctx.environment.groundHeight)

	local scale = math.min(ctx.player.jujuRealm, 2) / 2
	local maxJuju = 7
	if maxJuju - ctx.player.jujuRealm < 1 then
		scale = maxJuju - ctx.player.jujuRealm
	end
	scale = .4 + scale * .4
	self.radius = 40 * scale
	
	if ctx.upgrades.muju.diffuse.level == 1 and ctx.player.jujuRealm < 5 and math.distance(self.x, self.y, px, py) < self.radius * 2 then
		ctx.player.jujuRealm = .1
	end
end

function GhostPlayer:despawn()
	ctx.view:unregister(self)
end

function GhostPlayer:draw()
	local g = love.graphics
	local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)

	local scale = math.min(ctx.player.jujuRealm, 2) / 2
	local maxJuju = 7
	if maxJuju - ctx.player.jujuRealm < 1 then
		scale = maxJuju - ctx.player.jujuRealm
	end
	scale = .4 + scale * .4
	local alphaScale = math.min(ctx.player.jujuRealm * 6 / maxJuju, 1)
	g.setColor(255, 255, 255, 30 * alphaScale)
	g.draw(self.image, x, y, self.angle, 1 * scale, 1 * scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
	g.setColor(255, 255, 255, 75 * alphaScale)
	g.draw(self.image, x, y, self.angle, .75 * scale, .75 * scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
	g.setColor(255, 255, 255, 200 * alphaScale)
	g.draw(self.image, x, y, self.angle, .6 * scale, .6 * scale, self.image:getWidth() / 2, self.image:getHeight() / 2)

	g.setColor(255, 255, 255, 10)
	g.circle('fill', ctx.player.x, ctx.player.y + ctx.player.height, self.maxDis)
end
