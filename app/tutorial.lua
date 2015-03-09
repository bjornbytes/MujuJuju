local g = love.graphics
local tween = require 'lib/deps/tween/tween'
Tutorial = class()

function Tutorial:init(active)
  self.active = active

  self.messages = {
    muju = 'This is Muju',
    move = 'You can move Muju with A and D',
    shrine = 'This is Muju\'s shrine.  Protect it!',
    enemy = 'Enemies will attack your shrine.',
    minion = 'Press space to summon a minion.',
    battle = 'Your minions will protect your shrine.',
    juju = 'Enemies drop Juju when they die.',
    realm = 'Juju can be collected in the Juju Realm.',
    death = 'Muju enters the Juju Realm when he dies.',
    collect = 'Control the ghost with WASD to get the juju.',
    goodjob = 'Good job!',
    resurrect = 'Muju\'s ghost returns to his body after some time.',
    status = 'Here you can see your Juju and the clock.',
    hudminions = 'Here you can see information about your minions.',
    cost = 'Minions have a cost...',
    cooldown = '...and a cooldown.',
    upgrade = 'Stand near your shrine and press E to upgrade minions.',
    upgradecost = 'All upgrades cost Juju.',
    upgradehover = 'Hover over an icon for more information about the upgrade.',
    upgradetry = 'To continue, purchase any upgrade by clicking on it.',
    upgradeexit = 'Awesome!  Press E again to exit the upgrade menu.',
    glhf = 'That\'s about it.  Have fun!'
  }

  self.nextMessage = {
    muju = 'move',
    move = 'shrine',
    shrine = 'enemy',
    enemy = 'minion',
    minion = 'battle',
    battle = 'juju',
    juju = 'realm',
    realm = 'death',
    death = 'collect',
    collect = 'goodjob',
    goodjob = 'resurrect',
    resurrect = 'status',
    status = 'hudminions',
    hudminions = 'cost',
    cost = 'cooldown',
    cooldown = 'upgrade',
    upgrade = 'upgradecost',
    upgradecost = 'upgradehover',
    upgradehover = 'upgradetry',
    upgradetry = 'upgradeexit',
    upgradeexit = 'glhf'
  }

  self.pointerOrientations = {
    status = 'top',
    hudminions = 'top',
    cost = 'top',
    cooldown = 'top',
    upgradecost = 'none',
    upgradehover = 'none',
    upgradetry = 'none',
    upgradeexit = 'none',
    glhf = 'none'
  }

  self.messageIndex = 1
  self.message = 'muju'

  self.opened = true
  self.time = 0
  self.prevTime = self.time
  self.maxTime = .1
  self.factor = {value = 0}
  self.tween = tween.new(self.maxTime, self.factor, {value = 1}, 'inOutBack')
  self.delay = self.maxTime
  self.x = ctx.hud.u * .5
  self.y = 0
  self.prevx, self.prevy = self.x, self.y

  self.moveTargetX = ctx.map.width * .62

  if active then
    ctx.player.x = ctx.map.width * .4
    ctx.player.animation.flipped = true
    ctx.player.juju = 100
  end

  ctx.event:emit('view.register', {object = self, mode = 'gui'})
end

function Tutorial:update()
  if not self.active then return end

  self.prevTime = self.time
  self.prevx = self.x
  self.prevy = self.y

  local u, v = ctx.hud.u, ctx.hud.v
  local height = .02 * v + .01 * u + 10

  local x, y = self.x or 0, self.y or 0
  local yoffsets = {default = height, top = -height, none = 0}
  y = y + (yoffsets[self.pointerOrientations[self.message]] or yoffsets.default)
  if self.message == 'muju' then
    x, y = ctx.view:screenPoint(ctx.player.x, ctx.player.y - 25)
  elseif self.message == 'shrine' then
    x, y = ctx.view:screenPoint(ctx.shrine.x, ctx.shrine.y)
  elseif self.message == 'move' then
    x, y = ctx.view:screenPoint(self.moveTargetX, ctx.map.height - ctx.map.groundHeight - ctx.player.height - 25)
  elseif self.message == 'enemy' then
    if self.enemy then
      x, y = ctx.view:screenPoint(self.enemy.x, self.enemy.y - self.enemy.height)
    end
  elseif self.message == 'minion' then
    x, y = ctx.view:screenPoint(ctx.player.x + 30, self.enemy.y - self.enemy.height)
  elseif self.message == 'battle' then
    local minion = ctx.units:filter(function(m) return m.player end)[1]
    if minion and self.enemy then
      x, y = ctx.view:screenPoint((minion.x + self.enemy.x) / 2, self.enemy.y - self.enemy.height - 40)
    end
  elseif self.message == 'juju' or self.message == 'realm' then
    local _, juju = next(ctx.jujus.jujus)
    if juju then
      x, y = ctx.view:screenPoint(juju.x, juju.y - juju.amount)
    end
  elseif self.message == 'death' then
    x, y = ctx.view:screenPoint(ctx.player.x, ctx.player.y - 65)
  elseif self.message == 'collect' then
    if ctx.player.ghost then
      x, y = ctx.view:screenPoint(ctx.player.ghost.x, ctx.player.ghost.y - 40)
    end
  elseif self.message == 'resurrect' then
    x, y = ctx.view:screenPoint(ctx.player.x, ctx.player.y - 65)
  elseif self.message == 'status' then
    x, y = u * .92, v * .1
  elseif self.message == 'hudminions' then
    x, y = u * .5, v * .25
  elseif self.message == 'cost' then
    x, y = u * .445, v * .15
  elseif self.message == 'cooldown' then
    x, y = u * .5, v * .06
  elseif self.message == 'upgrade' then
    x, y = ctx.view:screenPoint(ctx.shrine.x, ctx.shrine.y)
  elseif self.message == 'upgradecost' or self.message == 'upgradehover' or self.message == 'upgradetry' or self.message == 'upgradeexit' then
    x, y = u * .5, v * .3
  elseif self.message == 'glhf' then
    x, y = u * .5, v * .5
  end

  y = y - (yoffsets[self.pointerOrientations[self.message]] or yoffsets.default)

  self.x = math.lerp(self.x, x, 12 * ls.tickrate)
  self.y = math.lerp(self.y, y, 12 * ls.tickrate)

  if self.opened then
    self.delay = timer.rot(self.delay)
    if self.delay == 0 then
      if self.time < self.maxTime then
        self.time = math.min(self.time + ls.tickrate, self.maxTime)
        if self.time == self.maxTime then
          self:enter(self.message)
        end
      end
    end
  else
    self.delay = timer.rot(self.delay)
    if self.delay == 0 then
      self.time = math.max(self.time - ls.tickrate, 0)
      if self.time == 0 then
        self.message = self.nextMessage[self.message]
        self.messageIndex = self.messageIndex + 1
        self.opened = true
      end
    end
  end

  if self.opened and self.delay == 0 and self.time == self.maxTime then
    if self.message == 'muju' and love.keyboard.isDown('return', ' ') then
      self.opened = false
    elseif self.message == 'shrine' and love.keyboard.isDown('return', ' ') then
      self.opened = false
    elseif self.message == 'move' and math.abs(ctx.player.x - self.moveTargetX) < 20 then
      self.opened = false
      self.delay = .35
    elseif self.message == 'enemy' and love.keyboard.isDown('return', ' ') then
      self.opened = false
    elseif self.message == 'minion' and ctx.player.totalSummoned > 0 then
      self.opened = false
    elseif self.message == 'battle' then
      local _, juju = next(ctx.jujus.jujus)
      if juju and math.abs(juju.vy) < 100 then
        self.opened = false
      end
    elseif self.message == 'juju' and love.keyboard.isDown('return', ' ') then
      self.opened = false
    elseif self.message == 'realm' and love.keyboard.isDown('return', ' ') then
      self.opened = false
    elseif self.message == 'death' and ctx.player.dead then
      self.opened = false
    elseif self.message == 'collect' then
      if not next(ctx.jujus.jujus) then
        self.opened = false
      end
    elseif self.message == 'goodjob' then
      self.delay = 1
      self.opened = false
    elseif self.message == 'resurrect' and not ctx.player.dead then
      self.delay = 2
      self.opened = false
    elseif (self.message == 'status' or self.message == 'hudminions' or self.message == 'cost' or self.message == 'cooldown') and love.keyboard.isDown('return', ' ') then
      self.opened = false
    elseif self.message == 'upgrade' and ctx.hud.upgrades.active then
      self.opened = false
    elseif (self.message == 'upgradecost' or self.message == 'upgradehover') and love.keyboard.isDown('return', ' ') then
      self.opened = false
    elseif self.message == 'upgradetry' and data.unit.bruju.cost > 10 then
      self.delay = .2
      self.opened = false
    elseif self.message == 'upgradeexit' and not ctx.hud.upgrades.active then
      self.delay = .8
      self.opened = false
    elseif self.message == 'glhf' and love.keyboard.isDown('return', ' ') then
      self.opened = false
    end

    if not self.opened then
      self:exit(self.message)
    end
  end
end

function Tutorial:gui()
  if not self.active then return end

  local u, v = ctx.view.frame.width, ctx.view.frame.height
  local font = g.setFont('mesmerize', .04 * v)

  if self.messages[self.message] then
    local str = self.messages[self.message]
    local factor, t = self:getFactor()
    local alpha = (t / self.maxTime) ^ 3
    local x = math.lerp(self.prevx, self.x, ls.accum / ls.tickrate)
    local y = math.lerp(self.prevy, self.y, ls.accum / ls.tickrate)
    local rx, ry = x, y

    local w, h = font:getWidth(str), font:getHeight(str)
    local padding = u * .01

    rx = math.min(rx, u - w / 2 - 2 * padding)
    ry = math.min(ry, v - h / 2 - 2 * padding)

    g.setColor(0, 0, 0, 200 * alpha)
    g.rectangle('fill', rx - w / 2 - padding, ry - h / 2 - padding, w + 2 * padding, h + 2 * padding)
    if self.pointerOrientations[self.message] == 'top' then
      g.polygon('fill', x - 10, y - h / 2 - padding, x + 10, y - h / 2 - padding, x, y - h / 2 - padding - 10)
    elseif self.pointerOrientations[self.message] ~= 'none' then
      g.polygon('fill', x - 10, y + h / 2 + padding, x + 10, y + h / 2 + padding, x, y + h / 2 + padding + 10)
    end

    g.setColor(255, 255, 255, 255 * alpha)
    g.printShadow(str, rx, ry, true)
  end
end

function Tutorial:keypressed(key)
  --
end

function Tutorial:getFactor()
  local t = math.lerp(self.prevTime, self.time, ls.accum / ls.tickrate)
  self.tween:set(t)
  return self.factor.value, t
end

function Tutorial:enter(message)
  if message == 'move' then
    self.moveX = ctx.player.x
  elseif message == 'death' then
    local minion = ctx.units:filter(function(m) return m.player end)[1]
    if minion then
      minion:hurt(100000)
    end
    self.enemy = ctx.units:add('duju', {x = ctx.map.width * .75})
    self.enemy.damage = 35
  elseif message == 'cooldown' then
    ctx.player.deck[1].cooldown = 3
  end
end

function Tutorial:exit(message)
  if message == 'shrine' then
    self.enemy = ctx.units:add('duju', {x = ctx.map.width * .9})
    self.enemy.damage = 8
  elseif message == 'minion' then
    ctx.player.juju = 100
  elseif message == 'death' then
    self.enemy:hurt(100000)
    self.enemy = nil
  elseif message == 'glhf' then
    Context:add(Menu)
    Context:remove(ctx)
  end
end

function Tutorial:shouldPlayerMove()
  return not self.active or self.message == 'move' or self.message == 'upgrade'
end

function Tutorial:shouldDecayHealth()
  return not self.active or false
end

function Tutorial:shouldSummon()
  return not self.active or self.message == 'minion'
end

function Tutorial:shouldShowHudStatus()
  return not self.active or self.messageIndex >= 13
end

function Tutorial:shouldShowHudUnits()
  return not self.active or self.messageIndex >= 14
end

function Tutorial:shouldShowHealthbars()
  return not self.active or self.messageIndex >= 6
end

function Tutorial:shouldAllowUpgradeToggling()
  return not self.active or self.message == 'upgrade' or self.message == 'upgradeexit'
end

function Tutorial:shouldPurchaseUpgrade()
  return not self.active or self.message == 'upgradetry'
end

function Tutorial:shouldHighlightShrine()
  return not self.active or self.message == 'upgrade' or self.message == 'upgradeexit'
end

function Tutorial:shouldUpdateUnits()
  return not self.active or self.message == 'battle' or self.message == 'death' or self.message == 'collect'
end

function Tutorial:shouldDropJuju()
  return not self.active or self.message == 'battle'
end

function Tutorial:shouldFloatJuju()
  return not self.active or false
end

function Tutorial:shouldDecayGhost()
  return not self.active or (self.message ~= 'collect' or not next(ctx.jujus.jujus))
end
