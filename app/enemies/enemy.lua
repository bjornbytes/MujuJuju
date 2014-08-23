Enemy = class()

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
	if self.target and self.fireTimer == 0 and math.abs(self.x - self.target.x) <= self.attackRange then
		self:attack()
	end

	self.fireTimer = timer.rot(self.fireTimer)
end

function Enemy:draw()
	local g = love.graphics

	g.setColor(255, 0, 0, 160)
	g.rectangle('fill', self.x - self.width / 2, self.y, self.width, self.height)

	g.setColor(255, 0, 0)
	g.rectangle('line', self.x - self.width / 2, self.y, self.width, self.height)
end
