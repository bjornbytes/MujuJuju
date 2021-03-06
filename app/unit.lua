local g = love.graphics

Unit = class()

Unit.classStats = {'width', 'height', 'health', 'damage', 'range', 'attackSpeed', 'speed', 'spirit', 'haste'}

Unit.width = 64
Unit.height = 64
Unit.depth = -3.5

----------------
-- Core
----------------
function Unit:activate()

  -- Static canvas variable is shared by all units for outline drawing
  Unit.canvas = Unit.canvas or g.newCanvas(400, 400)
  Unit.backCanvas = Unit.backCanvas or g.newCanvas(400, 400)

  -- Position
  self.y = ctx.map.height - ctx.map.groundHeight - self.height

  -- Depth
  local r = love.math.random(-30, 30)
  if ctx.player.totalSummoned == 0 then r = 0 end
  self.y = self.y - r / 1.5
  self.depth = self.depth + r / 30

  -- Scale
  self.scale = 1 - r / 300

  -- Initialize subsystems
  self:initAnimation()
  self.buffs = UnitBuffs(self)

  -- Elite stat modifiers
  if self.elite then
    self.health = self.health * config.elites.healthModifier
    self.damage = self.damage * config.elites.damageModifier

    if ctx.player:hasShruju('slayer') then
      self.buffs:add('slayer')
    end
  end

  -- Scale stats
  if not self.player then
    local function scale(stat)
      if self.class[stat .. 'Scaling'] then
        local coefficient, exponent = unpack(self.class[stat .. 'Scaling'])
        self[stat] = self[stat] + coefficient * ctx.units.level ^ exponent
      end
    end

    scale('health')
    scale('damage')
  else
    self.health = self.health + config.units.baseHealthScaling * (ctx.timer * ls.tickrate / 60)
    self.damage = self.damage + config.units.baseDamageScaling * (ctx.timer * ls.tickrate / 60)
  end

  -- Basic data
  self.team = self.player and self.player.team or 0
  self.dying = false
  self.died = false
  self.casting = false
  self.channeling = false
  self.spawning = true

  -- Add abilities
  self.abilities = {}
  table.each(self.class.startingAbilities, function(ability)
    self:addAbility(ability)
  end)

  if self.player then

    -- Apply attributes
    table.each(config.attributes.list, function(attribute)
      table.each(config.attributes[attribute], function(perLevel, stat)
        self[stat] = self[stat] + self.class.attributes[attribute] * perLevel
      end)
    end)

    -- Apply upgrades
    if self.player then
      for i = 1, #self.class.upgrades do
        local upgrade = self.class.upgrades[i]
        f.exe(upgrade.apply, upgrade, self)
      end
    end
  end

  -- Display-related variables
  self.visible = true
  self.maxHealth = self.health
  self.healthDisplay = self.health
  self.prev = {x = self.x, y = self.y, health = self.health, healthDisplay = self.healthDisplay, knockup = 0, glowScale = 1, alpha = 0}
  self.alpha = 0
  self.glowScale = 1
  self.knockup = 0

  -- AI
  self.ai = (data.ai[self.class.code] or UnitAI)()
  self.ai.unit = self
  self.target = nil
  self:aiCall('activate')

  self.range = self.range + love.math.random(-10, 10)

  -- Register with View
  ctx.event:emit('view.register', {object = self})
end

function Unit:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Unit:update()

  if not ctx.tutorial:shouldUpdateUnits() then return end

  -- For lerping
  self.prev.x = self.x
  self.prev.y = self.y
  self.prev.health = self.health
  self.prev.healthDisplay = self.healthDisplay
  self.prev.knockup = self.knockup
  self.prev.glowScale = self.glowScale
  self.prev.alpha = self.alpha

  if ctx.player:hasShruju('distort') and ctx.player.dead then return end

  -- Dying behavior
  if self.dying then
    self.channeling = false
    self.spawning = false
    self.casting = false
    self.animation:set('death', {force = true})
    self.animation.speed = 1
    self.healthDisplay = math.lerp(self.healthDisplay, 0, math.min(10 * ls.tickrate, 1))
    self.alpha = math.lerp(self.alpha, 0, math.min(6 * ls.tickrate, 1))
    self.buffs:update()
    return
  end

  -- Update abilities
  self:abilityCall('update')
  self:abilityCall('rot')

  -- Update buffs
  self.buffs:update()

  self.buffs:emitParticles()
  -- Update AI
  if not self.spawning and not self.casting and not self.channeling then
    self:aiCall('update')
  end

  -- Lerps
  self.healthDisplay = math.lerp(self.healthDisplay, self.health, math.min(10 * ls.tickrate, 1))
  self.glowScale = math.lerp(self.glowScale, 1, math.min(6 * ls.tickrate, 1))
  self.alpha = math.lerp(self.alpha, 1, math.min(6 * ls.tickrate, 1))

  -- Update animation speed
  if self.animation.state.name == 'attack' then
    local current = self.animation.spine.animationState:getCurrent(0)
    if current then self.animation.speed = current.endTime / self.animation.state.speed / self.attackSpeed end
  elseif self.animation.state.name == 'walk' then
    self.animation.speed = self.speed / self.class.speed
  else
    self.animation.speed = 1
  end
end

function Unit:draw()
  local lerpd = table.interpolate(self.prev, self, ls.accum / ls.tickrate)
  local x, y, health = lerpd.x, lerpd.y, lerpd.health

  if not self.visible then return end

  -- Draw animation
  local noupdate = (ctx.player:hasShruju('distort') and ctx.player.dead) or ctx.paused or ctx.hud.upgrades.active or ctx.ded
  self.animation:draw(x, y - (lerpd.knockup or 0), {noupdate = noupdate})

  -- Fear icon
  local buffY = self.y - self.height - 35
  if self.buffs:feared() then
    local fear = self.buffs:feared()
    g.setColor(255, 255, 255, 150 * lerpd.alpha * math.min(fear.timer * 2, 1))
    local image = data.media.graphics.spell.fear
    local scale = (40 / image:getHeight()) * (1 + math.cos(math.sin(tick) / 3) / 5)
    g.draw(image, self.x, buffY, math.cos(tick / 3) / 6, scale, scale, 53, 83)
    buffY = buffY - 50
  end

  -- Stun icon
  if self.buffs:stunned() then
    local stun = self.buffs:stunned()
    g.setColor(255, 255, 255, 150 * lerpd.alpha * math.min(stun.timer * 2, 1))
    local image = data.media.graphics.spell.stun
    local scale = (30 / image:getHeight())
    g.draw(image, self.x, buffY, tick / 8, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    buffY = buffY - 30
  end
end

function Unit:getHealthbar()
  local lerpd = table.interpolate(self.prev, self, ls.accum / ls.tickrate)
  return lerpd.x, lerpd.y, lerpd.health / self.maxHealth, lerpd.healthDisplay / self.maxHealth
end

function Unit:paused()
  self.prev.x = self.x
  self.prev.y = self.y
  self.prev.health = self.health
  self.prev.healthDisplay = self.healthDisplay
  self.prev.knockup = self.knockup
  self.prev.glowScale = self.glowScale
  self.prev.alpha = self.alpha
end

----------------
-- Behavior
----------------
function Unit:attack(options) -- Called when attack animation event is fired

  -- Interpret options
  options = options or {}
  local target = options.target or self.target
  local amount = options.damage or self.damage
  if not target then return end

  -- Preattack hooks
  amount = self:abilityCall('preattack', target, amount) or amount
  amount = self.buffs:preattack(target, amount) or amount

  -- Actually deal damage
  amount = target:hurt(amount, self, {'attack'}) or amount

  -- Postattack hooks
  self:abilityCall('postattack', target, amount)
  self.buffs:postattack(target, amount)

  -- Kill event
  if target.dying then
    self:abilityCall('kill', target)
  end

  -- Play sound
  if not options.nosound then
    ctx.sound:play(data.media.sounds[self.class.code].attackHit, function(sound)
      sound:setVolume(.4)
    end)
  end

  -- Emit particles
  if not options.noparticles and data.particle[self.class.code .. 'attack'] then
    local x, y = self:attackParticlePosition(target)
    ctx.particles:emit(self.class.code .. 'attack', x, y, self.class.attackParticleCount or 5)
  end
end

function Unit:hurt(amount, source, kind)
  if self.dying then return end

  local pure = kind and table.has(kind, 'pure')

  -- Prehurt hooks
  if not pure then
    self:abilityCall('prehurt', amount, source, kind)
    amount = self.buffs:prehurt(amount, source, kind) or amount
  end

  -- Deal damage
  self.health = math.max(self.health - amount, 0)

  -- Posthurt hooks
  if not pure then
    self:abilityCall('posthurt', amount, source, kind)
    self.buffs:posthurt(amount, source, kind)
  end

  -- Die if we are dead
  if self.health <= 0 then

    self.dying = true

    -- Animation
    self.animation:set('death', {force = true})

    -- Sound
    ctx.sound:play(data.media.sounds[self.class.code].death, function(sound)
     sound:setVolume(.4)
    end)

    -- Target reset
    ctx.units:each(function(u)
      if u.target == self then u.target = nil end
    end)
  end

  return amount
end

function Unit:heal(amount, source)
  if self.dying then return end

  self.health = math.min(self.health + amount * self.buffs:potency(), self.maxHealth)
end

function Unit:die()
  self:abilityCall('deactivate')
  ctx.units:remove(self)
end


----------------
-- Helper
----------------
function Unit:abilityCall(key, ...)
  local arg = {...}
  table.each(self.abilities, function(ability)
    f.exe(ability[key], ability, unpack(arg))
  end)
end

function Unit:aiCall(key, ...)
  f.exe(self.ai[key], self.ai, ...)
end

function Unit:contains(...)
  return self.animation:contains(...)
end

function Unit:hasRunes()
  local runes = self.player and self.player.deck[self.class.code].runes
  return runes and #runes > 0
end

function Unit:addAbility(code)
  if self:hasAbility(code) then return end
  local Ability = data.ability[self.class.code][code]
  assert(Ability, 'Added invalid ability ' .. code)
  local ability = Ability()
  ability.unit = self
  table.insert(self.abilities, ability)

  f.exe(ability.activate, ability)

  return ability
end

function Unit:hasAbility(code)
  return next(table.filter(self.abilities, function(ability) return ability.code == code end))
end

function Unit:upgradeLevel(code)
  return self.class.upgrades[code] and self.class.upgrades[code].level or 0
end

function Unit:attackParticlePosition(target)
  local x, y = target.x + (target.width * .4 * -math.sign(target.x - self.x)), self.y + self.height * .4
  if self.class.attackParticleBone then
    local bone = self.animation.spine.skeleton:findBone(self.class.attackParticleBone)
    local sign = self.animation.flipped and -1 or 1
    x, y = self.animation.spine.skeleton.x + bone.worldX, self.animation.spine.skeleton.y - bone.worldY
  end
  return x, y
end

function Unit:initAnimation()
  self.animation = data.animation[self.class.code]({
    scale = data.animation[self.class.code].scale * (self.elite and config.elites.scale or 1) * self.scale
  })

  if self.player then
    self.animation.flipped = not self.player.animation.flipped
  else
    local _, shrine = next(ctx.shrines:filter(function(s) return s.team == ctx.player.team end))
    self.animation.flipped = math.sign(self.x - shrine.x) > 0
  end

  self.animation:on('event', function(event)
    if event.data.name == 'attack' then
      if self.target and (tick - self.attackStart) * ls.tickrate > self.attackSpeed * .25 then
        if self.class.attackSpell then
          ctx.spells:add(data.spell[self.class.code][self.class.attackSpell], {unit = self, target = self.target})
          ctx.sound:play(data.media.sounds[self.class.code].attackStart, function(sound) sound:setVolume(.5) end)
          -- Emit particles
          if data.particle[self.class.code .. 'attack'] then
            local x, y = self:attackParticlePosition(self.target)
            ctx.particles:emit(self.class.code .. 'attack', x, y, self.class.attackParticleCount or 5)
          end
        else
          self:attack()
        end
      end
    elseif event.data.name == 'deathjuju' then
      if not self.died then
        self:abilityCall('die')
        self.buffs:die()

        if ctx.tutorial:shouldDropJuju() and (not self.player or (self.player:hasShruju('relinquish') and love.math.random() < .5)) then
          local juju = config.juju
          local minAmount = juju.minimum.base + (ctx.units.level ^ juju.minimum.exponent) * juju.minimum.coefficient
          local maxAmount = juju.maximum.base + (ctx.units.level ^ juju.maximum.exponent) * juju.maximum.coefficient
          local amount = love.math.random(minAmount, maxAmount) * (self.elite and config.elites.jujuModifier or 1)
          local jujus = love.math.random(1, 3)

          if ctx.tutorial.active then jujus = 1 end

          if ctx.player:hasShruju('harvest') then amount = amount * 1.3 end

          if self.elite and love.math.random() < .25 then
            ctx.shrujus:add(data.shruju[love.math.random(1, #data.shruju)], {x = self.x, juju = amount})
          else
            for i = 1, jujus do
              ctx.jujus:add({
                x = self.x,
                y = self.y,
                amount = amount / jujus,
                vx = love.math.random(-100, 100),
                vy = love.math.random(-200, -100)
              })
            end
          end

          ctx.particles:emit('jujusex', self.x, self.y, 30)
        end

        self.died = true
      end
    elseif event.data.name == 'spawn' then
      ctx.sound:play(data.media.sounds[self.class.code].spawn, function(sound) sound:setVolume(.5) end)
      self:abilityCall('spawn')
    end
  end)

  self.animation:on('complete', function(data)
    if self.dying then return self:die() end
    if data.state.name == 'spawn' then
      self.spawning = false
      self.animation:set('idle', {force = true})
    elseif self.casting then
      self.casting = false
    elseif data.state.name:match('attack') then
      self:aiCall('useAbilities')
    end

    if not data.state.loop then self.animation:set('idle', {force = true}) end
    self.attackStart = tick
  end)
end

function Unit.getStat(class, stat)
  if type(class) == 'string' then class = data.unit[class] end
  local amount = class[stat]
  if stat == 'attackSpeed' or stat == 'haste' then amount = 0 end

  table.each(config.attributes.list, function(attribute)
    table.each(config.attributes[attribute], function(perLevel, attributeStat)
      if attributeStat == stat then
        amount = amount + class.attributes[attribute] * perLevel
      end
    end)
  end)

  table.each(ctx.player.deck[class.code].runes, function(rune)
    table.each(rune.stats, function(runeAmount, runeStat)
      if runeStat == stat then
        amount = amount + runeAmount
      end
    end)
  end)

  return amount
end
