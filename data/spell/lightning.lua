local Lightning = class()

Lightning.maxHealth = .2

function Lightning:activate()
	self.range = 50
	self.health = self.maxHealth
	self.prevHealth = self.health
	self.sparked = false
	self:lightning()
  ctx.event:emit('view.register', {object = self})
end

function Lightning:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Lightning:lightning()
	local function t(x, y)
		table.insert(self.path, x)
		table.insert(self.path, y)
	end

	self.path = {}
	self.distance = 0
	if not self.target then return end

	local x, y = self.x, self.y
	t(x, y)

	for i = 0, 1, .1 do
		if i == 1 then t(self.target.x, self.target.y) break end
		x, y = math.lerp(self.x, self.target.x, i), math.lerp(self.y, self.target.y, i)
		local n1, n2 = love.math.noise(x * y * i), love.math.noise(x / (1 + y) / (1 + i))
		n1, n2 = 2 * n1 - 1, 2 * n2 - 1
		x = x + 50 * n1
		y = y + 50 * n2
		if #self.path > 0 then
			self.distance = self.distance + math.distance(self.path[#self.path - 1], self.path[#self.path], x, y)
		end
		t(x, y)
	end
end

function Lightning:update()
	self.prevHealth = self.health
	self.health = timer.rot(self.health, function()
		ctx.spells:remove(self)
	end)
	if not self.sparked and self.health < self.maxHealth / 2 then
		for i = 1, 12 do
      ctx.event:emit('particles.add', {kind = 'spark', x = self.path[#self.path - 1], y = self.path[#self.path]})
		end
		self.sparked = true
	end
end

function Lightning:draw()
	local g = love.graphics
	local hp = math.lerp(self.prevHealth, self.health, tickDelta / tickRate)
	local dis = self.distance * (1 - math.max((hp / self.maxHealth) - .5, 0) * 2)
	
	for i = 1, #self.path - 2, 2 do
		g.setLineWidth(3 * (1 - (dis / self.distance)))
		g.setColor(255, 255, 220, math.min(2 * hp / self.maxHealth, 1) * 255)
		local x1, y1 = self.path[i], self.path[i + 1]
		local x2, y2 = self.path[i + 2], self.path[i + 3]
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

return Lightning
