Enemies = class()

function Enemies:init()
	self.enemies = {}
	self.level = 0
	self.nextEnemy = 5
	self.minEnemyRate = 7
	self.maxEnemyRate = 9
end

function Enemies:update()
	self.nextEnemy = timer.rot(self.nextEnemy, function()
		local spawnType
		local x = love.math.random() > .5 and 0 or love.graphics.getWidth()

		spawnType = Puju
		if self.maxEnemyRate < 7 then
			if love.math.random() < .1 then
				spawnType = SpiritBomb
			end
		end

		self:add(spawnType, {x = x})
		self.minEnemyRate = math.max(self.minEnemyRate - .055, 1.4)
		self.maxEnemyRate = math.max(self.maxEnemyRate - .0675, 2.5)
		return self.minEnemyRate + love.math.random() * (self.maxEnemyRate - self.minEnemyRate)
	end)

	table.with(self.enemies, 'update')

	self.level = self.level + tickRate / (16 + self.level / 2)
end

function Enemies:add(kind, data)
	local enemy = kind(data)
	self.enemies[enemy] = enemy
end

function Enemies:remove(enemy)
	ctx.view:unregister(enemy)
	local x = love.math.random(7 + self.level * .25, 7 + math.round(self.level * 1.5))
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
end
