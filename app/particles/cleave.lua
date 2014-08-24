require 'app/particles/particle'

Cleave = extend(Particle)

Cleave.maxHealth = .5

function Cleave:init(data)
	self.health = self.maxHealth
	Particle.init(self, data)
end

function Cleave:update()
	self.health = timer.rot(self.health, function() ctx.particles:remove(self) end)
end

function Cleave:draw()
	local g = love.graphics
	g.setColor(200, 200, 200, (self.health / self.maxHealth) * 255)
	g.circle('line', self.x, self.y, self.radius)
end

