Enemy = class()

Enemy.width = 24
Enemy.height = 24
Enemy.speed = 50
Enemy.damage = 5
Enemy.fireRate = 10
Enemy.health = 100
Enemy.depth = -5

function Enemy:init(data)
	self.target = ctx.shrine
	self.x = 0
	self.y = love.graphics.getHeight() - ctx.environment.groundHeight - self.height
	self.fireTimer = 0

	table.merge(data, self)	
	ctx.view:register(self)
end

function Enemy:update()
	--
end

function Enemy:draw()
	local g = love.graphics

	g.setColor(255, 0, 0, 160)
	g.rectangle('fill', self.x, self.y, self.width, self.height)

	g.setColor(255, 0, 0)
	g.rectangle('line', self.x, self.y, self.width, self.height)

end
