require 'app/enemies/enemy'

Peon = extend(Enemy)

Peon.width = 24
Peon.height = 24
Peon.speed = 50
Peon.damage = 5
Peon.fireRate = 2
Peon.health = 100
Peon.attackRange = Peon.width

function Peon:update()
	self:chooseTarget()
	Enemy.update(self)
end

function Peon:chooseTarget()
	local minion
  local playerDistance = math.abs(self.x - ctx.player.x)
	local shrineDistance = math.abs(self.x - ctx.shrine.x)

	local minionDistance = math.huge
	table.each(ctx.player.minions, function(m)
		local distance = self.x - m.x
		if distance < minionDistance then
			minionDistance = distance
			minion = m
		end
	end)

	local closest = math.min(playerDistance, shrineDistance, minionDistance)

	if playerDistance < 64 + 16 and not ctx.player.dead then
		self.target = ctx.player
	elseif minionDistance < self.width * 2 then
		self.target = minion
		minion.target = self
	else
		self.target = ctx.shrine
	end

	local dif = self.target.x - self.x
	if math.abs(dif) > self.attackRange then
		self.x = self.x + self.speed * math.sign(self.target.x - self.x) * tickRate
	end
end

function Peon:attack()
	if self.target:hurt(self.damage) then self.target = false end
	self.fireTimer = self.fireRate
end
