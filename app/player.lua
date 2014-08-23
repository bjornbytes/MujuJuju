Player = class()

Player.width = 30
Player.height = 60

Player.walkSpeed = 65
Player.maxHealth = 100

function Player:init()
	self.health = 100
	self.x = 100
	self.y = love.graphics.getHeight() - ctx.environment.groundHeight - self.height
	self.prevx = self.x
	self.prevy = self.y
	self.speed = 0
	self.jujuRealm = 0
	self.jujuJuice = 100

	ctx.view:register(self)
end

function Player:update()
	self.prevx = self.x
	self.prevy = self.y

	if love.keyboard.isDown('left', 'a') then
		self.speed = math.lerp(self.speed, -self.walkSpeed, math.min(10 * tickRate, 1))
	elseif love.keyboard.isDown('right', 'd') then
		self.speed = math.lerp(self.speed, self.walkSpeed, math.min(10 * tickRate, 1))
	else
		self.speed = math.lerp(self.speed, 0, math.min(10 * tickRate, 1))
	end

	self.x = self.x + self.speed * tickRate

	-- Check whether or not to enter Juju Realm
	if self.health == 0 and self.jujuRealm == 0 then
  	-- We jujuin'
		self.jujuRealm = 5
	end

	if self.jujuRealm > 0 then
		-- What's going on in the Juju Realm
	end

	self.jujuRealm = timer.rot(self.jujuRealm)
end

function Player:spend(amount)
	-- Check if Juju is broke
	if self.jujuJuice <= amount then
		-- He's not broke!
		return true
	else 
		-- He's broke!
		return false
	end
end
function Player:draw()
	local g = love.graphics
	local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)

	g.setColor(128, 0, 255, 160)
	g.rectangle('fill', x, y, self.width, self.height)

	g.setColor(128, 0, 255)
	g.rectangle('line', x, y, self.width, self.height)
end

function Player:summon()
  -- Summon minions
end

function Player:keypressed(key)
	--
end

function Player:keyreleased(key)
	--
end
