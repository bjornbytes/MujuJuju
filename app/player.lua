Player = class()

Player.width = 45
Player.height = 90

Player.depth = -10


----------------
-- Core
----------------
function Player:init()
	self.x = ctx.map.width / 2
	self.y = ctx.map.height - ctx.map.groundHeight - self.height
  self.direction = 1
  self.speed = 0
  self.walkSpeed = 65

  self.maxHealth = 100
  self.health = self.maxHealth
  self.healthDisplay = self.health

  self.dead = false
  self.deathTimer = 0

  self.juju = 30
  self.jujuTimer = 1
  self.jujuRate = 1

	self.prevx = self.x
	self.prevy = self.y

	self.minions = {}
	self.minioncds = {0}

	self.selectedMinion = 1
	self.recentSelect = 0
	self.invincible = 0

	local joysticks = love.joystick.getJoysticks()
	for _, joystick in ipairs(joysticks) do
		if joystick:isGamepad() then self.gamepad = joystick break end
	end
	self.gamepadSelectDirty = false
end

function Player:activate()
  self.animation = data.animation.muju()
  self.animation:on('complete', function(data)
    if data.state.name ~= 'death' and not data.state.loop then
      self.animation:set('idle', {force = true})
    end
  end)

  -- self:initDeck() -- TODO

  ctx.event:emit('view.register', {object = self})
end

function Player:update()
	self.prevx = self.x
	self.prevy = self.y

	self:animate()

	if self.dead or self.animation.state.name == 'summon' or self.animation.state.name == 'death' or self.animation.state.name == 'resurrect' then
		self.speed = 0
	else
		local maxSpeed = self.walkSpeed
		if self.gamepad and math.abs(self.gamepad:getGamepadAxis('leftx')) > .5 then
			maxSpeed = self.walkSpeed * math.abs(self.gamepad:getGamepadAxis('leftx'))
		end
		if love.keyboard.isDown('left', 'a') or (self.gamepad and self.gamepad:getGamepadAxis('leftx') < -.5) then
			self.speed = math.lerp(self.speed, -maxSpeed, math.min(10 * tickRate, 1))
		elseif love.keyboard.isDown('right', 'd') or (self.gamepad and self.gamepad:getGamepadAxis('leftx') > .5) then
			self.speed = math.lerp(self.speed, maxSpeed, math.min(10 * tickRate, 1))
		else
			self.speed = math.lerp(self.speed, 0, math.min(10 * tickRate, 1))
		end

		local delta = self.x + self.speed * tickRate
		self.x = self.x + self.speed * tickRate
		self.direction = self.speed == 0 and self.direction or math.sign(self.speed)

		-- Controller
		if self.gamepad then
			local ltrigger = self.gamepad:getGamepadAxis('triggerleft') > .5
			local rtrigger = self.gamepad:getGamepadAxis('triggerright') > .5
			if not self.gamepadSelectDirty then
				if rtrigger then self.selectedMinion = self.selectedMinion + 1 end
				if ltrigger then self.selectedMinion = self.selectedMinion - 1 end
				if ltrigger or rtrigger then self.recentSelect = 1 end
				if self.selectedMinion <= 0 then self.selectedMinion = #self.minions
				elseif self.selectedMinion > #self.minions then self.selectedMinion = 1 end
			end
			self.gamepadSelectDirty = rtrigger or ltrigger
		end
	end

	self.x = math.clamp(self.x, 0, love.graphics.getWidth())

	self.deathTimer = timer.rot(self.deathTimer, function()
		self.invincible = 2
		self.health = self.maxHealth
		self.dead = false
		self.ghost:despawn()
		self.ghost = nil

    self.animation:set('resurrect')
	end)
	self.invincible = timer.rot(self.invincible)

	table.each(self.minioncds, function(cooldown, index)
		self.minioncds[index] = timer.rot(cooldown, function()
			ctx.hud.selectExtra[index] = 1
		end)
	end)

	if self.ghost then
		self.ghost:update()
	end

	self:hurt(self.maxHealth * .033 * tickRate)

	self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)

	self.jujuTimer = timer.rot(self.jujuTimer, function()
		self.juju = self.juju + 1
		return self.jujuRate
	end)

	self.recentSelect = timer.rot(self.recentSelect)
end

function Player:draw()
	if math.floor(self.invincible * 4) % 2 == 0 then
    local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
		love.graphics.setColor(255, 255, 255)
		self.animation:draw(x, y)
	end
end


----------------
-- Core
----------------
function Player:animate()
  if self.dead then return end

  self.animation:set(math.abs(self.speed) > self.walkSpeed / 2 and 'walk' or 'idle')
  self.animation.speed = self.animation.state.name == 'walk' and math.max(math.abs(self.speed / self.walkSpeed), .4) or 1

	if self.speed ~= 0 then self.animation.flipped = math.sign(self.speed) > 0 end
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

function Player:cooldown()
	
end

function Player:summon()
	local minion = self.minions[self.selectedMinion]
	local cooldown = self.minioncds[self.selectedMinion]
	local cost = minion:getCost()
	if cooldown == 0 and self:spend(cost) then
		ctx.minions:add(minion, {x = self.x + love.math.random(-20, 20), direction = self.direction})
		self.minioncds[self.selectedMinion] = minion.cooldown * (1 - (.1 * ctx.upgrades.muju.flow.level))
		if ctx.upgrades.muju.refresh.level == 1 and love.math.random() < .15 then
			self.minioncds[self.selectedMinion] = 0
		end

		self.animation:set('summon')
		local summonSound = love.math.random(1, 3)
		ctx.sound:play({sound = 'summon' .. summonSound})
	end
end

function Player:hurt(amount, source)
	if self.invincible == 0 then
		self.health = math.max(self.health - amount, 0)
		if self.gamepad and self.gamepad:isVibrationSupported() then
			local l, r = .25, .25
			if source then
				if source.x > self.x then r = .5
				elseif source.x < self.x then l = .5 end
			end

			self.gamepad:setVibration(l, r, .25)
		end
	end
	-- Check whether or not to enter Juju Realm
	if self.health <= 0 and self.deathTimer == 0 then
  	-- We jujuin'
		self.deathTimer = 7
		self.dead = true
		self.ghost = GhostPlayer(self)

    self.animation:set('death')
		ctx.sound:play({sound = 'death'})

		if self.gamepad and self.gamepad:isVibrationSupported() then
			self.gamepad:setVibration(1, 1, .5)
		end

		return true
	end
end

function Player:keypressed(key)
	for i = 1, #self.minions do
		if tonumber(key) == i then
			self.selectedMinion = i
			self.recentSelect = 1
			return
		end
	end

	if key == ' ' and not self.dead then
		self:summon()
	end
end

function Player:gamepadpressed(gamepad, button)
	if gamepad == self.gamepad then
		if (button == 'a' or button == 'rightstick' or button == 'rightshoulder') and not self.dead then
      self:summon()
		end
	end
end

function Player:getHealthbar()
  return self.x, self.y, self.healthDisplay / self.maxHealth
end

function Player:atShrine()
  local shrine = table.values(ctx.shrines:filter(function(shrine) return shrine.team == self.team end))[1]
  if not shrine then return false end
  return math.abs(self.x - shrine.x) < self.width
end
