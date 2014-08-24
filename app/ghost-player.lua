GhostPlayer = class()

GhostPlayer.radius = 16

function GhostPlayer:init()
	self.x = ctx.player.x
	self.y = ctx.player.y
	self.magnetRange = 15
	self.prevx = self.x
	self.prevy = self.y
	self.image = love.graphics.newImage('media/graphics/spiritmuju.png')

	self.direction = -math.pi / 2
	self.maxRange = 500

	ctx.view:register(self)
end

function GhostPlayer:update()
	self.prevx = self.x
	self.prevy = self.y

	if love.mouse.isDown('l') then
		local dir = math.anglediff(self.direction, math.direction(self.x, self.y, love.mouse.getPosition()))
		if dir < 0 then
			self.direction = self.direction - 12 * tickRate
		elseif dir > 0 then
			self.direction = self.direction + 12 * tickRate
		end
	else
		if love.keyboard.isDown('left', 'a') then
			self.direction = self.direction - 8 * tickRate
		elseif love.keyboard.isDown('right', 'd') then
			self.direction = self.direction + 8 * tickRate
		end
	end

	self.x = self.x + math.dx(300, self.direction) * tickRate
	self.y = self.y + math.dy(300, self.direction) * tickRate

	local maxJuju = 6 + math.min(tick * tickRate / 45, 4)
	self.maxDis = math.lerp(self.maxRange, 0, (1 - (ctx.player.jujuRealm / maxJuju)) ^ 3)
	if math.distance(self.x, self.y, ctx.player.x, ctx.player.y) > self.maxDis then
		local angle = math.direction(ctx.player.x, ctx.player.y, self.x, self.y)
		self.x, self.y = ctx.player.x + math.dx(self.maxDis, angle), ctx.player.y + math.dy(self.maxDis, angle)
	end

	self.x = math.clamp(self.x, self.radius, love.graphics.getWidth() - self.radius)
	self.y = math.clamp(self.y, self.radius, love.graphics.getHeight() - self.radius - ctx.environment.groundHeight)
end

function GhostPlayer:despawn()
		ctx.view:unregister(self)
end

function GhostPlayer:draw()
	local g = love.graphics
	local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)

	local scale = math.min(ctx.player.jujuRealm, 2) / 2
	local maxJuju = 6 + math.min(tick * tickRate / 45, 4)
	if maxJuju - ctx.player.jujuRealm < 1 then
		scale = maxJuju - ctx.player.jujuRealm
	end
	scale = .4 + scale * .6
	g.setColor(255, 255, 255, 50)
	g.draw(self.image, x, y, self.direction + (math.pi / 2), 1 * scale, 1 * scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
	g.setColor(255, 255, 255, 75)
	g.draw(self.image, x, y, self.direction + (math.pi / 2), .75 * scale, .75 * scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
	g.setColor(255, 255, 255, 200)
	g.draw(self.image, x, y, self.direction + (math.pi / 2), .6 * scale, .6 * scale, self.image:getWidth() / 2, self.image:getHeight() / 2)

	g.setColor(255, 255, 255, 10 * (ctx.player.jujuRealm / maxJuju))
	g.circle('fill', ctx.player.x, ctx.player.y, self.maxDis)
end
