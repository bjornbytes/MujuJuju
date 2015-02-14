local g = love.graphics

Unit = class()

Unit.classStats = {'width', 'height', 'health', 'damage', 'range', 'attackSpeed', 'speed', 'flow'}

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
    self.health = self.health + config.units.baseHealthScaling * (ctx.timer * tickRate / 60)
    self.damage = self.damage + config.units.baseDamageScaling * (ctx.timer * tickRate / 60)
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

  -- Ability stats
  self.spirit = 0
  self.haste = 1

  -- Apply attributes
  table.each(config.attributes.list, function(attribute)
    table.each(config.attributes[attribute], function(perLevel, stat)
      self[stat] = self[stat] + self.class.attributes[attribute] * perLevel
    end)
  end)

  -- Apply upgrades
  table.each(self.class.upgrades, function(upgrade)
    f.exe(upgrade.apply, upgrade, self)
  end)

  -- Display-related variables
  self.maxHealth = self.health
  self.healthDisplay = self.health
  self.prev = {x = self.x, y = self.y, health = self.health, healthDisplay = self.healthDisplay, knockup = 0, glowScale = 1}
  self.alpha = 1
  self.glowScale = 1
  self.knockup = 0

  -- AI
  self.ai = (data.ai[self.class.code] or UnitAI)()
  self.ai.unit = self
  self.target = nil
  self:aiCall('activate')

  -- Register with View
  ctx.event:emit('view.register', {object = self})
end

function Unit:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Unit:update()

  -- For lerping
  self.prev.x = self.x
  self.prev.y = self.y
  self.prev.health = self.health
  self.prev.healthDisplay = self.healthDisplay
  self.prev.knockup = self.knockup
  self.prev.glowScale = self.glowScale

  -- Dying behavior
  if self.dying then
    self.channeling = false
    self.spawning = false
    self.casting = false
    self.animation:set('death', {force = true})
    self.animation.speed = 1
    self.healthDisplay = math.lerp(self.healthDisplay, 0, math.min(10 * tickRate, 1))
    self.buffs:update()
    return
  end

  -- Update abilities
  self:abilityCall('update')
  self:abilityCall('rot')

  -- Update buffs
  self.buffs:update()

  -- Update AI
  if not self.spawning and not self.casting and not self.channeling then
    self:aiCall('update')
  end

  -- Lerps
  self.healthDisplay = math.lerp(self.healthDisplay, self.health, math.min(10 * tickRate, 1))
  self.glowScale = math.lerp(self.glowScale, 1, math.min(6 * tickRate, 1))

  -- Update animation speed
  if self.animation.state.name == 'attack' then
    local current = self.animation.spine.animationState:getCurrent(0)
    if current then self.animation.speed = current.endTime / self.animation.state.speed / self.attackSpeed end
  elseif self.animation.state.name == 'walk' then
    self.animation.speed = self.speed / self.class.speed
  else
    self.animation.speed = 1
  end

  -- Health decay
  if self.player then self:hurt(self.maxHealth * .02 * tickRate) end
end

function Unit:draw()
  local lerpd = table.interpolate(self.prev, self, tickDelta / tickRate)
  local x, y, health = lerpd.x, lerpd.y, lerpd.health

  -- Decide on color
  local r, gg, b = 0, 0, 0
  r = self.team == ctx.player.team and 0 or 255
  gg = self.team == ctx.player.team and 255 or 0

  self.canvas:clear(r, gg, b, 0)
  self.backCanvas:clear(r, gg, b, 0)
  g.setColor(r, gg, b, 255 * self.alpha)

  -- Render colored silhouette of unit to canvas
  local shader = data.media.shaders.colorize
  self.canvas:renderTo(function()
    g.setShader(shader)
    g.pop()
    self.animation:draw(200, 200)
    ctx.view:worldPush()
    g.setShader()
  end)

  -- Blur canvas
  data.media.shaders.horizontalBlur:send('amount', .0005 * lerpd.glowScale)
  data.media.shaders.verticalBlur:send('amount', .0005 * lerpd.glowScale)
  g.setColor(255, 255, 255)
  for i = 1, 3 do
    g.setShader(data.media.shaders.horizontalBlur)
    self.backCanvas:renderTo(function()
      g.pop()
      g.draw(self.canvas)
      ctx.view:worldPush()
    end)
    g.setShader(data.media.shaders.verticalBlur)
    self.canvas:renderTo(function()
      g.pop()
      g.draw(self.backCanvas)
      ctx.view:worldPush()
    end)
  end
  g.setShader()

  -- Draw blurred outline
  g.setColor(255, 255, 255, 255 * self.alpha)
  g.draw(self.canvas, x, y - (lerpd.knockup or 0), 0, 1, 1, 200, 200)

  -- Draw animation
  self.animation:draw(x, y - (lerpd.knockup or 0), {noupdate = true})

  -- Fear icon
  if self.buffs:feared() then
    g.setColor(255, 255, 255, 150 * self.alpha)
    local image = data.media.graphics.fear
    local scale = (40 / image:getHeight()) * (1 + math.cos(math.sin(tick) / 3) / 5)
    g.draw(image, self.x, self.y - self.height - 35, math.cos(tick / 3) / 6, scale, scale, 53, 83)
  end
end

function Unit:getHealthbar()
  local lerpd = table.interpolate(self.prev, self, tickDelta / tickRate)
  return lerpd.x, lerpd.y, lerpd.health / self.maxHealth, lerpd.healthDisplay / self.maxHealth
end

function Unit:paused()
  self.prev.x = self.x
  self.prev.y = self.y
  self.animation:set('idle')
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
    self.abilityCall('kill', target)
  end

  -- Play sound
  if not options.nosound then
    ctx.sound:play(data.media.sounds[self.class.code].attackHit, function(sound)
      sound:setVolume(.4)
    end)
  end

  -- Emit particles
  if not options.noparticles and data.particle[self.class.code .. 'attack'] then
    ctx.particles:emit(self.class.code .. 'attack', target.x + (target.width * .4 * -math.sign(target.x - self.x)), self.y + self.height * .4, 5)
  end
end

function Unit:hurt(amount, source, kind)
  if self.dying then return end

  -- Prehurt hooks
  self:abilityCall('prehurt', amount, source, kind)
  amount = self.buffs:prehurt(amount, source, kind) or amount

  -- Deal damage
  self.health = math.max(self.health - amount, 0)

  -- Posthurt hooks
  self:abilityCall('posthurt', amount, source, kind)
  self.buffs:posthurt(amount, source, kind)

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

  -- Apply ability runes
  if self.player then
    table.each(self.player.deck[self.class.code].runes, function(rune)
      if rune.unit == self.class.code and rune.abilities[code] then
        table.each(rune.abilities[code], function(amount, stat)
          ability[stat] = ability[stat] + amount
        end)
      end
    end)
  end

  f.exe(ability.activate, ability)
end

function Unit:hasAbility(code)
  return next(table.filter(self.abilities, function(ability) return ability.code == code end))
end

function Unit:upgradeLevel(code)
  return self.class.upgrades[code] and self.class.upgrades[code].level or 0
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
      if self.target and (tick - self.attackStart) * tickRate > self.attackSpeed * .25 then
        if self.class.attackSpell then
          ctx.spells:add(data.spell[self.class.code][self.class.attackSpell], {unit = self, target = self.target})
          ctx.sound:play(data.media.sounds[self.class.code].attackStart, function(sound) sound:setVolume(.5) end)
        else
          self:attack()
        end
      end
    elseif event.data.name == 'deathjuju' then
      if not self.died then
        self:abilityCall('die')
        self.buffs:die()

        if not self.player then
          local juju = config.biomes[ctx.biome].juju
          local minAmount = juju.minimum.base + (ctx.units.level ^ juju.minimum.exponent) * juju.minimum.coefficient
          local maxAmount = juju.maximum.base + (ctx.units.level ^ juju.maximum.exponent) * juju.maximum.coefficient
          local amount = love.math.random(minAmount, maxAmount)
          local jujus = love.math.random(1, 2)

          if self.elite then
            amount = amount * config.elites.jujuModifier
            jujus = 1
          end

          for i = 1, jujus do
            ctx.jujus:add({
              x = self.x,
              y = self.y,
              amount = amount / jujus,
              vx = love.math.random(-50, 50),
              vy = love.math.random(-300, -100)
            })
          end
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
