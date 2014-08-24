Minion = class()

Minion.width = 20
Minion.height = 20

Minion.depth = -10

function Minion:init(data)
	self.target = nil
	self.fireTimer = 0
	self.y = love.graphics.getHeight() - ctx.environment.groundHeight - self.height

	table.merge(data, self)

	self.health = self.maxHealth + ctx.upgrades[self.code].fortify * 50

	ctx.view:register(self)
end

function Minion:update()
	self.timeScale = 1 / (1 + ctx.upgrades.muju.warp * (ctx.player.dead and 1 or 0))

	
		--[[if self.x > self.width * 2 and self.x < love.graphics.getWidth() - 3 * self.width then
			self.x = self.x + self.direction * self.speed * tickRate * self.timeScale
		end
		
	else
		if math.abs(self.x - self.target.x) > self.attackRange + self.target.width / 2 then
			self.x = self.x + self.direction * self.speed * tickRate * self.timeScale
		end
		]]
	self.target = ctx.target:getClosestEnemy(self)
	if self.target == nil then
		self.target = ctx.target:getShrine(self)
	end
	local dif = self.target.x - self.x
	if math.abs(dif) > self.attackRange + self.target.width / 2 then
			self.x = self.x + self.speed * math.sign(dif) * tickRate * self.timeScale
	end
	if self.target ~= ctx.shrine then
		self:attack()
	end
	
	self.fireTimer = self.fireTimer - math.min(self.fireTimer, tickRate * self.timeScale)
end

function Minion:attack()
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
