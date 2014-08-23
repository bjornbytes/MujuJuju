Game = class()

function Game:load()
	self.view = View()
	self.player = Player()
	self.shrine = Shrine()
	self.targets = {}

	for i = 1, 10 do
		table.insert(self.targets, i, Peon())
	end
end

function Game:update()
	self.player:update()
	self.shrine:update()
	table.each(self.targets, function(target)
		target:update()	
	end)
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
