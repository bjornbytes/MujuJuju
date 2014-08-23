Shrine = class()

Shrine.width = 128 
Shrine.height = 128 

function Shrine:init()
	local g = love.graphics

	self.x = g.getWidth() / 2 - self.width / 2;
	self.y = g.getHeight() / 2 - self.height / 2;
	self.speed = 20
	self.health = 100

	ctx.view:register(self)
end

function Shrine:update()
	--
end

function Shrine:draw()
	local g = love.graphics

	g.setColor(0, 200, 200, 160)
	g.rectangle('fill', self.x, self.y, self.width, self.height)

	g.setColor(0, 200, 200)
	g.rectangle('line', self.x, self.y, self.width, self.height)
end
