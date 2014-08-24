Enemies = class()

function Enemies:init()
	self.enemies = {}
	self.nextEnemy = 5
	self.minEnemyRate = 7
	self.maxEnemyRate = 10
end

function Enemies:update()
	self.nextEnemy = timer.rot(self.nextEnemy, function()
		local spawnType
		local x = love.math.random() > .5 and 0 or love.graphics.getWidth()

		spawnType = Peon
		if self.maxEnemyRate < 5 then
			if love.math.random() < .3 then
				spawnType = SpiritBomb
			end
		end

		self:add(spawnType, {x = x})
		self.minEnemyRate = math.max(self.minEnemyRate - .05, 1.5)
		self.maxEnemyRate = math.max(self.maxEnemyRate - .08, 2.5)
		return self.minEnemyRate + love.math.random() * (self.maxEnemyRate - self.minEnemyRate)
	end)

	table.with(self.enemies, 'update')
end

function Enemies:add(kind, data)
	local enemy = kind(data)
	self.enemies[enemy] = enemy
end

function Enemies:remove(enemy)
	ctx.view:unregister(enemy)
	local x = love.math.random(30, 45)
	if love.math.random() > .5 then
		ctx.jujus:add({amount = x, x = enemy.x, y = enemy.y, velocity = math.floor(love.math.random(-0.9, 1.9)), speed = love.math.random(1, 15)})
	else
		ctx.jujus:add({amount = x / 2, x = enemy.x, y = enemy.y, velocity = -1, speed = love.math.random(1, 25)})
		ctx.jujus:add({amount = x / 2, x = enemy.x, y = enemy.y, velocity = 1, speed = love.math.random(1, 25)})
	end

	table.each(ctx.minions.minions, function(minion)
		if minion.target == enemy then
			minion.target = nil
		end
	end)

	if self.code == 'zuju' and ctx.upgrades.zuju.burst > 0 then
		local radius = 100 * ctx.upgrades.zuju.burst
		local damage = 30 * ctx.upgrades.zuju.burst
		ctx.particles:add(Burst, {x = self.x, y = self.y, radius = radius})
		table.each(ctx.enemies.enemies, function(enemy)
			if math.distance(self.x, self.y, enemy.x, enemy.y) < radius then
				enemy:hurt(damage)
			end
		end)
	end

	self.enemies[enemy] = nil
end
