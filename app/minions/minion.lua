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
	self.target = ctx.target:getClosestEnemy(self)
	if self.target ~= ctx.shrine then
		self:attack()
	end
	
	self.fireTimer = self.fireTimer - math.min(self.fireTimer, tickRate * self.timeScale)
	self:hurt(2 * tickRate)
	self.speed = self.speed - 1 * tickRate
end

function Minion:attack()
	if self.fireTimer == 0 then		
		if self.target ~= nil then
			local dif = math.abs(self.target.x - self.x)
			local targets = ctx.target:getEnemiesInRange(self, dif + self.attackRange * (ctx.upgrades.zuju.cleave+1))
			if dif <= self.attackRange + self.target.width / 2 then				
				if ctx.upgrades.zuju.cleave == 0 then
					if self.target:hurt(self.damage) then
						self.target = nil
					end
				else
					if self.target:hurt(self.damage) then
						self.target = nil
					end
					for i = 1, math.min(ctx.upgrades.zuju.cleave + 1, #targets) do
						if targets[i] ~= self.target then
							targets[i]:hurt(self.damage)
						end
					end
				end
				self.fireTimer = self.fireRate
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
