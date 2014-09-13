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
	self.dead = false
	table.merge(data, self)

	for i = 1, 15 do
		ctx.particles:add(JujuSex, {x = self.x, y = self.y})
	end
	ctx.view:register(self)
end

function Juju:update()
	self.prevx = self.x
	self.prevy = self.y
	
	if self.dead then
		local tx, ty = 52, 52
		self.x, self.y = math.lerp(self.x, tx, 10 * tickRate), math.lerp(self.y, ty, 10 * tickRate)
		self.scale = math.lerp(self.scale, .1, 5 * tickRate)
		if math.distance(self.x, self.y, tx, ty) < 16 then
			ctx.jujus:remove(self)
			ctx.player.juju = ctx.player.juju + self.amount
			ctx.hud.jujuIconScale = 1
			for i = 1, 20 do
				ctx.particles:add(JujuSex, {x = tx, y = ty})
			end
		end
		for i = 1, 2 do
			ctx.particles:add(JujuSex, {x = self.x, y = self.y})
		end
		return
	end

	self.vx = math.lerp(self.vx, 0, tickRate)
	self.vy = math.lerp(self.vy, 0, 2 * tickRate)
	self.x = self.x + self.vx * tickRate
	self.y = self.y + self.vy * tickRate
	if self.vy > -.1 then
		self.y = self.y - 10 * tickRate
	end
	
	if love.math.random() < 2 * tickRate then
		ctx.particles:add(JujuSex, {x = self.x, y = self.y, vy = love.math.random(-150, -75), vx = love.math.random(-100, 100), alpha = .35})
	end

	if ctx.player.jujuRealm > 0 then
		local ghost = ctx.player.ghost
		if ctx.upgrades.muju.absorb.level > 0 then
			local distance, direction = math.vector(self.x, self.y, ghost.x, ghost.y)
			local threshold = self.amount + 75 + 50 * ctx.upgrades.muju.absorb.level
			local factor = math.clamp((threshold - distance) / threshold, 0, 1)
			local speed = threshold * factor * tickRate
			self.x = self.x + math.dx(speed, direction)
			self.y = self.y + math.dy(speed, direction)
		end

		if math.distance(ghost.x, ghost.y, self.x, self.y) < self.amount + ghost.radius then
			ctx.sound:play({sound = ctx.sounds['juju1']})
			self.dead = true
		end
	end

	if self.y < -50 then
		ctx.jujus:remove(self)
	end

	self.angle = self.angle + (math.sin(tick * tickRate) * math.cos(tick * tickRate)) / love.math.random(9, 11)
	self.scale = math.lerp(self.scale, math.clamp(self.amount / 50, .25, .6), 2 * tickRate)
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
