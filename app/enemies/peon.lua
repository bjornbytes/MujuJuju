require 'app/enemies/enemy'

Peon = extend(Enemy)

function Peon:init()
	Enemy:init(self)
	self.target = ctx.shrine
end

function Peon:update()
  local playerDistance = math.distance(self.x, self.y, ctx.player.x, ctx.player.y)
	local shrineDistance = math.distance(self.x, self.y, ctx.player.x, ctx.player.y)

	if playerDistance < shrineDistance then 
		self.target = ctx.player	
	else
		self.target = ctx.shrine
	end

	self.x = self.x + self.speed * math.sign(self.target.x - self.x) * tickRate
end

function Peon:draw()
	--
end
