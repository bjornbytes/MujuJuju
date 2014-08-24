require 'app/minions/minion'

Voodoo = extend(Minion)

Voodoo.code = 'vuju'
Voodoo.cost = 30 
Voodoo.cooldown = 5
Voodoo.maxHealth = 70

Voodoo.damage = 17
Voodoo.fireRate = 1.7
Voodoo.attackRange = Voodoo.width * 8 
Voodoo.curseFireRate = 6

function Voodoo:init()
	self.curseFireTimer = 0
	Minion.init(self)
end

function Voodoo:update()
	Minion.update(self)

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
		ctx.particles:add(Lightning, {x = self.target.x})
	end

	self.fireTimer = self.fireTimer - math.min(self.fireTimer, tickRate * self.timeScale)
	self.curseFireTimer = self.curseFireTimer - math.min(self.curseFireTimer, tickRate * self.timeScale)
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

function Voodoo:attack()
	Minion.attack(self)

	if self.curseFireTimer == 0 and ctx.upgrades.vuju.curse > 0 then
		ctx.particles:add(Curse, {x = self.target.x - Curse.width / 2, y = self.target.y - 16})
		table.each(ctx.enemies.enemies, function(enemy)
			if self.curseFireTimer > 0 then
				-- curse you!
			end
		end)
		self.curseFireTimer = self.curseFireRate - (.5 * ctx.upgrades.vuju.curse)
	end
end

