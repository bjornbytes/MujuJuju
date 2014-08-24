Tutorial = class()

function Tutorial:init()
	self.bg = love.graphics.newImage('media/graphics/tutorial.png')
end

function Tutorial:keypressed(key)
	Context:remove(ctx)
	Context:add(Game)
end

function Tutorial:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.bg)
end
