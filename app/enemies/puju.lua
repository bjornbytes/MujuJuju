require 'app/enemies/enemy'

Puju = extend(Enemy)

Puju.code = 'puju'
Puju.width = 24
Puju.height = 24
Puju.speed = 40
Puju.damage = 18
Puju.fireRate = 1.1
Puju.maxHealth = 100
Puju.attackRange = Puju.width / 2

function Puju:update()
	Enemy.update(self)
	self:chooseTarget()
end

function Puju:chooseTarget()
	if not ctx.player.dead then
		self.target = ctx.target:getClosestTarget(self)
	else
		self.target = ctx.target:getClosestNPC(self)
	end

	local dif = self.target.x - self.x
	if math.abs(dif) > self.attackRange + self.target.width / 2 then
		self.x = self.x + self.speed * math.sign(dif) * tickRate * self.timeScale * (1 - self.slow)
	end
end

function Puju:attack()
	if self.target:hurt(self.damage) then self.target = false end
	self.fireTimer = self.fireRate
end
