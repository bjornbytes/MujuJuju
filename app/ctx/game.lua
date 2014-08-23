Game = class()

function Game:load()
	self.view = View()
	self.environment = Environment()
	self.enemies = Enemies()
	self.minions = Minions()
	self.player = Player()
	self.shrine = Shrine()
	self.jujuJuices = JujuJuices()
	self.hud = Hud()
end

function Game:update()
	self.enemies:update()
	self.minions:update()
	self.player:update()
	self.shrine:update()
	self.jujuJuices:update()
	self.view:update()
end

function Game:draw()
	self.view:draw()
end

function Game:resize()
	self.view:resize()
end

function Game:keypressed(key)
	self.player:keypressed(key)

	if key == 'escape' then
		love.event.quit()
	end
end

function Game:keyreleased(...)
	self.player:keyreleased(...)
end
