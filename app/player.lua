Player = class()

Player.width = 45
Player.height = 90

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
	self.juju = 50
	self.dead = false
	self.minions = {Zuju}
	self.minioncds = {0}
	self.selectedMinion = 1
	self.summoned = false
	self.direction = 1

	self.skeleton = Skeleton({name = 'muju', x = self.x, y = self.y, scale = .6})

	self.animator = Animator({
		skeleton = self.skeleton,
		mixes = {
			{from = 'idle', to = 'idle', time = .1},
			{from = 'walk', to = 'idle', time = .2},
			{from = 'idle', to = 'walk', time = .2},
			{from = 'walk', to = 'summon', time = .1},
			{from = 'summon', to = 'walk', time = .2},
			{from = 'idle', to = 'summon', time = .1},
			{from = 'summon', to = 'idle', time = .2},
			{from = 'death', to = 'resurrect', time = .2},
			{from = 'idle', to = 'death', time = .2},
			{from = 'walk', to = 'death', time = .2},
			{from = 'death', to = 'idle', time = .2}
		}
	})

	self.animationState = 'idle'
	self.animator:add(self.animationState, true)
	self.animator.state.onComplete = function(trackIndex)
		local name = self.animator.state:getCurrent(trackIndex).animation.name
		if name == 'summon' or name == 'death' or name == 'resurrect' then
			self.animationLock = nil
		end
	end

	self.animationSpeeds = table.map({
		walk = function() return tickRate * math.abs(self.speed / self.walkSpeed) end,
		idle = tickRate * .4,
		summon = tickRate * 1.85,
		resurrect = tickRate,
		death = tickRate
	}, f.val)

	ctx.view:register(self)
end

function Player:update()
	self.prevx = self.x
	self.prevy = self.y

	if self.dead or self.animationState == 'summon' then
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

		self.animationState = 'resurrect'
		self.animationLock = true
		self.animator:set('resurrect', false)
	end)

	table.each(self.minioncds, function(cooldown, index)
		self.minioncds[index] = timer.rot(cooldown)
	end)

	if self.ghost then
		self.ghost:update()
	end
	
	self:animate()
end

function Player:animate()
	if not self.animationLock and not self.dead then
		local old = self.animationState
		if self.animationState ~= 'walk' and math.abs(self.speed) > self.walkSpeed / 2 then
			self.animationState = 'walk'
		elseif self.animationState ~= 'idle' and math.abs(self.speed) <= self.walkSpeed / 2 then
			self.animationState = 'idle'
		end

		if old ~= self.animationState then
			self.animator:set(self.animationState, true)
		end
	end

	self.skeleton.skeleton.x = self.x
	self.skeleton.skeleton.y = self.y + self.height / 2
	if self.speed ~= 0 then
		self.skeleton.skeleton.flipX = self.speed > 0
	end
	
	self.animator:update(self.animationSpeeds[self.animationState]())
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
	love.graphics.setColor(255, 255, 255)
	self.animator:draw()
end

function Player:cooldown()
	
end

function Player:summon()
	local minion = self.minions[self.selectedMinion]
	local cooldown = self.minioncds[self.selectedMinion]
	if cooldown == 0 and self:spend(minion.cost) then
		ctx.minions:add(minion, {x = self.x + love.math.random(-10, 20), direction = self.direction})
		self.minioncds[self.selectedMinion] = minion.cooldown

		self.animationLock = true
		self.animationState = 'summon'
		self.animator:set('summon', false)
	end
end

function Player:hurt(amount)
	self.health = math.max(self.health - amount, 0)
	-- Check whether or not to enter Juju Realm
	if self.health <= 0 and self.jujuRealm == 0 then
  	-- We jujuin'
		self.jujuRealm = 5 + math.min(tick * tickRate / 45, 5)
		self.dead = true
		self.ghost = GhostPlayer()

		self.animationState = 'death'
		self.animationLock = true
		self.animator:set('death', false)
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
