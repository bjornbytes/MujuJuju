Player = class()

Player.width = 30
Player.height = 60

Player.walkSpeed = 65
Player.maxHealth = 100

Player.depth = 0

function Player:init()
	self.health = 100
	self.x = love.graphics.getWidth() / 2
	self.y = love.graphics.getHeight() - ctx.environment.groundHeight - self.height
	self.prevx = self.x
	self.prevy = self.y
	self.speed = 0
	self.jujuRealm = 0
	self.juju = 7000
	self.dead = false
	self.minions = {Imp}
	self.minioncds = {0}
	self.selectedMinion = 1
	self.summoned = false
	self.direction = 1
	self.skeleton = Skeleton({name = 'muju', x = self.x, y = self.y})
	self.animator = Animator({skeleton = self.skeleton})
	self.animator:add('idle', true)
	ctx.view:register(self)
end

function Player:update()
	self.prevx = self.x
	self.prevy = self.y

	if self.dead then
		self.speed = 0
	else
		if love.mouse.isDown('l') then
			local sign = math.sign(love.mouse.getX() - self.x)
			if sign < 0 then
				self.speed = math.lerp(self.speed, -self.walkSpeed, math.min(10 * tickRate, 1))
			elseif sign > 0 then
				self.speed = math.lerp(self.speed, self.walkSpeed, math.min(10 * tickRate, 1))
			else
				self.speed = math.lerp(self.speed, 0, math.min(10 * tickRate, 1))
			end
		else
			if love.keyboard.isDown('left', 'a') then
				self.speed = math.lerp(self.speed, -self.walkSpeed, math.min(10 * tickRate, 1))
			elseif love.keyboard.isDown('right', 'd') then
				self.speed = math.lerp(self.speed, self.walkSpeed, math.min(10 * tickRate, 1))
			else
				self.speed = math.lerp(self.speed, 0, math.min(10 * tickRate, 1))
			end
		end

		local delta = self.x + self.speed * tickRate
		if love.mouse.isDown('l') and self.speed * tickRate > math.abs(self.x - love.mouse.getX()) then
			self.x = love.mouse.getX()
		else
			self.x = self.x + self.speed * tickRate
		end
		self.direction = self.speed == 0 and self.direction or math.sign(self.speed)
	end

	self.jujuRealm = timer.rot(self.jujuRealm, function()
		self.health = self.maxHealth
		self.dead = false
		self.ghost:despawn()
		self.ghost = nil
	end)

	table.each(self.minioncds, function(cooldown, index)
		self.minioncds[index] = timer.rot(cooldown)
	end)

	if self.ghost then
		self.ghost:update()
	end

	self.skeleton.skeleton.x = self.x
	self.skeleton.skeleton.y = self.y
	self.animator:update()
end

function Player:spend(amount)
	-- Check if Muju is broke
	if self.juju >= amount then
		-- He's not broke!
		self.juju = self.juju - amount
		return true
	else 
		-- He's broke!
		return false
	end
end

function Player:draw()
	local g = love.graphics
	local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)

	g.setColor(128, 0, 255, self.dead and 80 or 160)
	g.rectangle('fill', x - self.width / 2, y, self.width, self.height)

	g.setColor(128, 0, 255)
	g.rectangle('line', x - self.width / 2, y, self.width, self.height)

	self.animator:draw()
end

function Player:cooldown()
	
end

function Player:summon()
	local minion = self.minions[self.selectedMinion]
	local cooldown = self.minioncds[self.selectedMinion]
	if self:spend(minion.cost) and cooldown == 0 then
		ctx.minions:add(minion, {x = self.x + love.math.random(-10, 20), direction = self.direction})
		self.minioncds[self.selectedMinion] = minion.cooldown
	end
end

function Player:hurt(amount)
	self.health = math.max(self.health - amount, 0)
	-- Check whether or not to enter Juju Realm
	if self.health <= 0 and self.jujuRealm == 0 then
  	-- We jujuin'
		self.jujuRealm = 10
		self.dead = true
		self.ghost = GhostPlayer()
		return true
	end

	if self.jujuRealm > 0 then
		-- What's going on in the Juju Realm
	end
end

function Player:keypressed(key)
	for i = 1, #self.minions do
		if tonumber(key) == i then
			self.selectedMinion = i
			return
		end
	end

	if key == ' ' and not self.dead then
		self:summon()
	end
end

function Player:keyreleased(key)
	--
end

function Player:mousepressed(x, y, button)
	if button == 'r' and not summoned then
		self:summon()
		self.summoned = true
	end
end

function Player:mousereleased(x, y, button)
	if button == 'r' then
		self.summoned = false
	end
end
