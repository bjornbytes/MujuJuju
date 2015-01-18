local Blight = extend(Spell)

local g = love.graphics

Blight.depth = -10

function Blight:activate()
  local unit = self:getUnit()

  self.x = unit.x
  self.y = unit.y

  self.team = unit.team

  table.each(ctx.target:inRange(self, self.range, 'enemy', 'shrine', 'unit', 'player'), function(target)
    local damage = self.damage
    if isa(target, Shrine) then damage = damage * 2 end
    target:hurt(damage, unit, {'spell'})
  end)

  self.scale = 0
  self.prevscale = self.scale

	self.health = self.maxHealth

	self.angle = love.math.random() * 2 * math.pi
  self.image = data.media.graphics.spell.burst
  ctx.event:emit('view.register', {object = self})
end

function Blight:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Blight:update()
  self.health = timer.rot(self.health, function() ctx.spells:remove(self) end)
  self.prevscale = self.scale
  self.scale = math.lerp(self.scale, 1, math.min(20 * tickRate, 1))
end

function Blight:draw()
  local unit = self:getUnit()
	g.setColor(250, 130, 100, self.health / self.maxHealth * 255)

  local scale = math.lerp(self.prevscale, self.scale, tickDelta / tickRate)
  scale = scale * ((self.range + 50) * 2 / self.image:getWidth())

	g.draw(self.image, self.x, self.y, self.angle, scale, scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
end

return Blight
