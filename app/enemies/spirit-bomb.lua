require 'app/enemies/enemy'

SpiritBomb = extend(Enemy)

SpiritBomb.width = 35
SpiritBomb.height = 35
SpiritBomb.maxHealth = 200
SpiritBomb.damage = 100
SpiritBomb.attackRange = 0
SpiritBomb.speed = 7

function SpiritBomb:update()
	local dif = self.target.x - self.x
	if math.abs(dif) > self.attackRange + self.target.width / 2 then
		self.x = self.x + self.speed * math.sign(dif) * tickRate
	end

	Enemy.update(self)
end

function SpiritBomb:attack()
	self.target:hurt(self.damage)
	self:hurt(self.health)
end
