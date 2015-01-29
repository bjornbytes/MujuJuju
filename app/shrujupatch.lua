local g = love.graphics

ShrujuPatch = class()

ShrujuPatch.width = 80
ShrujuPatch.height = 40
ShrujuPatch.depth = 1

function ShrujuPatch:activate()
  self.y = ctx.map.height - ctx.map.groundHeight
  self.types = {} 

  self.effects = {}
  for i = 1, #data.shruju do
    if not isa(data.shruju[i], Shruju) then
      table.insert(self.effects, data.shruju[i].code)
    end
  end

  for i = 1, #data.shruju do
    if isa(data.shruju[i], Shruju) then
      table.insert(self.types, data.shruju[i].code)
    end
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

  if self.shrujuAnimation then self.shrujuAnimation:draw(self.x, self.y + 15) end
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
  local p = ctx.player
  return not p.dead and math.abs(p.x - self.x) <= self.width / 2 + p.width / 2
end

function ShrujuPatch:makeShruju()
  if self.growing and not self.slot then
    local shruju = data.shruju[self.growing]()

    -- Magic effect
    if love.math.random() < .25 then
      local effects = self.effects
      shruju.effect = setmetatable({timer = config.shruju.magicDuration}, {__index = data.shruju[effects[love.math.random(1, #effects)]]})
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
