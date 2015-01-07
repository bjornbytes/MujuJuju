local FrozenOrb = extend(Spell)
FrozenOrb.code = 'frozenorb'
FrozenOrb.depth = -10

function FrozenOrb:activate()
  local unit = self:getUnit()

  self.team = unit.team
  self.returning = false

  self.damaged = {}

  self.x = unit.x
  self.y = unit.y
  self.prevx = unit.x
  self.startx = self.x
  self.angle = love.math.random() * 2 * math.pi
  self.prevangle = self.angle
  self.angularVelocity = 4 + love.math.random()

  ctx.event:emit('view.register', {object = self})
end

function FrozenOrb:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function FrozenOrb:update()
  local direction = self.ability:getUnitDirection() 
  local inRange = math.abs(self.ability.unit.x - self.x) < self.ability.range

  self.prevx = self.x
  self.prevangle = self.angle

  if inRange and not self.returning then
    self.x = self.x + direction * self.speed * tickRate * math.max(1 - math.abs(self.ability.unit.x - self.x) / self.ability.range, .6)
    self.angle = self.angle + self.angularVelocity * tickRate
  elseif not inRange or self.returning then
    if not self.returning then table.clear(self.damaged) end
    self.returning = true
    self.x = self.x - direction * self.speed * tickRate
    self.angle = self.angle - self.angularVelocity * tickRate
  end

  if math.abs(self.x - self.ability.unit.x) <= self.ability.unit.width / 2 and self.returning then
    self:deactivate()
  end

  table.each(ctx.target:inRange(self, self.radius, 'enemy', 'unit', 'player'), function(target)
    if not self.damaged[target.viewId] then
      if target.buffs then
        target.buffs:add('slow', {
          slow = self.slow,
          timer = self.duration
        })
      end
      target:hurt(self.damage, unit)
      self.damaged[target.viewId] = true
    end
  end)
end

function FrozenOrb:draw()
	local g = love.graphics
  local image = data.media.graphics.spell.frozenorb
  local x = math.lerp(self.prevx, self.x, tickDelta / tickRate)
  local angle = math.anglerp(self.prevangle, self.angle, tickDelta / tickRate)
  local scale = self.radius * 2 / image:getWidth()
  g.setColor(255, 255, 255)
  g.draw(image, x, self.y, self.angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
end

return FrozenOrb
