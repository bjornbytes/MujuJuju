Enemies = class()

function Enemies:init()
	self.enemies = {}
	self.level = 0
	self.nextEnemy = 5
	self.minEnemyRate = 6
	self.maxEnemyRate = 9
end

function Enemies:update()
	self.nextEnemy = timer.rot(self.nextEnemy, function()
		if table.count(self.enemies) < 1 + self.level / 2 then
			local spawnType
			local x = love.math.random() > .5 and 0 or love.graphics.getWidth()

			spawnType = Puju
			if self.maxEnemyRate < 8 then
				if love.math.random() < math.min(8 - self.maxEnemyRate, 2) * .06 then
					spawnType = Spuju
				end
			end

			self:add(spawnType, {x = x})
			self.minEnemyRate = math.max(self.minEnemyRate - .055 * math.clamp(self.minEnemyRate / 5, .1, 1), 1.4)
			self.maxEnemyRate = math.max(self.maxEnemyRate - .03 * math.clamp(self.maxEnemyRate / 4, .5, 1), 2.75)
		end
		return self.minEnemyRate + love.math.random() * (self.maxEnemyRate - self.minEnemyRate)
	end)

	if not next(self.enemies) and self.level > 1 then
		self.nextEnemy = math.max(.01, lume.lerp(self.nextEnemy, 0, .75 * ls.tickrate))
	end

	table.with(self.enemies, 'update')

	self.level = self.level + ls.tickrate / (16 + self.level / 2)
end

function Enemies:add(kind, data)
	local enemy = kind(data)
	self.enemies[enemy] = enemy
end

function Enemies:remove(enemy)
	ctx.view:unregister(enemy)
	local x = love.math.random(14 + (self.level ^ .85) * .75, 20 + (self.level ^ .85))
	if love.math.random() > .5 then
		ctx.jujus:add({amount = x, x = enemy.x, y = enemy.y, vx = love.math.random(-35, 35)})
	else
		ctx.jujus:add({amount = x / 2, x = enemy.x, y = enemy.y, vx = love.math.random(0, 45)})
		ctx.jujus:add({amount = x / 2, x = enemy.x, y = enemy.y, vx = love.math.random(-45, 0)})
	end

	table.each(ctx.minions.minions, function(minion)
		if minion.target == enemy then
			minion.target = nil
		end
	end)
	self.enemies[enemy] = nil
	enemy = nil
end
