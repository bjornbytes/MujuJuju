require('app/minions/minion')

Imp = extend(Minion)

Imp.code = 'zuju'
Imp.cost = 10
Imp.cooldown = 2

Imp.speed = 60
Imp.damage = 35
Imp.fireRate = 1.7
Imp.attackRange = Imp.width / 2
Imp.maxHealth = 70
function Imp:update()
	Minion.update(self)
	if self.target == nil then
		self.target = ctx.target:getShrine(self)
	end
	local dif = self.target.x - self.x
	if math.abs(dif) > self.attackRange + self.target.width / 2 then
		self.x = self.x + self.speed * math.sign(dif) * tickRate * self.timeScale
	end
end