Enemies = class()

function Enemies:init()
	self.enemies = {}
	self.nextEnemy = 1
	self.enemyRate = 5
end

function Enemies:update()
	self.nextEnemy = timer.rot(self.nextEnemy, function()
		local x = love.math.random() > .5 and 0 or love.graphics.getWidth()
		self:add(Enemy)
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
	self.enemies[enemy] = nil
end
