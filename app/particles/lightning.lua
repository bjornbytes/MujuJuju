require 'app/particles/particle'

Lightning = extend(Particle)

Lightning.maxHealth = .2

function Lightning:init(data)
	self.range = 50
	self.targetX = data.x
	self.y = 0
	self.health = self.maxHealth
	Particle.init(self, data)
end

function Lightning:randomLine(range)
	local ending = {}
	ending.x = self.x + love.math.random(-range, range)
	ending.y = self.y + love.math.random(0, ctx.environment.groundHeight)

	return ending.x, ending.y
end

function Lightning:update()
	if self.health < .1 then
		self.range = 0
		self.x = self.targetX
	end

	self.health = timer.rot(self.health, function()
		ctx.particles:remove(self)
	end)
end

function Lightning:draw()
	local g = love.graphics
	g.setColor(200, 200, 0, (self.health / self.maxHealth) * 255)
	local x, y = self:randomLine(self.range)
	g.setLineWidth(love.math.random(4, 10))
	g.line(self.x, self.y, x, y)
	g.setLineWidth(1)

	self.x = x
	self.y = y
end

