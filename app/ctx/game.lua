Game = class()

function Game:load()
	self.view = View()
	self.environment = Environment()
	self.enemies = Enemies()
	self.player = Player()
	self.shrine = Shrine()
end

function Game:update()
	self.enemies:update()
	self.player:update()
	self.shrine:update()
	self.view:update()
end

function Game:draw()
	self.view:draw()
end

function Game:resize()
	self.view:resize()
end

function Game:keypressed(...)
	self.player:keypressed(...)

	if key == 'escape' then
		love.event.quit()
	end
end

function Game:keyreleased(...)
	self.player:keyreleased(...)
end
