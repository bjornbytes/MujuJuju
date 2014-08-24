require 'app/particles/particle'

Burst = extend(Particle)

Burst.maxHealth = .5

function Burst:init(data)
	self.health = self.maxHealth
	Particle.init(self, data)
end

function Burst:update()
	self.health = timer.rot(self.health, function() ctx.particles:remove(self) end)
end

function Burst:draw()
	local g = love.graphics
	g.setColor(200, 0, 0, (self.health / self.maxHealth) * 255)
	g.circle('fill', self.x, self.y, self.radius)
end

