require 'app/enemies/enemy'

Peon = extend(Enemy)

function Peon:init()
	Enemy.init(self)
	self.target = ctx.shrine
end

function Peon:update()
	self:target()
end

function Peon:target()
	local minion
  local playerDistance = math.distance(self.x, self.y, ctx.player.x, ctx.player.y)
	local shrineDistance = math.distance(self.x, self.y, ctx.shrine.x, ctx.shrine.y)

	local minionDistance = math.huge
	table.each(ctx.player.minions, function(m)
		local distance = math.distance(self.x, self.y, m.x, m.y)
		if distance < minionDistance then
			minionDistance = distance
			minion = m
		end
	end)

	local closest = math.min(playerDistance, shrineDistance, minionDistance)

	if closest == playerDistance then
		self.target = ctx.player
	elseif closest == minionDistance then
		self.target = minion
	else
		self.target = ctx.shrine
	end

	self.x = self.x + self.speed * math.sign(self.target.x - self.x) * tickRate
end
