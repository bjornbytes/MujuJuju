require 'app/particles/particle'

Lightning = extend(Particle)

Lightning.maxHealth = .225

function Lightning:init(data)
	self.range = 50
	self.targetX = data.x
	self.health = self.maxHealth
	self.prevHealth = self.health
	self.path = self:lightning()
	Particle.init(self, data)
end

function Lightning:lightning()
	local path = {}
	self.maxDistance = 0

	local start = {x = self.targetX, y = 0}
	table.insert(path, start)

	for i = 1, 10 do
		local x, y = self:randomLine(start, self.range)
		table.insert(path, {x = x, y = y})
		self.maxDistance = self.maxDistance + math.distance(path[#path].x, path[#path].y, path[#path - 1].x, path[#path - 1].y)
		start = path[#path]
	end
	table.insert(path, {x = self.targetX, y = love.graphics.getHeight() - ctx.environment.groundHeight})
	self.maxDistance = self.maxDistance + math.distance(path[#path].x, path[#path].y, path[#path - 1].x, path[#path - 1].y)

	return path
end

function Lightning:randomLine(start, range)
	local ending = {}
	ending.x = start.x + love.math.random(-range, range)
	ending.y = start.y + love.math.random(0, range * 1.5)

	return ending.x, ending.y
end

function Lightning:update()
	self.prevHealth = self.health
	self.health = timer.rot(self.health, function()
		ctx.particles:remove(self)
	end)
end

function Lightning:draw()
	local g = love.graphics
	local hp = math.lerp(self.prevHealth, self.health, tickDelta / tickRate)
	local dis = (1 - (hp / self.maxHealth)) * self.maxDistance
	
	for i = 1, #self.path - 1 do
		g.setLineWidth(3 * (1 - (dis / self.maxDistance)))
		g.setColor(255, 255, 220, 128 + (hp / self.maxHealth * 127))
		local x1, y1 = self.path[i].x, self.path[i].y
		local x2, y2 = self.path[i + 1].x, self.path[i + 1].y
		local d = math.distance(x1, y1, x2, y2)
		if d < dis then
			g.line(x1, y1, x2, y2)
			dis = dis - d
		else
			local dir = math.direction(x1, y1, x2, y2)
			g.line(x1, y1, x1 + math.dx(dis, dir), y1 + math.dy(dis, dir))
			break
		end
	end

	g.setLineWidth(1)
end

