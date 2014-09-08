Tutorial = class()

local function goToGame()
	Context:remove(ctx)
	Context:add(Game)
end

function Tutorial:init()
	self.bg = love.graphics.newImage('media/graphics/tutorial.png')
end

Tutorial.keypressed = goToGame
Tutorial.mousepressed = goToGame
Tutorial.gamepadpressed = goToGame

function Tutorial:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.bg)
end
