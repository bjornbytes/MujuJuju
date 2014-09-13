SpiritBomb = extend(Particle)

SpiritBomb.gravity = 700
SpiritBomb.image = love.graphics.newImage('media/graphics/spuju-skull.png')
SpiritBomb.scale = 1
SpiritBomb.maxHealth = .3
SpiritBomb.radius = 40

function SpiritBomb:init(data)
	self.owner = data.owner
	data.owner = nil
	Particle.init(self, data)
	local dx = math.abs(self.targetx - self.x)
	local dy = -Spuju.height
	local g = self.gravity
	local v = self.velocity
	local root = math.sqrt(v ^ 4 - (g * ((g * dx ^ 2) + (2 * dy * v ^ 2))))
	local angle
	if root ~= root then
		angle = math.pi / 2 + love.math.random(-math.pi / 4, math.pi / 4)
	else
		local a1, a2 = math.atan((v ^ 2 + root) / (g * dx)), math.atan((v ^ 2 - root) / (g * dx))
		angle = math.max(a1, a2)
	end
	self.vx = math.cos(angle) * v * math.sign(self.targetx - self.x)
	self.vy = math.sin(angle) * -v
	self.angle = love.math.random() * 2 * math.pi
	self.health = nil
	ctx.view:register(self)
end

function SpiritBomb:update()
	if self.health then
		self.health = timer.rot(self.health, function() ctx.particles:remove(self) end)
	else
		self.x = self.x + self.vx * tickRate
		self.y = self.y + self.vy * tickRate
		self.vy = self.vy + self.gravity * tickRate
		self.angle = self.angle + math.sign(self.vx) * tickRate
		if self.y + self.image:getWidth() >= love.graphics.getHeight() - ctx.environment.groundHeight then
			self.health = self.maxHealth
			table.each(ctx.target:getMinionsInRange(self, self.radius), function(m)
				m:hurt(self.damage)
			end)
			if math.abs(self.x - ctx.player.x) < self.radius + ctx.player.width / 2 then
				ctx.player:hurt(self.damage / 2, self.owner)
			end
			if math.abs(self.x - ctx.shrine.x) < self.radius + ctx.shrine.width / 2 then
				ctx.shrine:hurt(self.damage)
			end
		end
	end
end

function SpiritBomb:draw()
	local g = love.graphics
	if self.health then
		g.setColor(0, 255, 0, 200 * self.health / self.maxHealth)
		g.circle('fill', self.x, g.getHeight() - ctx.environment.groundHeight, self.radius)
	else
		g.setColor(255, 255, 255)
		g.draw(self.image, self.x, self.y, self.angle, self.scale, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
	end
end
