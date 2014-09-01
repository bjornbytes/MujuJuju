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
	self.angle = love.math.random() * 2 * math.pi
	self.depth = self.depth + love.math.random()
	self.vy = love.math.random(-300, -100)
	self.scale = 0
	self.alpha = 0
	table.merge(data, self)
	ctx.view:register(self)
end

function Juju:update()
	self.prevx = self.x
	self.prevy = self.y

	self.vx = math.lerp(self.vx, 0, tickRate)
	self.vy = math.lerp(self.vy, 0, 2 * tickRate)
	self.x = self.x + self.vx * tickRate
	self.y = self.y + self.vy * tickRate
	if self.vy > -.1 then
		self.y = self.y - 10 * tickRate
	end

	if ctx.player.jujuRealm > 0 then
		local ghost = ctx.player.ghost
		if ctx.upgrades.muju.zeal >= 3 and math.distance(self.x, self.y, ghost.x, ghost.y) < self.amount + 120 then
			local magnetStrength = 2 * tickRate
			self.x, self.y = math.lerp(self.x, ghost.x, magnetStrength), math.lerp(self.y, ghost.y, magnetStrength)
		end

		if math.distance(ghost.x, ghost.y, self.x, self.y) < self.amount + ghost.radius then
			ctx.player.juju = ctx.player.juju + self.amount
			ctx.jujus:remove(self)
			ctx.sound:play({sound = ctx.sounds.juju})
		end
	end

	if self.y < -50 then
		ctx.jujus:remove(self)
		ctx.sound:play({sound = ctx.sounds.juju})
	end

	self.angle = self.angle + (math.sin(tick * tickRate) * math.cos(tick * tickRate)) / love.math.random(9, 11)
	self.scale = math.lerp(self.scale, math.clamp(self.amount / 50, .3, 1), 2 * tickRate)
	self.alpha = math.lerp(self.alpha, 1, 2 * tickRate)

	self.x = math.clamp(self.x, self.amount, love.graphics.getWidth() - self.amount)
end

function Juju:draw()
	local g = love.graphics
	local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
	local wave = math.sin(tick * tickRate * 4)

	g.setBlendMode('additive')
	g.setColor(255, 255, 255, 30 * self.alpha)
	g.draw(self.image, self.x, self.y + 5 * wave, self.angle, self.scale * (1.6 + wave / 12), self.scale * (1.6 + wave / 12), self.image:getWidth() / 2, self.image:getHeight() / 2)
	g.setBlendMode('alpha')

	g.setColor(255, 255, 255, 255 * self.alpha)
	g.draw(self.image, self.x, self.y + 5 * wave, self.angle, self.scale, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
end
