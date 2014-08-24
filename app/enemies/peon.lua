require 'app/enemies/enemy'

Peon = extend(Enemy)

Peon.width = 24
Peon.height = 24
Peon.speed = 40
Peon.damage = 18
Peon.fireRate = 1.1
Peon.maxHealth = 100
Peon.attackRange = Peon.width / 2

function Peon:update()
	Enemy.update(self)
	self:chooseTarget()
end

function Peon:chooseTarget()
	if not ctx.player.dead then
		self.target = ctx.target:getClosestTarget(self)
	else
		self.target = ctx.target:getClosestNPC(self)
	end

	local dif = self.target.x - self.x
	if math.abs(dif) > self.attackRange + self.target.width / 2 then
		self.x = self.x + self.speed * math.sign(dif) * tickRate * self.timeScale
	end
end

function Peon:attack()
	if self.target:hurt(self.damage) then self.target = false end
	self.fireTimer = self.fireRate
end
