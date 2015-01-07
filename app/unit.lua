local g = love.graphics

Unit = class()

Unit.classStats = {'health', 'damage', 'range', 'attackSpeed', 'speed'}
Unit.stanceList = {'defensive', 'aggressive', 'follow'}
table.each(Unit.stanceList, function(stance, i) Unit.stanceList[stance] = i end)

Unit.width = 64
Unit.height = 64
Unit.depth = -3

----------------
-- Core
----------------
function Unit:activate()
  self.animation = data.animation[self.class.code]({
    scale = (self.elite and config.elites.scale) or nil
  })

  if self.player then
    self.animation.flipped = not self.player.animation.flipped
  else
    local _, shrine = next(ctx.shrines:filter(function(s) return s.team == ctx.players:get(ctx.id).team end))
    self.animation.flipped = math.sign(self.x - shrine.x) > 0
  end

  self.animation:on('event', function(event)
    if event.data.name == 'attack' then
      if self.target and (tick - self.attackStart) * tickRate > self.attackSpeed * .25 then
        if self.class.attackSpell then
          ctx.spells:add(self.class.attackSpell, {unit = self, target = self.target})
          ctx.sound:play(data.media.sounds[self.class.code].attackStart, function(sound) sound:setVolume(.5) end)
        else
          self:attack()
        end
      end
    elseif event.data.name == 'deathjuju' then
      if not self.player and not self.droppedJuju then
        local juju = config.biomes[ctx.biome].juju
        local minAmount = juju.minimum.base + (ctx.units.level ^ juju.minimum.exponent) * juju.minimum.coefficient
        local maxAmount = juju.maximum.base + (ctx.units.level ^ juju.maximum.exponent) * juju.maximum.coefficient
        local amount = love.math.random(minAmount, maxAmount)
        local jujus = math.random(1, 2)

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

        self.droppedJuju = true
      end
    elseif event.data.name == 'spawn' then
      ctx.sound:play(data.media.sounds[self.class.code].spawn, function(sound) sound:setVolume(.5) end)
    end
  end)

  self.animation:on('complete', function(data)
    if self.dying then return self:die() end
    if data.state.name == 'spawn' then
      self.spawning = false
      self.animation:set('idle', {force = true})
    elseif self.casting then
      self.casting = false
    end

    if not data.state.loop then self.animation:set('idle', {force = true}) end
    self.attackStart = tick
  end)

  self.buffs = UnitBuffs(self)

  if self.elite then
    self.health = self.health * config.elites.healthModifier
    self.damage = self.damage * config.elites.damageModifier
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

  self.y = ctx.map.height - ctx.map.groundHeight - self.height
  self.team = self.player and self.player.team or 0
  self.maxHealth = self.health
  self.stance = 'aggressive'
  self.dying = false
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

  self.range = self.range + love.math.random(-10, 10)

  self.healthDisplay = self.health
  self.prev = {x = self.x, y = self.y, healthDisplay = self.healthDisplay}
  self.backCanvas = g.newCanvas(200, 200)
  self.canvas = g.newCanvas(200, 200)
  self.alpha = 0

  local r = love.math.random(0, 20)
  self.y = self.y + r
  self.depth = self.depth - r / 30 + love.math.random() * (1 / 30)

  ctx.event:emit('view.register', {object = self})
end

function Unit:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Unit:update()
  self.prev.healthDisplay = self.healthDisplay
  self.prev.x = self.x
  self.prev.y = self.y
  self.prev.health = self.health
  self.prev.knockup = self.knockup

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
    f.exe(self.stances[self.stance], self)
  end

  self.buffs:postupdate()

  self.healthDisplay = math.lerp(self.healthDisplay, self.health, math.min(10 * tickRate, 1))

  if self.animation.state.name == 'attack' then
    local current = self.animation.spine.animationState:getCurrent(0)
    if current then self.animation.speed = current.endTime / self.class.attackSpeed end
  else
    self.animation.speed = 1
  end

  if self.player then self:hurt(self.maxHealth * .02 * tickRate) end
end

function Unit:draw()
  local lerpd = table.interpolate(self.prev, self, tickDelta / tickRate)
  local x, y, health = lerpd.x, lerpd.y, lerpd.health

  local r, gg, b
  local max = self.player and self.class.health or self.maxHealth
  if lerpd.healthDisplay > max then
    local prc = (self.maxHealth - lerpd.healthDisplay) / (self.maxHealth - max)
    r = math.lerp(128, 0, prc)
    gg = math.lerp(0, 255, prc)
    b = math.lerp(255, 0, prc)
  else
    local prc = math.min(lerpd.healthDisplay / self.class.health, 1)
    r = math.lerp(255, 0, prc)
    gg = math.lerp(0, 255, prc)
    b = math.lerp(0, 0, prc)
  end

  self.canvas:clear(r, gg, b, 0)
  self.backCanvas:clear(r, gg, b, 0)
  g.setColor(r, gg, b)

  local shader = data.media.shaders.colorize
  self.canvas:renderTo(function()
    g.setShader(shader)
    self.animation:draw(100, 100)
    g.setShader()
  end)

  data.media.shaders.horizontalBlur:send('amount', .001)
  data.media.shaders.verticalBlur:send('amount', .001)
  g.setColor(255, 255, 255)
  for i = 1, 1 do
    g.setShader(data.media.shaders.horizontalBlur)
    self.backCanvas:renderTo(function()
      g.draw(self.canvas)
    end)
    g.setShader(data.media.shaders.verticalBlur)
    self.canvas:renderTo(function()
      g.draw(self.backCanvas)
    end)
  end

  g.setShader(data.media.shaders.colorize)
  g.setColor(r, gg, b)
  self.backCanvas:clear(r, gg, b, 0)
  self.backCanvas:renderTo(function()
    g.draw(self.canvas)
  end)
  g.setShader()
  
  g.setColor(255, 255, 255, 128 * self.alpha)
  g.draw(self.backCanvas, x, y - lerpd.knockup, 0, 1, 1, 100, 100)
  g.setColor(255, 255, 255)
  self.animation:draw(x, y - lerpd.knockup, {noupdate = true})
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
-- Stances
----------------
Unit.stances = {}
function Unit.stances:defensive()
  self:changeTarget(ctx.target:closest(self, 'enemy', 'player', 'unit'))

  if self.target and self:inRange(self.target) then
    self:startAttacking(self.target)
  else
    self.animation:set('idle')
  end
end

function Unit.stances:aggressive()
  self:changeTarget(ctx.target:closest(self, 'enemy', 'shrine', 'player', 'unit'))

  if self.target and self:inRange(self.target) then
    self:startAttacking(self.target)
  elseif self.target then
    self:moveIntoRange(self.target)
  else
    self.animation:set('idle')
  end
end

function Unit.stances:follow()
  self:moveTowards(self.player)
end


----------------
-- Behavior
----------------
function Unit:changeTarget(target)
  local taunt = self.buffs:taunted()
  self.target = taunt or target
end

function Unit:inRange(target)
  return math.abs(target.x - self.x) <= self.range + target.width / 2 + self.width / 2
end

function Unit:moveIntoRange(target)
  if self:inRange(target) then
    self.animation:set('idle')
    return
  end

  self:moveTowards(target)
end

function Unit:moveTowards(target)
  if math.abs(target.x - self.x) <= target.width / 2 + self.width / 2 then
    self.animation:set('idle')
    return
  end

  self.x = self.x + self.speed * math.sign(target.x - self.x) * tickRate
  self.animation:set('walk')
  self.animation.flipped = self.x > target.x
end

function Unit:startAttacking(target)
  if not self:inRange(target) or self.buffs:stunned() then
    self.target = nil
    self.animation:set('idle')
    return
  end

  self.target = target
  if self.animation.state.name ~= 'attack' then self.attackStart = tick end
  self.animation.flipped = self.x > target.x
  self.animation:set('attack')
end

function Unit:attack(options)
  options = options or {}
  local target = options.target or self.target
  if not target then return end
  local amount = options.damage or self.damage
  amount = self:abilityCall('preattack', target, amount) or amount
  amount = self.buffs:preattack(target, amount) or amount
  amount = target:hurt(amount, self, 'attack') or amount
  self:abilityCall('postattack', target, amount)
  self.buffs:postattack(target, amount)
  self.ai.useAbilities(self)
  if not options.nosound then
    local sounds = data.media.sounds[self.class.code]
    local sound = sounds and sounds.attackHit
    if self.class.attackHitSoundCount then
      sound = sounds['attackHit' .. love.math.random(1, self.class.attackHitSoundCount)]
    end
    ctx.sound:play(sound, function(sound)
      sound:setVolume(.4)
    end)
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
  end

  return amount
end

function Unit:heal(amount, source)
  if self.dying then return end

  self.health = math.min(self.health + amount, self.maxHealth)
end

function Unit:die()
  self:abilityCall('die')
  self:abilityCall('deactivate')

  table.each(ctx.units.objects, function(u)
    if u.target == self then u.target = nil end
  end)

  ctx.units:remove(self)
end


----------------
-- AI
----------------
Unit.ai = {}
function Unit.ai.useAbilities(self)
  table.each(self.abilities, function(ability)
    if ability:canUse() and love.math.random() < .5 then
      f.exe(ability.use, ability)
    end
  end)
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
