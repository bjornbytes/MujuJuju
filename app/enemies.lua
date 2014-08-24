Enemies = class()

function Enemies:init()
	self.enemies = {}
	self.nextEnemy = 1
	self.enemyRate = 7
end

function Enemies:update()
	self.nextEnemy = timer.rot(self.nextEnemy, function()
		local spawnType
		local x = love.math.random() > .5 and 0 or love.graphics.getWidth()
		local spawnChance = math.ceil(math.random() * 100)
	
		if spawnChance > 0 and spawnChance < 60 then
			spawnType = SpiritBomb
		-- Add more enemies with ranges or specifc spawn numbers
		else
			spawnType = Peon
		end

		self:add(spawnType, {x = x})
		self.enemyRate = math.max(self.enemyRate - .1, 1)
		return self.enemyRate
	end)

	table.with(self.enemies, 'update')
end

function Enemies:add(kind, data)
	local enemy = kind(data)
	self.enemies[enemy] = enemy
end

function Enemies:remove(enemy)
	ctx.view:unregister(enemy)
	local randomNum = love.math.random(10, 45)
	if randomNum <= 20 then
		ctx.jujus:add({amount = randomNum, x = enemy.x, y = enemy.y, velocity = math.floor(love.math.random(-0.9, 1.9)),speed = love.math.random(1, 15)})
	elseif randomNum > 20 and randomNum <= 30 then
		ctx.jujus:add({amount = randomNum*0.25, x = enemy.x, y = enemy.y, velocity = -1,speed = love.math.random(1, 25)})
		ctx.jujus:add({amount = randomNum*0.75, x = enemy.x, y = enemy.y, velocity = 1,speed = love.math.random(1, 25)})
	elseif randomNum > 30 then
		ctx.jujus:add({amount = randomNum*0.15, x = enemy.x, y = enemy.y, velocity = 1,speed = love.math.random(1, 25)})
		ctx.jujus:add({amount = randomNum*0.35, x = enemy.x, y = enemy.y, velocity = -1,speed = love.math.random(1, 25)})
		ctx.jujus:add({amount = randomNum*0.50, x = enemy.x, y = enemy.y, velocity = 0,speed = love.math.random(1, 25)})
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
