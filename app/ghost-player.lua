GhostPlayer = class()

GhostPlayer.radius = 16

function GhostPlayer:init()
	self.x = ctx.player.x
	self.y = ctx.player.y

	self.prevx = self.x
	self.prevy = self.y

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
			self.direction = self.direction - 5 * tickRate
		elseif dir > 0 then
			self.direction = self.direction + 5 * tickRate
		end
	else
		if love.keyboard.isDown('left', 'a') then
			self.direction = self.direction - 5 * tickRate
		elseif love.keyboard.isDown('right', 'd') then
			self.direction = self.direction + 5 * tickRate
		end
	end

	self.x = self.x + math.dx(300, self.direction) * tickRate
	self.y = self.y + math.dy(300, self.direction) * tickRate

	self.maxDis = math.lerp(self.maxRange, 0, (1 - (ctx.player.jujuRealm / 10)) ^ 3)
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

	g.setColor(128, 0, 255, 160)
	g.circle('fill', x, y, self.radius)

	g.setColor(128, 0, 255)
	g.circle('line', x, y, self.radius)

	g.setColor(0, 255, 255, 128)
	g.circle('line', ctx.player.x, ctx.player.y, self.maxDis)
end
