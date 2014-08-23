Player = class()

Player.x = 100
Player.y = 100
Player.width = 64
Player.height = 64

Player.speed = 20
Player.health = 100
Player.maxHealth = 100

Player.jujuRealm = 0

function Player:init()
	ctx.view:register(self)
end

function Player:update()
	if love.keyboard.isDown('left', 'a') then
		self.x = self.x - self.speed * tickRate
	elseif love.keyboard.isDown('right', 'd') then
		self.x = self.x + self.speed * tickRate
	end

	-- Check whether or not to enter Juju Realm
	if self.health == 0 then
  	-- We jujuin'
		self.jujuRealm = 5
	end

	if self.jujuRealm > 0 then
		-- What's going on in the Juju Realm
	end

	-- self.jujuRealm = timer.rot(self.jujuRealm)
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
