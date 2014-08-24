require 'app/enemies/enemy'

SpiritBomb = extend(Enemy)

SpiritBomb.width = 35
SpiritBomb.height = 35
SpiritBomb.maxHealth = 200
SpiritBomb.damage = 100
SpiritBomb.attackRange = 0
SpiritBomb.speed = 7

function SpiritBomb:update()
	Enemy.update(self)

	local dif
	local minion
	local minionDistance = math.huge
	table.each(ctx.minions.minions, function(m)
		local distance = math.abs(self.x - m.x)
		if distance < minionDistance then
			minionDistance = distance
			minion = m
		end
	end)

	if minion then
		dif = minion.x - self.x
		if math.abs(dif) < self.width / 2 then
			minion.target = self
		end
	end

	dif = self.target.x - self.x
	if math.abs(dif) > self.attackRange + self.target.width / 2 then
		self.x = self.x + self.speed * math.sign(dif) * tickRate * self.timeScale
	end
end

function SpiritBomb:attack()
	self.target:hurt(self.damage)
	self:hurt(self.health)
end
