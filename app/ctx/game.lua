Game = class()

function Game:load()
	self.view = View()
	self.environment = Environment()
	self.enemies = Enemies()
	self.player = Player()
	self.shrine = Shrine()
	self.hud = Hud()

	self.jujujuice = JujuJuice({amount = love.math.random(1, 50), x = love.math.random(1, 500), y = love.math.random(1, 500), velocity = love.math.random(-1, 1),speed = love.math.random(1, 15)})
end

function Game:update()
	self.enemies:update()
	self.player:update()
	self.shrine:update()
	
	self.jujujuice:update()
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
