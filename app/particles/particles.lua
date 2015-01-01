Particles = class()

function Particles:init()
	self.particles = {}
end

function Particles:update()
	table.with(self.particles, 'update')
end

function Particles:add(kind, data)
	local particle = kind(data)
	self.particles[particle] = particle
	return particle
end

function Particles:remove(particle)
  ctx.event:emit('view.unregister', {object = particle})
	self.particles[particle] = nil
end
