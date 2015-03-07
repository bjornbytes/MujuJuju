Player = class()

Player.width = 45
Player.height = 90
Player.depth = -3.5
Player.walkSpeed = 65

----------------
-- Core
----------------
function Player:init()

  -- Physics
  self.x = ctx.map.width / 2
  self.y = ctx.map.height - ctx.map.groundHeight - self.height
  self.prevx = self.x
  self.prevy = self.y
  self.direction = 1
  self.speed = 0
  self.walkSpeed = Player.walkSpeed

  -- Health
  self.maxHealth = 100
  self.health = self.maxHealth
  self.healthDisplay = self.health
  self.prevHealthDisplay = self.healthDisplay
  self.prevHealth = self.health

  -- Dead
  self.dead = false
  self.deathTimer = 0
  self.deathDuration = 7

  -- Juju
  self.juju = 0
  self.totalJuju = 0
  self.jujuTimer = config.player.jujuRate
  self.jujuRate = config.player.jujuRate
  self:addJuju(config.player.baseJuju)

  -- The current magic shruju
  self.shruju = nil

  -- Summoning and selection
  self.summonSelect = 1
  self.totalSummoned = 0

  -- Channeled Heal
  self.healing = false
  self.healingAmount = .05
  self.healingCost = 2
  self.healingRange = 200
  self.healingTick = 1
  self.healingTimer = 0

  -- Buffs
  self.invincible = 0
  self.ghostSpeedMultiplier = 1
  self.cooldownSpeed = 1
  self.buffs = PlayerBuffs(self)

  -- joystick
  self.joystick = #love.joystick.getJoysticks() > 0 and love.joystick.getJoysticks()[1]
end

function Player:activate()

  -- Create animation
  self.animation = data.animation.muju()
  self.animation:on('complete', function(data)
    if data.state.name ~= 'death' and not data.state.loop then
      self.animation:set('idle', {force = true})
    end
  end)

  self.animation.spine.skeleton:setSkin('santa')
  self.animation.spine.skeleton:findBone('hat').scaleX = self.animation.scale
  self.animation.spine.skeleton:findBone('hat').scaleY = self.animation.scale

  -- Color animation
  for _, slot in pairs({'robebottom', 'torso', 'front_upper_arm', 'rear_upper_arm', 'front_bracer', 'rear_bracer'}) do
    local slot = self.animation.spine.skeleton:findSlot(slot)
    slot.r, slot.g, slot.b = unpack(config.player.colors[ctx.user.color])
  end

  -- Initialize deck data structure from ctx.user
  self:initDeck()

  ctx.event:emit('view.register', {object = self})
end

function Player:update()

  -- Lerp vars
  self.prevx = self.x
  self.prevy = self.y
  self.prevHealthDisplay = self.healthDisplay
  self.prevHealth = self.health

  -- Core updates
  self:move()
  self:animate()
  self.buffs:update()
  if self.ghost then self.ghost:update() end

  -- Rots
  self.deathTimer = timer.rot(self.deathTimer, function() self:spawn() end)
  self.invincible = timer.rot(self.invincible)

  -- Healing Rot
  if self.healingTimer <= 0 and self.healing then
      self.healingTimer = self.healingTick
  end

  self.healingTimer = timer.rot(self.healingTimer, function()
    if self.healing then
      self:channelHeal()
    end
  end)

  for i = 1, #self.deck do
    if self.deck[i].cooldown > 0 then
      self.deck[i].cooldown = self.deck[i].cooldown - ls.tickrate * self.cooldownSpeed
      if self.deck[i].cooldown <= 0 then
        ctx.hud.units.cooldownPop[i] = 1
        self.deck[i].cooldown = 0
      end
    end
  end

  -- Health decay
  self:hurt(self.maxHealth * .033 * ls.tickrate)

  -- Lerp healthbar
  self.healthDisplay = math.lerp(self.healthDisplay, self.health, math.min(10 * ls.tickrate, 1))

  -- Juju trickle
  self.jujuTimer = timer.rot(self.jujuTimer, function()
    self:addJuju(1)
    return self.jujuRate
  end)
end

function Player:draw()

  -- Flash when invincible
  if math.floor(self.invincible * 4) % 2 == 0 then
    local x, y = math.lerp(self.prevx, self.x, ls.accum / ls.tickrate), math.lerp(self.prevy, self.y, ls.accum / ls.tickrate)
    love.graphics.setColor(255, 255, 255)
    self.animation:draw(x, y)
  end

  -- Draw a line to healed target
  if self.healingTimer <= .5 and self.healing and self.healingTarget then
    love.graphics.setColor(50, 230, 50)
    love.graphics.setLineWidth(3)
    love.graphics.setLineStyle('smooth')
    love.graphics.line(self.x, self.y + self.height / 2, self.healingTarget.x, self.healingTarget.y + self.healingTarget.height / 2)
  end
end

function Player:channelHeal()
  local ally
  local allies = ctx.target:inRange(self, self.healingRange, 'ally', 'unit')

  for _, unit in ipairs(allies) do
    if not ally or ally.health > unit.health then
      ally = unit
    end
  end

  if ally then
    self.healingTarget = ally
    if self:spend(self.healingCost) then
      self.healingTarget:heal(self.healingTarget.maxHealth * self.healingAmount)
    end
  else
    self.healingTarget = nil
  end
end

function Player:keypressed(key)

  -- Select minions with digits
  for i = 1, #self.deck do
    if tonumber(key) == i then
      self.summonSelect = i
      return
    end
  end

  -- Summon with space
  if key == ' ' and not self.dead then
    self:summon()
  end

  if key == 'q' then
    ctx.shrujus:each(function(shruju)
      if shruju:playerNearby() then
        if self.shruju then self.shruju:drop() end
        shruju:pickup()
        return true
      end
    end)
  end

  if key == 'lshift' and not self.dead then
    self.healing = true
  end
end

function Player:keyreleased(key)
  if key == 'lshift' then
    self.healing = false
  end
end

function Player:gamepadpressed(gamepad, button)
end

function Player:gamepadaxis(joystick, axis, value)
  if axis == 'triggerright' and value > .75 and not self.dead then
    self:summon()
  end
end

function Player:paused()

  -- Reset prev variables when paused to fix lerp jitter.
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

  -- If we can't move then don't move
  local animation = self.animation.state.name
  if self.dead or animation == 'summon' or animation == 'death' or animation == 'resurrect' then
    self.speed = 0
    return
  end

  -- Adjust speed to target speed based on keystate
  local maxSpeed = self.walkSpeed

  if love.keyboard.isDown('left', 'a') or (self.joystick and self.joystick:getGamepadAxis('leftx') < -.5) then
    self.speed = math.lerp(self.speed, -maxSpeed, math.min(10 * ls.tickrate, 1))
  elseif love.keyboard.isDown('right', 'd') or (self.joystick and self.joystick:getGamepadAxis('leftx') > .5) then
    self.speed = math.lerp(self.speed, maxSpeed, math.min(10 * ls.tickrate, 1))
  else
    self.speed = math.lerp(self.speed, 0, math.min(10 * ls.tickrate, 1))
  end

  -- Actually move
  self.x = self.x + self.speed * ls.tickrate
  self.direction = self.speed == 0 and self.direction or math.sign(self.speed)

  -- Don't go outside map
  self.x = math.clamp(self.x, 0, ctx.map.width)
end

function Player:summon(options)
  options = options or {}
  local minion = self.deck[self.summonSelect].code
  local cooldown = self.deck[self.summonSelect].cooldown
  local cost = data.unit[minion].cost
  local animation = self.animation.state.name

  -- Check if we can summon
  if not options.force and not (not ctx.hud.upgrades.active and not ctx.paused and ctx.tutorial == nil and cooldown == 0 and animation ~= 'dead' and animation ~= 'resurrect' and self:spend(cost)) then
    return ctx.sound:play('misclick', function(sound) sound:setVolume(.3) end)
  end

  -- Create minion
  local unit = ctx.units:add(minion, {player = self, x = self.x + love.math.random(-20, 20)})

  -- Set cooldowns (global cooldown)
  local cooldown = config.player.baseCooldown
  if self:hasShruju('refresh') and love.math.random() < .25 then cooldown = 0 end
  for i = 1, #self.deck do
    if cooldown > self.deck[i].cooldown then
      self.deck[i].cooldown = cooldown
      self.deck[i].maxCooldown = cooldown
    end
  end

  -- Achievement: Mini Arsenal
  ctx.event:emit('achievement', {name = 'miniarsenal'})

  -- Aftermath, juice, animations, etc.
  self.totalSummoned = self.totalSummoned + 1
  self.invincible = 0
  self.animation:set('summon')
  if not options.nosound then
    local summonSound = love.math.random(1, 3)
    ctx.sound:play('summon' .. summonSound)
  end
  ctx.hud.units.animations[self.summonSelect]:set('spawn')
  for i = 1, 20 do
    ctx.particles:emit('jujudrop', self.x + love.math.randomNormal(20), self.y + love.math.randomNormal(20) + self.height / 2, 1)
  end
end

function Player:animate()
  if self.dead then return end

  -- Flip animation, set animation speed
  self.animation:set(math.abs(self.speed) > self.walkSpeed / 2 and 'walk' or 'idle')
  self.animation.speed = self.animation.state.name == 'walk' and math.max(math.abs(self.speed / Player.walkSpeed), .4) or 1
  if self.speed ~= 0 then self.animation.flipped = math.sign(self.speed) > 0 end
end

function Player:spend(amount)
  if self.juju >= amount then
    self.juju = self.juju - amount
    return true
  end

  return false
end

function Player:addJuju(amount)
  self.juju = self.juju + amount
  self.totalJuju = self.totalJuju + amount
end

function Player:hurt(amount, source, kind)
  if not self.dead and self.invincible == 0 then
    amount = self.buffs:prehurt(amount, source, kind) or amount
    self.health = math.max(self.health - amount, 0)
    self.buffs:posthurt(amount, source, kind)

    ctx.event:emit('player.hurt', {amount = amount, source = source, kind = kind})

    if amount > 5 then
      local sound = data.media.sounds['hit' .. love.math.random(1, 3)]
      ctx.sound:play(sound)
    end

    -- Die if we are dead
    if self.health <= 0 and self.deathTimer == 0 then self:die() end
  end

  return amount
end

function Player:die()
  self.deathTimer = self.deathDuration
  self.dead = true
  self.ghost = GhostPlayer(self)
  self.buffs:die()

  self.animation:set('death')
  ctx.sound:play('death', function(sound) sound:setVolume(.2) end)

  if self:hasShruju('reincarnation') then
    self:summon({force = true, nosound = true})
  end
end

function Player:spawn()
  self.deathTimer = 0
  self.invincible = 4.5
  self.health = self.maxHealth
  self.dead = false
  self.ghost:despawn()
  self.ghost = nil
  self.animation:set('resurrect')
end

function Player:heal(amount, source)
  if self.dead then return end
  self.health = math.min(self.health + amount, self.maxHealth)
end


----------------
-- Helper
----------------
function Player:getHealthbar()
  local x = math.lerp(self.prevx, self.x, ls.accum / ls.tickrate)
  local y = math.lerp(self.prevy, self.y, ls.accum / ls.tickrate)
  local healthDisplay = math.lerp(self.prevHealthDisplay, self.healthDisplay, ls.accum / ls.tickrate)
  local health = math.lerp(self.prevHealth, self.health, ls.accum / ls.tickrate)
  return x, y, health / self.maxHealth, healthDisplay / self.maxHealth
end

function Player:atShrine()
  local shrine = table.values(ctx.shrines:filter(function(shrine) return shrine.team == self.team end))[1]
  if not shrine then return false end
  return math.abs(self.x - shrine.x) < self.width
end

function Player:initDeck()
  self.deck = {}

  local minions = {}
  if ctx.mode == 'campaign' then
    minions = {config.biomes[ctx.biome].minion}
  elseif ctx.mode == 'survival' then
    minions = ctx.user.survival.minions
  end

  for i = 1, 2 do
    local code = minions[i]

    if code then
      self.deck[code] = {
        runes = ctx.user.runes[code],
        cooldown = 0,
        maxCooldown = 3,
        code = code
      }

      self.deck[i] = self.deck[code]

      table.each(self.deck[i].runes, function(rune)
        if rune.attributes then
          table.each(rune.attributes, function(amount, attribute)
            local class = data.unit[code]
            class.attributes[attribute] = class.attributes[attribute] + amount
          end)
        end
      end)
    end
  end
end

function Player:contains(x, y)
  math.inside(x, y, self.x - self.width / 2, self.y, self.width, self.height)
end

function Player:hasShruju(code)
  return self.shruju and self.shruju.code == code
end
