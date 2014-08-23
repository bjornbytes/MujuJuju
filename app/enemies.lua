Enemies = class()

function Enemies:init()
	self.enemies = {}
	self.nextEnemy = 1
	self.enemyRate = 5
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
	jujuJuices:add({amount = love.math.random(1, 50), x = enemy.x, y = enemy.y + love.math.random(50, 250), velocity = love.math.random(-1, 1),speed = love.math.random(1, 15)})
	self.enemies[enemy] = nil
end
