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

		if spawnChance > 50 and spawnChance < 60 then
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
	local randomNum = love.math.random(10, 35)
	if randomNum <= 13 then
		ctx.jujus:add({amount = randomNum, x = enemy.x, y = enemy.y - love.math.random(50, 250), velocity = love.math.random(-1, 1),speed = love.math.random(1, 15)})
	elseif randomNum > 13 then
		ctx.jujus:add({amount = math.max(7,randomNum/1.5), x = enemy.x, y = enemy.y - love.math.random(50, 250), velocity = love.math.random(-1, 1),speed = love.math.random(1, 15)})
		ctx.jujus:add({amount = math.max(7,randomNum/2), x = enemy.x, y = enemy.y - love.math.random(50, 250), velocity = love.math.random(-1, 1),speed = love.math.random(1, 15)})
	end
	if randomNum > 25 then
		ctx.jujus:add({amount = math.max(1,randomNum/4), x = enemy.x, y = enemy.y - love.math.random(50, 250), velocity = love.math.random(-1, 1),speed = love.math.random(1, 15)})
	end

	--ctx.jujus:add({amount = love.math.random(1, 20), x = enemy.x, y = enemy.y - love.math.random(50, 250), velocity = love.math.random(-1, 1),speed = love.math.random(1, 15)})

	table.each(ctx.minions.minions, function(minion)
		if minion.target == enemy then
			minion.target = nil
		end
	end)

	self.enemies[enemy] = nil
end
