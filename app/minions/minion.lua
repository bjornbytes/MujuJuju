Minion = class()

Minion.width = 48
Minion.height = 48

Minion.depth = -10

function Minion:init(data)
	self.target = nil
	self.fireTimer = 0
	self.y = love.graphics.getHeight() - ctx.environment.groundHeight - self.height

	table.merge(data, self)

	self.health = self.maxHealth + ctx.upgrades[self.code].fortify * 50
	self.healthDisplay = self.health

	ctx.view:register(self)
end

function Minion:update()
	self.timeScale = 1 / (1 + ctx.upgrades.muju.warp * (ctx.player.dead and 1 or 0))
	self.target = ctx.target:getClosestEnemy(self)
	if self.target ~= ctx.shrine then
		self:attack()
	end
	
	self.fireTimer = self.fireTimer - math.min(self.fireTimer, tickRate * self.timeScale)
	self:hurt(2 * tickRate)
	self.speed = math.max(self.speed - 1 * tickRate, 25)
	self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)
end

function Minion:attack()
	if self.fireTimer == 0 then		
		if self.target ~= nil then
			local dif = math.abs(self.target.x - self.x)
			if dif <= self.attackRange + self.target.width / 2 then
				self.target:hurt(self.damage)
				self.fireTimer = self.fireRate
				local cleaveLevel = ctx.upgrades.zuju.cleave
				if self.code == 'zuju' and cleaveLevel > 0 then
					local cleaveRadius = (self.width/2 + self.attackRange) + (15 * cleaveLevel)
					local cleaveDamage = self.damage/2
					ctx.particles:add(Cleave, {x = self.x, y = self.y+self.height/2, radius = cleaveRadius})
					local enemiesInRadius = ctx.target:getEnemiesInRange(self, cleaveRadius)
					local count = 0
					table.each(enemiesInRadius, function(enemy)
						if enemy ~= self.target then
							if count < cleaveLevel then
								enemy:hurt(cleaveDamage)
							end
							count = count+1
						end
					end)
				end
				ctx.sound:play({sound = ctx.sounds.combat})
			end
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
