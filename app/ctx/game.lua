Game = class()

function Game:load()
	self.view = View()
	self.player = Player()
end

function Game:update()
	self.player:update()
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
end

function Game:keyreleased(...)
	self.player:keyreleased(...)
end
