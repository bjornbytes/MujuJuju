Shrine = class()

Shrine.width = 128 
Shrine.height = 128 

Shrine.depth = 5

function Shrine:init()
	local w, h = love.graphics.getDimensions()

	self.x = w / 2 - self.width / 2
	self.y = h - ctx.environment.groundHeight - self.height
	self.health = 100

	ctx.view:register(self)
end

function Shrine:update()
	if self.health <= 0 then
		Context:remove(ctx)
		Context:add(Game)
	end
end

function Shrine:draw()
	local g = love.graphics

	g.setColor(0, 200, 200, 160)
	g.rectangle('fill', self.x, self.y, self.width, self.height)

	g.setColor(0, 200, 200)
	g.rectangle('line', self.x, self.y, self.width, self.height)
end

function Shrine:hurt(value)
	self.health = self.health - value
	if self.health < 0 then
		return true
	end
end
