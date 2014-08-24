require 'app/enemies/enemy'

SpiritBomb = extend(Enemy)

SpiritBomb.code = 'spirit-bomb'
SpiritBomb.width = 35
SpiritBomb.height = 35
SpiritBomb.maxHealth = 200
SpiritBomb.damage = 100
SpiritBomb.attackRange = 100
SpiritBomb.speed = 47

function SpiritBomb:update()
	self.timeScale = 1 / (1 + ctx.upgrades.muju.warp * (ctx.player.dead and 1 or 0))
	local dif = self.target.x - self.x
	self.target = ctx.target:getShrine(self)
	if math.abs(dif) > 20 then
		self.x = self.x + self.speed * math.sign(dif) * tickRate * self.timeScale
	else
		self:attack()
	end
end

function SpiritBomb:attack()
	local dif
	ctx.particles:add(Burst, {x = self.x, y = self.y, radius = self.attackRange})

	table.each(ctx.minions.minions, function(minion)
		dif = minion.x - self.x
		if math.abs(dif) <= self.attackRange + minion.width / 2 then
			minion:hurt(self.damage)		
		end
	end)

	dif = ctx.player.x - self.x
	if math.abs(dif) <= self.attackRange + ctx.player.width / 2 and not ctx.player.dead then
		ctx.player:hurt(self.damage)
	end

	self.target:hurt(self.damage)
	self:hurt(self.health)
end
