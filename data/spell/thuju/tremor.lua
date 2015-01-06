local Tremor = extend(Spell)
Tremor.code = 'tremor'

local g = love.graphics

Tremor.maxHealth = 1.5

function Tremor:activate()
  local ability, unit = self:getAbility(), self:getUnit()

  self.timer = self.maxHealth
  self.direction = self:getAbility():getUnitDirection()

  self.x = unit.x + (unit.width / 2 + self.width / 2) * self.direction
  self.team = unit.team

  table.each(ctx.target:inRange(self, self.width / 2, 'enemy', 'unit'), function(target)
    target:hurt(self.damage, unit)
    target.buffs:add('tremorstun', {stun = self.stun, timer = self.stun})
  end)

  self.x = unit.x

  self.spikeHeight = 100
  self.spikeTargetY = ctx.map.height - ctx.map.groundHeight
  self.spikeStartY = self.spikeTargetY + self.spikeHeight
  self.spikes = {}
  for i = 1, 3 do
    self.spikes[i] = {
      x = unit.x + (unit.width / 2 + self.width * (i / 3)) * self.direction,
      y = self.spikeStartY,
      alpha = 0
    }
  end
  self.activeSpike = 1

  for i = 1, 15 do
    ctx.spells:add('dirt', {x = self.spikes[1].x, y = self.spikeTargetY})
  end

  ctx.event:emit('view.register', {object = self})
end

function Tremor:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Tremor:update()
  self.timer = timer.rot(self.timer, function()
    ctx.spells:remove(self)
  end)

  if self.activeSpike then
    local spike = self.spikes[self.activeSpike]
    spike.y = math.max(spike.y - 650 * tickRate, self.spikeTargetY)
    spike.alpha = 1 - ((spike.y - self.spikeTargetY) / (self.spikeStartY - self.spikeTargetY))
    if spike.y == self.spikeTargetY then
      self.activeSpike = self.activeSpike + 1
      if self.activeSpike > #self.spikes then self.activeSpike = nil
      else
        for i = 1, 15 do
          ctx.spells:add('dirt', {x = self.spikes[self.activeSpike].x, y = self.spikeTargetY})
        end
      end
    end
  end
end

function Tremor:draw()
  local image = data.media.graphics.spell.tremor
  local scale = self.spikeHeight / image:getHeight()
  for i = 1, #self.spikes do
    local spike = self.spikes[i]
    g.setColor(255, 255, 255, (spike.alpha * math.clamp(self.timer, 0, .2) / .2) * 255)
    g.draw(image, spike.x, spike.y, 0, scale, scale, image:getWidth() / 2, image:getHeight())
  end

  local unit = self:getUnit()
  local alpha = self.timer / self.maxHealth * 255
  g.setColor(unit.team == ctx.players:get(ctx.id).team and {0, 255, 0, alpha} or {255, 0, 0, alpha})

  local x
  if self.direction == 1 then
    x = self.x + unit.width / 2
  else
    x = self.x - unit.width / 2 - self.width
  end

  local height = 64
  local y = ctx.map.height - ctx.map.groundHeight - height

  g.rectangle('line', x, y, self.width, height)
end

return Tremor
