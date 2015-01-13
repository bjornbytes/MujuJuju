local Tremor = extend(Spell)

local g = love.graphics

Tremor.maxHealth = 1.5
Tremor.depth = -5

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

  self.spikeTargetY = ctx.map.height - ctx.map.groundHeight + 16
  self.spikes = {}
  for i = 1, 3 do
    local height = 90 - (10 * i)
    local y = self.spikeTargetY + height
    self.spikes[i] = {
      height = height,
      x = unit.x + (unit.width / 2 + (self.width * .8) * (i / 3)) * self.direction,
      starty = y,
      y = y,
      alpha = 0
    }
  end
  self.activeSpike = 1

  for i = 1, 25 do
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
    spike.alpha = 1 - ((spike.y - self.spikeTargetY) / (spike.starty - self.spikeTargetY))
    if spike.y == self.spikeTargetY then
      self.activeSpike = self.activeSpike + 1
      if self.activeSpike > #self.spikes then self.activeSpike = nil
      else
        for i = 1, 25 do
          ctx.spells:add('dirt', {x = self.spikes[self.activeSpike].x, y = self.spikeTargetY})
        end
      end
    end
  end
end

function Tremor:draw()
  local image = data.media.graphics.spell.tremor
  for i = 1, #self.spikes do
    local spike = self.spikes[i]
    local scale = spike.height / image:getHeight()
    g.setColor(255, 255, 255, (spike.alpha * math.clamp(self.timer, 0, .2) / .2) * 255)
    g.draw(image, spike.x, spike.y, 0, scale * self.direction, scale, image:getWidth() / 2, image:getHeight())
  end
end

return Tremor
