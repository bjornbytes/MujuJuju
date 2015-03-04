local FrozenOrb = extend(Spell)
FrozenOrb.depth = -10
FrozenOrb.speed = 500
FrozenOrb.radius = 16

function FrozenOrb:activate()
  local unit, ability = self:getUnit(), self:getAbility()

  self.direction = ability:getUnitDirection()
  self.team = unit.team

  self.x = unit.x
  self.y = unit.y
  self.prevx = self.x
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
  local ability, unit = self:getAbility(), self:getUnit()

  self.prevx = self.x
  self.prevangle = self.angle

  self.x = self.x + self.direction * self.speed * ls.tickrate
  self.angle = self.angle + self.angularVelocity * ls.tickrate

  local target, distance = ctx.target:closest(self, 'enemy', 'unit', 'player')
  if target and distance < self.radius then
    local exhaust, slow, timer, knockback = .4, .4, 1.5, 100 * self.direction
    if target.buffs then
      target.buffs:add('chilled', {exhaust = exhaust, slow = slow, timer = timer})
      if unit:upgradeLevel('avalanche') then
        target.buffs:add('avalanche', {offset = knockback})
      end
    end

    local damage = unit.spirit * (.5 * unit:upgradeLevel('frozenorb'))
    target:hurt(damage, unit, {'spell'})

    local hypothermia = unit:upgradeLevel('hypothermia')
    if hypothermia > 0 then
      target:hurt(target.health * (.06 * hypothermia), unit, {'spell'})
    end

    if unit:upgradeLevel('shatter') > 0 then
      local targets = ctx.target:inRange(self, 80, 'enemy', 'unit', 'player', 'shrine')
      table.each(targets, function(other)
        if math.sign(other.x - target.x) == self.direction then
          if other.buffs then
            other.buffs:add('chilled', {exhaust = exhaust / 2, slow = slow / 2, timer = timer / 2})
            if unit:upgradeLevel('avalanche') then
              other.buffs:add('avalanche', {offset = knockback / 2})
            end
          end

          other:hurt(damage / 2, unit, {'spell'})

          if hypothermia > 0 then
            other:hurt(other.health * (.08 * hypothermia), unit, {'spell'})
          end
        end
      end)
    end

    ctx.spells:remove(self)
  end

  if not math.inside(self.x, self.y, 0, 0, ctx.map.width, ctx.map.height) then
    ctx.spells:remove(self)
  end
end

function FrozenOrb:draw()
	local g = love.graphics
  local image = data.media.graphics.spell.frozenorb
  local x = math.lerp(self.prevx, self.x, ls.accum / ls.tickrate)
  local angle = math.anglerp(self.prevangle, self.angle, ls.accum / ls.tickrate)
  local scale = self.radius * 2 / image:getWidth()
  g.setColor(255, 255, 255)
  g.draw(image, x, self.y, self.angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
end

return FrozenOrb
