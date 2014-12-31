local SpiritBomb = class()
SpiritBomb.code = 'spiritbomb'

SpiritBomb.maxHealth = .3

function SpiritBomb:activate()
  self.health = self.maxHealth
  self.angle = love.math.random() * 2 * math.pi
  self.scale = 0
  ctx.event:emit('view.register', {object = self})
end

function SpiritBomb:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function SpiritBomb:update()
  self.health = timer.rot(self.health, function() ctx.particles:remove(self) end)
  self.scale = math.lerp(self.scale, self.radius / data.media.graphics.explosion:getWidth(), 20 * tickRate)
end

function SpiritBomb:draw()
  local g = love.graphics
  local explosion = data.media.graphics.explosion
  g.setColor(80, 230, 80, 200 * self.health / self.maxHealth)
  g.draw(explosion, self.x, self.y, self.angle, self.scale + .25, self.scale + .25, explosion:getWidth() / 2, explosion:getHeight() / 2)
end

return SpiritBomb
