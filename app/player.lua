Player = class()

Player.width = 64
Player.height = 64

function Player:init()
	self.x = 100
	self.y = 100
	self.speed = 20

	ctx.view:register(self)
end

function Player:update()
	if love.keyboard.isDown('left', 'a') then
		self.x = self.x - self.speed * tickRate
	elseif love.keyboard.isDown('right', 'd') then
		self.x = self.x + self.speed * tickRate
	end
end

function Player:draw()
	local g = love.graphics

	g.setColor(128, 0, 255, 160)
	g.rectangle('fill', self.x, self.y, self.width, self.height)

	g.setColor(128, 0, 255)
	g.rectangle('line', self.x, self.y, self.width, self.height)
end

function Player:keypressed(key)
	--
end

function Player:keyreleased(key)
	--
end
