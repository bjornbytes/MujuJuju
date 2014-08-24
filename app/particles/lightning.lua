require 'app/particles/particle'

Lightning = extend(Particle)

Lightning.maxHealth = .2

function Lightning:init(data)
	self.range = 50
	self.targetX = data.x
	self.health = self.maxHealth
	self.path = self:lightning()
	Particle.init(self, data)
end

function Lightning:lightning()
	local path = {}

	local start = {x = self.targetX, y = 0}
	table.insert(path, start)

	for i = 1, 10 do
		local x, y = self:randomLine(start, self.range)
		table.insert(path, {x = x, y = y})
		start = path[#path]
	end
	table.insert(path, {x = self.targetX, y = love.graphics.getHeight() - ctx.environment.groundHeight})

	return path
end

function Lightning:randomLine(start, range)
	local ending = {}
	ending.x = start.x + love.math.random(-range, range)
	ending.y = start.y + love.math.random(0, range * 2)

	return ending.x, ending.y
end

function Lightning:update()
	self.health = timer.rot(self.health, function()
		ctx.particles:remove(self)
	end)
end

function Lightning:draw()
	local g = love.graphics
	g.setColor(255, 255, 220, 128 + (self.health / self.maxHealth) * 128)

	table.each(self.path, function(path, index)
		g.setLineWidth(3)
		if index < #self.path then
			g.line(path.x, path.y, self.path[index + 1].x, self.path[index + 1].y)
		end
	end)

	g.setLineWidth(1)
end

