require 'app/minions/minion'

Voodoo = extend(Minion)

Voodoo.code = 'vuju'
Voodoo.cost = 10
Voodoo.cooldown = 5

Voodoo.damage = 17
Voodoo.fireRate = 1.7
Voodoo.attackRange = Voodoo.width * 8 
Voodoo.maxHealth = 70

function Voodoo:update()
	local distance = math.huge
	table.each(ctx.enemies.enemies, function(enemy)
		local dif = math.abs(enemy.x - self.x)
		if dif < distance then
			distance = dif
			self.target = enemy
		end
	end)
	
	if self.target then
		self:attack()
	end

	self.fireTimer = timer.rot(self.fireTimer)
end

function Voodoo:draw()
	local g = love.graphics

	g.setColor(255, 255, 0, 160)
	g.rectangle('fill', self.x - self.width / 2, self.y, self.width, self.height)

	g.setColor(255, 255, 0)
	g.rectangle('line', self.x - self.width / 2, self.y, self.width, self.height)

	g.setColor(255, 255, 255, 75)
	g.circle('line', self.x, self.y, self.attackRange)
end

