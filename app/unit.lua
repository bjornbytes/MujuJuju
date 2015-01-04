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
  self.animation = data.animation[self.class.code]()
  self.animation.flipped = self.player and not self.player.animation.flipped

  self.animation:on('event', function(data)
    if data.data.name == 'attack' then
      if self.target and (tick - self.attackStart) * tickRate > self.attackSpeed * .25 then
        self:abilityCall('preattack', self.target, self.damage)
        self.buffs:preattack(self.target, self.damage)
        local amount = self.target:hurt(self.damage, self, 'attack')
        self:abilityCall('postattack', self.target, amount)
        self.buffs:postattack(self.target, amount)
        if not self.target or self.target.dying then
          self.target = nil
          self.animation:set('idle')
        end

        self.ai.useAbilities(self)
      end
    end
  end)

  self.animation:on('complete', function(data)
    if data.state.name == 'death' then
      self:die()
    elseif data.state.name == 'spawn' then
      self.spawning = false
      self.animation:set('idle', {force = true})
    elseif self.casting then
      self.casting = false
    end

    if not data.state.loop then self.animation:set('idle', {force = true}) end
    self.attackStart = tick
  end)

  self.buffs = UnitBuffs(self)

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

  table.each(self.class.upgrades, function(upgrade)
    f.exe(upgrade.apply, upgrade, self)
  end)

  self.range = self.range + love.math.random(-10, 10)

  self.healthDisplay = self.health
  self.prev = {x = self.x, y = self.y, healthDisplay = self.healthDisplay}
  self.backCanvas = g.newCanvas(200, 200)
  self.canvas = g.newCanvas(200, 200)

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

  if self.dying then
    self.healthDisplay = math.lerp(self.healthDisplay, 0, 20 * tickRate)
    return
  end

  self:abilityCall('update')
  self:abilityCall('rot')

  self.buffs:preupdate()

  if not self.spawning and not self.casting and not self.channeling then
    f.exe(self.stances[self.stance], self)
  end

  self.buffs:postupdate()

  self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)

  if self.player then self:hurt(self.maxHealth * .02 * tickRate) end
end

function Unit:draw()
  local lerpd = table.interpolate(self.prev, self, tickDelta / tickRate)
  local x, y, health = lerpd.x, lerpd.y, lerpd.health

  if self.team == ctx.players:get(ctx.id).team then
    self.canvas:clear(0, 255, 0, 0)
    self.backCanvas:clear(0, 255, 0, 0)
    g.setColor(0, 255, 0)
    self.canvas:clear(0, 0, 0, 0)
    self.backCanvas:clear(0, 0, 0, 0)
    g.setColor(0, 0, 0)
  else
    self.canvas:clear(255, 0, 0, 0)
    self.backCanvas:clear(255, 0, 0, 0)
    g.setColor(255, 0, 0)
    self.canvas:clear(0, 0, 0, 0)
    self.backCanvas:clear(0, 0, 0, 0)
    g.setColor(0, 0, 0)
  end

  local shader = data.media.shaders.colorize
  self.canvas:renderTo(function()
    g.setShader(shader)
    self.animation:draw(100, 100)
    g.setShader()
  end)

  local selected = true
  data.media.shaders.horizontalBlur:send('amount', selected and .004 or .002)
  data.media.shaders.verticalBlur:send('amount', selected and .004 or .002)
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
  g.setColor(255, 255, 255, 128)
  g.draw(self.canvas, x, y, 0, 1, 1, 100, 100)
  g.setColor(255, 255, 255)
  self.animation:draw(x, y, {noupdate = true})
end

function Unit:getHealthbar()
  local lerpd = table.interpolate(self.prev, self, tickDelta / tickRate)
  return lerpd.x, lerpd.y, lerpd.healthDisplay / self.maxHealth
end


----------------
-- Stances
----------------
Unit.stances = {}
function Unit.stances:defensive()
  self:changeTarget(ctx.target:closest(self, 'enemy', 'player', 'unit'))

  if self.target and self:inRange(self.target) then
    self:attack(self.target)
  else
    self.animation:set('idle')
  end
end

function Unit.stances:aggressive()
  self:changeTarget(ctx.target:closest(self, 'enemy', 'shrine', 'player', 'unit'))

  if self.target and self:inRange(self.target) then
    self:attack(self.target)
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

function Unit:attack(target)
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
  amount = self.buffs:prehurt(amount, source, kind)

  self.health = math.max(self.health - amount, 0)

  self:abilityCall('posthurt', amount, source, kind)
  self.buffs:posthurt(amount, source, kind)

  if self.health <= 0 then
    self.animation:set('death', {force = true})
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

  if not self.player then
    local amount = love.math.random(8 + (ctx.units.level ^ .8) * .75, 12 + (ctx.units.level ^ .85))
    local jujus = 1
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
  return self.runes and #self.runes > 0
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