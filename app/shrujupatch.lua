local g = love.graphics

ShrujuEffects = {
  wealth = {
    code = 'wealth',
    name = 'Wealth',
    description = 'Doubles your passive juju income rate.',

    activate = function(self)
      local p = ctx.players:get(ctx.id)
      p.jujuRate = p.jujuRate / 2
    end,

    deactivate = function(self)
      local p = ctx.players:get(ctx.id)
      p.jujuRate = p.jujuRate * 2
    end
  },
  sugarrush = {
    code = 'sugarrush',
    name = 'Sugar Rush',
    description = 'Muju moves faster.',

    activate = function(self)
      local p = ctx.players:get(ctx.id)
      p.walkSpeed = p.walkSpeed * 2
    end,

    deactivate = function(self)
      local p = ctx.players:get(ctx.id)
      p.walkSpeed = p.walkSpeed / 2
    end
  },
  imbue = {
    code = 'imbue',
    name = 'Imbue',
    description = 'Shrine heals health per second.',

    activate = function(self)
      local p = ctx.players:get(ctx.id)
      local _, shrine = next(ctx.shrines:filter(function(s) return s.team == p.team end))
      if shrine then
        shrine.regen = shrine.regen + 20
      end
    end,

    deactivate = function(self)
      local p = ctx.players:get(ctx.id)
      local _, shrine = next(ctx.shrines:filter(function(s) return s.team == p.team end))
      if shrine then
        shrine.regen = shrine.regen - 20
      end
    end
  },
  zeal = {
    code = 'zeal',
    name = 'Zeal',
    description = 'Muju moves faster in the juju realm.',

    activate = function(self)
      local p = ctx.players:get(ctx.id)
      p.ghostSpeedMultiplier = p.ghostSpeedMultiplier * 2
    end,

    deactivate = function(self)
      local p = ctx.players:get(ctx.id)
      p.ghostSpeedMultiplier = p.ghostSpeedMultiplier / 2
    end
  },
  civilization = {
    code = 'civilization',
    name = 'Civilization',
    description = '+3 to maximum population.',

    activate = function(self)
      local p = ctx.players:get(ctx.id)
      p.maxPopulation = p.maxPopulation + 3
    end,

    deactivate = function(self)
      local p = ctx.players:get(ctx.id)
      p.maxPopulation = p.maxPopulation - 3
    end
  },
  marathon = {
    code = 'marathon',
    name = 'Marathon',
    description = 'Fast minions!',

    activate = function(self)
      local p = ctx.players:get(ctx.id)
      p.summonBuffs.marathon = 'marathon'
      ctx.units:each(function(unit)
        if unit.player == p then unit.buffs:add('marathon') end
      end)
    end,

    deactivate = function(self)
      local p = ctx.players:get(ctx.id)
      p.summonBuffs.marathon = nil
      ctx.units:each(function(unit)
        if unit.player == p then unit.buffs:remove('marathon') end
      end)
    end
  },
  spinach = {
    code = 'spinach',
    name = 'Spinach',
    description = 'Makes your minions stronger.',

    activate = function(self)
      local p = ctx.players:get(ctx.id)
      p.summonBuffs.spinach = 'spinach'
      ctx.units:each(function(unit)
        if unit.player == p then unit.buffs:add('spinach') end
      end)
    end,

    deactivate = function(self)
      local p = ctx.players:get(ctx.id)
      p.summonBuffs.spinach = nil
      ctx.units:each(function(unit)
        if unit.player == p then unit.buffs:remove('spinach') end
      end)
    end
  },
  frenzy = {
    code = 'frenzy',
    name = 'Frenzy',
    description = 'Your minions attack twice as fast.',

    activate = function(self)
      local p = ctx.players:get(ctx.id)
      p.summonBuffs.frenzy = 'frenzy'
      ctx.units:each(function(unit)
        if unit.player == p then unit.buffs:add('frenzy') end
      end)
    end,

    deactivate = function(self)
      local p = ctx.players:get(ctx.id)
      p.summonBuffs.frenzy = nil
      ctx.units:each(function(unit)
        if unit.player == p then unit.buffs:remove('frenzy') end
      end)
    end
  },
  spiritblitz = {
    code = 'spiritrush',
    name = 'Spirit Rush',
    description = 'Summon all day erry day.',

    activate = function(self)
      local p = ctx.players:get(ctx.id)
      p.flatCooldownReduction = p.flatCooldownReduction + 10
    end,

    deactivate = function(self)
      local p = ctx.players:get(ctx.id)
      p.flatCooldownReduction = p.flatCooldownReduction - 10
    end
  },
  theone = {
    code = 'theone',
    name = 'The One',
    description = 'Take the red pill.',

    activate = function(self)
      local p = ctx.players:get(ctx.id)
      p.invincible = p.invincible + 100
    end,

    deactivate = function(self)
      local p = ctx.players:get(ctx.id)
      p.invincible = 0
    end
  }
}

ShrujuPatch = class()

ShrujuPatch.width = 80
ShrujuPatch.height = 40
ShrujuPatch.depth = 1

function ShrujuPatch:activate()
	self.y = ctx.map.height - ctx.map.groundHeight
  self.types = {} 

  for i = 1, #data.shruju do
    table.insert(self.types, data.shruju[i].code)
  end

  self.timer = 0
  self.slot = nil
  self.highlight = 0
  self.prevHighlight = self.highlight

  self.animation = data.animation.shrujupatch()
  self.animation:on('complete', function(data)
    if data.state.name == 'spawn' then self.animation:set('idle') end
  end)

  self.shrujuAnimation = nil
  ctx.event:emit('view.register', {object = self})
end

function ShrujuPatch:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function ShrujuPatch:update()
  self.timer = timer.rot(self.timer, function()
    self:makeShruju()
    ctx.sound:play('shrujuSpawn')
  end)

  self.prevHighlight = self.highlight
	self.highlight = math.lerp(self.highlight, self:playerNearby() and 128 or 0, math.min(5 * tickRate))
end

function ShrujuPatch:draw()
  self.animation:draw(self.x, self.y)

  local highlight = math.lerp(self.prevHighlight, self.highlight, tickDelta / tickRate)
  table.each(self.animation.spine.skeleton.slots, function(slot)
    slot.a = highlight / 255
    slot.data.additiveBlending = true
  end)
  self.animation:draw(self.x, self.y)
  table.each(self.animation.spine.skeleton.slots, function(slot)
    slot.a = 1
    slot.data.additiveBlending = false
  end)
  g.setBlendMode('alpha')

  if self.shrujuAnimation then self.shrujuAnimation:draw(self.x, self.y) end
end

function ShrujuPatch:grow(what)
  if not self:playerNearby() or not table.has(self.types, what) or self.growing or self.slot then return end
  self.timer = self:getGrowTime(what)
  self.growing = what
end

function ShrujuPatch:take()
  if not self:playerNearby() or not self.slot then return end
  local slot = self.slot
  self.slot = nil
  self.shrujuAnimation = nil
  return slot
end

function ShrujuPatch:playerNearby()
  local p = ctx.players:get(ctx.id)
  return not p.dead and math.abs(p.x - self.x) <= self.width / 2 + p.width / 2
end

function ShrujuPatch:makeShruju()
  if self.growing and not self.slot then
    local shruju = data.shruju[self.growing]()

    -- Randomly give it a random magical effect
    if love.math.random() < .33 then
      local effects = table.keys(ShrujuEffects)
      shruju.effect = setmetatable({timer = config.shruju.magicDuration}, {__index = ShrujuEffects[effects[love.math.random(1, #effects)]]})
    end

    self.slot = shruju
    self.growing = nil

    self.shrujuAnimation = data.animation.shruju1()
    self.shrujuAnimation:on('complete', function(data)
      if data.state.name == 'spawn' then
        self.shrujuAnimation:set('idle')
      end
    end)
  end
end

function ShrujuPatch:getGrowTime(code)
  return math.max(config.shruju.growTime - (ctx.shrujuPatches.harvestLevel * config.shruju.harvestCooldownReduction), config.shruju.minGrowTime)
end

function ShrujuPatch:removeType(code)
  for i = 1, #self.types do
    if self.types[i] == code then table.remove(self.types, i) return end
  end
end
