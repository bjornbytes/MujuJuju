Enemy = class()

Enemy.x = 0
Enemy.y = 0
Enemy.width = 64
Enemy.height = 64
Enemy.speed = 50
Enemy.damage = 5
Enemy.fireRate = 10
Enemy.health = 100
Enemy.depth = .5

function Enemy:init(data)
	self.target = ctx.shrine
	table.merge(data, self)	

	ctx.view:register(self)
end

function Enemy:update()
	local playerDistance = math.distance(self.x, self.y, ctx.player.x, ctx.player.y)
	local shrineDistance = math.distance(self.x, self.y, ctx.player.x, ctx.player.y)

	if playerDistance < shrineDistance then 
		self.target = ctx.player	
	else
		self.target = ctx.shrine
	end

	self.x = self.x + self.speed * math.sign(self.target.x - self.x) * tickRate
end

function Enemy:draw()
	local g = love.graphics

	g.setColor(255, 0, 0, 160)
	g.rectangle('fill', self.x, self.y, self.width, self.height)

	g.setColor(255, 0, 0)
	g.rectangle('line', self.x, self.y, self.width, self.height)

end
