local Burst = extend(Spell)
Burst.code = 'burst'

local g = love.graphics

Burst.maxHealth = .5

function Burst:activate()
  local unit, player = self:getUnit(), self:getPlayer()

  self.x = unit.x
  self.y = unit.y

  if ctx.tag == 'server' then
    assert(self.damage and self.heal)

    self.team = unit.team

    table.each(ctx.target:inRange(self, self.range, 'enemy', 'unit', 'player'), function(target)
      target:hurt(self.damage, unit)
    end)

    table.each(ctx.target:inRange(self, self.range, 'ally', 'unit', 'player'), function(target)
      target:heal(target.maxHealth * self.heal, unit)
    end)

    return ctx.spells:remove(self)
  end

  self.scale = 0
  self.prevscale = self.scale

	self.health = self.maxHealth

	self.angle = love.math.random() * 2 * math.pi
  self.image = data.media.graphics.spell.burst
  ctx.event:emit('view.register', {object = self})
end

function Burst:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Burst:update()
  if ctx.tag == 'client' then
    self.health = timer.rot(self.health, function() ctx.spells:remove(self) end)
    self.prevscale = self.scale
    self.scale = math.lerp(self.scale, 1, 20 * tickRate)
  end
end

function Burst:draw()
  local unit = self:getUnit()
  local color = unit.team == ctx.players:get(ctx.id).team and {40, 230, 40} or {230, 40, 40}
  color[4] = self.health / self.maxHealth * 255
	g.setColor(color)

  local scale = math.lerp(self.prevscale, self.scale, tickDelta / tickRate)
  scale = scale * ((self.range + 50) * 2 / self.image:getWidth())

	g.draw(self.image, self.x, self.y, self.angle, scale, scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
  g.circle('line', self.x, self.y, self.range * self.scale)
end

return Burst
