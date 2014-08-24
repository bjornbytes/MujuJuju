Shrine = class()

Shrine.width = 128 
Shrine.height = 128 

Shrine.maxHealth = 10000

Shrine.depth = 5

function Shrine:init()
	local w, h = love.graphics.getDimensions()

	self.x = w / 2
	self.y = h - ctx.environment.groundHeight - self.height
	self.health = self.maxHealth
	self.image = love.graphics.newImage('media/graphics/shrine-v3.png')

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

	local scale = self.width / self.image:getWidth()
	g.setColor(150, 150, 150)
	g.draw(self.image, self.x, self.y + self.height + 12, 0, scale, scale, self.image:getWidth() / 2, self.image:getHeight())
end

function Shrine:hurt(value)
	self.health = self.health - value
	if self.health < 0 then
		return true
	end
end
