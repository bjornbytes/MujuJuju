GhostPlayer = class()

GhostPlayer.width = 64
GhostPlayer.height = 64

function GhostPlayer:init()
	self.x = ctx.player.x
	self.y = 10
	self.prevx = self.x
	self.prevy = self.y

	ctx.view:register(self)
end

function GhostPlayer:update()
	self.prevx = self.x
	self.prevy = self.y

	local angle = math.direction(self.x, self.y, ctx.player.x, ctx.player.y)
	local dx = 100 * math.cos(angle)
	local dy = 100 * math.sin(angle)

	self.x = self.x + dx * tickRate
	self.y = self.y + dy * tickRate
end

function GhostPlayer:despawn()
		ctx.view:unregister(self)
end

function GhostPlayer:draw()
	local g = love.graphics
	local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)

	g.setColor(128, 0, 255, self.dead and 80 or 160)
	g.rectangle('fill', x - self.width / 2, y, self.width, self.height)

	g.setColor(128, 0, 255)
	g.rectangle('line', x - self.width / 2, y, self.width, self.height)
end
