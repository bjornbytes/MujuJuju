local g = love.graphics

-- Amount is always between 0 and 1 and determines how strong the magic effect is.
ShrujuEffects = {
  wealth = {
    name = 'Wealth',
    description = 'Doubles your passive juju income rate.',

    pickup = function(self)
      local p = ctx.players:get(ctx.id)
      self.amount = 1.9 + (.2 * self.strength)
      p.jujuRate = p.jujuRate / self.amount
    end,

    drop = function(self)
      local p = ctx.players:get(ctx.id)
      p.jujuRate = p.jujuRate * self.amount
    end
  },
  sugarrush = {
    name = 'Sugar Rush',
    description = 'Muju moves faster.',

    pickup = function(self)
      local p = ctx.players:get(ctx.id)
      self.amount = 1.5 + (1 * self.strength)
      p.walkSpeed = p.walkSpeed * self.amount
    end,

    drop = function(self)
      local p = ctx.players:get(ctx.id)
      p.walkSpeed = p.walkSpeed / self.amount
    end
  },
  imbue = {
    name = 'Imbue',
    description = 'Shrine heals health per second.',

    pickup = function(self)
      local p = ctx.players:get(ctx.id)
      local _, shrine = next(ctx.shrines:filter(function(s) return s.team == p.team end))
      self.amount = 15 + self.strength * 10
      if shrine then
        shrine.regen = shrine.regen + self.amount
      end
    end,

    drop = function(self)
      local p = ctx.players:get(ctx.id)
      local _, shrine = next(ctx.shrines:filter(function(s) return s.team == p.team end))
      if shrine then
        shrine.regen = shrine.regen - self.amount
      end
    end
  },
  zeal = {
    name = 'Zeal',
    description = 'Muju moves faster in the juju realm.',

    pickup = function(self)
      local p = ctx.players:get(ctx.id)
      self.amount = 1.75 + (.5 * self.strength)
      p.ghostSpeedMultiplier = p.ghostSpeedMultiplier * self.amount
    end,

    drop = function(self)
      local p = ctx.players:get(ctx.id)
      p.ghostSpeedMultiplier = p.ghostSpeedMultiplier / self.amount
    end
  }
}

ShrujuPatch = class()

ShrujuPatch.width = 40
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
  self.timer = math.max(data.shruju[what].time - (ctx.shrujuPatches.harvestLevel * ctx.shrujuPatches.harvestFactor), 10)
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
    local shruju = setmetatable({}, {__index = data.shruju[self.growing]})

    -- Randomly give it a random magical effect
    if love.math.random() < .2 then
      local effects = table.keys(ShrujuEffects)
      local effect = setmetatable({}, {__index = ShrujuEffects[effects[love.math.random(1, #effects)]]})
      effect.strength = love.math.random()
      shruju.effect = effect
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
