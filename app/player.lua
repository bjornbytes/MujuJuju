Player = class()

Player.width = 45
Player.height = 90
Player.depth = 0
Player.walkSpeed = 65


----------------
-- Core
----------------
function Player:init()
	self.x = ctx.map.width / 2
	self.y = ctx.map.height - ctx.map.groundHeight - self.height
  self.direction = 1
  self.speed = 0
  self.walkSpeed = Player.walkSpeed

  self.maxHealth = 100
  self.health = self.maxHealth
  self.healthDisplay = self.health
  self.prevHealthDisplay = self.healthDisplay
  self.prevHealth = self.health

  self.dead = false
  self.deathTimer = 0

  self.juju = 30
  self.jujuTimer = 1
  self.jujuRate = 1

  self.shrujus = {}

	self.prevx = self.x
	self.prevy = self.y

	self.selected = 1
  self.maxPopulation = 3
	self.recentSelect = 0
	self.invincible = 0
  self.flatCooldownReduction = 0
  self.ghostSpeedMultiplier = 1

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

  self:initDeck()

  ctx.event:emit('view.register', {object = self})
end

function Player:update()
	self.prevx = self.x
	self.prevy = self.y
  self.prevHealthDisplay = self.healthDisplay
  self.prevHealth = self.health

  self:move()
	self:animate()

	self.deathTimer = timer.rot(self.deathTimer, function()
		self.invincible = 3
		self.health = self.maxHealth
		self.dead = false
		self.ghost:despawn()
		self.ghost = nil

    self.animation:set('resurrect')
	end)
	self.invincible = timer.rot(self.invincible)

	if self.ghost then
		self.ghost:update()
	end

	self:hurt(self.maxHealth * .033 * tickRate)

  self.maxHealth = self.maxHealth + (.25 * tickRate)
  self.health = self.health + (.25 * tickRate)

	self.healthDisplay = math.lerp(self.healthDisplay, self.health, math.min(10 * tickRate, 1))

	self.jujuTimer = timer.rot(self.jujuTimer, function()
		self.juju = self.juju + 1
		return self.jujuRate
	end)

  for i = 1, #self.deck do
    self.deck[i].cooldown = timer.rot(self.deck[i].cooldown)
  end

	self.recentSelect = timer.rot(self.recentSelect)
end

function Player:draw()
	if math.floor(self.invincible * 8) % 2 == 0 then
    local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
		love.graphics.setColor(255, 255, 255)
		self.animation:draw(x, y)
	end
end

function Player:keypressed(key)
	for i = 1, #self.deck do
		if tonumber(key) == i then
			self.selected = i
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

function Player:paused()
  self.prevx = self.x
  self.prevy = self.y
  self.animation:set('idle')
  if self.ghost then
    self.ghost.prevx = self.ghost.x
    self.ghost.prevy = self.ghost.y
  end
end


----------------
-- Behavior
----------------
function Player:move()
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
				if self.selectedMinion <= 0 then self.selectedMinion = #self.deck
				elseif self.selectedMinion > #self.deck then self.selectedMinion = 1 end
			end
			self.gamepadSelectDirty = rtrigger or ltrigger
		end
	end

	self.x = math.clamp(self.x, 0, love.graphics.getWidth())
end

function Player:summon()
	local minion = self.deck[self.selected].code
	local cooldown = self.deck[self.selected].cooldown
  local population = self:getPopulation()
	local cost = data.unit[minion].cost
	if cooldown == 0 and population < self.maxPopulation and self:spend(cost) then
		ctx.units:add(minion, {player = self, x = self.x + love.math.random(-20, 20)})
		self.deck[self.selected].cooldown = math.max(3 - self.flatCooldownReduction, .5)

		self.animation:set('summon')
		local summonSound = love.math.random(1, 3)
		ctx.sound:play({sound = 'summon' .. summonSound})
    for i = 1, 15 do
      ctx.particles:add(Dirt, {x = self.x, y = self.y + self.height})
    end
	end
end

function Player:animate()
  if self.dead then return end

  self.animation:set(math.abs(self.speed) > self.walkSpeed / 2 and 'walk' or 'idle')
  self.animation.speed = self.animation.state.name == 'walk' and math.max(math.abs(self.speed / self.walkSpeed), .4) or 1

	if self.speed ~= 0 then self.animation.flipped = math.sign(self.speed) > 0 end
end

function Player:spend(amount)
	if self.juju >= amount then
		self.juju = self.juju - amount
		return true
  end

  return false
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


----------------
-- Helper
----------------
function Player:getHealthbar()
  local x = math.lerp(self.prevx, self.x, tickDelta / tickRate)
  local y = math.lerp(self.prevy, self.y, tickDelta / tickRate)
  local healthDisplay = math.lerp(self.prevHealthDisplay, self.healthDisplay, tickDelta / tickRate)
  local health = math.lerp(self.prevHealth, self.health, tickDelta / tickRate)
  return x, y, health / self.maxHealth, healthDisplay / self.maxHealth
end

function Player:atShrine()
  local shrine = table.values(ctx.shrines:filter(function(shrine) return shrine.team == self.team end))[1]
  if not shrine then return false end
  return math.abs(self.x - shrine.x) < self.width
end

function Player:initDeck()
  self.deck = {}
  local deck = ctx.user.deck

  for i = 1, 3 do
    local code = deck.minions[i]

    if code then
      self.deck[code] = {
        runes = deck.runes[i] or {},
        cooldown = 0,
        code = code
      }

      self.deck[i] = self.deck[code]

      -- Perform a one-time application of upgrade runes.
      table.each(deck.runes[i], function(rune)
        local upgrade = rune.upgrade and data.unit[code].upgrades[rune.upgrade]
        if upgrade then upgrade.level = upgrade.level + 1 end
      end)
    end
  end
end

function Player:contains(x, y)
  math.inside(x, y, self.x - self.width / 2, self.y, self.width, self.height)
end

function Player:getPopulation()
  return table.count(ctx.units:filter(function(u) return u.player == self end))
end

function Player:hasUnitAbility(unit, ability)
  if type(unit) == 'number' then unit = self.deck[unit].code end
  if type(ability) == 'number' then ability = data.unit[unit].abilities[ability] end
  return self.deck[unit].abilities[ability]
end

function Player:hasUnitAbilityUpgrade(unit, ability, upgrade)
  if type(unit) == 'number' then unit = self.deck[unit].code end
  if type(ability) == 'number' then ability = data.unit[unit].abilities[ability] end
  if type(upgrade) == 'number' then upgrade = data.ability[unit][ability].upgrades[upgrade].code end
  return self.deck[unit].upgrades[ability][upgrade]
end
