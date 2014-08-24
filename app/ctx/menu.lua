Menu = class()

function Menu:init()
	self.sound = Sound()
	self.menuSounds = self.sound:play({sound = 'menu'})
	self.bg = love.graphics.newImage('media/graphics/main-menu.png')
	self.font = love.graphics.newFont('media/fonts/pixel.ttf', 8)
	self.creditsAlpha = 0
end

function Menu:update()
	self.creditsAlpha = timer.rot(self.creditsAlpha)
end

function Menu:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.bg)
	love.graphics.setFont(self.font)
	love.graphics.setColor(255, 255, 255, math.min(self.creditsAlpha * 255, 255))
	love.graphics.print('We do not mind who gets the credit.', 2, 0)
end

function Menu:keypressed(key)
	
end

function Menu:keyreleased(key)

end

function Menu:mousepressed(x, y, b)
	if math.inside(x, y, 435, 220, 190, 90) then
		self.menuSounds:stop()
		Context:remove(ctx)
		Context:add(Tutorial)
	elseif math.inside(x, y, 425, 335, 210, 90) then
		print('Harry Truman bitch!')
		self.creditsAlpha = 2
	elseif math.inside(x, y, 455, 445, 160, 90) then
		love.event.quit()
	end
end

function Menu:mousereleased(x, y, b)

end
