Minion = class()

Minion.width = 20
Minion.height = 20

Minion.depth = -10

function Minion:init(data)
	self.target = nil
	self.fireTimer = 0
	self.y = love.graphics.getHeight() - ctx.environment.groundHeight - self.height

	table.merge(data, self)

	self.health = self.maxHealth

	ctx.view:register(self)
end

function Minion:update()
	if not self.target then
		if self.x > self.width * 2 and self.x < love.graphics.getWidth() - 3 * self.width then
			self.x = self.x + self.direction * self.speed * tickRate
		end
	else
		if math.abs(self.x - self.target.x) > self.attackRange + self.target.width / 2 then
			self.x = self.x + self.direction * self.speed * tickRate
		end

		if self.fireTimer == 0 then
			local dif = math.abs(self.target.x - self.x)
			if dif <= self.attackRange + self.target.width / 2 then
				if self.target:hurt(self.damage) then
					self.target = nil
				end
				self.fireTimer = self.fireRate
			end
		end
	end
	
	self.fireTimer = timer.rot(self.fireTimer)
end

function Minion:hurt(amount)
	self.health = self.health - amount
	if self.health <= 0 then
		ctx.minions:remove(self)
		return true
	end
end

function Minion:draw()
	local g = love.graphics

	g.setColor(0, 255, 0, 160)
	g.rectangle('fill', self.x - self.width / 2, self.y, self.width, self.height)

	g.setColor(0, 255, 0)
	g.rectangle('line', self.x - self.width / 2, self.y, self.width, self.height)
end
