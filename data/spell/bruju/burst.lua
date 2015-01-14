local Burst = extend(Spell)

local g = love.graphics

Burst.depth = -10

function Burst:activate()
  local unit, player = self:getUnit(), self:getPlayer()

  self.x = unit.x
  self.y = unit.y

  self.team = unit.team

  table.each(ctx.target:inRange(self, self.range, 'enemy', 'unit', 'player'), function(target)
    target:hurt(self.damage, unit, {'spell'})
  end)

  table.each(ctx.target:inRange(self, self.range, 'ally', 'unit', 'player'), function(target)
    target:heal(self.heal, unit)
  end)

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
  self.health = timer.rot(self.health, function() ctx.spells:remove(self) end)
  self.prevscale = self.scale
  self.scale = math.lerp(self.scale, 1, math.min(20 * tickRate, 1))
end

function Burst:draw()
  local unit = self:getUnit()
	g.setColor(130, 250, 100, self.health / self.maxHealth * 255)

  local scale = math.lerp(self.prevscale, self.scale, tickDelta / tickRate)
  scale = scale * ((self.range + 50) * 2 / self.image:getWidth())

	g.draw(self.image, self.x, self.y, self.angle, scale, scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
end

return Burst
