Minion = class()

Minion.width = 20
Minion.height = 20

Minion.maxHealth = 70
Minion.speed = 10

Minion.fireRate = .8

function Minion:init(data)
	self.target = nil
	self.fireTimer = 0
	self.y = love.graphics.getHeight() - ctx.environment.groundHeight - self.height

	table.merge(data, self)
end

function Minion:update()
	if not self.target then
		self.x = self.x + self.direction * self.speed * tickRate
		local enemies = ctx.enemies.enemies
		if #enemies == 0 then
			local distances = {}
			table.each(enemies, function(enemy)
				table.insert(distances, {math.distance(self.x + self.width / 2, self.y, enemy.x + enemy.width / 2, self.y), enemy})
			end)
			table.sort(distances, function(a, b) return a[1] < b[1] end)
		end
	else
		if self.fireTimer == 0 then
			if self.target:hurt(self.damage) then
				self.target = nil
			end
			self.fireTimer = self.fireRate
		end
	end
	
	self.fireTimer = timer.rot(self.fireTimer)
end

function Minion:draw()
	--
end
