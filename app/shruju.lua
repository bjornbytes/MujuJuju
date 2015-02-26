local g = love.graphics
Shruju = class()

Shruju.width = 64
Shruju.height = 64

function Shruju:activate()
  self.y = ctx.map.height - ctx.map.groundHeight

  ctx.event:emit('view.register', {object = self})
end

function Shruju:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Shruju:draw()
  g.setColor(64, 0, 128)
  g.rectangle('fill', self.x - self.width, self.y - self.height, self.width, self.height)
end

function Shruju:pickup()
  ctx.player.shruju = self
  self:apply()
  ctx.shrujus:remove(self)
  ctx.event:emit('view.unregister', {object = self})
end

function Shruju:drop()
  self:remove()
  ctx.shrujus.objects[self] = self
  ctx.event:emit('view.register', {object = self})
end

function Shruju:playerNearby()
  local p = ctx.player
  return not p.dead and math.abs(p.x - self.x) <= self.width / 2 + p.width / 2
end
