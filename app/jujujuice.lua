JujuJuice = class()

JujuJuice.maxHealth = 100
JujuJuice.moveSpeed = 10
JujuJuice.depth = -6

function JujuJuice:init(data)
	-- Data = ({amount, x, y,, velocity,speed})
	--self.amount = 20
	self.x = 100
	self.y = 100
	self.prevx = self.x
	self.prevy = self.y
	self.velocity = 1
	self.speed = 10
	table.merge(data, self)
	ctx.view:register(self)
end

function JujuJuice:update()
	self.prevx = self.x
	self.prevy = self.y

	if self.velocity < 0 then
		self.speed = math.lerp(self.speed, -self.moveSpeed, math.min(10 * tickRate, 1))
	elseif self.velocity > 0 then
		self.speed = math.lerp(self.speed, self.moveSpeed, math.min(10 * tickRate, 1))
	else
		self.speed = math.lerp(self.speed, 0, math.min(10 * tickRate, 1))
	end
	self.x = self.x + self.speed * tickRate
	if ctx.player.jujuRealm > 0 then
		if (love.mouse.getX() >= self.x-self.amount) and (love.mouse.getX() <= self.x+self.amount) and (love.mouse.getY() >= self.y-self.amount) and (love.mouse.getY() <= self.y+self.amount) then
			ctx.player.jujuJuice = ctx.player.jujuJuice + self.amount
			ctx.jujuJuices:remove(self)
		end
	end
end

function JujuJuice:draw()
	local g = love.graphics
	local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)

	g.setColor(64, 0, 128, 160)
	g.circle('fill', x, y, self.amount)

	g.setColor(128, 0, 128)
	g.circle('line', x, y, self.amount)
end
