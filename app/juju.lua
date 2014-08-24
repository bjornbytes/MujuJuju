Juju = class()

Juju.maxHealth = 100
Juju.moveSpeed = 10
Juju.depth = -6
Juju.image = love.graphics.newImage('media/graphics/juju-icon.png')

function Juju:init(data)
	-- Data = ({amount, x, y, velocity,speed})
	--self.amount = 20
	self.x = 100
	self.y = 100
	self.prevx = self.x
	self.prevy = self.y
	self.sinState = math.pi - 1
	self.angle = love.math.random() * 2 * math.pi
	self.depth = self.depth + love.math.random()
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
		--[[if (ctx.player.ghost.x >= self.x-self.amount-ctx.player.ghost.magnetRange) and (ctx.player.ghost.x <= self.x+self.amount+ctx.player.ghost.magnetRange) and (ctx.player.ghost.y >= self.y-self.amount-ctx.player.ghost.magnetRange) and (ctx.player.ghost.y<= self.y+self.amount+ctx.player.ghost.magnetRange) then
			--If mouse close to Juju
			local angle = math.atan2((ctx.player.ghost.y - self.y), (ctx.player.ghost.x - self.x))
			local dx = 50 * math.cos(angle)
			local dy = 50 * math.sin(angle)
			self.x = self.x + (dx * tickRate)
			self.y = self.y + (dy * tickRate)
			--Move Juju towards mouse
		end]]

		local ghost = ctx.player.ghost
		if math.distance(self.x, self.y, ghost.x, ghost.y) < self.amount + (65 * ctx.upgrades.muju.magnet) then
			local magnetStrength = 2 * ctx.upgrades.muju.magnet * tickRate
			self.x, self.y = math.lerp(self.x, ghost.x, magnetStrength), math.lerp(self.y, ghost.y, magnetStrength)
		end

		if math.distance(ghost.x, ghost.y, self.x, self.y) < self.amount + ghost.radius then
			--If mouse is over Juju
			ctx.player.juju = ctx.player.juju + self.amount
			--Give Muju dat Juju
			ctx.jujus:remove(self)
			--Remove da Juju mon!
			ctx.sound:play({sound = ctx.sounds.juju})
		end
	end

	if not math.inside(self.x, self.y, -self.amount, -self.amount, love.graphics.getWidth() + self.amount, love.graphics.getHeight() + self.amount) then
		ctx.jujus:remove(self)
		ctx.sound:play({sound = ctx.sounds.juju})
	end
	self.angle = self.angle + (math.sin(tick * tickRate) * math.cos(tick * tickRate)) / 10
end

function Juju:draw()
	local g = love.graphics
	local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)

	g.setColor(255, 255, 255, 180)
	g.draw(self.image, self.x, self.y, self.angle, (self.amount / 50), (self.amount / 50), self.image:getWidth() / 2, self.image:getHeight() / 2)
end
