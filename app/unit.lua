local g = love.graphics

Unit = class()

Unit.classStats = {'width', 'height', 'health', 'damage', 'range', 'attackSpeed', 'speed', 'flow'}
Unit.stanceList = {'defensive', 'aggressive', 'follow'}
table.each(Unit.stanceList, function(stance, i) Unit.stanceList[stance] = i end)

Unit.width = 64
Unit.height = 64
Unit.depth = -3

----------------
-- Core
----------------
function Unit:activate()
  Unit.canvas = Unit.canvas or g.newCanvas(400, 400)
  Unit.backCanvas = Unit.backCanvas or g.newCanvas(400, 400)

  self.animation = data.animation[self.class.code]({
    scale = data.animation[self.class.code].scale * (self.elite and config.elites.scale or (self.boss and 2 or 1))
  })

  if self.player then
    self.animation.flipped = not self.player.animation.flipped
  else
    local _, shrine = next(ctx.shrines:filter(function(s) return s.team == ctx.player.team end))
    self.animation.flipped = math.sign(self.x - shrine.x) > 0
  end

  self.animation:on('event', function(event)
    if event.data.name == 'attack' then
      if self.attackTarget and (tick - self.attackStart) * tickRate > self.attackSpeed * .25 then
        if self.class.attackSpell then
          ctx.spells:add(data.spell[self.class.code][self.class.attackSpell], {unit = self, target = self.attackTarget})
          ctx.sound:play(data.media.sounds[self.class.code].attackStart, function(sound) sound:setVolume(.5) end)
        else
          if self.attackTarget.player and not self.attackTarget.attackTarget and math.abs(self.attackTarget.x - (self.attackTarget.moveTarget or self.attackTarget.x)) < 2 then
            self.attackTarget.attackTarget = self
          end
          self:attack()
        end
      end
    elseif event.data.name == 'deathjuju' then
      if not self.died then
        self:abilityCall('die')

        if not self.player then
          local juju = config.biomes[ctx.biome].juju
          local minAmount = juju.minimum.base + (ctx.units.level ^ juju.minimum.exponent) * juju.minimum.coefficient
          local maxAmount = juju.maximum.base + (ctx.units.level ^ juju.maximum.exponent) * juju.maximum.coefficient
          local amount = love.math.random(minAmount, maxAmount)
          local jujus = love.math.random(1, 2)

          if self.elite then
            amount = amount * config.elites.jujuModifier
            jujus = 1
          elseif self.boss then
            amount = amount * 4
            jujus = 1
          end

          for i = 1, jujus do
            ctx.jujus:add({
              x = self.x,
              y = self.y,
              amount = amount / jujus,
              vx = love.math.random(-50, 50),
              vy = love.math.random(-300, -100),
              dead = self.boss
            })
          end
        end

        self.died = true
        
        if self.boss and not ctx.ded then
          ctx.won = true
        end
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
    elseif data.state.name == 'attack' then
      self:aiCall('useAbilities')
    end

    if not data.state.loop then self.animation:set('idle', {force = true}) end
    self.attackStart = tick
  end)

  self.buffs = UnitBuffs(self)

  if self.elite then
    self.health = self.health * config.elites.healthModifier
    self.damage = self.damage * config.elites.damageModifier
  elseif self.boss then
    self.health = self.health * 50
    self.damage = self.damage * 3
  end

  self.abilities = {}

  if not self.player then
    local function scale(stat)
      if self.class[stat .. 'Scaling'] then
        local coefficient, exponent = unpack(self.class[stat .. 'Scaling'])
        self[stat] = self[stat] + coefficient * ctx.units.level ^ exponent
      end
    end

    scale('health')
    scale('damage')
  end

  self.health = self.health + config.units.baseHealthScaling * (ctx.timer * tickRate / 60)
  self.damage = self.damage + config.units.baseDamageScaling * (ctx.timer * tickRate / 60)
  self.flow = 1

  table.each(self.class.attributes, function(attribute)
    self[attribute.stat] = self[attribute.stat] + attribute.amount * attribute.level
  end)

  self.y = ctx.map.height - ctx.map.groundHeight - self.height
  self.team = self.player and self.player.team or 0
  self.maxHealth = self.health
  self.dying = false
  self.died = false
  self.casting = false
  self.channeling = false
  self.spawning = true
  self.droppedJuju = false
  self.knockup = 0

  table.each(self.class.upgrades, function(upgrade)
    f.exe(upgrade.apply, upgrade, self)
  end)

  table.each(self.class.startingAbilities, function(ability)
    self:addAbility(ability)
  end)

  self.healthDisplay = self.health
  self.prev = {x = self.x, y = self.y, health = self.health, healthDisplay = self.healthDisplay, knockup = 0, glowScale = 1}
  self.alpha = 1
  self.glowScale = 1

  local r = love.math.random(0, 20)
  self.y = self.y + r
  self.depth = self.depth - r / 30 + love.math.random() * (1 / 30)

  self.moveTarget = self.x
  self.attackTarget = nil

  self.ai = (data.ai[self.class.code] or UnitAI)()
  self.ai.unit = self
  self:aiCall('activate')

  ctx.event:emit('view.register', {object = self})
end

function Unit:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Unit:update()
  self.prev.x = self.x
  self.prev.y = self.y
  self.prev.health = self.health
  self.prev.healthDisplay = self.healthDisplay
  self.prev.knockup = self.knockup
  self.prev.glowScale = self.glowScale

  self.alpha = math.lerp(self.alpha, self.dying and 0 or 1, math.min(10 * tickRate, 1))

  if self.dying then
    self.channeling = false
    self.spawning = false
    self.casting = false
    self.animation:set('death', {force = true})
    self.animation.speed = 1
    self.healthDisplay = math.lerp(self.healthDisplay, 0, math.min(10 * tickRate, 1))
    self.buffs:postupdate()
    return
  end

  self:abilityCall('update')
  self:abilityCall('rot')

  self.buffs:preupdate()

  if not self.spawning and not self.casting and not self.channeling then
    self:aiCall('update')
  end

  self.buffs:postupdate()

  f.exe(self.class.update, self)

  self.healthDisplay = math.lerp(self.healthDisplay, self.health, math.min(10 * tickRate, 1))
  self.glowScale = math.lerp(self.glowScale, 1, math.min(6 * tickRate, 1))

  if self.animation.state.name == 'attack' then
    local current = self.animation.spine.animationState:getCurrent(0)
    if current then self.animation.speed = current.endTime / self.attackSpeed end
  elseif self.animation.state.name == 'walk' then
    self.animation.speed = self.speed / self.class.speed
  else
    self.animation.speed = 1
  end
end

function Unit:draw()
  local lerpd = table.interpolate(self.prev, self, tickDelta / tickRate)
  local x, y, health = lerpd.x, lerpd.y, lerpd.health

  local r, gg, b = 0, 0, 0
  if self.selected or self:contains(love.mouse.getPosition()) then
    r = self.team == ctx.player.team and 0 or 255
    gg = self.team == ctx.player.team and 255 or 0
  end

  self.canvas:clear(r, gg, b, 0)
  self.backCanvas:clear(r, gg, b, 0)
  g.setColor(r, gg, b, 255 * self.alpha)

  local shader = data.media.shaders.colorize
  self.canvas:renderTo(function()
    g.setShader(shader)
    self.animation:draw(200, 200)
    g.setShader()
  end)

  data.media.shaders.horizontalBlur:send('amount', .0005 * lerpd.glowScale)
  data.media.shaders.verticalBlur:send('amount', .0005 * lerpd.glowScale)
  g.setColor(255, 255, 255)
  for i = 1, 3 do
    g.setShader(data.media.shaders.horizontalBlur)
    self.backCanvas:renderTo(function()
      g.draw(self.canvas)
    end)
    g.setShader(data.media.shaders.verticalBlur)
    self.canvas:renderTo(function()
      g.draw(self.backCanvas)
    end)
  end
  g.setShader()

  g.setColor(255, 255, 255)
  self.canvas:renderTo(function()
    self.animation:draw(200, 200, {noupdate = true})
  end)

  g.setColor(255, 255, 255, 255 * self.alpha)
  g.draw(self.canvas, x, y - (lerpd.knockup or 0), 0, 1, 1, 200, 200)
  self.animation:setPosition(x, y - (lerpd.knockup or 0))

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
function Unit:attack(options)
  options = options or {}
  local target = options.target or self.attackTarget
  if not target then return end
  local amount = options.damage or self.damage
  amount = self:abilityCall('preattack', target, amount) or amount
  amount = self.buffs:preattack(target, amount) or amount
  amount = target:hurt(amount, self, {'attack'}) or amount
  self:abilityCall('postattack', target, amount)
  self.buffs:postattack(target, amount)

  if not options.nosound then
    ctx.sound:play(data.media.sounds[self.class.code].attackHit, function(sound)
      sound:setVolume(.4)
    end)
  end

  if not options.noparticles and data.particle[self.class.code .. 'attack'] then
    ctx.particles:emit(self.class.code .. 'attack', target.x + (target.width * .4 * -math.sign(target.x - self.x)), self.y + self.height * .4, 5)
  end
end

function Unit:useAbility(index, target)
  if self.dying or self.casting or self.channeling then return end

  local ability = self.abilities[index]
  if ability:canUse() and not self.buffs:silenced() then
    ctx.net:emit('unitAbility', {id = self.id, tick = tick, ability = index, target = target})

    if ability.target == 'unit' or ability.target == 'ally' or ability.target == 'enemy' then
      target = ctx.units:get(target)
    end
    f.exe(ability.use, ability, target)
    f.exe(ability.used, ability, target)
  end
end

function Unit:hurt(amount, source, kind)
  if self.dying then return end

  self:abilityCall('prehurt', amount, source, kind)
  amount = self.buffs:prehurt(amount, source, kind) or amount

  self.health = math.max(self.health - amount, 0)

  self:abilityCall('posthurt', amount, source, kind)
  self.buffs:posthurt(amount, source, kind)

  if self.health <= 0 then
    self.animation:set('death', {force = true})
    ctx.sound:play(data.media.sounds[self.class.code].death, function(sound)
     sound:setVolume(.4)
    end)
    self.dying = true

    ctx.units:each(function(u)
      if u.attackTarget == self then u.attackTarget = nil end
    end)
  end

  return amount
end

function Unit:heal(amount, source)
  if self.dying then return end

  self.health = math.min(self.health + amount * self.buffs:potency(), self.maxHealth)
end

function Unit:die()
  if self.player then
    self.player.deck[self.class.code].instance = nil
  end

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
end

function Unit:hasAbility(code)
  return next(table.filter(self.abilities, function(ability) return ability.code == code end))
end

function Unit:upgradeLevel(code)
  return self.class.upgrades[code] and self.class.upgrades[code].level or 0
end
