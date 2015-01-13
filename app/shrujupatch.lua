local g = love.graphics

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

  self.weightSum = 0
  table.each(self.types, function(code)
    self.weightSum = self.weightSum + (data.shruju[code].rarity or 5)
  end)

  self.slots = {}
  for i = 1, 3 do
    self:randomizeSlot(i)
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
  if ctx.won then return end

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

function ShrujuPatch:grow(index)
  if not self:playerNearby() or self.growing or self.slot or not self.slots[index] then return end
  local code = self.slots[index]
  self.timer = self:getGrowTime(code)
  self.growing = code

  self:randomizeSlot(index)
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

function ShrujuPatch:randomizeSlot(index)
  local random = love.math.random() * self.weightSum
  local code = nil
  for i = 1, #self.types do
    local rarity = data.shruju[self.types[i]].rarity
    if random < rarity then
      code = self.types[i]
      break
    end
    random = random - rarity
  end

  self.slots[index] = code
end
