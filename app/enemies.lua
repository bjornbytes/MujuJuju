Enemies = class()

function Enemies:init()
	self.enemies = {}
	self.nextEnemy = 1
	self.enemyRate = 7
end

function Enemies:update()
	self.nextEnemy = timer.rot(self.nextEnemy, function()
		local x = love.math.random() > .5 and 0 or love.graphics.getWidth()
		self:add(Peon, {x = x})
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
	local randomNum = love.math.random(10, 50)
	if randomNum <= 13 then
		ctx.jujuJuices:add({amount = randomNum, x = enemy.x, y = enemy.y - love.math.random(50, 250), velocity = love.math.random(-1, 1),speed = love.math.random(1, 15)})
	elseif randomNum > 13 then
		ctx.jujuJuices:add({amount = math.max(3,randomNum/1.5), x = enemy.x, y = enemy.y - love.math.random(50, 250), velocity = love.math.random(-1, 1),speed = love.math.random(1, 15)})
		ctx.jujuJuices:add({amount = math.max(3,randomNum/2), x = enemy.x, y = enemy.y - love.math.random(50, 250), velocity = love.math.random(-1, 1),speed = love.math.random(1, 15)})
	end
	if randomNum > 25 then
		ctx.jujuJuices:add({amount = math.max(1,randomNum/3), x = enemy.x, y = enemy.y - love.math.random(50, 250), velocity = love.math.random(-1, 1),speed = love.math.random(1, 15)})
	end

	--ctx.jujuJuices:add({amount = love.math.random(1, 20), x = enemy.x, y = enemy.y - love.math.random(50, 250), velocity = love.math.random(-1, 1),speed = love.math.random(1, 15)})

	table.each(ctx.minions.minions, function(minion)
		if minion.target == enemy then
			minion.target = nil
		end
	end)

	self.enemies[enemy] = nil
end
