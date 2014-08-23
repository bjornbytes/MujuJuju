Juju = class()

Juju.maxHealth = 100
Juju.moveSpeed = 10
Juju.depth = -6

function Juju:init(data)
	-- Data = ({amount, x, y, velocity,speed})
	--self.amount = 20
	self.x = 100
	self.y = 100
	self.prevx = self.x
	self.prevy = self.y
	self.sinState = math.pi - 1
	--self.velocity = 1
	--self.speed = 20
	table.merge(data, self)
	ctx.view:register(self)
end

function Juju:update()
	self.prevx = self.x
	self.prevy = self.y
	if self.sinState < math.pi then
		self.sinState = self.sinState + 0.1
	else
		self.sinState = 0
	end

	if self.velocity < 0 then
		self.speed = math.lerp(self.speed, -self.moveSpeed, math.min(10 * tickRate, 1))
	elseif self.velocity > 0 then
		self.speed = math.lerp(self.speed, self.moveSpeed, math.min(10 * tickRate, 1))
	else
		self.speed = math.lerp(self.speed, 0, math.min(10 * tickRate, 1))
	end
	self.x = self.x + self.speed * tickRate
	self.y = self.y - (self.y/6) * tickRate
	self.y = self.y + math.sin(self.sinState)
	if ctx.player.jujuRealm > 0 then
		--If Muju dead
		if (ctx.player.ghost.x >= self.x-self.amount-15) and (ctx.player.ghost.x <= self.x+self.amount+15) and (ctx.player.ghost.y >= self.y-self.amount-15) and (ctx.player.ghost.y<= self.y+self.amount+15) then
			--If mouse close to Juju
			local angle = math.atan2((ctx.player.ghost.y - self.y), (ctx.player.ghost.x - self.x))
			local dx = 50 * math.cos(angle)
			local dy = 50 * math.sin(angle)
			self.x = self.x + (dx * tickRate)
			self.y = self.y + (dy * tickRate)
			--Move Juju towards mouse
		end
		if math.distance(ctx.player.ghost.x, ctx.player.ghost.y, self.x, self.y) < self.amount + ctx.player.ghost.radius then
			--If mouse is over Juju
			ctx.player.juju = ctx.player.juju + self.amount/2
			--Give Muju dat Juju
			ctx.jujus:remove(self)
			--Remove da Juju mon!
		end
	end

	if not math.inside(self.x, self.y, 0, 0, love.graphics.getDimensions()) then
		ctx.jujus:remove(self)
	end
end

function Juju:draw()
	local g = love.graphics
	local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)

	g.setColor(64, 0, 128, 160)
	--g.circle('fill', x, y, math.max(20,self.amount*3))
	g.circle('fill', x, y, self.amount)

	g.setColor(128, 0, 128)
	--g.circle('line', x, y, math.max(20,self.amount*3))
	g.circle('line', x, y, self.amount)
end
